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
- Create bug spec in `.junior/bugs/bug-N-name/`
- TDD workflow: write failing test → fix → verify test passes
- Track bug stories and implementation tasks
- Link to related features/code areas

**Out of Scope:**
- Bug tracking systems integration (Jira, GitHub Issues, etc.)
- Bug prioritization or triage workflows
- Performance profiling or debugging tools
- Root cause analysis frameworks

## Acceptance Criteria

- [ ] Given bug discovered, when `/bugfix` runs, then captures description and reproduction steps
- [ ] Given bug captured, when spec created, then stored in `.junior/bugs/bug-N-name/`
- [ ] Given bug spec, when implementing, then follows TDD (failing test first)
- [ ] Given fix implemented, when complete, then test passes and bug verified
- [ ] Given bug closed, when reviewing, then reproduction steps documented for future reference
- [ ] Given git state, when starting bugfix, then checks for uncommitted changes (like /feature)

## Implementation Tasks

- [ ] 10.1 Research `reference-impl/cursor/commands/fix-bug.md` for bug-specific workflow patterns
- [ ] 10.2 Run `/new-command` with prompt: "Create bugfix command for bug-specific workflow with reproduction steps and verification. Clarification asks: bug description, exact reproduction steps, expected vs actual behavior, affected codebase area. Generates bug spec in `.junior/bugs/bug-N-name/` with bug.md and user-stories/. Emphasizes TDD workflow: write failing test that reproduces bug, implement fix, verify test passes and no regressions. Includes verification checklist. Implements feat-1-story-10."
- [ ] 10.3 User review: Document real or hypothetical bug, verify reproduction steps template
- [ ] 10.4 Test bug spec generation and structure
- [ ] 10.5 Verify TDD workflow emphasis is clear
- [ ] 10.6 Refine verification checklist based on completeness
- [ ] 10.7 Finalize: Test complete workflow with real bug scenario

## Technical Notes

**Bug Directory Structure:**
```
.junior/bugs/bug-N-name/
├── bug.md                 # Main bug specification
└── user-stories/          # Implementation tasks
    ├── README.md          # Progress tracking
    └── bug-N-story-M-name.md
```

**Bug Clarification Questions:**
1. "What's the bug in one sentence?"
2. "What are the exact steps to reproduce it?"
3. "What do you expect to happen?"
4. "What actually happens?"
5. "What area of the codebase is affected?"

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

