# Story 5: Update Other Commands for Component Support

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** Stories 1-4 (requires structure changes in place)
> **Deliverable:** All commands work seamlessly with Stage 1/2/3

## User Story

**As a** Junior user with component-organized project
**I want** all commands to work correctly regardless of stage
**So that** I can use any command without worrying about paths

## Scope

**In Scope:**
- Update `/implement`, `/status`, `/refactor` to use `detect_stage()` and resolve paths correctly
- Add old structure detection with migration prompt (graceful, not blocking)
- `/status` shows component-grouped view for Stage 2+

**Out of Scope:**
- Backward compatibility (users must migrate eventually)
- New command functionality

## Acceptance Criteria

- [ ] Given any stage, when `/implement` runs, then finds feature correctly
- [ ] Given Stage 2+, when `/status` runs, then shows components with features grouped
- [ ] Given old structure, when any command runs, then shows migration prompt (graceful)
- [ ] Given `/refactor` adding docs/ to Stage 2 component, when running, then uses `detect_future_stage()` and prompts for `/maintenance`

## Implementation Tasks

- [ ] 5.1 Update `/implement` - add stage detection, use path resolution based on stage
- [ ] 5.2 Update `/status` - add stage detection, show component-grouped view for Stage 2+ (tree format)
- [ ] 5.3 Update `/refactor` - add stage detection, use `detect_future_stage()` if creating docs/specs under component
- [ ] 5.4 Add old structure detection helper to all commands (check flat features + no components → show migration prompt)

## Testing

Test scenarios:
- `/implement` on all 3 stages → finds features correctly
- `/status` on Stage 2+ → shows component tree
- `/refactor` triggering Stage 3 → prompts for `/maintenance`
- Any command on old structure → shows migration prompt

## Definition of Done

- [ ] All commands updated
- [ ] Stage detection integrated consistently
- [ ] `/status` shows organized view for Stage 2+
- [ ] `/refactor` uses future detection
- [ ] Old structure detection graceful
- [ ] Tested with all stages
