# Story 11: Implement /enhancement Command

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** Story 10 (similar pattern to /bugfix)
> **Deliverable:** Fully working enhancement workflow for small improvements without full feature ceremony

## User Story

**As a** developer making small improvements
**I want** a lightweight workflow for enhancements that doesn't require full feature planning
**So that** quick wins and polish work can be implemented efficiently

## Scope

**In Scope:**
- Create enhancement.md command file with lightweight workflow
- Capture enhancement description and value
- Create enhancement spec in `.junior/features/feat-N-name/enhancements/enh-M-name/` (nested within parent feature)
- Simpler than features, more structured than ad-hoc changes
- TDD workflow for implementation
- Track enhancement stories and tasks (optional for small enhancements)

**Out of Scope:**
- Large features (use `/feature` instead)
- Bug fixes (use `/bugfix` instead)
- Experiments or research (use `/experiment` or `/research`)
- Product strategy changes (use `/init` or update product docs)

## Acceptance Criteria

- [ ] Given small improvement, when `/enhancement` runs, then prompts for parent feature selection
- [ ] Given parent feature selected, when enhancement captured, then stored in `.junior/features/feat-N-name/enhancements/enh-M-name/`
- [ ] Given enhancement spec created, when reviewing structure, then nested under correct parent feature
- [ ] Given enhancement scope, when too large, then suggests using `/feature` instead
- [ ] Given enhancement spec, when implementing, then follows TDD workflow
- [ ] Given enhancement complete, when reviewing, then improves user experience measurably
- [ ] Given git state, when starting enhancement, then checks for uncommitted changes

## Implementation Tasks

- [ ] 11.1 Research `reference-impl/cursor/commands/enhancement.md` for lightweight improvement patterns
- [ ] 11.2 Run `/new-command` with prompt: "Create enhancement command for small improvements without full feature ceremony. Quick clarification: which feature does this enhancement belong to, description, value, scope type (UI/UX, performance, refactor, docs, config, API). Generates enhancement spec in `.junior/features/feat-N-name/enhancements/enh-M-name/` (nested within parent feature) with enh-M-overview.md. Includes scope detection: suggests `/feature` if too large, suggests `/refactor` if not user-facing. Good for polish work, small optimizations, and quick wins. Implements feat-1-story-11."
- [ ] 11.3 User review: Create small enhancement (UI polish), verify parent feature selection and nested structure
- [ ] 11.4 Test scope detection (create large enhancement, verify suggests `/feature`; create non-user-facing, verify suggests `/refactor`)
- [ ] 11.5 Refine criteria for enhancement vs feature vs improvement distinction
- [ ] 11.6 Finalize: Verify workflow is faster than full `/feature`

## Technical Notes

**Enhancement Directory Structure (Nested in Features):**
```
.junior/features/feat-N-name/enhancements/enh-M-name/
└── enh-M-overview.md      # Enhancement description, value, scope
```

**Key changes from previous structure:**
- Enhancements now nest **within their parent feature** (not top-level `.junior/enhancements/`)
- Numbering: `enh-1-name`, `enh-2-name` (sequential within each feature)
- Path example: `.junior/features/feat-3-admin-panel/enhancements/enh-1-ui-polish/`
- Enhancement belongs to the feature it improves - better organization and context
- No user-stories/ for most enhancements (they're small, single-task improvements)

**Scope Guidelines:**
- **Use `/enhancement` for (user-facing improvements to existing features):**
  - UI polish and small UX improvements
  - Performance optimizations (single component, user-visible)
  - Documentation improvements
  - Configuration changes (user-facing settings)
  - Small API additions (user-visible endpoints)

- **Use `/feature` instead for:**
  - New user-facing capabilities
  - Multi-component changes
  - Architectural changes
  - Integration with external systems
  - Changes requiring multiple stories

- **Use `/refactor` instead for (non-user-facing improvements):**
  - Code refactoring (limited scope, no behavior change)
  - Internal performance optimizations
  - Technical debt reduction
  - Code quality improvements
  - Library migrations

**Quick Clarification Questions:**
1. "Which feature does this enhancement belong to?" (Select from existing features)
2. "What's the enhancement in one sentence?"
3. "What value does this add for users?" (if not user-facing, suggest `/refactor` instead)
4. "What's the scope? (UI/UX, performance, docs, config, API)"

**Enhancement Contract Format:**
```
## Enhancement Contract

**Enhancement:** [One sentence description]
**Type:** [UI/UX | Performance | Refactor | Docs | Config | API]
**Value:** [What improves and for whom]
**Scope:** [What changes, estimated effort]
**Success:** [How to verify improvement]
```

See [../feature.md](../feature.md) for overall feature context.

## Testing Strategy

**TDD Approach:**
- Write tests first (red)
- Implement to pass tests (green)
- Refactor (clean)

**Unit Tests:**
- Enhancement contract generation
- Scope classification
- Scope validation (detect when too large)

**Integration Tests:**
- Complete enhancement workflow
- Enhancement spec creation
- Suggest `/feature` when appropriate

**Manual Testing:**
- Capture small UI improvement
- Capture performance optimization
- Try large enhancement (verify suggests /feature)
- Complete enhancement end-to-end

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Command works end-to-end (no stubs/mocks)
- [ ] All tests passing (unit + integration + end-to-end)
- [ ] No regressions in existing commands
- [ ] Code follows Junior's principles (simple, TDD, vertical slice)
- [ ] Documentation updated
- [ ] **User can implement small improvements efficiently**
- [ ] Scope detection prevents misuse (suggests /feature when needed)
- [ ] Enhancement specs searchable for tracking polish work

