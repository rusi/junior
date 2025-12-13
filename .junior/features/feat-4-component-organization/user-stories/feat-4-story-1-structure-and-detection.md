# Story 1: Structure Rules & Stage Detection

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Updated 01-structure.mdc with 3-stage progressive structure, stage detection working, future detection for Stage 2→3

## User Story

**As a** Junior user
**I want** clear documentation of the 3-stage structure
**So that** I understand how my project will evolve

## Scope

**In Scope:**
- Update `.cursor/rules/01-structure.mdc` with 3-stage progressive structure
- Define `detect_stage()` function ONCE in structure rules (DRY)
- Define `detect_future_stage()` function for proactive detection
- Document triggers for each transition
- Complete directory tree examples for all 3 stages
- Document component overview structure

**Out of Scope:**
- Command implementations (Stories 2-5)
- Actual reorganization logic
- Migration from old structure

## Acceptance Criteria

- [ ] Given 01-structure.mdc updated, when developer reads it, then all 3 stages are clear with examples
- [ ] Given `detect_stage()` defined, when commands invoke it, then returns correct stage
- [ ] Given `detect_future_stage()` defined, when feature adds docs/, then detects Stage 2→3 transition needed
- [ ] Given any stage, when detection runs, then completes in <100ms

## Implementation Tasks

- [ ] 1.1 Update 01-structure.mdc with 3-stage structure (see 01-Technical.md for structure, DON'T repeat here)
- [ ] 1.2 Define `detect_stage()` function in structure rules (bash function, filesystem checks only)
- [ ] 1.3 Define `detect_future_stage(component, adding_type)` function - returns true if would trigger Stage 3
- [ ] 1.4 Document component overview template (ONCE, other stories reference this)
- [ ] 1.5 Update numbering conventions with component numbering (comp-N-name pattern)

## Technical Notes

### Future Detection Logic

When `/feature` or `/refactor` would add `docs/` or `specs/` to a component:
- Check current stage
- If Stage 2 + flat component + adding docs/specs → triggers Stage 3
- Options: (1) Ask user to run `/maintenance` first, OR (2) Create and recommend maintenance after
- **Decision:** Ask user to run `/maintenance` first (cleaner - reorganize THEN add)

Prompt:
```
⚠️ Adding docs/ to comp-1-backend would trigger Stage 3 reorganization.

Run /maintenance to reorganize first, then retry this command.

Reason: Stage 3 groups items by type for cleaner navigation.
```

### Testing

Test with mock directory structures:
- Stage 1: flat features → returns "stage1"
- Stage 2: components (flat) → returns "stage2"
- Stage 3: components (grouped) → returns "stage3"
- Future: Stage 2 + adding docs/ → future detection returns true

**Note:** Junior tests itself by using on real projects. No dedicated test suite for commands.

## Definition of Done

- [ ] All tasks completed
- [ ] 01-structure.mdc updated with complete 3-stage documentation
- [ ] `detect_stage()` defined once (NOT repeated in other files)
- [ ] `detect_future_stage()` defined for proactive detection
- [ ] Component overview template documented once
- [ ] Tested manually with mock structures
- [ ] Documentation follows DRY (references, not repetition)
- [ ] Documentation is concise (no unnecessary verbosity)
