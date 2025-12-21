# Story 14: Add Validation Patterns (Command-Type Specific)

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Command-type specific validation patterns added

## Developer Story

**As a** maintainer of Junior commands
**I want** validation patterns tailored to command types
**So that** AI verifies completion correctly per command type (code vs docs vs meta)

## Current State

**What's wrong:**
- Commands say "100% test pass rate" but no checklist to verify
- No systematic validation before completion
- **Validation needs differ by command type:**
  - `/implement` needs test validation (code projects)
  - `/commit` needs documentation sync validation
  - `/status` needs completeness validation
  - Different validations for code vs docs projects
- One-size-fits-all doesn't work

## Target State

**What improved code looks like:**
- Shared validation patterns: `.cursor/commands/_shared/validation-patterns.md` (Mode A)
- **Command-type specific** validation sections:
  - **Implementation commands** (`/implement`, `/feature`): Test validation, code quality
  - **Commit commands** (`/commit`): Documentation sync, file grouping validation
  - **Meta commands** (`/status`, `/maintenance`): Completeness, consistency checks
- **Project-type specific** validations:
  - Code projects: Test pass rate, type checking, linting
  - Doc projects: Completeness, formatting, cross-references
- Clear "If ANY item fails, STOP and fix" guidance

## Scope

**In Scope:**
- Create `.cursor/commands/_shared/validation-patterns.md` (Mode A)
- Define validation patterns by command type:
  - **Implementation validation** (for `/implement`, `/feature`)
  - **Commit validation** (for `/commit`)
  - **Meta validation** (for `/status`, `/maintenance`, etc.)
- Add command-type specific validation sections to commands
- Project-type branching (code vs docs validation)

**Out of Scope:**
- Changing validation logic (just organizing patterns)
- Automated validation tools (manual only)
- One-size-fits-all validation (doesn't work)

## Acceptance Criteria

- [ ] Given validation pattern, when extracted, then `.cursor/commands/_shared/validation-checklist.md` exists
- [ ] Given 9 commands, when updated, then all have "Final Validation Checklist" section
- [ ] Given checklists, when reviewed, then all follow standard format
- [ ] Given validation items, when checked, then include grep checks, test verification, documentation sync

## Implementation Tasks

- [ ] 14.1 Create `validation-checklist.md` with standard pattern (Mode A)
- [ ] 14.2 Update `feature.md` - add validation checklist
- [ ] 14.3 Update `implement.md` - add validation checklist
- [ ] 14.4 Update `commit.md` - add validation checklist
- [ ] 14.5 Update `status.md` - add validation checklist
- [ ] 14.6 Update `maintenance.md` - add validation checklist
- [ ] 14.7 Update `debug.md` - add validation checklist
- [ ] 14.8 Update `refactor.md` - add validation checklist
- [ ] 14.9 Update `migrate.md` - add validation checklist
- [ ] 14.10 Update `new-command.md` - add validation checklist
- [ ] 14.11 User review

## Verification Checklist

- [ ] Shared module exists
- [ ] All 9 commands have validation sections
- [ ] Standard format followed
- [ ] Command-specific items added where needed
- [ ] User reviewed

## Technical Notes

**Shared module (.cursor/commands/_shared/validation-patterns.md):**
```markdown
# Validation Patterns (AI Internal - Mode A)

## Implementation Validation (for /implement, /feature)

**Code projects:**
- [ ] All tests pass (100% pass rate)
- [ ] Type checking clean (mypy/tsc)
- [ ] Linting clean
- [ ] No uncommitted debug code

**Doc projects:**
- [ ] All sections complete
- [ ] Cross-references valid
- [ ] Formatting consistent
- [ ] Examples work

## Commit Validation (for /commit)

- [ ] Documentation synced with code changes
- [ ] Feature/story files updated
- [ ] File grouping correct
- [ ] No WIP commits

## Meta Validation (for /status, /maintenance)

- [ ] All items reviewed
- [ ] Completeness verified
- [ ] Consistency checked
- [ ] Next actions identified

## Usage
Commands reference appropriate validation pattern.
**If ANY item fails, STOP and fix before proceeding.**
```

**In commands:**
```markdown
### Final Validation

**For implementation:** Use implementation validation from `_shared/validation-patterns.md`.
**For commits:** Use commit validation from `_shared/validation-patterns.md`.
**For meta commands:** Use meta validation from `_shared/validation-patterns.md`.
```

## Definition of Done

- [ ] All tasks completed
- [ ] Shared module created
- [ ] All 9 commands have validation checklists
- [ ] Standard format followed
- [ ] User reviewed
- [ ] **Validation checklists added to all commands**

