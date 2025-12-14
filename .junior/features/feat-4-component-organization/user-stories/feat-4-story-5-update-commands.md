# Story 5: Update Other Commands for Component Support

> **Status:** Completed
> **Priority:** Medium
> **Dependencies:** Stories 1-4 (requires structure changes in place)
> **Deliverable:** All commands work seamlessly with Stage 1/2/3

## User Story

**As a** Junior user with component-organized project
**I want** all commands to work correctly regardless of stage
**So that** I can use any command without worrying about paths

## Scope

**In Scope:**
- Update `/implement` and `/status` to use stage detection and resolve paths correctly
- Add old structure detection with migration prompt (graceful, not blocking)
- `/status` shows component-grouped view for Stage 2+

**Out of Scope:**
- `/refactor` stage detection (works with top-level `.junior/improvements/`, not stage-dependent)
- Other commands (`/commit`, `/debug` don't navigate feature structure)
- Backward compatibility (users must migrate eventually)
- New command functionality

**Note:** During implementation, determined `/refactor` doesn't need stage awareness since it creates improvements in top-level directory, not within feature structure.

## Acceptance Criteria

- [x] Given any stage, when `/implement` runs, then finds features correctly using stage-aware paths ✅
- [x] Given Stage 2+, when `/status` runs, then shows components with features grouped in tree view ✅
- [x] Given old structure, when stage-aware commands run, then shows migration prompt (graceful, not blocking) ✅
- [x] Given Stage 1/2/3, when checking other commands, then only `/implement` and `/status` have stage detection (others don't need it) ✅

## Implementation Tasks

- [x] 5.1 Update `/implement` - add stage detection reference, use stage-aware path resolution ✅
- [x] 5.2 Update `/status` - add stage detection reference, show component tree for Stage 2+ ✅
- [x] 5.3 Remove unnecessary repetition - reference `01-structure.mdc` instead of duplicating detection logic ✅
- [x] 5.4 Add old structure detection to stage-aware commands (graceful migration prompt) ✅

**Implementation Notes:**
- Replaced bash pseudocode blocks with references to `01-structure.mdc` (DRY principle)
- Removed stage detection from `/refactor` (doesn't navigate feature structure)
- Only commands that navigate `.junior/features/` need stage awareness: `/implement`, `/status`, `/feature`, `/migrate`

## Testing

Test scenarios:
- `/implement` on all 3 stages → finds features correctly using stage-aware paths
- `/status` on Stage 2+ → shows component tree with grouped features
- `/implement` or `/status` on old structure → shows graceful migration prompt
- `/refactor` creates improvements in `.junior/improvements/` → works without stage detection

## Definition of Done

- [x] Stage-aware commands (`/implement`, `/status`) updated with path resolution ✅
- [x] Stage detection references `01-structure.mdc` (no repetition) ✅
- [x] `/status` shows tree view for Stage 2+ ✅
- [x] Removed unnecessary stage detection from `/refactor` ✅
- [x] Old structure detection added to stage-aware commands (graceful) ✅
- [x] No bash pseudocode blocks (replaced with references) ✅
