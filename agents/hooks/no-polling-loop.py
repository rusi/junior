"""Refuse a shell loop that polls the process table for a pattern.

A waiter written as `until ! pgrep -f "<pattern>"; do sleep N; done` carries
`<pattern>` in its own command line. `pgrep` excludes itself but not a sibling,
so a second copy of the same waiter matches the first and the first matches the
second: neither can ever exit. The work they were waiting on finishes, and the
waiters keep running until someone notices hours later.

This is enforced here rather than written down because the moments it applies to
can be enumerated -- a loop keyword plus a process-table query -- and because the
party it constrains is the party that would have to remember the rule.

Waiting on work has instruments that do not have this failure: `Monitor` for a
condition, `run_in_background` for a command whose completion is reported. A
one-shot `pgrep`/`pkill` is untouched; only the polling loop is refused.

Fails open. A guard that crashes would block every shell command in every
project, which is a worse failure than the one it prevents.
"""

from __future__ import annotations

import json
import re
import sys

LOOP_OPENS = re.compile(r"\b(?:until|while)\b")
LOOP_CLOSES = re.compile(r"\bdone\b")
PROCESS_QUERY = re.compile(r"\b(?:pgrep|pkill)\b")
PS_GREP = (re.compile(r"\bps\b"), re.compile(r"\bgrep\b"))

REASON = (
    "This is a shell loop that polls the process table, which deadlocks with "
    "itself: the loop's own command line contains the pattern it searches for, so "
    "a second copy of the same waiter matches the first and neither ever exits.\n\n"
    "Wait a different way:\n"
    "  - Monitor, for a condition to become true\n"
    "  - Bash with run_in_background: true, for a command whose completion is "
    "reported back to you\n\n"
    "A single pgrep/pkill outside a loop is fine and is not blocked."
)


def polls_in_a_loop(command: str) -> bool:
    """Whether a command queries the process table from inside a loop.

    Containment, not co-occurrence: a one-shot `pgrep` standing beside an
    unrelated `while` loop in the same command is not the hazard, and refusing
    it would train the reader to route around this guard. Only the span from the
    first loop keyword to the last `done` is examined.
    """
    opens = LOOP_OPENS.search(command)
    if opens is None:
        return False

    closes = [match.end() for match in LOOP_CLOSES.finditer(command)]
    body = command[opens.start() : closes[-1] if closes else len(command)]

    if PROCESS_QUERY.search(body):
        return True
    return all(pattern.search(body) for pattern in PS_GREP)


def main() -> None:
    """Deny a polling loop; stay silent on everything else."""
    try:
        payload = json.load(sys.stdin)
        command = payload.get("tool_input", {}).get("command", "")
    except Exception:
        return

    if not isinstance(command, str) or not polls_in_a_loop(command):
        return

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": REASON,
            },
        },
        sys.stdout,
    )


if __name__ == "__main__":
    main()
