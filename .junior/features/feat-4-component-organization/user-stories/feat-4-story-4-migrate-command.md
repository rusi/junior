# Story 4: Migrate Command Component Support

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** Story 1 (requires structure rules)
> **Deliverable:** `/migrate` handles old Junior → Stage 1 or Stage 2 with intelligent grouping

## User Story

**As a** user upgrading from pre-feat-4 Junior
**I want** migrate to detect old structure and propose component grouping
**So that** I upgrade to component-based organization intelligently

## Scope

**In Scope:**
- Update `.cursor/commands/migrate.md` with old Junior detection
- Analyze features for clustering (reuse semantic clustering from Story 2)
- Propose Stage 1 (if <6 features) or Stage 2 (if clustering detected)
- User can adjust proposed grouping
- Git discipline: moves → commit → content → commit

**Out of Scope:**
- Automatic grouping (requires approval)
- Stage 3 migration (use `/maintenance` later)

## Acceptance Criteria

- [ ] Given old Junior (flat features), when `/migrate` runs, then detects old structure
- [ ] Given <6 features, when analyzing, then recommends Stage 1 (keep flat)
- [ ] Given 6+ features with clustering, when analyzing, then recommends Stage 2 with component groups
- [ ] Given user approves, when migrating, then creates correct structure with git discipline

## Implementation Tasks

- [ ] 4.1 Read current `.cursor/commands/migrate.md` to understand workflow and integration points
- [ ] 4.2 Add old Junior detection in Step 2 (check for flat `.junior/features/feat-N/` without `comp-*/`)
- [ ] 4.3 Add structure analysis in Step 3 (count features, if 6+: semantic clustering like Story 2, otherwise: recommend flat)
- [ ] 4.4 Update Step 4 (Migration Plan) to show component grouping proposal with reasoning
- [ ] 4.5 Update Steps 5-7 to handle component migration with git discipline (same as Story 2)
- [ ] 4.6 Test with multiple scenarios (small project, large with clustering, user adjustments)
- [ ] 4.7 Review and refine, verify consistency with Code Captain migration workflow

## Testing

Test scenarios:
- Old Junior with 3 features → recommends Stage 1, keeps flat
- Old Junior with 8 features (clustering) → recommends Stage 2, shows grouping
- User adjusts grouping → updates proposal
- Migration executes → 2 commits, component overviews created

## Definition of Done

- [ ] `.cursor/commands/migrate.md` updated
- [ ] Old Junior detection works
- [ ] Clustering analysis proposes sensible groups
- [ ] Stage 1 migration works (keeps flat)
- [ ] Stage 2 migration works (creates components)
- [ ] Git discipline maintained
- [ ] Tested with multiple scenarios
