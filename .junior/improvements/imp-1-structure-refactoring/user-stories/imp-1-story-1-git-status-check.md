# Story 1: Extract Git Status Check Pattern

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Git status check pattern DRY'd across 3 commands

## Developer Story

**As a** maintainer of Junior commands
**I want** git status checking logic extracted to a shared module
**So that** updates to the pattern only need to happen once, not in 3 places

## Current State

**What's wrong with current code:**
- Git status checking logic duplicated in `feature.md`, `implement.md`, `commit.md`
- Same pattern: check for uncommitted changes, warn user, handle responses
- If logic changes (e.g., add .gitignore check), must update 3 files
- DRY violation: ~30 lines repeated 3 times

**Examples:**

In `feature.md`:
```markdown
Check for uncommitted changes:
- Run git status
- If uncommitted changes, warn user
- Ask: commit-first | continue | cancel
```

Same pattern in `implement.md` and `commit.md`.

## Target State

**What improved code looks like:**
- Single source of truth: `.cursor/commands/_shared/git-status-check.md` (Mode A)
- Commands reference shared module: "Use git status check from `_shared/git-status-check.md`"
- Future changes only need one file updated
- ~90 lines reduced to ~30 lines + 3 references

**Shared module structure:**
- Detection logic (how to check status)
- Warning messages (Mode C - user-facing)
- Response handling (options presented to user)

## Scope

**In Scope:**
- Create `.cursor/commands/_shared/git-status-check.md`
- Extract git status checking pattern (Mode A instructions)
- Update `feature.md` to reference shared module
- Update `implement.md` to reference shared module
- Update `commit.md` to reference shared module
- Grep verification: old pattern removed

**Out of Scope:**
- Changing the git status logic itself (just extracting)
- Other shared patterns (saved for other stories)

## Acceptance Criteria

- [ ] Given git status check logic, when extracted to shared module, then `.cursor/commands/_shared/git-status-check.md` exists
- [ ] Given `feature.md`, `implement.md`, `commit.md`, when updated, then they reference shared module (not duplicate logic)
- [ ] Given old git status pattern, when grep search performed, then 0 results found in commands (only in shared module)

## Implementation Tasks

- [ ] 1.1 Create `.cursor/commands/_shared/` directory
- [ ] 1.2 Create `git-status-check.md` with extracted pattern (Mode A)
- [ ] 1.3 Update `feature.md` - replace pattern with reference
- [ ] 1.4 Update `implement.md` - replace pattern with reference
- [ ] 1.5 Update `commit.md` - replace pattern with reference
- [ ] 1.6 Grep verification: `grep -r "git status" .cursor/commands/*.md` (should only find reference, not full logic)
- [ ] 1.7 User review of changes

## Verification Checklist

**Before marking story complete, verify:**
- [ ] Shared module exists: `.cursor/commands/_shared/git-status-check.md`
- [ ] Module is Mode A (AI instructions, not verbose)
- [ ] User-facing messages in module marked as Mode C
- [ ] 3 commands updated with references
- [ ] Grep check passes (old pattern removed)
- [ ] User has reviewed and approved changes

## Regression Prevention

**Strategy:**
- Extract exact existing logic (no behavior changes)
- Commands reference shared module
- User reviews before/after comparison

**Validation:**
- Manual review: Compare old vs new command text
- Grep verification: Old pattern gone
- Reference check: Commands properly reference shared module

## Rollback Plan

**If issues arise:**
1. Revert commit
2. Commands return to inline git status checks
3. Shared module can be refined and re-extracted

**Rollback criteria:**
- References don't work as expected
- Logic was changed unintentionally
- User finds issues in review

## Technical Notes

**Shared module structure (.cursor/commands/_shared/git-status-check.md):**

```markdown
# Git Status Check (AI Internal - Mode A)

## Detection Logic
[What to check, how to check - concise for AI]

## User Messages (Mode C)
[Warning messages shown to user - full explanations]

## Response Handling
[Options: commit-first | continue | cancel]

## Usage in Commands
"Use git status check from `_shared/git-status-check.md`"
```

**Reference pattern in commands:**
```markdown
### Step X: Git Status Check
Use git status check from `_shared/git-status-check.md`.
```

**Mode A vs Mode C:**
- Detection logic, process flow = Mode A (concise)
- Messages shown to user = Mode C (full explanations)

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Shared module created (Mode A + Mode C messages)
- [ ] 3 commands updated with references
- [ ] Old pattern removed (grep verified)
- [ ] User reviewed and approved changes
- [ ] Zero functional changes (commands work identically)
- [ ] **Git status pattern DRY'd across 3 commands**

