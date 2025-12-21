# Story 9: Modularize implement.md

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** Story 7 (commands should be standardized first)
> **Deliverable:** implement.md modularized from 880 lines to ~300 lines main + submodules

## Developer Story

**As a** maintainer of Junior commands
**I want** implement.md broken into manageable submodules
**So that** TDD workflow, story discovery, and workflow branching (TDD vs non-TDD) are in separate files

## Current State

**What's wrong with current code:**
- `implement.md`: 880 lines (too long)
- TDD workflow, story discovery all mixed in one file
- No branching for TDD vs non-TDD workflows (code vs docs/scripts)
- Progress tracking should use shared module (Story 4)
- Hard to find specific logic
- Difficult to maintain and review

## Target State

**What improved code looks like:**
- Main file: `implement.md` at top level (~300 lines)
- Submodules in `.cursor/commands/implement/`:
  - `tdd-workflow.md` (Mode A) - Test-first development for code
  - `non-tdd-workflow.md` (Mode A) - Workflow for docs/scripts/non-code
  - `story-discovery.md` (Mode A) - Story file discovery logic
- **Progress tracking uses shared module from Story 4** (not duplicate)

**Structure:**
```
.cursor/commands/
├── implement.md                    # Main command (Mode A, ~300 lines)
│                                   # References _shared/todo-progress-patterns.md
└── implement/
    ├── tdd-workflow.md            # Mode A - for code projects
    ├── non-tdd-workflow.md        # Mode A - for docs/scripts
    └── story-discovery.md         # Mode A

```

**Key addition:** Branch after discovery:
- Code project? → TDD workflow (Red → Green → Refactor)
- Doc/script project? → Non-TDD workflow (implement → verify → refine)

## Scope

**In Scope:**
- Create `.cursor/commands/implement/` directory
- Extract TDD workflow to submodule (for code)
- Create non-TDD workflow submodule (for docs/scripts)
- Extract story discovery to submodule
- Add branching logic: TDD vs non-TDD
- **Use shared progress tracking from Story 4** (not duplicate)
- Update main file with references

**Out of Scope:**
- Changing implement logic (just organizing and adding branch)
- Other commands (separate stories)

## Acceptance Criteria

- [ ] Given implement.md, when split, then main file is ~300 lines
- [ ] Given submodules, when created, then tdd-workflow.md, non-tdd-workflow.md, story-discovery.md exist
- [ ] Given branching, when implemented, then code→TDD, docs/scripts→non-TDD
- [ ] Given progress tracking, when checked, then uses shared module from Story 4
- [ ] Given main file, when reviewed, then it references all submodules
- [ ] Given implement command, when tested, then it works identically

## Implementation Tasks

- [ ] 9.1 Create `.cursor/commands/implement/` directory
- [ ] 9.2 Create `implement/tdd-workflow.md` (extract TDD process for code)
- [ ] 9.3 Create `implement/non-tdd-workflow.md` (create workflow for docs/scripts)
- [ ] 9.4 Create `implement/story-discovery.md` (extract discovery logic)
- [ ] 9.5 Add branching logic: After discovery → TDD or non-TDD based on project type
- [ ] 9.6 Update `implement.md` to reference `_shared/todo-progress-patterns.md` (not duplicate)
- [ ] 9.7 Update `implement.md` with submodule references
- [ ] 9.8 Test implement command works (both branches)
- [ ] 9.9 User review of structure

## Verification Checklist

**Before marking story complete, verify:**
- [ ] Directory structure created
- [ ] Main file ~300 lines
- [ ] All 3 submodules created
- [ ] Main file references submodules
- [ ] Implement command tested and works
- [ ] User reviewed structure

## Technical Notes

**Main file structure (implement.md ~300 lines):**
```markdown
### Step X: Story Discovery
See [implement/story-discovery.md](implement/story-discovery.md) for story file discovery.

### Step Y: Workflow Selection (NEW BRANCHING)
**IF code project:**
  See [implement/tdd-workflow.md](implement/tdd-workflow.md) for test-first development.
  - Red: Write failing test
  - Green: Make test pass
  - Refactor: Improve code

**IF docs/scripts project:**
  See [implement/non-tdd-workflow.md](implement/non-tdd-workflow.md) for document/script workflow.
  - Implement: Create document/script
  - Verify: Check correctness/completeness
  - Refine: Polish and improve

### Step Z: Progress Tracking
Use progress tracking from `_shared/todo-progress-patterns.md` (Story 4).
```

**All submodules are Mode A** (AI instructions for workflow).

**Key principle:** Branch based on project type, use shared progress tracking.

## Definition of Done

- [ ] All tasks completed
- [ ] implement.md split successfully
- [ ] Main file ~300 lines
- [ ] All submodules created (Mode A)
- [ ] References work correctly
- [ ] Command tested successfully
- [ ] User reviewed structure
- [ ] **implement.md modularized (880→300 lines)**

