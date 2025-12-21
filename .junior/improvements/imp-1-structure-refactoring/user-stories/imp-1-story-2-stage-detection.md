# Story 2: Extract Stage Detection Pattern

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Stage detection pattern DRY'd across 5 commands

## Developer Story

**As a** maintainer of Junior commands
**I want** stage detection logic extracted to a shared module
**So that** updates to stage detection only need to happen once, not in 5 places

## Current State

**What's wrong with current code:**
- Stage detection logic duplicated in `feature.md`, `implement.md`, `status.md`, `maintenance.md`, `migrate.md`
- Same pattern: Check for `comp-*/`, check for `features/` subdirectory, return stage1|stage2|stage3
- If detection changes (e.g., new stage indicator), must update 5 files
- DRY violation: ~20 lines repeated 5 times

**Examples:**

In multiple commands:
```markdown
Detect stage:
- Check for comp-*/ under .junior/features/
- If none → stage1
- If exist, check for features/ subdirectory
- If no subdirectory → stage2
- If subdirectory exists → stage3
```

## Target State

**What improved code looks like:**
- Single source of truth: `.cursor/commands/_shared/stage-detection.md` (Mode A)
- Commands reference: "Use stage detection from `_shared/stage-detection.md`"
- ONLY detection logic (which stage: 1, 2, or 3)
- Transition logic stays in `/maintenance` command (Stage 1→2, 2→3 reorganization)
- ~100 lines reduced to ~20 lines + 5 references

**Shared module structure:**
- Detection logic (filesystem checks)
- Returns: "stage1" | "stage2" | "stage3"
- NOT transition/reorganization logic (that's maintenance-specific)

## Scope

**In Scope:**
- Create `.cursor/commands/_shared/stage-detection.md`
- Extract ONLY detection logic (which stage?)
- Update 5 commands to reference shared module:
  - `feature.md` - references detection
  - `implement.md` - references detection
  - `status.md` - references detection
  - `maintenance.md` - references detection (but keeps transition logic!)
  - `migrate.md` - references detection
- Grep verification: old detection pattern removed

**Out of Scope:**
- Transition logic (Stage 1→2, 2→3 reorganization) - stays in maintenance.md
- Changing detection logic itself (just extracting)
- Component overview updates (separate pattern)

**CRITICAL DISTINCTION:**
- **Stage detection** = Determine current stage (shared module)
- **Stage transition** = Reorganize files for Stage 1→2, 2→3 (maintenance command only)

## Acceptance Criteria

- [ ] Given stage detection logic, when extracted to shared module, then `.cursor/commands/_shared/stage-detection.md` exists
- [ ] Given 5 commands, when updated, then they reference shared module for detection (not inline logic)
- [ ] Given `maintenance.md`, when updated, then it still contains transition/reorganization logic (only detection extracted)
- [ ] Given old detection pattern, when grep search performed, then 0 results found (only in shared module)

## Implementation Tasks

- [ ] 2.1 Create `stage-detection.md` with ONLY detection logic (Mode A)
- [ ] 2.2 Update `feature.md` - replace detection with reference
- [ ] 2.3 Update `implement.md` - replace detection with reference
- [ ] 2.4 Update `status.md` - replace detection with reference
- [ ] 2.5 Update `maintenance.md` - replace detection with reference (keep transition logic!)
- [ ] 2.6 Update `migrate.md` - replace detection with reference
- [ ] 2.7 Grep verification: Old detection pattern gone (transition logic remains in maintenance.md)
- [ ] 2.8 User review of changes

## Verification Checklist

**Before marking story complete, verify:**
- [ ] Shared module exists: `.cursor/commands/_shared/stage-detection.md`
- [ ] Module is Mode A (concise for AI)
- [ ] Module contains ONLY detection (not transition)
- [ ] 5 commands updated with references
- [ ] Maintenance command keeps transition logic
- [ ] Grep check passes (detection pattern removed from commands)
- [ ] User has reviewed and approved changes

## Regression Prevention

**Strategy:**
- Extract exact existing detection logic (no behavior changes)
- Leave transition logic in maintenance.md untouched
- Commands reference shared detection module

**Validation:**
- Manual review: Detection vs transition logic separated correctly
- Grep verification: Detection pattern gone from commands
- Maintenance check: Transition logic still present

## Rollback Plan

**If issues arise:**
1. Revert commit
2. Commands return to inline detection
3. Maintenance keeps all logic (detection + transition)

**Rollback criteria:**
- Detection/transition separation incorrect
- References don't work
- Logic changed unintentionally

## Technical Notes

**Shared module structure (.cursor/commands/_shared/stage-detection.md):**

```markdown
# Stage Detection (AI Internal - Mode A)

## Detection Logic

**Stage 1:** No `comp-*/` directories under `.junior/features/`
**Stage 2:** `comp-*/` exists, NO `features/` subdirectory
**Stage 3:** `comp-*/` with `features/` subdirectory

## Detection Process

1. Check for `comp-*/` under `.junior/features/`
2. If none exist → stage1
3. If exist, check for `features/` subdirectory
4. If no subdirectory → stage2
5. If subdirectory exists → stage3

Returns: "stage1" | "stage2" | "stage3"

## Usage in Commands

"Use stage detection from `_shared/stage-detection.md`"

## NOT in This Module

Stage transition logic (Stage 1→2, 2→3 reorganization) remains in `/maintenance` command.
```

**Reference pattern in commands:**
```markdown
### Step X: Detect Current Stage
Use stage detection from `_shared/stage-detection.md`.
[Then command-specific logic based on detected stage]
```

**Maintenance command keeps:**
- Detection reference (shared module)
- Transition logic: How to reorganize Stage 1→2
- Transition logic: How to reorganize Stage 2→3
- Component overview updates

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Shared module created (detection ONLY)
- [ ] 5 commands updated with references
- [ ] Maintenance command keeps transition logic
- [ ] Old detection pattern removed (grep verified)
- [ ] User reviewed and approved changes
- [ ] Zero functional changes
- [ ] **Stage detection DRY'd across 5 commands**

