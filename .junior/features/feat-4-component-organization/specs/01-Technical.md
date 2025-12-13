# Technical Specification: Progressive Component Organization

## Overview

This document details the technical approach for implementing progressive component-based organization in Junior. The system uses a 3-stage structure that adapts to project complexity, with fast stage detection and intelligent reorganization workflows.

## Architecture

### High-Level Design

```
┌─────────────────────────────────────────────────────────────┐
│                   Junior Commands                            │
│  /feature  /implement  /status  /maintenance  /migrate      │
│  /refactor                                                   │
└────────────┬────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────┐
│              Stage Detection Layer                           │
│  • detect_stage() - filesystem analysis                     │
│  • detect_future_stage() - proactive detection              │
│  • Returns: "stage1" | "stage2" | "stage3"                  │
│  • Defined in 01-structure.mdc (single source)              │
└────────────┬────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────┐
│         Component Organization Logic                         │
│  • Path resolution (feat-N → correct location)              │
│  • Semantic clustering (keyword-based)                      │
│  • Reorganization workflows (git mv + content updates)      │
└────────────┬────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────┐
│           .junior/ File Structure                            │
│  Stage 1: features/feat-N/                                   │
│  Stage 2: features/comp-M/feat-N/                            │
│  Stage 3: features/comp-M/features/feat-N/                   │
└─────────────────────────────────────────────────────────────┘
```

### Structure Reference

**Complete structure definitions:** See `01-structure.mdc`
- 3-stage progressive structure with directory trees
- Stage detection functions (`detect_stage()`, `detect_future_stage()`)
- Component overview template
- Numbering conventions (comp-N-name, feat-N-name)

**Why reference instead of repeat:** Single source of truth (DRY). Structure definitions maintained in one place, consumed by all commands.

### Component Structure Details

**Stage 1: Flat Features (Default)**

```
.junior/features/
├── feat-1-auth/
├── feat-2-api/
└── feat-3-dashboard/
```

Characteristics: Zero overhead, implicit "one component", best for small projects.

**Stage 2: Component Organization**

```
.junior/features/
├── comp-1-backend/
│   ├── comp-1-overview.md
│   ├── feat-1-auth/
│   ├── feat-2-api/
│   └── imp-1-refactor/
└── comp-2-frontend/
    ├── comp-2-overview.md
    └── feat-3-dashboard/
```

Characteristics: Flat within component (no type mixing), components group related features.

**Stage 3: Grouped Structure (Optional)**

```
.junior/features/
└── comp-1-backend/
    ├── comp-1-overview.md
    ├── features/
    │   ├── feat-1-auth/
    │   └── feat-2-api/
    ├── improvements/
    │   └── imp-1-refactor/
    ├── docs/
    └── specs/
```

Characteristics: Grouped by type, cleaner navigation for large components.

## Components

### Stage Detection Module

**Responsibility:** Determine which stage a project is in

**Location:** Defined in `01-structure.mdc` (single source of truth)

**Interface:**
- `detect_stage()` → "stage1" | "stage2" | "stage3"
- `detect_future_stage(component, type)` → boolean
- `check_for_old_structure()` → boolean

**Implementation:** Filesystem checks only, no content parsing

**Dependencies:** None (pure filesystem operations)

### Path Resolution Module

**Responsibility:** Find features/components in correct locations

**Paths by stage:**
- Stage 1: `.junior/features/feat-N/`
- Stage 2: `.junior/features/comp-M/feat-N/`
- Stage 3: `.junior/features/comp-M/features/feat-N/`

Commands use stage detection to resolve correct paths dynamically.

### Semantic Clustering Module

**Responsibility:** Analyze features and propose component groupings

**Approach:** Keyword extraction from feature names/descriptions, simple grouping by shared keywords (no NLP/AI required).

**Parameters:**
- Minimum cluster size: 3-4 features
- Threshold for recommendation: 4-6+ features per cluster
- Stopwords: "feature", "system", "module" (common non-discriminative terms)

