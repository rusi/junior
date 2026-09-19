# Understand Before Acting

## The Problem This Solves

The most expensive failure pattern is: symptom → quick fix → fix breaks → another fix → that breaks too → finally research the problem → realize the first fix was wrong.

Each iteration wastes time, introduces risk, and erodes trust. The root cause is acting before understanding.

## Core Rule

**Before changing anything, understand what you're changing and why it currently works the way it does.**

This applies to:
- Bug fixes (understand the system before patching the symptom)
- Feature additions (understand the existing design before extending it)
- Configuration changes (understand why the current config exists)
- Refactors (understand the constraints that shaped the current code)
- Workflow/process changes (understand who depends on the current behavior)

## Required Behavior

### 1. Investigate Before Proposing

When something is broken or needs changing:

- **Map the context**: What system are you in? What are the moving parts? What depends on what?
- **Understand the current design**: Why does it work this way? Was it deliberate? Check history, comments, related code, documentation.
- **Identify the actual problem**: Distinguish the symptom from the root cause. "It doesn't work" is a symptom. "The API returns 401 because the token refresh middleware isn't registered for this route" is a root cause.

### 2. When a Fix Doesn't Work, Stop and Research

If your first attempt fails or gets rejected, that is a signal that you don't understand the problem well enough. Do NOT try another fix of similar depth. Instead:

- Stop and widen your investigation
- Ask: "What am I missing about how this system works?"
- Read the code, check the history, trace the execution, study the architecture
- Only propose a new fix once you have a deeper understanding

**The "fix the fix" cycle is always wrong.** Two failed attempts means you need research, not a third attempt.

### 3. Enumerate Options for Non-Trivial Changes

When a change involves design trade-offs (not just a clear bug with a clear fix):

- Identify at least 2 viable approaches
- For each, state: what it does, what it costs, what it enables, what it breaks
- Make a recommendation with reasoning
- Let the decision-maker (you or the user) choose with full context

This is NOT over-engineering — it's the minimum diligence to avoid the fix-the-fix cycle.

### 4. Respect Existing Design Intent

Before changing a configuration, permission, interface, or boundary:

- Check if the current state was deliberate (git history, comments, documentation)
- If it was deliberate, understand the reasoning before proposing to change it
- If you can't determine intent, state that explicitly: "I don't know why this path was excluded from the build config — it may have been deliberate"

**Never assume the current state is accidental.** Systems have memory; understand it before overwriting it.

### 5. "Pre-existing" Is Not a Category

Age and authorship are not scope boundaries. A defect you did not write, in a file you did not create,
committed before this session, is still a defect — and if it is small and verifiable, it is still yours
to fix.

- ❌ **FORBIDDEN:** "pre-existing", "not from this session", "someone else wrote it" as a reason to leave something broken
- ❌ **FORBIDDEN:** dressing a lookup up as a judgment call to avoid doing it
- ✅ **REQUIRED:** run the check first — `git log --all -- <path>`, `ls`, `grep` — then decide with evidence
- ✅ **REQUIRED:** hand work back only when it genuinely needs the lead's judgment, is materially out of scope, or is large enough to need approval

A wrong path in a governance file is wrong regardless of who typed it. Thirty seconds of `git log`
usually settles whether it was renamed, abandoned, or never existed. Do that before writing a verdict.

This does not license silent scope expansion — see *Scope Verification: Adjacent Improvements* in
13-software-implementation-principles.md. The distinction is that a **broken** thing gets fixed or
explicitly tracked; a **working** thing you merely want to improve gets recorded and deferred.

## Anti-Patterns

| Anti-Pattern | What To Do Instead |
|---|---|
| Symptom → immediate fix attempt | Symptom → investigate → understand → fix |
| Fix fails → try different fix | Fix fails → stop → research → understand → fix |
| Fix fails → add fallback | Fix fails → find the real problem → make it work |
| "I'll just add X" without checking why X isn't there | Check why X isn't there, then decide if adding it is correct |
| Proposing a change to code you haven't read | Read the code, trace the execution, then propose |
| Three attempts at the same depth of understanding | After two failures, go deeper — read more code, check history, trace execution |

## Calibration

This principle is about **proportional diligence**, not analysis paralysis:

- **Typo fix**: just fix it
- **Clear bug with obvious root cause**: fix it, verify it
- **Bug where root cause is unclear**: investigate first, then fix
- **Change to system boundaries, permissions, or contracts**: full investigation — understand the design, enumerate options if trade-offs exist
- **Change that failed once already**: mandatory deeper investigation before second attempt

The trigger for deeper investigation is **not complexity** — it's **uncertainty**. If you're confident you understand the system, act. If you're not, investigate until you are.

## Relationship to Other Principles

- **Evidence-Based Debugging**: covers debugging methodology. This principle covers the higher-level discipline of understanding before acting, which applies to all changes, not just debugging.
- **Non-Speculative Execution**: covers not fabricating evidence. This principle covers not skipping the evidence-gathering step entirely.
- **Pre-Action Assertion**: covers making reasoning visible. This principle covers doing the reasoning in the first place.
