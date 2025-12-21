# Story 10: Modularize commit.md

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** Story 7 (commands should be standardized first)
> **Deliverable:** commit.md modularized from 783 lines to ~300 lines main + submodules

## Developer Story

**As a** maintainer of Junior commands
**I want** commit.md broken into manageable submodules
**So that** documentation updates, grouping detection, and message generation are in separate files

## Current State

**What's wrong with current code:**
- `commit.md`: 783 lines (too long)
- Documentation update logic, grouping detection, message generation all in one file
- Hard to find specific logic
- Difficult to maintain

## Target State

**What improved code looks like:**
- Main file: `commit.md` (~300 lines)
- Submodules in `.cursor/commands/commit/`:
  - `doc-update.md` (Mode A) - Documentation update logic
  - `grouping-detection.md` (Mode A) - File grouping detection
  - `message-generation.md` (Mode A) - Commit message generation

**Structure:**
```
.cursor/commands/
├── commit.md (main, ~300 lines)
└── commit/
    ├── doc-update.md (Mode A)
    ├── grouping-detection.md (Mode A)
    └── message-generation.md (Mode A)
```

## Scope

**In Scope:**
- Create `.cursor/commands/commit/` directory
- Extract documentation update logic to submodule
- Extract grouping detection to submodule
- Extract message generation to submodule
- Update main file with references

**Out of Scope:**
- Changing commit logic (just organizing)
- Other commands (separate stories)

## Acceptance Criteria

- [ ] Given commit.md, when split, then main file is ~300 lines
- [ ] Given submodules, when created, then doc-update.md, grouping-detection.md, message-generation.md exist
- [ ] Given main file, when reviewed, then it references all submodules
- [ ] Given commit command, when tested, then it works identically

## Implementation Tasks

- [ ] 10.1 Create `.cursor/commands/commit/` directory
- [ ] 10.2 Create `commit/doc-update.md` (extract doc update logic)
- [ ] 10.3 Create `commit/grouping-detection.md` (extract grouping logic)
- [ ] 10.4 Create `commit/message-generation.md` (extract message logic)
- [ ] 10.5 Update `commit.md` with references
- [ ] 10.6 Test commit command works
- [ ] 10.7 User review of structure

## Verification Checklist

**Before marking story complete, verify:**
- [ ] Directory structure created
- [ ] Main file ~300 lines
- [ ] All 3 submodules created
- [ ] Main file references submodules
- [ ] Commit command tested and works
- [ ] User reviewed structure

## Technical Notes

**Main file structure (commit.md ~300 lines):**
```markdown
### Step X: Documentation Update
See [commit/doc-update.md](commit/doc-update.md) for documentation sync logic.

### Step Y: Grouping Detection
See [commit/grouping-detection.md](commit/grouping-detection.md) for file grouping.

### Step Z: Message Generation
See [commit/message-generation.md](commit/message-generation.md) for commit message creation.
```

**All submodules are Mode A** (AI instructions).

## Definition of Done

- [ ] All tasks completed
- [ ] commit.md split successfully
- [ ] Main file ~300 lines
- [ ] All submodules created (Mode A)
- [ ] References work correctly
- [ ] Command tested successfully
- [ ] User reviewed structure
- [ ] **commit.md modularized (783→300 lines)**

