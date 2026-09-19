# Junior Rule 10: Waiting on Work

## The Failure This Prevents

Long work is started, and then a hand-rolled shell loop is written to watch it.
The loop outlives the work and runs until someone notices hours later. Nothing
reports the stall, because the thing that was supposed to report it is the thing
that hung.

The cost is not the wasted process. It is that the session believes it is waiting
on work that finished, and every judgment made after that rests on a false state.

## Use the Instrument the Harness Provides

- **A condition to become true** → the monitoring tool the runtime offers
- **A command whose completion must be reported** → start it as a tracked
  background task, and let the completion notification wake the session
- **A one-shot check** → run it once and read the answer

**Never hand-roll a polling loop over the process table.** A shell loop that
greps for a process carries the search pattern in its own command line, so a
second copy of the same waiter matches the first and neither can exit. This is
guarded for Claude's Bash tool by `hooks/no-polling-loop.py`. In other runtimes it remains
an agent norm unless an equivalent guard is installed.

## Triggers (stop and re-choose the instrument)

- Writing `until`/`while` around anything that inspects running processes
- Reaching for a detached launcher (`nohup`, `&`, `disown`) for work whose result
  the session actually needs — the harness cannot track it, which is what
  creates the need to poll in the first place
- A wait that has already timed out once, about to be run again unchanged

## When a Wait Times Out, Do Not Re-run It

A tracked tool returning a running session ID is a normal yield: resume that same session
through the tool's continuation API. It is not a reason to launch the command again.
The rule below concerns a stalled waiter or an actual timeout, not a normal yield.

A waiter that did not return is evidence about the waiter, not only about the
work. Running the same command a second time is how one stuck process becomes
two, and concurrent waiters can block each other in ways a single one never
would.

- ✅ **REQUIRED:** ask why the first one did not return before starting another
- ✅ **REQUIRED:** check whether the underlying work is still alive, once
- ❌ **FORBIDDEN:** re-issuing an identical wait because the first was slow

## Track What You Start

Anything started in the background is owed a check before the session ends: is it
finished, and did anything still running need to be stopped. Work started and
forgotten is the same failure as a wait that never returns, arrived at from the
other direction.

## Why This Is Split Between Code and Prose

Recognising *which* instrument fits a wait is judgment and stays here. Refusing
the one shape that deadlocks by construction is enumerable, so it is mechanised
where it cannot be reasoned past. See `09-code-or-skill.md`.
