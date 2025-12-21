# Story 4: Extract TODO & Progress Tracking Patterns

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** TODO & progress tracking patterns standardized across 9 commands

## Developer Story

**As a** maintainer of Junior commands
**I want** TODO and progress tracking patterns extracted to a shared module
**So that** all commands follow consistent TODO structure (5-7 items, `[action]-[target]` naming) AND consistent progress display

## Current State

**What's wrong with current code:**
- TODO structures inconsistent across commands:
  - `/feature`: 7 TODOs
  - `/debug`: 6 TODOs
  - `/status`: 6 TODOs
  - `/migrate`: 12 TODOs (too many!)
- Naming inconsistent: Some use verbs, some use nouns
- No standard pattern for TODO granularity
- Progress tracking repeated in `/implement` and other commands
- DRY violation: TODO and progress tracking guidance repeated

**Examples:**

Inconsistent patterns:
```markdown
Command A:
- clarify (verb only)
- assess (verb only)
- execute (verb only)

Command B:
- Clarification phase (noun + phase)
- Assessment step (noun + step)
- Execution (noun only)

Command C:
- Step 1: Clarify (Step + number + verb)
```

## Target State

**What improved code looks like:**
- Single source of truth: `.cursor/commands/_shared/todo-patterns.md` (Mode A)
- Commands reference: "Use TODO patterns from `_shared/todo-patterns.md`"
- Standard: 5-7 TODOs per command (not more than 8)
- Naming pattern: `[action]-[target]` (e.g., `generate-spec`, `update-docs`, `verify-tests`)
- Each TODO = 1 major step (not sub-tasks)

**Shared module structure:**
- TODO structure guidance (Mode A)
- Naming conventions (Mode A)
- Granularity rules (5-7 items)
- Examples of good TODO names
- Progress tracking display patterns (Mode A)
- Progress update patterns (Mode A)

## Scope

**In Scope:**
- Create `.cursor/commands/_shared/todo-progress-patterns.md`
- Define standard TODO structure (5-7 items, naming pattern)
- Define standard progress tracking display
- Update ALL 9 commands to reference shared patterns:
  - `feature.md` - standardize TODOs and progress
  - `implement.md` - standardize TODOs and progress (remove inline progress tracking)
  - `commit.md` - standardize TODOs and progress
  - `status.md` - standardize TODOs and progress
  - `maintenance.md` - standardize TODOs and progress
  - `debug.md` - standardize TODOs and progress
  - `refactor.md` - standardize TODOs and progress
  - `migrate.md` - reduce from 12 to 5-7 TODOs, standardize progress
  - `new-command.md` - standardize TODOs and progress
- Grep verification: old inconsistent patterns removed

**Out of Scope:**
- Changing TODO tracking tool itself (just standardizing structure)
- Adding new TODO features (just consistency)

## Acceptance Criteria

- [ ] Given TODO pattern, when extracted to shared module, then `.cursor/commands/_shared/todo-patterns.md` exists
- [ ] Given 9 commands, when updated, then all follow 5-7 TODO structure
- [ ] Given TODO names, when standardized, then all follow `[action]-[target]` pattern
- [ ] Given commands, when reviewed, then all reference shared TODO pattern module

## Implementation Tasks

- [ ] 4.1 Create `todo-patterns.md` with standards (Mode A)
- [ ] 4.2 Update `feature.md` - standardize TODOs (reference pattern)
- [ ] 4.3 Update `implement.md` - standardize TODOs
- [ ] 4.4 Update `commit.md` - standardize TODOs
- [ ] 4.5 Update `status.md` - standardize TODOs
- [ ] 4.6 Update `maintenance.md` - standardize TODOs
- [ ] 4.7 Update `debug.md` - standardize TODOs
- [ ] 4.8 Update `refactor.md` - standardize TODOs
- [ ] 4.9 Update `migrate.md` - reduce to 5-7 TODOs
- [ ] 4.10 Update `new-command.md` - standardize TODOs
- [ ] 4.11 Grep verification: Inconsistent patterns gone
- [ ] 4.12 User review of changes

## Verification Checklist

**Before marking story complete, verify:**
- [ ] Shared module exists: `.cursor/commands/_shared/todo-patterns.md`
- [ ] Module is Mode A (concise guidelines)
- [ ] All 9 commands have 5-7 TODOs (not more than 8)
- [ ] All TODO names follow `[action]-[target]` pattern
- [ ] Commands reference shared pattern
- [ ] User has reviewed and approved changes

## Regression Prevention

**Strategy:**
- Standardize existing TODOs (don't change workflow)
- Apply consistent naming (improve clarity)
- Reference shared pattern (easier to maintain)

**Validation:**
- Manual review: Each command has 5-7 TODOs
- Naming check: All follow `[action]-[target]`
- Pattern check: Commands reference shared module

## Rollback Plan

**If issues arise:**
1. Revert commit
2. Commands return to original TODO structures
3. Pattern can be refined and re-applied

**Rollback criteria:**
- TODO structure doesn't fit command workflow
- Naming pattern unclear
- Too few/too many TODOs for specific command

## Technical Notes

**Shared module structure (.cursor/commands/_shared/todo-progress-patterns.md):**

```markdown
# TODO & Progress Tracking Patterns (AI Internal - Mode A)

## Standard TODO Structure
5-7 TODOs per command (not more than 8)
Each TODO = 1 major step (not sub-tasks)

## Naming Pattern
`[action]-[target]` format:
- generate-spec (not "Generation" or "Spec generation")
- update-docs (not "Documentation update" or "Update documentation")
- verify-tests (not "Test verification" or "Verify")

## TODO Examples
✅ Good:
- clarify-intent
- assess-complexity
- generate-spec
- update-docs
- verify-tests

❌ Bad:
- clarify (too vague)
- Clarification phase (noun + phase)
- Step 1: Clarify (includes step number)

## Progress Tracking Display

**Standard format:**
- Show current story/step
- Show completion status
- Show what's remaining
- Visual indicators (✓ ✗ ⏳)

**Example:**
```
Progress: Story 2/5 (Database layer)
✓ Story 1: API endpoints
⏳ Story 2: Database layer (in progress)
  - Task 2.1: Schema (completed)
  - Task 2.2: Migrations (in progress)
  - Task 2.3: Tests (pending)
☐ Story 3: Integration tests
☐ Story 4: Documentation
☐ Story 5: Deployment
```

## Usage in Commands
"Use TODO and progress patterns from `_shared/todo-progress-patterns.md`"
```

**Reference pattern in commands:**
```markdown
### Step 1: Initialize Tracking

Create TODOs using `todo_write` (follow patterns from `_shared/todo-patterns.md`):

```json
{
  "todos": [
    {"id": "clarify-intent", "content": "Clarify ...", "status": "in_progress"},
    {"id": "assess-complexity", "content": "Assess ...", "status": "pending"},
    ...
  ]
}
```
```

**Standardization examples:**

Before (feature.md):
```
- clarify
- scan
- analyze
- contract
- approval
- generate
- complete
```

After:
```
- clarify-intent
- scan-codebase
- analyze-gaps
- present-contract
- generate-spec
```

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Shared module created (TODO standards)
- [ ] All 9 commands updated with 5-7 TODOs
- [ ] All TODOs follow `[action]-[target]` naming
- [ ] Commands reference shared pattern
- [ ] User reviewed and approved changes
- [ ] Zero functional changes (just consistency)
- [ ] **TODO patterns standardized across 9 commands**

