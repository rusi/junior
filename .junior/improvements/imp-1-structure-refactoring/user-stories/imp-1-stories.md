# Improvement 1: Command & Rule Structure Refactoring - Stories

> **Progress:** 0/18 stories completed
> **Status:** Not Started

## Story List

### Phase 1: Extract Shared Modules (DRY Enforcement)

- [ ] [Story 1: Extract Git Status Check Pattern](imp-1-story-1-git-status-check.md) - Shared module, update 3 commands
- [ ] [Story 2: Extract Stage Detection Pattern](imp-1-story-2-stage-detection.md) - Shared module, update 5 commands
- [ ] [Story 3: Extract Clarification Loop Pattern](imp-1-story-3-clarification-loop.md) - Shared module, update 4 commands **(CRITICAL: ONE question at a time)**
- [ ] [Story 4: Extract TODO & Progress Tracking Patterns](imp-1-story-4-todo-progress.md) - Shared module, standardize 9 commands
- [ ] [Story 5a: Extract Feature Command Templates](imp-1-story-5a-feature-templates.md) - feature/templates/, update feature.md
- [ ] [Story 5b: Extract Debug Command Templates](imp-1-story-5b-debug-templates.md) - debug/templates/, update debug.md
- [ ] [Story 5c: Extract Refactor Command Templates](imp-1-story-5c-refactor-templates.md) - refactor/templates/, update refactor.md

### Phase 2: Command Structure Standardization

- [ ] [Story 6: Create Command Structure Template](imp-1-story-6-command-template.md) - Standard template (integrate with /new-command)
- [ ] [Story 7: Apply Standard Structure to ALL Commands](imp-1-story-7-standardize-all-commands.md) - Update 9 commands

### Phase 3: Break Long Commands into Submodules

- [ ] [Story 8: Modularize feature.md](imp-1-story-8-modularize-feature.md) - 1200→300 lines (keep feature.md at top, use feature/ submodules)
- [ ] [Story 9: Modularize implement.md](imp-1-story-9-modularize-implement.md) - 880→300 lines (add TDD vs non-TDD branch)
- [ ] [Story 10: Modularize commit.md](imp-1-story-10-modularize-commit.md) - 783→300 lines

### Phase 4: Rule Cross-References

- [ ] [Story 11: Add Cross-References to Core Rules](imp-1-story-11-core-rules-xref.md) - Update 3 core rules
- [ ] [Story 12: Add Cross-References to Implementation Rules](imp-1-story-12-impl-rules-xref.md) - Update 4 implementation rules
- [ ] [Story 13: Add Cross-References to Remaining Rules](imp-1-story-13-remaining-rules-xref.md) - Update 2 remaining rules

### Phase 5: Validation & Discovery

- [ ] [Story 14: Add Validation Patterns (Command-Type Specific)](imp-1-story-14-validation-patterns.md) - Different validations per command type
- [ ] [Story 15: Create /help Command](imp-1-story-15-help-command.md) - New help command

### Phase 6: Final Assessment

- [ ] [Story 16: Re-assess All Commands for Consistency](imp-1-story-16-final-assessment.md) - Complete review, measure improvements

**Future Improvements:** See [imp-1-story-future-improvements.md](imp-1-story-future-improvements.md) (not numbered, sorts last)

## Dependencies

**Phase dependencies:**
- Phase 1 (Stories 1-5c): Independent, can be done in any order
- Phase 2 (Stories 6-7): Should complete after Phase 1 (references shared modules)
- Phase 3 (Stories 8-10): Should complete after Phase 2 (follows standard structure)
- Phase 4 (Stories 11-13): Independent, can be done in parallel with other phases
- Phase 5 (Stories 14-15): Independent
- Phase 6 (Story 16): Final assessment after all others

**Story dependencies within phases:**
- Story 6 must complete before Story 7 (template definition before application)
- Stories 5a, 5b, 5c are independent (can be done in any order)
- All others are independent within their phase

## Completion Criteria

- [ ] All stories completed (18 stories total)
- [ ] Zero grep matches for old patterns (DRY verified)
- [ ] All commands follow standard template (9/9)
- [ ] Long commands <300 lines main file (3/3)
- [ ] All rules cross-referenced (9/9)
- [ ] `/help` command works
- [ ] Final re-assessment complete

## Testing Strategy

**Per story:**
- User reviews changes (before/after comparison)
- Grep verification for pattern elimination
- Manual command testing if applicable

**Final validation:**
- Install Junior on real project
- Execute all commands
- Verify zero functional changes
- Confirm improved maintainability

