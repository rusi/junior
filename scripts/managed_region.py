#!/usr/bin/env python3
"""The region Junior owns inside a file that belongs to the operator.

`settings.json`, `CLAUDE.md`, and Codex's `AGENTS.md` / `AGENTS.override.md` belong to
the operator. Junior owns hook entries in JSON and marked blocks in Markdown. Two formats,
one guarantee. Everything outside Junior's region survives the write untouched, and a
second install replaces the region rather than leaving a second copy beside it.

The region is recognised by what it carries rather than by where it sits, so an operator
who moves the block or reorders their hooks still ends up with one of each.
"""

from __future__ import annotations

import copy
import re
import shlex
from pathlib import Path
from typing import Any

BLOCK_BEGIN = "<!-- BEGIN junior -->"
BLOCK_END = "<!-- END junior -->"
BLOCK_NOTE = "<!-- Managed by Junior and replaced on install. Delete the whole block to unlink it. -->"

# A hook is identified by the script it runs. Position changes whenever the operator
# edits their settings, and an extra key of Junior's own risks being rejected by the
# runtime that has to read the file.
HOOK_TOKEN = "junior-session-start"
GUARD_HOOK_TOKEN = "no-polling-loop"

SESSION_START = "SessionStart"
PRE_TOOL_USE = "PreToolUse"


class ManagedRegionError(Exception):
    """Raised when the content around Junior's region cannot be preserved with confidence."""


def upsert_markdown_block(document: str, body: str) -> str:
    """Return `document` with Junior's block holding `body`, and nothing else changed."""
    block = f"{BLOCK_BEGIN}\n{BLOCK_NOTE}\n{body.strip()}\n{BLOCK_END}"

    begin = document.find(BLOCK_BEGIN)
    end = document.find(BLOCK_END)
    if (begin == -1) != (end == -1) or (begin != -1 and end < begin):
        raise ManagedRegionError(
            "Junior's block markers are incomplete or out of order; the file was left unchanged"
        )

    if begin == -1:
        if not document.strip():
            return f"{block}\n"
        return f"{document.rstrip(chr(10))}\n\n{block}\n"

    tail = document[end + len(BLOCK_END) :]
    return document[:begin] + block + (tail or "\n")


def upsert_hook(settings: dict[str, Any], event: str, token: str, entry: dict[str, Any]) -> dict[str, Any]:
    """Return `settings` with `entry` registered under `event` exactly once.

    Only child hooks carrying `token` are replaced; neighboring hooks retain their
    matcher and other group properties.
    """
    merged = copy.deepcopy(settings)

    hooks = merged.get("hooks", {})
    if not isinstance(hooks, dict):
        raise ManagedRegionError("'hooks' in settings is not an object; Junior will not replace it")

    entries = hooks.get(event, [])
    if not isinstance(entries, list):
        raise ManagedRegionError(f"'hooks.{event}' in settings is not a list; Junior will not replace it")

    kept = []
    for existing in entries:
        if is_junior_hook_entry(existing, token):
            existing["hooks"] = [hook for hook in existing["hooks"] if not is_junior_hook(hook, token)]
            if not existing["hooks"]:
                continue
        kept.append(existing)
    kept.append(entry)

    hooks[event] = kept
    merged["hooks"] = hooks
    return merged


def has_hook(settings: Any, event: str, token: str) -> bool:
    """Whether Junior's hook for `event` is already registered, asked of settings of any shape."""
    if not isinstance(settings, dict):
        return False
    hooks = settings.get("hooks")
    if not isinstance(hooks, dict):
        return False
    entries = hooks.get(event)
    if not isinstance(entries, list):
        return False
    return any(is_junior_hook_entry(entry, token) for entry in entries)


def remove_session_start_hook(settings: dict[str, Any], script_paths: set[str]) -> dict[str, Any]:
    """Retire known scanner invocations; refuse ambiguous commands without changing settings."""
    if not isinstance(settings, dict) or not isinstance(settings.get("hooks", {}), dict):
        raise ManagedRegionError("Settings hooks must be an object; startup retirement requires reconciliation")
    entries = settings.get("hooks", {}).get(SESSION_START, [])
    if not isinstance(entries, list):
        raise ManagedRegionError("SessionStart must be a list; startup retirement requires reconciliation")
    merged = copy.deepcopy(settings)
    kept = []
    for entry in copy.deepcopy(entries):
        if not is_junior_hook_entry(entry):
            kept.append(entry)
            continue
        remaining = []
        for hook in entry["hooks"]:
            if not is_junior_hook(hook, HOOK_TOKEN):
                remaining.append(hook)
                continue
            command = hook["command"]
            try:
                parts = shlex.split(command)
            except ValueError as exc:
                raise ManagedRegionError("Unparseable startup command; reconcile SessionStart before updating") from exc
            if (hook.get("type") != "command" or len(parts) != 2
                    or not re.fullmatch(r"python(?:\d+(?:\.\d+)*)?(?:\.exe)?", parts[0].replace("\\", "/").rsplit("/", 1)[-1])
                    or (parts[1] not in script_paths and str(Path(parts[1]).resolve()) not in script_paths)):
                raise ManagedRegionError("Custom startup command mentions junior-session-start; reconcile SessionStart before updating")
        if remaining:
            entry["hooks"] = remaining
            kept.append(entry)
    if kept != entries:
        merged["hooks"][SESSION_START] = kept
    return merged


def upsert_guard_hook(
    settings: dict[str, Any],
    command: str,
    matcher: str,
    timeout: int,
) -> dict[str, Any]:
    """Return `settings` with Junior's tool guard registered exactly once.

    A guard runs before a tool call rather than at session start, so it carries the
    matcher naming the tool it screens and a timeout: a guard that hangs would stall
    every call it screens, which is worse than the failure it refuses.
    """
    return upsert_hook(
        settings,
        PRE_TOOL_USE,
        GUARD_HOOK_TOKEN,
        {"matcher": matcher, "hooks": [{"type": "command", "command": command, "timeout": timeout}]},
    )


def is_junior_hook_entry(entry: Any, token: str = HOOK_TOKEN) -> bool:
    if not isinstance(entry, dict):
        return False
    hooks = entry.get("hooks")
    if not isinstance(hooks, list):
        return False
    return any(is_junior_hook(hook, token) for hook in hooks)


def is_junior_hook(hook: Any, token: str) -> bool:
    return isinstance(hook, dict) and token in str(hook.get("command", ""))
