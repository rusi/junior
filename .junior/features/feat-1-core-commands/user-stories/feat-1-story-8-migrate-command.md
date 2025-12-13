# Story 8: Implement /migrate Command

> **Status:** Completed
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
- Handle both Code Captain versions (spec-N-name AND date-prefixed patterns)
- Rename `.code-captain/` → `.junior/` OR merge into existing `.junior/`
- Rename `spec-N-name` → `feat-N-name` for features
- Keep `exp-N-name` unchanged for experiments
- Update all internal references and cross-links
- Preserve git history and all completed work
- Generate migration report showing what changed
- Continue migration on validation failures with post-migration fix list
- Update installation script to cleanup Code Captain files (rules, commands, docs)

**Out of Scope:**
- Migrating from other systems (only Code Captain)
- Content transformation (only renaming and restructuring)
- Backup mechanisms (git provides version control)
- Automatic conflict resolution for merge scenarios (user reviews)

## Acceptance Criteria

- ✅ Given Code Captain project, when `/migrate` runs, then `.code-captain/` becomes `.junior/`
- ✅ Given specifications exist, when migration runs, then `spec-N-name` becomes `feat-N-name`
- ✅ Given experiments exist, when migration runs, then `exp-N-name` stays unchanged
- ✅ Given cross-references in docs, when migration runs, then all links updated correctly
- ✅ Given completed tasks, when migration runs, then all progress preserved
- ✅ Given migration completes, when user runs `/status`, then all work shows correctly

## Implementation Tasks

- ✅ 8.1 Research `reference-impl/cursor/docs/migration-guide.md` for migration patterns and scripts
- ✅ 8.2 Create migrate.md command file (initial version)
- ✅ 8.3 Update migrate.md to handle both Code Captain versions (spec-N-name and date-prefixed)
- ✅ 8.4 Update migrate.md to handle merge scenario (both .junior and .code-captain exist)
- ✅ 8.5 Update migrate.md to continue on validation failures with post-migration fix list
- ✅ 8.6 Remove all backup references (git provides version control)
- ✅ 8.7 Update installation script to cleanup Code Captain files (rules, commands, docs)
- ✅ 8.8 Test migration command with different scenarios
- ✅ 8.9 Finalize: Verify all features work end-to-end

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

- ✅ All tasks completed
- ✅ All acceptance criteria met
- ✅ Command works end-to-end (no stubs/mocks)
- ✅ All tests passing (unit + integration + end-to-end)
- ✅ No regressions in existing commands
- ✅ Code follows Junior's principles (simple, TDD, vertical slice)
- ✅ Documentation updated
- ✅ **User can migrate Code Captain project and continue working**
- ✅ Migration tested and verified

