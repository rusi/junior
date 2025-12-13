# Story 10: Implement /bugfix Command

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** Story 2 (follows /implement patterns)
> **Deliverable:** Fully working bug-specific workflow with reproduction steps and verification

## User Story

**As a** developer fixing a bug
**I want** a streamlined workflow that captures reproduction steps and ensures the fix works
**So that** bugs are properly documented and don't regress

## Scope

**In Scope:**
- Create bugfix.md command file with bug-specific workflow
- Capture bug description and reproduction steps
- Create bug spec in `.junior/features/feat-N-name/bugs/bug-M-name/` (nested within parent feature)
- TDD workflow: write failing test → fix → verify test passes
- Track bug stories and implementation tasks
- Link to parent feature and related code areas

**Out of Scope:**
- Bug tracking systems integration (Jira, GitHub Issues, etc.)
- Bug prioritization or triage workflows
- Performance profiling or debugging tools
- Root cause analysis frameworks

## Acceptance Criteria

- [ ] Given bug discovered, when `/bugfix` runs, then prompts for parent feature selection
- [ ] Given parent feature selected, when bug captured, then stored in `.junior/features/feat-N-name/bugs/bug-M-name/`
- [ ] Given bug spec created, when reviewing structure, then nested under correct parent feature
- [ ] Given bug spec, when implementing, then follows TDD (failing test first)
- [ ] Given fix implemented, when complete, then test passes and bug verified
- [ ] Given bug closed, when reviewing, then reproduction steps documented for future reference
- [ ] Given git state, when starting bugfix, then checks for uncommitted changes (like /feature)

## Implementation Tasks

- [ ] 10.1 Research `reference-impl/cursor/commands/fix-bug.md` for bug-specific workflow patterns
- [ ] 10.2 Run `/new-command` with prompt: "Create bugfix command for bug-specific workflow with reproduction steps and verification. Clarification asks: which feature does this bug belong to, bug description, exact reproduction steps, expected vs actual behavior, affected codebase area. Generates bug spec in `.junior/features/feat-N-name/bugs/bug-M-name/` (nested within parent feature) with bug-M-overview.md and bug-M-resolution.md. Emphasizes TDD workflow: write failing test that reproduces bug, implement fix, verify test passes and no regressions. Includes verification checklist. Implements feat-1-story-10."
- [ ] 10.3 User review: Document real or hypothetical bug, verify parent feature selection and nested structure
- [ ] 10.4 Test bug spec generation and nested directory structure
- [ ] 10.5 Verify TDD workflow emphasis is clear
- [ ] 10.6 Refine verification checklist based on completeness
- [ ] 10.7 Finalize: Test complete workflow with real bug scenario

## Technical Notes

**Bug Directory Structure (Nested in Features):**
```
.junior/features/feat-N-name/bugs/bug-M-name/
├── bug-M-overview.md      # Bug description, reproduction steps, expected vs actual
└── bug-M-resolution.md    # Root cause, fix approach, verification (created after fix)
```

**Key changes from previous structure:**
- Bugs now nest **within their parent feature** (not top-level `.junior/bugs/`)
- Numbering: `bug-1-name`, `bug-2-name` (sequential within each feature)
- Path example: `.junior/features/feat-3-admin-panel/bugs/bug-1-login-failure/`
- Bug belongs to the feature it affects - better organization and context

**Bug Clarification Questions:**
1. "Which feature does this bug belong to?" (Select from existing features or create new)
2. "What's the bug in one sentence?"
3. "What are the exact steps to reproduce it?"
4. "What do you expect to happen?"
5. "What actually happens?"
6. "What area of the codebase is affected?"

**TDD Emphasis:**
- Step 1: Write test that reproduces bug (test fails)
- Step 2: Implement fix (test passes)
- Step 3: Verify no regressions (all tests pass)
- Step 4: Document fix in bug.md

**Bug Contract Format:**
```
## Bug Contract

**Bug:** [One sentence description]
**Severity:** [Critical/High/Medium/Low]
**Area:** [Affected component/feature]
**Reproduction:** [Exact steps]
**Expected:** [What should happen]
**Actual:** [What actually happens]
**Related Work:** [Links to related features]
```

See [../feature.md](../feature.md) for overall feature context.

## Testing Strategy

**TDD Approach:**
- Write tests first (red)
- Implement to pass tests (green)
- Refactor (clean)

**Unit Tests:**
- Bug contract generation
- Reproduction step parsing
- Story generation logic

**Integration Tests:**
- Complete bugfix workflow
- Bug spec creation and storage
- Cross-references to affected code

**Manual Testing:**
- Capture real bug with reproduction steps
- Follow TDD workflow
- Verify fix and no regressions
- Check documentation completeness

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Command works end-to-end (no stubs/mocks)
- [ ] All tests passing (unit + integration + end-to-end)
- [ ] No regressions in existing commands
- [ ] Code follows Junior's principles (simple, TDD, vertical slice)
- [ ] Documentation updated
- [ ] **User can capture and fix bugs with proper documentation**
- [ ] TDD workflow enforced (test → fix → verify)
- [ ] Bug specs searchable for future reference

