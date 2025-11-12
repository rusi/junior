# Story 8: Implement /migrate Command

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None
> **Deliverable:** Fully working migration command that converts Code Captain projects to Junior

## User Story

**As a** Code Captain user
**I want** to migrate my existing project to Junior
**So that** I can use Junior's features without losing my existing work

## Scope

**In Scope:**
- Create migrate.md command file with complete migration workflow
- Detect Code Captain installation (`.code-captain/` directory)
- Rename `.code-captain/` → `.junior/` preserving all content
- Rename `spec-N-name` → `feat-N-name` for features
- Keep `exp-N-name` unchanged for experiments
- Update all internal references and cross-links
- Preserve git history and all completed work
- Generate migration report showing what changed

**Out of Scope:**
- Migrating from other systems (only Code Captain)
- Content transformation (only renaming and restructuring)
- Backup/rollback mechanisms (git provides this)

## Acceptance Criteria

- [ ] Given Code Captain project, when `/migrate` runs, then `.code-captain/` becomes `.junior/`
- [ ] Given specifications exist, when migration runs, then `spec-N-name` becomes `feat-N-name`
- [ ] Given experiments exist, when migration runs, then `exp-N-name` stays unchanged
- [ ] Given cross-references in docs, when migration runs, then all links updated correctly
- [ ] Given completed tasks, when migration runs, then all progress preserved
- [ ] Given migration completes, when user runs `/status`, then all work shows correctly

## Implementation Tasks

- [ ] 8.1 Research `reference-impl/cursor/docs/migration-guide.md` for migration patterns and scripts
- [ ] 8.2 Run `/new-command` with prompt: "Create migrate command that converts Code Captain projects to Junior structure. Detects `.code-captain/` directory, renames to `.junior/`, renames `spec-N-name` to `feat-N-name` (keeps `exp-N-name` unchanged), updates all internal cross-references in markdown files, preserves git history using `git mv`, generates migration report. Uses git commands for safe renaming. Implements feat-1-story-8."
- [ ] 8.3 User review: Test on sample Code Captain project (or create test fixture)
- [ ] 8.4 Verify all cross-references updated correctly
- [ ] 8.5 Verify git history preserved
- [ ] 8.6 Refine migration report format
- [ ] 8.7 Finalize: Test on real Code Captain project if available

## Technical Notes

**Migration Strategy:**
- Use git mv for directory renaming (preserves history)
- Parse all .md files for references to update
- Maintain file modification timestamps where possible
- Generate detailed log of all changes

**Detection Logic:**
- Check for `.code-captain/` directory
- Verify structure matches Code Captain pattern
- Warn if already migrated

**Reference Updating:**
- Update markdown links: `spec-N-` → `feat-N-`
- Update directory references: `.code-captain/` → `.junior/`
- Preserve `exp-N-` references unchanged
- Update README.md if it references old structure

See [../feature.md](../feature.md) for overall feature context.

## Testing Strategy

**TDD Approach:**
- Write tests first (red)
- Implement to pass tests (green)
- Refactor (clean)

**Unit Tests:** 
- Detection logic (finds Code Captain projects)
- Renaming patterns (spec→feat transformation)
- Reference parsing and updating

**Integration Tests:** 
- Complete migration on test Code Captain project
- Verify all files renamed correctly
- Verify all references updated
- Verify work progress preserved

**Manual Testing:** 
- Run on sample Code Captain project
- Verify `/status` shows correct structure after migration
- Check git history preserved

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Command works end-to-end (no stubs/mocks)
- [ ] All tests passing (unit + integration + end-to-end)
- [ ] No regressions in existing commands
- [ ] Code follows Junior's principles (simple, TDD, vertical slice)
- [ ] Documentation updated
- [ ] **User can migrate Code Captain project and continue working**
- [ ] Migration tested and verified

