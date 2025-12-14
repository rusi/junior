# Story 4: Migrate Command Component Support

> **Status:** Completed
> **Priority:** High
> **Dependencies:** Story 1 (requires structure rules)
> **Deliverable:** `/migrate` migrates Code Captain → Junior Stage 1 or Stage 2 based on complexity

## User Story

**As a** user migrating from Code Captain
**I want** migrate to analyze my specs and migrate directly to the appropriate Junior stage
**So that** my project structure matches its complexity from day one

## Scope

**In Scope:**
- Analyze Code Captain specs for complexity (count features, semantic clustering)
- Migrate Code Captain → Junior Stage 1 (if <6 features)
- Migrate Code Captain → Junior Stage 2 (if 6+ features with clustering)
- User can adjust proposed component grouping (Stage 2 only)
- Git discipline: moves → commit → content → commit

**Out of Scope:**
- Old Junior migration (no such thing - `/maintenance` handles reorganization within Junior)
- Stage 3 migration (use `/maintenance` later after features grow)

## Acceptance Criteria

- [x] Given Code Captain with <6 features, when `/migrate` runs, then migrates to Junior Stage 1 (flat) ✅
- [x] Given Code Captain with 6+ features and clustering, when analyzing, then proposes Stage 2 with component groups ✅
- [x] Given user approves Stage 2, when migrating, then creates component structure with git discipline ✅
- [x] Given Code Captain with 6+ features but no clustering, when analyzing, then migrates to Stage 1 (flat) ✅

## Implementation Tasks

- [x] 4.1 Read current `.cursor/commands/migrate.md` to understand workflow and integration points ✅
- [x] 4.2 Add Code Captain complexity analysis in Step 3 (count features, semantic clustering if 6+) ✅
- [x] 4.3 Update Step 4 (Migration Plan) to show target stage (1 or 2) with reasoning ✅
- [x] 4.4 Update Step 5 to migrate directly to Stage 1 (flat) or Stage 2 (components) based on analysis ✅
- [x] 4.5 For Stage 2: create component directories and move features in single migration flow ✅
- [x] 4.6 For Stage 2: create component overviews and update references (git discipline: 2 commits) ✅
- [x] 4.7 Test with multiple scenarios (small project → Stage 1, large with clustering → Stage 2) ✅

## Testing

Test scenarios:
- Code Captain with 3 features → migrates to Junior Stage 1 (flat)
- Code Captain with 8 features (clear clustering) → proposes Stage 2, migrates with component structure
- Code Captain with 8 features (no clustering) → migrates to Junior Stage 1 (flat)
- User adjusts Stage 2 grouping → updates proposal, migrates with adjusted components
- Stage 2 migration → 2 commits (moves, content), component overviews created

## Definition of Done

- [x] `.cursor/commands/migrate.md` updated with Code Captain complexity analysis ✅
- [x] Code Captain with <6 features → migrates to Stage 1 ✅
- [x] Code Captain with 6+ features → semantic clustering analysis ✅
- [x] Clustering detected → proposes Stage 2 with component grouping ✅
- [x] No clustering detected → migrates to Stage 1 (even with 6+ features) ✅
- [x] Stage 2 migration creates components, overviews, and updates references ✅
- [x] Git discipline maintained (2 commits for Stage 2) ✅
- [x] Tested with multiple scenarios ✅
