# Story 2: Maintenance Command

> **Status:** Completed
> **Priority:** High
> **Dependencies:** Story 1 (requires stage detection)
> **Deliverable:** Working `/maintenance` command via `/new-command`

## User Story

**As a** developer with growing project complexity
**I want** Junior to analyze my structure and propose reorganization
**So that** I can evolve from Stage 1→2 or Stage 2→3 when it makes sense

## Scope

**In Scope:**
- Use `/new-command` to create maintenance command with comprehensive prompt
- Command analyzes structure, proposes reorganization, executes with git discipline
- Semantic clustering for Stage 1→2 (keyword-based, simple)
- Size analysis for Stage 2→3 (item count, type mixing detection)
- Git discipline: moves → commit → content → commit
- User approval required before any changes

**Out of Scope:**
- Automatic reorganization (always requires approval)
- Component dependency analysis
- Performance metrics

## Acceptance Criteria

- [ ] Given Stage 1 with clustering, when `/maintenance` runs, then proposes Stage 2 with component grouping
- [ ] Given Stage 2 component with >13 items OR docs/, when `/maintenance` runs, then proposes Stage 3
- [ ] Given user approves, when reorganization executes, then uses `git mv` and two-phase commits
- [ ] Given reorganization complete, when verifying, then all files moved and references updated

## Implementation Tasks

- [x] 2.1 Run `/new-command` with maintenance command prompt (see below) ✅

**Prompt for `/new-command`:**

```
Create maintenance command for structure reorganization.

**Purpose:** Analyze project structure and propose reorganization (Stage 1→2 or Stage 2→3).

**Type:** Direct execution with approval gate.

**Workflow:**

1. Detect current stage using `detect_stage()` from 01-structure.mdc
2. Analyze for reorganization opportunities:
   - Stage 1→2: If 4-6+ features cluster semantically (keyword-based: extract keywords from feat names, find clusters of 3-4+)
   - Stage 2→3: If component has >13 items OR has docs/specs directories (type mixing)
3. If opportunity found: Present proposal with before/after trees and reasoning
4. Wait for approval: yes | adjust | cancel
5. Execute with git discipline:
   - Phase 1: File moves with `git mv`, verify, commit moves
   - Phase 2: Create comp-N-overview.md (use template from 01-structure.mdc), update references, verify, commit content
6. Report success

**Key points:**
- Semantic clustering: simple keyword extraction and grouping, no NLP
- Git discipline: TWO commits (moves first, content second) to preserve history
- User can adjust groupings before approval
- Verification after each phase (count files, search for old references)
- For comp-N-overview.md: use template from 01-structure.mdc, populate with detected purpose/scope from feature names

**Tools:** todo_write, codebase_search, grep, read_file, write, run_terminal_cmd

Implements feat-4-story-2. See 01-Technical.md for architecture (DON'T repeat here).
```

## Testing

Test scenarios:
- Stage 1 with 8 features (clear clustering) → proposes 2-3 components
- Stage 2 component with 15 features → proposes Stage 3
- Stage 2 component with docs/ → proposes Stage 3
- User adjusts grouping → updates proposal, waits for re-approval
- Git commits → verify 2 commits with correct messages

**Note:** Junior tests itself by using on real projects. Test manually during implementation.

## Definition of Done

- [ ] `/new-command` invoked with prompt
- [ ] Maintenance command created and working
- [ ] Stage 1→2 transition works (clustering, proposal, execution)
- [ ] Stage 2→3 transition works (size/type triggers, execution)
- [ ] Git discipline maintained (2 commits, git mv)
- [ ] Component overviews created correctly
- [ ] Cross-references updated
- [ ] Tested manually with real scenarios
