# Improvement 1: Command & Rule Structure Refactoring

> **Created:** 2025-12-21
> **Status:** In Progress
> **Type:** Systematic

## Contract

**Improvement:** Systematic refactoring of Junior commands and rules based on comprehensive assessment

**Type:** Systematic (DRY, consistency, maintainability, discoverability)

**Motivation:**
- **Assessment finding:** 85% excellent → 98% perfect with these fixes
- **Maintainability:** Eliminate redundancy, standardize structure, manageable file sizes
- **Consistency:** Uniform command structure, standardized patterns
- **Discoverability:** Cross-references, validation checklists, help system
- **Impact:** Easier to maintain, extend, and use Junior effectively

**Scope:**
- ✅ **Critical Issues (ALL 4):**
  1. Extract shared command modules (DRY violations)
  2. Standardize command structure (consistent template)
  3. Break long commands into submodules (maintainability)
  4. Add rule cross-references (eliminate duplication)

- ✅ **Moderate Issues (ALL 4):**
  5. Add validation checklists to commands
  6. Standardize TODO tracking (5-7 TODOs per command)
  7. Create `/help` command
  8. Make patterns function-based (covered in #1)

- ✅ **Reference Documentation:**
  - Include assessment as reference in improvement

- ❌ **Excluded (Future Improvements):**
  - Quick reference cards (separate enhancement)
  - Command execution metrics (separate enhancement)
  - Error recovery patterns (separate enhancement)

**Behavior Guarantee:** Zero functional changes - commands work identically, just better organized

**Risk Assessment:**
- **Risk Level:** Medium
- **What could break:** Commands might reference wrong modules, miss updates, or have inconsistent structure
- **Mitigation:**
  - Each story is vertical (complete one aspect end-to-end)
  - Grep verification ensures all references updated
  - Manual testing after each story
  - Easy to review (clear before/after per story)

**Testing Strategy:**
- **Per story:** User review and refinement of changes
- **Final validation:** Install Junior on real project and use all commands
- **No automated testing:** Manual verification only

**Mode A/B/C Guide:**
- **Mode A (AI → AI):** Shared modules, command instructions, detection logic, process flows - concise triggers and references
- **Mode B (AI + User):** Story specifications, contracts, technical decisions - enough context for both
- **Mode C (User only):** Contract presentations, clarification questions, summaries, help output - full explanations

## Architecture

### Current State (Problems)

**DRY Violations:**
- Stage detection logic repeated in 5 commands
- Clarification loop patterns repeated in 4 commands
- Git status checking repeated in 3 commands
- TODO patterns inconsistent across 9 commands
- Template structures duplicated in 3 commands

**Inconsistency:**
- Command structure varies (7 steps vs 15 steps)
- TODO granularity inconsistent (7 TODOs vs 12 TODOs)
- No standard template for commands

**Maintainability:**
- feature.md: 1200 lines
- implement.md: 880 lines
- commit.md: 783 lines
- migrate.md: 1197 lines
- Hard to navigate and update

**Discoverability:**
- No help system (can't list commands)
- Rules don't cross-reference each other
- Missing validation checklists

### Target State (Solution)

**DRY Enforcement:**
```
.cursor/commands/
├── _shared/
│   ├── git-status-check.md         # Used by 3 commands
│   ├── stage-detection.md          # Used by 5 commands
│   ├── clarification-loop.md       # Used by 4 commands
│   ├── todo-patterns.md            # Used by 9 commands
│   ├── template-structures.md      # Used by 3 commands
│   ├── command-template.md         # Standard for all commands
│   └── validation-checklist.md     # Used by 9 commands
```

**Modular Commands:**
```
.cursor/commands/
├── feature/
│   ├── feature.md (300 lines, main)
│   ├── clarification.md
│   ├── contract.md
│   ├── generation.md
│   └── templates/
├── implement/
│   ├── implement.md (300 lines, main)
│   ├── tdd-workflow.md
│   ├── story-discovery.md
│   └── progress-tracking.md
└── commit/
    ├── commit.md (300 lines, main)
    ├── doc-update.md
    ├── grouping-detection.md
    └── message-generation.md
```

**Rule Cross-References:**
- Dependency declarations in frontmatter
- "See also" sections
- Clear boundaries between rules

**Help System:**
- `/help` command listing all commands
- Categorized by purpose
- Quick reference for users

## Approach

**Strategy:** True vertical slicing
- Extract ONE pattern → Update ALL commands using it
- Not: Extract from one command, then another command
- Each story delivers complete value (one pattern fully DRY'd)

**Story Breakdown Rationale:**
- **Phase 1 (Stories 1-5):** Extract shared modules - DRY enforcement
- **Phase 2 (Stories 6-7):** Standardize command structure - consistency
- **Phase 3 (Stories 8-10):** Break long commands - maintainability
- **Phase 4 (Stories 11-13):** Add rule cross-references - discoverability
- **Phase 5 (Stories 14-15):** Validation & help - completeness
- **Phase 6 (Stories 16-17):** Documentation - reference materials

**Dependencies:**
- Most stories are independent (can be done in any order within phase)
- Phase 1 should complete before Phase 2 (shared modules referenced by standardization)
- Phase 2 should complete before Phase 3 (modularized commands follow standard structure)

**Rollback Strategy:**
- Each story is independently committable
- Can revert any story without affecting others
- Git history provides clear before/after for each pattern

## Technical Notes

### Stage Detection vs Transition Logic

**Critical distinction:**
- **Stage detection** (shared module): Determine current stage (1, 2, or 3)
- **Transition logic** (maintenance command): Reorganize Stage 1→2, Stage 2→3

Shared module ONLY contains detection, NOT reorganization.

### Mode A/B/C Application

**Mode A (AI instructions):**
- Shared modules (concise triggers)
- Command process flows
- Detection logic
- Cross-references

**Mode B (AI + User review):**
- Story specifications
- Technical decisions
- Template structures
- Contracts

**Mode C (User-facing):**
- Contract presentations
- Clarification questions
- Help command output
- Summaries

### File Size Targets

- Main command files: ~300 lines max
- Shared modules: 50-150 lines
- Submodules: 100-300 lines
- Total reduction: ~2000 lines reorganized

## Risks & Mitigation

**Risk 1: Missing a reference during extraction**
- Mitigation: Grep verification after each story
- Check pattern: `grep -r "old pattern" .cursor/commands/`
- Should return 0 results (only shared module reference)

**Risk 2: Commands don't work after refactoring**
- Mitigation: Manual testing after each story
- User reviews changes before proceeding
- Each story is small and reviewable

**Risk 3: Inconsistent Mode A/B/C application**
- Mitigation: Clear guidelines in contract
- Review each file's purpose
- AI instructions = Mode A, User-facing = Mode C

**Risk 4: Breaking command references during modularization**
- Mitigation: Test commands after Phase 3
- Verify submodule references work
- Keep original structure until verified

## Future Improvements

Captured in: `user-stories/imp-1-story-future-improvements.md` (not numbered, sorts last)

**Deferred to future:**
- Quick reference cards (`.cursor/quick-reference/`)
- Command execution metrics (performance targets per step)
- Error recovery patterns (resume from failed step)
- Command decision tree (which command to use when)
- Vertical slice checklist
- Evidence-based debugging quick guide

**Why deferred:** These are enhancements that add value but aren't critical to fixing the 8 identified issues. They can be implemented later once the foundation is solid.

## Success Criteria

- [ ] All 17 stories completed
- [ ] Zero grep matches for old patterns (DRY verified)
- [ ] All commands follow standard template (consistency verified)
- [ ] Long commands split into <300 line main files (maintainability verified)
- [ ] All rules have cross-references (discoverability verified)
- [ ] `/help` command works (help system verified)
- [ ] Junior installed on real project and all commands tested (regression verified)

**Measurable improvements:**
- Redundancy: ~40% reduction (5 shared modules eliminate duplication)
- File sizes: ~70% reduction for long commands (1200 → 300 lines)
- Consistency: 100% commands follow template (9/9)
- Discoverability: 100% rules cross-referenced (9/9)

