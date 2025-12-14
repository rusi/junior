# Progressive Component-Based Organization

> Created: 2025-12-13
> Status: In Progress
> Contract Locked: ✅

## Feature Contract

**Feature:** Progressive component-based organization for Junior

**User Value:** Projects start simple (flat features), naturally evolve to components when complexity emerges, then to grouped structure when components grow large

**Hardest Constraint:** Commands must detect 3 structure stages and work seamlessly across all, while keeping each stage minimal

**Success Criteria:** New projects start flat, Junior detects when reorganization would help and recommends `/maintenance`, structure evolves progressively without manual complexity

**Scope:**
- ✅ Included: 3-stage progressive structure, semantic detection for component clustering, `/maintenance` command for reorganization, update 01-structure.mdc, update `/feature` and `/migrate` commands
- ✅ Included: Git discipline (moves → commit → content → commit)
- ❌ Excluded: Automatic reorganization (user runs `/maintenance`), component dependencies/versioning, Stage 3 enforcement (optional optimization)

**Integration Points:**
- `.cursor/rules/01-structure.mdc` - Document 3-stage progressive structure
- `.cursor/commands/feature.md` - Detect stage, propose component if Stage 2+, future detection
- `.cursor/commands/migrate.md` - Handle Code Captain → Stage 1 or Stage 2
- `.cursor/commands/maintenance.md` - NEW: Analyze and reorganize structure
- Other commands (implement, status, refactor) - Detect and work with any stage, future detection

**⚠️ Technical Concerns:**
- Stage detection logic must be fast and reliable
- Semantic clustering for Stage 1→2 needs good heuristics
- Commands must handle 3 structures without becoming complex
- Component overview feature list must stay updated

**💡 Recommendations:**
- Start all new projects at Stage 1 (simplest)
- Make Stage 2→3 optional (performance optimization, not requirement)
- `/maintenance` shows "before/after" preview with clear reasoning
- Semantic detection uses feature names + descriptions (simple keyword analysis)

## Detailed Requirements

### Functional Requirements

**Stage Detection:**
- Commands automatically detect which stage project is in
- Fast detection (no heavy analysis on every command)
- Clear visual indicators when structure recommendations exist

**Stage 1 → Stage 2 Transition:**
- Semantic analysis detects feature clustering
- Threshold: 4-6+ features cluster into distinct components
- Junior recommends `/maintenance` when clustering detected
- User reviews proposal and approves reorganization

**Stage 2 → Stage 3 Transition:**
- Trigger: Component has `docs/` or `specs/` directories (type mixing)
- OR: Component has >13 items (size threshold)
- Optional optimization (not required)
- `/maintenance` proposes grouping into subfolders

**Component Management:**
- `comp-N-overview.md` contains purpose, scope, feature list
- Feature list auto-updated when features added/modified
- Components are logical groupings (not strict boundaries)
- Cross-component work handled gracefully

**Git Discipline:**
- All reorganization uses `git mv` (preserve history)
- Two-phase commit: (1) file moves, (2) content/reference updates
- Clear commit messages document reorganization reasoning

### Non-Functional Requirements

- **Performance:** Stage detection completes in <100ms
- **Simplicity:** Each stage has minimal overhead, progressive complexity only when needed
- **Maintainability:** Commands share detection logic, no duplication
- **Usability:** Clear recommendations with reasoning, easy approval/rejection

## User Stories

See [user-stories/feat-4-stories.md](./user-stories/feat-4-stories.md) for implementation breakdown.

**Note on Testing:** Junior tests itself by using on real projects. No dedicated test suite for commands. Each story includes manual testing during implementation (vertical integration).

## Technical Approach

See [specs/01-Technical.md](./specs/01-Technical.md) for detailed technical approach.

High-level strategy:
- Stage detection via directory structure analysis (fast filesystem checks)
- Semantic clustering using feature names + descriptions (keyword-based)
- `/maintenance` command orchestrates reorganization with git discipline
- Commands adapt behavior based on detected stage
- TDD approach: Test stage detection, reorganization logic, command integration

## 3-Stage Progressive Structure

**Stage 1: Simple (new projects, <10 features)**

```
.junior/features/
├── feat-1-name/
├── feat-2-name/
└── feat-3-name/
```

**Characteristics:**
- Zero overhead, flat structure
- Implicit "one component" project
- Best for: Small projects, prototypes, early development

**Detection:** No `comp-*/` directories under `.junior/features/`

---

**Stage 2: Component Organization (clear clustering emerges)**

```
.junior/features/
├── comp-1-core-framework/
│   ├── comp-1-overview.md
│   ├── feat-1-name/
│   ├── feat-2-name/
│   └── imp-1-name/
└── comp-2-installation/
    ├── comp-2-overview.md
    └── feat-3-name/
```

**Characteristics:**
- Flat within component (no type mixing)
- Components group related features
- Best for: Growing projects with distinct areas

**Trigger:** 4-6+ features cluster into distinct components (semantic detection)

**Detection:** `comp-*/` directories exist, no `features/` subdirectory within components

---

**Stage 3: Grouped Structure (large component)**

```
.junior/features/
└── comp-1-core-framework/
    ├── comp-1-overview.md
    ├── features/
    │   ├── feat-1-name/
    │   └── feat-2-name/
    ├── improvements/
    │   └── imp-1-name/
    ├── docs/              (component-level)
    └── specs/             (component-level)
```

**Characteristics:**
- Grouped by type within component
- Clean navigation for large components
- Best for: Complex components with many items

**Trigger:** Component has `docs/` or `specs/` directories OR >13 items

**Detection:** Component has `features/` subdirectory

## Dependencies

**External:**
- Git for file moves and history preservation
- Filesystem for structure detection

**Internal:**
- All commands must adapt to detected stage
- 01-structure.mdc defines canonical structure
- `/maintenance` orchestrates reorganization

## Risks & Mitigations

**Risk:** Semantic clustering produces poor component groupings
- **Mitigation:** Show reasoning, allow user to adjust before applying

**Risk:** Commands become complex handling 3 stages
- **Mitigation:** Shared detection logic, clear abstractions, progressive enhancement

**Risk:** Component overview feature list becomes stale
- **Mitigation:** Commands auto-update when features added/modified

**Risk:** Users confused about when to reorganize
- **Mitigation:** Clear recommendations with reasoning, optional (not required)

**Risk:** Git history lost during reorganization
- **Mitigation:** Always use `git mv`, two-phase commits, verification steps

## Success Metrics

- New projects start at Stage 1 (zero setup complexity)
- Stage detection completes in <100ms
- Semantic clustering accuracy >80% (user accepts proposal)
- Zero git history loss during reorganization
- Commands work seamlessly across all 3 stages

## Future Enhancements

See [user-stories/feat-4-story-7-future-enhancements.md](./user-stories/feat-4-story-7-future-enhancements.md) for detailed future work.

- Component dependency tracking and visualization
- Cross-component impact analysis
- Component-level metrics (size, complexity, health)
- Automatic component boundary detection
- Component templates for common patterns
- Multi-component refactoring workflows

