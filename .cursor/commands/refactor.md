# Refactor

## Purpose

Intelligent code quality improvements with adaptive workflow and guardian routing. Systematically improve architecture, reduce tech debt, optimize performance, and handle library migrations.

## Type

Adaptive - Direct execution for simple changes, contract-style for complex refactoring

## When to Use

- Improving code structure without changing behavior
- Reducing technical debt systematically
- Architectural changes (repository pattern, layering, etc.)
- Performance optimization (no behavior change)
- Library migrations and dependency updates
- Systematic code cleanup across multiple files

**NOT for:**
- Adding new capabilities → Use `/feature`
- Fixing broken behavior → Use `/bugfix`
- Small UI polish → Use `/enhancement` (nested in features)

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write`:

```json
{
  "todos": [
    {"id": "clarify", "content": "Clarify refactoring intent & guardian routing", "status": "in_progress"},
    {"id": "assess", "content": "Complexity assessment", "status": "pending"},
    {"id": "execute-or-contract", "content": "Execute directly OR present contract", "status": "pending"},
    {"id": "generate-spec", "content": "[If complex] Generate improvement spec", "status": "pending"}
  ]
}
```

### Step 2: Clarification & Guardian Routing

**CRITICAL: Refactoring improves existing code WITHOUT changing behavior. Features add capabilities. Bugs fix broken behavior.**

**2.1: Ask focused clarifying questions (one at a time):**

- What code are you improving?
- Why is this improvement needed? (maintainability, scalability, performance)
- What specific changes do you want to make?
- Are there any behavior changes involved?
- What scope are we talking about? (specific files, modules, entire layers)

**2.2: Guardian Routing - Detect disguised features/bugs:**

**Feature Detection Patterns:**
- Triggers: "add", "support", "enable", "implement", "create", "new capability"
- Example: "refactor authentication to support OAuth"
- Analysis: "support OAuth" = new capability (feature work)

**If detected:**
```
⚠️ This sounds like a feature, not a refactor.

**Reasoning:** You're adding OAuth support, which is a new capability. Features add user-facing value and require feature specifications with user stories. Refactoring improves existing code without changing behavior.

**I recommend:** Use `/feature` for this work.

Proceed with refactor anyway? [no | yes (veto override)]
```

**Bug Detection Patterns:**
- Triggers: "fix", "broken", "not working", "error", "fails", "doesn't work"
- Example: "refactor login - it's broken"
- Analysis: "broken" = fixing incorrect behavior (bug work)

**If detected:**
```
⚠️ This sounds like a bug, not a refactor.

**Reasoning:** The login function isn't working correctly. Bugs fix broken behavior with reproduction steps and verification. Refactoring improves working code.

**I recommend:** Use `/bugfix` for this work.

Proceed with refactor anyway? [no | yes (veto override)]
```

**User Veto Override:**

If user insists with "yes":
```
⚠️ I disagree, but proceeding with refactor as requested.

[Continue with refactor workflow]
[Add note in contract: "⚠️ User classified as refactor, may have feature/bug characteristics"]
```

**2.3: Continue clarification until 95% clear**

Ask follow-up questions until you understand:
- Exact scope (files, modules, layers)
- Specific improvements to make
- Why this matters (benefits)
- Any risks or concerns

### Step 3: Complexity Assessment

**CRITICAL: Data-driven decision, not guesswork.**

**3.1: Analyze scope using codebase tools:**

Use `codebase_search` and `grep` to gather:

1. **Files affected:** Count and list all files needing modification
2. **Dependencies impacted:** Analyze imports, cross-references, usage patterns
3. **Risk level:** Assess criticality based on code's role in the system
   - High risk: Critical business logic, core system functionality
   - Medium risk: Important but isolated components
   - Low risk: Utilities, helpers, peripheral code
4. **Change magnitude:** Estimate effort
   - Minor: Rename/extract, small tweaks
   - Moderate: Restructuring, pattern changes
   - Major: Architectural changes, large-scale refactoring

**3.2: Present assessment:**

```
📊 Complexity Assessment