### Reorganization Module

**Responsibility:** Execute structure transitions with git discipline

**Git Operations Pattern:**

**Phase 1: File moves**
```bash
# Create directories
mkdir -p .junior/features/comp-1-name

# Move features
git mv .junior/features/feat-1-name .junior/features/comp-1-name/
git mv .junior/features/feat-2-name .junior/features/comp-1-name/

# Verify moves (count files, check paths)
verify_file_moves()

# Commit phase 1
git commit -m "Reorganize into components (file moves)"
```

**Phase 2: Content updates**
```bash
# Create component overviews (use template from 01-structure.mdc)
create_component_overviews()

# Update cross-references (feat-1 → comp-1/feat-1)
update_cross_references()

# Verify content (search for old references)
verify_references()

# Commit phase 2
git commit -m "Add component overviews and update references"
```

**Why two-phase:** Git tracks file moves better when separated from content changes. Easier review/rollback.

### Component Overview Manager

**Responsibility:** Create and update component overview files

**Template location:** Defined in `01-structure.mdc` (reference, don't duplicate)

**Auto-update behavior:**
- When `/feature` adds feature: append row to Features table
- Update "Last Updated" timestamp
- Populate purpose/scope from feature descriptions (inference)

## Design Decisions

### Decision 1: Progressive 3-Stage Structure

**Context:** Need to organize features in growing projects without forcing complexity upfront.

**Decision:** Use 3 progressive stages that adapt to project size.

**Rationale:**
- Stage 1 (flat) keeps new projects simple - zero ceremony
- Stage 2 (components) emerges when natural clustering appears - guided evolution
- Stage 3 (grouped) optimizes large components - optional enhancement
- Each stage is optional transition, not forced
- Aligns with "simplicity is the ultimate sophistication"

**Alternatives Considered:**
- Single-stage (always components): Too complex for small projects, violates simplicity
- Two-stage (flat or components): Doesn't handle large components well
- Four+ stages: Unnecessary complexity, diminishing returns

**Trade-offs:** Commands must handle 3 structures. Accepted because each stage remains simple and detection is fast.

### Decision 2: Semantic Clustering via Keywords

**Context:** Need to propose component groupings automatically for `/maintenance` and `/migrate`.

**Decision:** Use keyword extraction and simple clustering, not NLP or AI.

**Rationale:**
- Simple, fast, no external dependencies
- Good enough accuracy for proposal (user reviews before applying)
- Transparent reasoning (can explain why features grouped)
- No training data or models needed
- Agent knows how to implement this without detailed pseudo-code

**Alternatives Considered:**
- Manual grouping only: Too much user burden, error-prone
- AI/LLM-based analysis: Overkill, adds complexity and dependencies
- Code analysis (imports/dependencies): Requires code parsing, language-specific, slow

**Trade-offs:** May miss subtle relationships. Acceptable because user reviews and can adjust grouping.

### Decision 3: Git Discipline (Two-Phase Commits)

**Context:** Reorganization involves both file moves and content updates.

**Decision:** Always commit moves first, then content, in separate commits.

**Rationale:**
- Git tracks file moves better when separated from content changes
- Easier to review each phase independently
- Simpler rollback if issues arise (revert last commit)
- Clear separation of concerns in commit history
- Matches best practice for large refactorings

**Alternatives Considered:**
- Single commit: Git may not track moves correctly, harder to review
- Three+ commits: Unnecessary granularity
- No git operations: User does manually (error-prone, loses history)

### Decision 4: Components Required in Stage 2+

**Context:** Should components be optional or required once Stage 2 is reached?

**Decision:** Components are required once project transitions to Stage 2.

**Rationale:**
- Simplifies mental model (either flat or components, not mixed)
- Prevents half-migrated state confusion
- User can always run `/maintenance` to reorganize if structure isn't ideal
- New features automatically go to correct place (no ambiguity)

**Alternatives Considered:**
- Optional components: Allows mixed state (confusing navigation)
- Top-level features + components: Inconsistent organization
- Require migration before new features: Blocks workflow unnecessarily

**Trade-offs:** Forces user to commit to component structure. Acceptable because transition is guided and reversible via git.

### Decision 5: Stage 3 Optional

**Context:** Should large components automatically transition to Stage 3?

**Decision:** Stage 3 is optional optimization, not enforced.

**Rationale:**
- Flat component structure works fine for most components (<13 items)
- Stage 3 adds nesting level (counter to simplicity principle)
- Let users decide based on their navigation preferences
- Can always transition later via `/maintenance` if needed

**Alternatives Considered:**
- Automatic Stage 3: Forces structure change without user control
- Never Stage 3: Doesn't handle very large components well (>20 items becomes cluttered)

**Trade-offs:** Some large components may remain flat. Acceptable because Stage 3 is always available when needed.

### Decision 6: Future Detection for Stage 2→3

**Context:** When `/feature` or `/refactor` would add docs/specs to Stage 2 component, should we handle Stage 3 transition?

**Decision:** Detect future Stage 3 need via `detect_future_stage()`, prompt user to run `/maintenance` first.

**Rationale:**
- Cleaner to reorganize THEN add, not add THEN reorganize
- Avoids mid-command structure changes
- User explicitly runs `/maintenance` (understands what's happening)
- Maintains separation of concerns (maintenance = structure, feature = content)

**Alternatives Considered:**
- Auto-transition to Stage 3: Surprising, violates explicit control
- Create docs/ anyway: Creates type mixing (trigger for Stage 3 but not organized)
- Ask during feature creation: Interrupts feature workflow

## Testing Strategy

**Philosophy:** Junior tests itself by using on real projects. No dedicated test suite for commands/rules.

**Manual testing during implementation:**

**Stage Detection:**
- Test with mock directories at each stage
- Verify correct stage returned
- Verify performance (should feel instant, target <100ms on typical project)

**Stage 1→2 Transition:**
- Create mock project with 8 features (clear clustering: 4 auth, 3 analytics, 1 standalone)
- Run `/maintenance`
- Verify proposal shows 2-3 components with reasoning
- Accept proposal
- Verify git log shows 2 commits (moves, content)
- Verify features moved correctly
- Verify component overviews created with correct content
- Verify cross-references updated

**Stage 2→3 Transition:**
- Create mock component with 15 features OR component with docs/ directory
- Run `/maintenance`
- Verify proposal shows grouping reasoning
- Accept proposal
- Verify features/ subdirectory created
- Verify items moved under subdirectories
- Verify cross-references updated

**Feature Creation:**
- Create feature on Stage 1 → verify flat location, no component prompt
- Create feature on Stage 2 → verify component proposed, created under component
- Create new component → verify component overview created
- Add feature to Stage 3 component → verify features/ subdirectory used

**Migration:**
- Create old Junior with 3 features → verify recommends Stage 1
- Create old Junior with 8 features (clustering) → verify recommends Stage 2 with grouping

**Future Detection:**
- Stage 2 component, feature adds docs/ → verify prompts for `/maintenance`

## Performance Targets

- **Stage detection:** <100ms on typical project (<10 components, <50 features)
- **Semantic clustering:** <2s for 50 features
- **Reorganization:** <30s for 50 features (mostly git operations)

## Cross-References

- Implements requirements from [feat-4-overview.md](../feat-4-overview.md)
- Story 1: [Structure & Detection](../user-stories/feat-4-story-1-structure-and-detection.md)
- Story 2: [Maintenance Command](../user-stories/feat-4-story-2-maintenance-command.md)
- Story 3: [Feature Command](../user-stories/feat-4-story-3-feature-command.md)
- Story 4: [Migrate Command](../user-stories/feat-4-story-4-migrate-command.md)
- Story 5: [Update Commands](../user-stories/feat-4-story-5-update-commands.md)
- Story 6: [Future Enhancements](../user-stories/feat-4-story-6-future-enhancements.md)
