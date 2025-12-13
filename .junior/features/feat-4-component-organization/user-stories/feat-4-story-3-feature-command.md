# Story 3: Feature Command Component Integration

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** Story 1 (requires stage detection)
> **Deliverable:** `/feature` command detects stage, proposes component, handles future detection

## User Story

**As a** developer adding a new feature
**I want** Junior to detect stage and propose appropriate component
**So that** new features are organized correctly

## Scope

**In Scope:**
- Update `.cursor/commands/feature.md` with stage detection
- Stage 1: Create at `.junior/features/feat-N/` (no change)
- Stage 2+: Propose component based on description, require selection
- Use `detect_future_stage()` - if adding docs/specs triggers Stage 3, prompt user to run `/maintenance` first
- Update component overview when adding to existing component

**Out of Scope:**
- Semantic clustering (that's `/maintenance`)
- Stage transitions (that's `/maintenance`)

## Acceptance Criteria

- [ ] Given Stage 1, when creating feature, then creates flat without component prompt
- [ ] Given Stage 2+, when creating feature, then proposes component based on description
- [ ] Given feature would trigger Stage 3, when creating, then prompts to run `/maintenance` first
- [ ] Given existing component, when adding feature, then updates comp-N-overview.md feature list

## Implementation Tasks

- [ ] 3.1 Read current `.cursor/commands/feature.md` to understand workflow and integration points
- [ ] 3.2 Add stage detection at start of Step 3 (use `detect_stage()` from 01-structure.mdc)
- [ ] 3.3 Add component proposal for Stage 2+ in Step 3 (semantic match with existing components, or propose new)
- [ ] 3.4 Add future detection before creating directories (use `detect_future_stage()` - if true, prompt user to run `/maintenance` first)
- [ ] 3.5 Update Step 6 directory creation to use correct paths based on stage
- [ ] 3.6 Test with all 3 stages and verify component proposal logic
- [ ] 3.7 Review and refine based on testing, verify consistency with other commands

## Testing

Test scenarios:
- Stage 1 → creates flat feature, no component prompt
- Stage 2, good match → proposes component, creates under component
- Stage 2, no match → proposes new component, creates comp + feature
- Stage 3 → creates under features/ subdirectory
- Future detection → adding docs/ triggers prompt

## Definition of Done

- [ ] `.cursor/commands/feature.md` updated
- [ ] Stage detection integrated
- [ ] Component proposal works for Stage 2+
- [ ] Future detection prevents premature Stage 3 triggers
- [ ] Component overview updated automatically
- [ ] Tested with all stages