**Files affected:** {N} files
[List specific files]

**Dependencies:** {M} modules/components need updates
[List import changes, cross-references]

**Risk level:** [Low | Medium | High]
[Explain why - what could break]

**Change magnitude:** [Minor | Moderate | Major]
[Explain effort required]

**Estimated complexity:** {X} story points
[List story breakdown if medium/large]

**Recommendation:** [Direct execution | Create improvement spec]

**Reasoning:**
[1-2 sentences explaining why this recommendation makes sense]

Proceed with recommendation? [yes | no, [execute-directly | create-spec]]
```

**Decision Thresholds:**
- **Small (direct execution):** 1-3 files, low-medium risk, minor changes
- **Medium (spec with stories):** 4-10 files, medium risk, moderate restructuring
- **Large (spec with stories):** 10+ files, high risk, major architectural changes

**User can override:** Accept either choice regardless of recommendation.

### Step 4A: Direct Execution (Small Scope)

**CRITICAL: No `.junior/` files created. Git log is history.**

**4A.1: Execute refactoring immediately:**

- Use `read_file` to understand current code
- Use `search_replace` to make improvements
- Keep changes focused and atomic
- Ensure no behavior changes

**4A.2: Verify refactoring:**

- Run tests if available
- Verify syntax is correct
- Check that behavior is unchanged

**4A.3: Present result:**

```
✅ Refactoring complete!

**Files modified:** {N} files
[List files changed]

**Changes made:**
[Brief summary of improvements]

**Next step:** Use `/commit` to commit these changes.
```

**Zero ceremony. Fast completion.**

### Step 4B: Contract & Generation (Medium/Large Scope)

**CRITICAL: Contract-first. Get approval before generating specs.**

**4B.1: Determine improvement number:**

Use `list_dir` to scan `.junior/improvements/` and find next number (`imp-N`).

**4B.2: Present refactoring contract:**

```
## Refactoring Contract

**Improvement:** [One sentence: what code is being improved]

**Type:** [Architectural | Systematic | Tech Debt | Performance | Library Migration]

**Motivation:** [Why this matters: maintainability, scalability, code quality, business impact]

**Scope:**
- ✅ **Included:** [What will be refactored]
- ❌ **Excluded:** [What won't be touched, saved for later]

**Behavior Guarantee:** [Confirm: no user-facing changes, OR specify any changes]

**Risk Assessment:**
- **Risk Level:** [Low | Medium | High]
- **What could break:** [Specific concerns, failure modes]
- **Mitigation:** [How to minimize risk, safeguards]

**Testing Strategy:**
- **Regression prevention:** [How to ensure no behavior changes]
- **Test approach:** [Unit, integration, manual testing plan]

**Stories Preview (vertical slices):**
- **Story 1:** [Minimal working improvement, end-to-end]
- **Story 2:** [Expand improvement, building on Story 1]
- **Story {N}:** [Continue building incrementally]
- **Story {N+1}:** Future Improvements (out-of-scope items, follow-up work)

**Timeline estimate:** [Rough estimate based on complexity]

---
**Options:** yes | edit: [changes] | suggest-feature | suggest-bug
```

**Wait for user response:**
- **yes** → Generate improvement spec
- **edit: [changes]** → Adjust contract and re-present
- **suggest-feature** → Re-route to `/feature`
- **suggest-bug** → Re-route to `/bugfix`

**4B.3: Generate improvement spec structure:**

Get current date:
```bash
date +"%Y-%m-%d"
```

Create structure:
```
.junior/improvements/imp-{N}-{name}/
├── imp-{N}-overview.md
└── user-stories/
    ├── imp-{N}-stories.md
    ├── imp-{N}-story-*.md (individual stories)
    └── imp-{N}-story-{M+1}-future-improvements.md (final story)
```

**4B.4: Generate `imp-{N}-overview.md`:**

```markdown
# Improvement {N}: [Title]

> **Created:** {YYYY-MM-DD}
> **Status:** In Progress
> **Type:** [Architectural | Systematic | Tech Debt | Performance | Library Migration]

## Contract

[Paste approved contract here - verbatim, locked]

## Architecture

[High-level diagram or description of:
- Current architecture/pattern (what needs improving)
- Target architecture/pattern (what we're moving to)
- Key components affected
- Integration points]

## Approach

[How we'll execute this refactoring:
- Strategy (incremental, big-bang, parallel)
- Story breakdown rationale
- Dependencies between stories
- Rollback strategy if needed]

## Technical Notes

[Implementation details:
- Patterns we're applying
- Code structures being changed
- Testing considerations
- Performance considerations]

## Risks & Mitigation

[Specific risks and how we're addressing them]

## Future Improvements

[Out-of-scope work captured for later:
- Related improvements not in this scope
- Nice-to-haves deferred
- Follow-up refactoring opportunities]

Captured in: `user-stories/imp-{N}-story-{M+1}-future-improvements.md`
```

**4B.5: Generate `user-stories/imp-{N}-stories.md`:**

```markdown
# Improvement {N}: [Title] - Stories

> **Progress:** {completed}/{total} stories completed
> **Status:** [Not Started | In Progress | Completed]

## Story List

- [ ] [Story 1: {title}](imp-{N}-story-1-{name}.md) - {brief description}
- [ ] [Story 2: {title}](imp-{N}-story-2-{name}.md) - {brief description}
- [ ] [Story {M}: {title}](imp-{N}-story-{M}-{name}.md) - {brief description}
- [ ] [Story {M+1}: Future Improvements](imp-{N}-story-{M+1}-future-improvements.md) - Out-of-scope work captured

## Dependencies

[Story dependency graph if complex, otherwise "All stories are independent"]

## Completion Criteria

- [ ] All stories completed and marked done
- [ ] All existing tests pass (no regressions)
- [ ] Code quality metrics improved (measurable)
- [ ] Documentation updated
- [ ] No user-facing behavior changes (unless specified in contract)
```

**4B.6: Generate story files using refactoring template:**

Each story uses this template:

```markdown
# Story {M}: [Title]

> **Status:** Not Started
> **Priority:** [High | Medium | Low]
> **Dependencies:** [None OR Story N]
> **Deliverable:** [Specific code improvement completed, regression-free]

## Developer Story

**As a** developer maintaining {component/module}
**I want** {code improvement}
**So that** {code quality benefit: maintainability, performance, clarity}

## Current State

**What's wrong with current code:**
- [Specific issue or smell]
- [Why it's problematic]
- [Technical debt context]

**Examples:** [Code examples showing current issues]

## Target State

**What improved code looks like:**
- [Desired structure or pattern]
- [Benefits gained]
- [Quality improvements]

**Examples:** [Code examples showing target approach]

## Scope

**In Scope:**
- [Specific files/modules to refactor]
- [Patterns to apply]
- [Improvements to make]

**Out of Scope:**
- [Related improvements saved for later]
- [Areas not touching in this story]

## Acceptance Criteria

- [ ] Given {current state}, when refactoring is applied, then {target state} is achieved
- [ ] Given {existing tests}, when refactoring is complete, then all tests still pass (no regressions)
- [ ] Given {existing functionality}, when code is refactored, then behavior is unchanged

## Implementation Tasks

- [ ] {M}.1 Write/update tests to lock in current behavior (TDD: establish baseline)
- [ ] {M}.2 Refactor {component} to {target pattern}
- [ ] {M}.3 Verify all tests pass (no regressions)
- [ ] {M}.4 Update related documentation
- [ ] {M}.5 Code review for quality and consistency
- [ ] {M}.6 Verify acceptance criteria met

## Regression Prevention

**Strategy:**
- Existing tests must pass before and after refactoring
- Add tests for edge cases if coverage is insufficient
- Manual validation of key user workflows
- Code review focused on behavior preservation

**Validation checklist:**
- [ ] All existing unit tests pass
- [ ] All existing integration tests pass
- [ ] Manual testing of affected features shows no behavior change
- [ ] Performance benchmarks show no degradation (or improvements if performance refactor)

## Rollback Plan

**If issues arise:**
1. Identify what broke (tests, functionality, performance)
2. Attempt quick fix if obvious
3. If not quickly fixable: `git revert [commit]`
4. Document issue in story for future attempt

**Rollback criteria:**
- Test failures that can't be fixed in < 30 minutes
- Unexpected behavior changes discovered
- Performance degradation > 20% (unless expected)

## Technical Notes

[Implementation approach, key decisions, patterns used, architectural considerations]

## Testing Strategy

**TDD Approach:**
- Establish test baseline (lock in current behavior)
- Refactor code
- Verify all tests still pass (green)
- Refactor tests if needed (clean)

**Test Levels:**
- **Unit tests:** [Specific components tested]
- **Integration tests:** [Cross-component interactions verified]
- **Manual testing:** [Key workflows validated]

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Current State → Target State transformation complete
- [ ] All existing tests pass (no regressions)
- [ ] Code quality improved (measurable: complexity, duplication, clarity)
- [ ] Documentation updated
- [ ] Code review completed
- [ ] Manual validation shows no behavior changes
- [ ] **Refactoring delivers measurable code quality improvement with zero behavior change**
```

**4B.7: Generate final story - Future Improvements:**

```markdown
# Story {M+1}: Future Improvements

> **Status:** Not Started
> **Priority:** Low (captured for future)
> **Dependencies:** All previous stories in Improvement {N}
> **Deliverable:** Planning document for future refactoring work

## Purpose

Capture out-of-scope improvements identified during Improvement {N} but deferred to maintain focus.

## Future Refactoring Opportunities

### [Category 1: e.g., Performance Optimization]

**Opportunity:** [Description]
**Benefit:** [Why this would be valuable]
**Effort:** [Rough estimate]
**Priority:** [High | Medium | Low]

### [Category 2: e.g., Additional Pattern Applications]

**Opportunity:** [Description]
**Benefit:** [Why this would be valuable]
**Effort:** [Rough estimate]
**Priority:** [High | Medium | Low]

## Related Work

[Links to other improvements, features, or experiments that relate]

## Notes

[Any additional context or considerations for future work]
```

**4B.8: Present result:**

```
✅ Improvement specification created!

📁 .junior/improvements/imp-{N}-{name}/
   ├── imp-{N}-overview.md
   └── user-stories/
       ├── imp-{N}-stories.md
       ├── imp-{N}-story-1-{name}.md
       ├── imp-{N}-story-2-{name}.md
       └── imp-{N}-story-{M+1}-future-improvements.md

**Next steps:**
1. Use `/commit` to commit this specification
2. Use `/implement imp-{N}-story-1` to start first story
3. Continue with remaining stories incrementally

**Key reminder:** Each story should be end-to-end and leave code in working state.
```

## Examples

### Guardian Routing

**Feature disguised as refactor:**
```
User: /refactor authentication to add OAuth support

Junior: ⚠️ This sounds like a feature, not a refactor.

**Reasoning:** You're adding OAuth support, which is a new capability. Features add
user-facing value and require feature specifications with user stories. Refactoring
improves existing code without changing behavior.

I recommend `/feature` for this work.

Proceed with refactor anyway? [no | yes (veto override)]
```

**Bug disguised as refactor:**
```
User: /refactor login - it's broken

Junior: ⚠️ This sounds like a bug, not a refactor.

**Reasoning:** The login function isn't working correctly. Bugs fix broken behavior
with reproduction steps and verification. Refactoring improves working code.

I recommend `/bugfix` or `/debug` for this work.

Proceed with refactor anyway? [no | yes (veto override)]
```

**Veto override:**
```
User: yes, I want to refactor anyway

Junior: ⚠️ I disagree, but proceeding with refactor as requested.
        [Continues with clarification and notes concern in contract]
```

### Complexity Assessment

**Small scope (direct execution):**
```
📊 Complexity Assessment

**Files affected:** 1 file (src/utils/validators.ts)
**Dependencies:** None
**Risk level:** Low (utility function, good test coverage)
**Change magnitude:** Minor (extract functions)

**Recommendation:** Direct execution

This is a small, isolated change with low risk. Git log will track the history.

Proceed with direct execution? [yes | no, create-spec]
```

**Large scope (create spec):**
```
📊 Complexity Assessment

**Files affected:** 12 files (services, repositories, tests)
**Dependencies:** 3 service modules need major restructuring
**Risk level:** High (core data access patterns)
**Change magnitude:** Major (architectural restructuring)

**Estimated complexity:** 3-4 stories
- Story 1: Repository interfaces + user repository
- Story 2: Refactor user service
- Story 3: Product/order repositories
- Story 4: Remaining services + tests

**Recommendation:** Create improvement spec with stories

Benefits: Vertical slices, comprehensive tests, rollback capability per story.

Proceed with spec creation? [yes | no, execute-directly]
```

### Complete Workflows

**Small refactoring (direct execution):**
```
User: /refactor extract validation helpers from validateUserInput

Junior: [Clarification]
        Which file? src/utils/validators.ts

        [Assessment]
        📊 1 file, low risk, minor changes → Direct execution

        [Execute]
        ✅ Refactoring complete!
        - Extracted validateEmail() and validatePassword()
        - Simplified validateUserInput()

        Next: Use `/commit` to commit changes.
```

**Large refactoring (spec creation):**
```
User: /refactor standardize API error handling with custom error classes

Junior: [Clarification]
        Scope? All API routes

        [Assessment]
        📊 18 files, high risk, major changes → Create spec

        [Contract]
        **Improvement:** Standardize API error handling
        **Type:** Systematic
        **Risk:** High (affects all endpoints)
        **Stories:** 4 stories + future improvements

        Options: yes | edit | suggest-feature | suggest-bug

User: yes

Junior: ✅ Improvement spec created!
        📁 .junior/improvements/imp-1-api-error-handling/

        Next: `/commit` then `/implement imp-1-story-1`
```

## Tool Integration

**Primary tools:**
- `todo_write` - Progress tracking throughout workflow
- `codebase_search` - Find files to refactor, assess scope
- `grep` - Pattern matching, dependency analysis, usage patterns
- `read_file` - Analyze current code structure
- `write` - Create improvement specs and stories
- `search_replace` - Execute direct refactoring (small scope)
- `run_terminal_cmd` - Get current date, run tests if available

**Workflow integration:**
- Use `codebase_search` for scope discovery during clarification
- Use `grep` for dependency analysis during complexity assessment
- Use `read_file` for understanding current state
- Use `write` for generating improvement specs
- Use `search_replace` for direct execution of small refactorings

## Key Principles

1. **Guardian routing is assertive** - Strongly recommend correct command with reasoning, but allow veto
2. **Data-driven complexity assessment** - Use actual file counts and dependency analysis, not guesswork
3. **Adaptive workflow** - Small changes get direct execution, complex work gets specs
4. **Behavior preservation** - Refactoring NEVER changes functionality (unless explicitly noted)
5. **Vertical slices** - Each story leaves code in working state
6. **Regression prevention** - Tests must pass before and after each story
7. **Rollback capability** - Each story is independently revertible

## Refactoring Types

**Architectural:**
- Design pattern application (repository, factory, strategy, etc.)
- Layer separation (presentation, business, data)
- Module reorganization
- Dependency injection

**Systematic:**
- Error handling standardization
- Logging improvements
- Consistent naming conventions
- Code style uniformity

**Tech Debt:**
- Remove dead code
- Eliminate duplication
- Simplify complex logic
- Update deprecated APIs

**Performance:**
- Algorithm optimization
- Database query improvements
- Caching strategy (if not adding new capability)
- Memory leak fixes

**Library Migration:**
- Dependency updates
- Framework version upgrades
- API migration (old → new)
- Deprecation handling

---

**Remember:** Refactoring improves code quality without changing behavior. If behavior changes, it's probably a feature or bug fix.
