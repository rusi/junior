# Story 14: Create /refactor Command

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** Story 13 (requires improvements/ structure)
> **Deliverable:** Working `/refactor` command for intelligent code quality improvements with adaptive workflow

## User Story

**As a** developer improving code quality
**I want** an intelligent refactoring command that routes work appropriately
**So that** systematic improvements, architectural changes, and tech debt are handled efficiently

## Scope

**In Scope:**
- Create `.cursor/commands/refactor.md` command specification
- Clarification loop to understand refactoring intent
- Strict guardian mode: detect feature/bug disguised as refactor, challenge with reasoning
- User veto override after challenge
- Complexity assessment based on files, dependencies, risk, changes
- Adaptive workflow:
  - Small scope (< 1 story): Direct execution, no `.junior/` tracking
  - Medium/Large scope (1+ stories): Contract-first with full spec generation
- Refactoring contract with improvement-specific sections
- Generate `improvements/imp-N-name/` structure for complex refactoring
- Refactoring-specific story template (Current State, Target State, Regression Prevention, Rollback Plan)
- Automatic final story: Future Improvements (capture out-of-scope work)

**Out of Scope:**
- Automatic refactoring execution (Junior assists, doesn't auto-refactor)
- Code analysis tools integration
- Refactoring pattern library
- Automated test generation

## Acceptance Criteria

- [ ] Given user runs `/refactor`, when describing work, then clarification loop asks focused questions about intent, scope, and goals
- [ ] Given user describes adding new capability, when `/refactor` detects it's a feature, then strongly recommends `/feature` with reasoning and allows veto override
- [ ] Given user describes fixing broken behavior, when `/refactor` detects it's a bug, then strongly recommends `/bugfix` with reasoning and allows veto override
- [ ] Given clarification is complete, when complexity assessment runs, then presents clear analysis (files, dependencies, risk) and recommendation (direct vs spec)
- [ ] Given small scope refactoring, when user approves direct execution, then executes changes without creating `.junior/` files
- [ ] Given medium/large scope refactoring, when user approves, then presents refactoring contract with improvement-specific sections
- [ ] Given contract is approved, when generating spec, then creates `improvements/imp-N-name/` with adapted structure and refactoring-specific story format
- [ ] Given improvement spec is generated, when reviewing stories, then final story captures future improvements and out-of-scope work

## Implementation Tasks

- [ ] 14.1 Research refactoring patterns by reading existing commands (`feature.md`, `implement.md`, `new-command.md`)
- [ ] 14.2 Run `/new-command` with comprehensive prompt:

**Prompt for `/new-command`:**
```
Create refactor command with intelligent routing and adaptive workflow.

**Purpose:** Unified command for code quality improvements (systematic, architectural, tech debt, performance, library migrations).

**Type:** Adaptive - Contract-style for complex work, direct execution for simple changes.

**Workflow:**

Phase 1 - Clarification & Guardian Routing (always):
- Clarify refactoring intent through focused questions (what, why, scope, motivation)
- Strict guardian mode: Detect if actually feature/bug in disguise
  - Feature triggers: "add", "support", "enable", "new capability"
  - Bug triggers: "fix", "broken", "not working", "error"
  - Challenge strongly with reasoning: "This sounds like [feature|bug] because [reasoning]. I recommend /[feature|bugfix]."
  - Allow user veto override: "I disagree, but proceeding with refactor as requested."
- Continue clarification until 95% clear

Phase 2 - Complexity Assessment (always):
- Analyze scope using codebase_search and grep:
  - Files affected (count)
  - Dependencies impacted (imports, cross-references)
  - Risk level (core logic vs peripheral)
  - Change magnitude (tweaks vs restructuring)
- Present clear assessment with recommendation
- Decision thresholds:
  - Small (direct execution): 1-3 files, low-medium risk, minor changes
  - Medium/Large (spec with stories): 4+ files, medium-high risk, restructuring
- User can override recommendation

Phase 3A - Direct Execution (small scope):
- Execute refactoring immediately
- No .junior/ tracking (git log is history)
- Zero ceremony

Phase 3B - Contract & Generation (medium/large scope):
- Present refactoring contract:
  - Improvement name and type (Architectural | Systematic | Tech Debt | Performance | Library Migration)
  - Motivation (why this matters: maintainability, scalability, code quality)
  - Scope (included vs excluded)
  - Behavior Guarantee (confirm: no user-facing changes, or specify if any)
  - Risk Assessment (what could break, mitigation strategy)
  - Testing Strategy (regression prevention)
  - Stories preview (vertical slices)
  - Options: yes | edit | suggest-feature | suggest-bug
- Generate improvements/imp-N-name/ structure:
  - imp-N-overview.md (contract + details + future improvements)
  - user-stories/imp-N-stories.md (tracking)
  - user-stories/imp-N-story-M-name.md (refactoring-specific format)
  - Final story: imp-N-story-{M+1}-future-improvements.md

**Refactoring Story Template Differences:**
- Developer story format: "As a developer, I want [improvement], So that [benefit]"
- Current State section (what's wrong with current code)
- Target State section (what improved code looks like)
- Regression Prevention section (how to ensure no behavior changes)
- Rollback Plan section (how to undo if problems arise)

**Outputs:**
- Small: Direct code changes (no .junior/ files)
- Large: improvements/imp-N-name/ with adapted structure

**Tools:** todo_write, codebase_search, grep, read_file, write, search_replace, run_terminal_cmd

**Examples needed:**
- Small refactoring with direct execution
- Architectural refactoring with contract + stories
- Guardian routing redirecting to /feature
- Complexity assessment recommending spec creation

Implements feat-1-story-14.
```

- [ ] 14.3 User review: Run `/refactor` with multiple test scenarios:
  - Small scope: "refactor calculateTotal function to be more readable"
  - Large scope: "refactor database layer to use repository pattern"
  - Feature disguised: "refactor authentication to add OAuth support"
  - Bug disguised: "refactor login - it's broken"
- [ ] 14.4 Refine based on review feedback:
  - Adjust complexity assessment thresholds if needed
  - Improve guardian routing pattern detection
  - Enhance refactoring contract clarity
  - Polish story templates
- [ ] 14.5 Verify complete command functionality:
  - Clarification loop asks right questions
  - Guardian routing works correctly with veto override
  - Complexity assessment is accurate
  - Direct execution works for small scope
  - Spec generation works for large scope
  - Story structure follows refactoring patterns
- [ ] 14.6 Test edge cases:
  - Vague refactoring request (forces clarification)
  - User veto override (guardian challenged, user insists)
  - Borderline complexity (could go either way)
  - Very large refactoring (10+ files, high risk)
- [ ] 14.7 Finalize documentation:
  - Decision tree (refactor vs feature vs bug)
  - Complexity assessment criteria
  - When to execute directly vs create spec
  - How to structure improvement stories
  - Examples covering all major scenarios

## Technical Notes

### Command Structure

**Type:** Adaptive - Direct execution OR Contract-style depending on complexity

**Workflow Phases:**

**Phase 1: Clarification & Routing (Always)**
1. Initialize `todo_write` progress tracking
2. Clarify refactoring intent through focused questions
3. Strict guardian mode:
   - Detect if actually feature/bug in disguise
   - Challenge strongly with reasoning
   - Allow user veto override if they insist
4. Continue clarification until 95% clear

**Phase 2: Complexity Assessment (Always)**
5. Analyze scope:
   - Files affected (use `codebase_search`, `grep` to count)
   - Dependencies impacted (import analysis)
   - Risk level (core logic vs peripheral)
   - Change magnitude (tweaks vs restructuring)
6. Present assessment with recommendation
7. User chooses: "Direct execution" OR "Create spec"

**Phase 3A: Direct Execution (Small Scope)**
8. Execute refactoring immediately
9. No `.junior/` files created (git log is history)
10. Zero ceremony, fast completion

**Phase 3B: Contract & Generation (Medium/Large Scope)**
8. Present refactoring contract (improvement-specific format)
9. Wait for approval: yes | edit | suggest-feature | suggest-bug
10. Generate `improvements/imp-N-name/` structure:
    - `imp-N-overview.md` (contract + details)
    - `user-stories/imp-N-stories.md` (tracking)
    - `user-stories/imp-N-story-M-name.md` (individual stories)
    - Final story: `imp-N-story-{M+1}-future-improvements.md`

### Refactoring Contract Template

```markdown
## Refactoring Contract

**Improvement:** [One sentence: what code is being improved]

**Type:** [Architectural | Systematic | Tech Debt | Performance | Library Migration]

**Motivation:** [Why this matters: maintainability, scalability, code quality]

**Scope:**
- ✅ Included: [What will be refactored]
- ❌ Excluded: [What won't be touched]

**Behavior Guarantee:** [Confirm: no user-facing changes, or specify if any]

**Risk Assessment:**
- Risk Level: [Low | Medium | High]
- What could break: [Specific concerns]
- Mitigation: [How to minimize risk]

**Testing Strategy:**
- Regression prevention: [How to ensure no behavior changes]
- Test approach: [Unit, integration, manual testing plan]

**Stories Preview (vertical slices):**
- Story 1: [Minimal working improvement, end-to-end]
- Story 2: [Expand improvement, building on Story 1]
- Story {M+1}: Future Improvements (out-of-scope items, follow-up work)

---
Options: yes | edit: [changes] | suggest-feature | suggest-bug
```

### Refactoring Story Template

```markdown
# Story {M}: [Title]

> **Status:** Not Started
> **Priority:** [High | Medium | Low]
> **Dependencies:** [None OR Story N]
> **Deliverable:** [Specific code improvement completed, regression-free]

## Developer Story

**As a** developer maintaining [component/module]
**I want** [code improvement]
**So that** [code quality benefit: maintainability, performance, clarity]

## Current State

[What's wrong with current code:]
- Specific issues or smells
- Why it's problematic
- Technical debt context

## Target State

[What improved code looks like:]
- Desired structure or pattern
- Benefits gained
- Quality improvements

## Scope

**In Scope:**
- [Specific files/modules to refactor]
- [Patterns to apply]
- [Improvements to make]

**Out of Scope:**
- [Related improvements saved for later]
- [Areas not touching this story]

## Acceptance Criteria

- [ ] Given [current state], when refactoring is applied, then [target state] is achieved
- [ ] Given [existing tests], when refactoring is complete, then all tests still pass (no regressions)
- [ ] Given [existing functionality], when code is refactored, then behavior is unchanged

## Implementation Tasks

- [ ] {M}.1 Write/update tests to lock in current behavior (TDD: establish baseline)
- [ ] {M}.2 Refactor [component] to [target pattern]
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
- [ ] Performance benchmarks show no degradation

## Rollback Plan

**If issues arise:**
1. Identify what broke (tests, functionality, performance)
2. Attempt quick fix if obvious
3. If not quickly fixable: `git revert [commit]`
4. Document issue in story for future attempt

**Rollback criteria:**
- Test failures that can't be fixed in < 30 minutes
- Unexpected behavior changes discovered
- Performance degradation > 20%

## Technical Notes

[Implementation approach, key decisions, patterns used]

## Testing Strategy

**TDD Approach:**
- Establish test baseline (lock in current behavior)
- Refactor code
- Verify all tests still pass (green)
- Refactor tests if needed (clean)

**Test Levels:**
- Unit tests: [Specific components tested]
- Integration tests: [Cross-component interactions verified]
- Manual testing: [Key workflows validated]

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

### Complexity Assessment Algorithm

**Inputs (gathered via codebase analysis):**
1. **File count:** How many files need modification?
   - Use `codebase_search` to find relevant files
   - Use `grep` to check usage patterns
2. **Dependency impact:** How many modules/components affected?
   - Analyze import statements
   - Check cross-references
3. **Risk level:** Is this core logic or peripheral?
   - Core authentication, data processing, business logic → High risk
   - UI components, utilities, helpers → Lower risk
4. **Change magnitude:** Minor tweaks or major restructuring?
   - Rename/extract → Minor
   - Redesign/restructure → Major

**Assessment Example:**

```
📊 Complexity Assessment

Files affected: 7 files
- src/auth/login.ts
- src/auth/session.ts
- src/auth/middleware.ts
- src/api/routes/auth.ts
- tests/auth/login.test.ts
- tests/auth/session.test.ts
- tests/integration/auth.test.ts

Dependencies: 3 modules need import updates
- API routes depend on new auth interface
- Middleware depends on session refactor
- Tests depend on both

Risk level: High
- Changes core authentication flow
- Affects all authenticated endpoints
- Session management is critical path

Estimated complexity: 2-3 story points
- Story 1: Refactor auth interfaces and types
- Story 2: Update login and session logic
- Story 3: Migrate middleware and routes

**Recommendation:** Create improvement spec with stories for safe, trackable execution.

This is complex enough to benefit from:
- Vertical slice approach (one component at a time)
- Comprehensive test coverage
- Rollback capability per story
- Clear documentation of changes

Proceed with spec creation? [yes | execute-directly]
```

**Decision Thresholds:**
- **Small (direct execution):** 1-3 files, low-medium risk, minor changes
- **Medium (spec with stories):** 4-10 files, medium risk, moderate restructuring
- **Large (spec with stories):** 10+ files, high risk, major architectural changes

### Guardian Routing Logic

**Feature Detection Patterns:**
```
Triggers: "add", "support", "enable", "implement", "create", "new capability"

Example: "refactor authentication to support OAuth"
Analysis: "support OAuth" = new capability
Response: "This sounds like a feature because you're adding OAuth support (new capability).
          Features add user-facing value, while refactoring improves existing code without
          behavior change. I recommend `/feature` for this work.

          Proceed with refactor anyway? [no | yes (veto)]"
```

**Bug Detection Patterns:**
```
Triggers: "fix", "broken", "not working", "error", "fails", "doesn't work"

Example: "refactor login function - it's broken"
Analysis: "broken" = fixing incorrect behavior
Response: "This sounds like a bug because the login function isn't working correctly.
          Bugs fix broken behavior with reproduction steps and verification, while refactoring
          improves working code. I recommend `/bugfix` for this work.

          Proceed with refactor anyway? [no | yes (veto)]"
```

**Veto Override:**
```
User: "yes, I want to refactor"
Response: "I disagree, but proceeding with refactor as requested. ⚠️"

Then continue with refactor workflow.
Document in contract: "⚠️ Note: User classified as refactor, may have feature/bug characteristics"
```

### Tool Integration

**Primary tools:**
- `todo_write` - Progress tracking throughout workflow
- `codebase_search` - Find files to refactor, assess scope
- `grep` - Pattern matching, usage analysis
- `read_file` - Analyze current code structure
- `write` - Create improvement specs and stories
- `search_replace` - Execute direct refactoring (small scope)
- `run_terminal_cmd` - Get current date, git status

**Workflow integration:**
- Use `codebase_search` for scope discovery during clarification
- Use `grep` for dependency analysis during complexity assessment
- Use `read_file` for understanding current state
- Use `write` for generating improvement specs
- Use `search_replace` for direct execution of small refactorings

## Testing Strategy

**TDD Approach:**
- Write command specification first (this story)
- Test command with sample refactoring scenarios
- Verify correct routing, assessment, and generation
- Refine based on actual usage

**Test Scenarios:**

**Scenario 1: Small refactoring (direct execution)**
- Input: "refactor calculateTotal function to be more readable"
- Expected: Clarify → Assess (small) → Execute directly → No `.junior/` files

**Scenario 2: Architectural refactoring (spec creation)**
- Input: "refactor database layer to use repository pattern"
- Expected: Clarify → Assess (large) → Contract → Generate `improvements/imp-1-repository-pattern/`

**Scenario 3: Feature disguised as refactor**
- Input: "refactor authentication to add OAuth support"
- Expected: Guardian detects feature → Recommends `/feature` → User can veto

**Scenario 4: Bug disguised as refactor**
- Input: "refactor login - it's not working"
- Expected: Guardian detects bug → Recommends `/bugfix` → User can veto

**Scenario 5: Complexity assessment edge case**
- Input: "refactor utilities module" (vague)
- Expected: Clarification questions → Scope discovery → Assessment based on actual files

**Manual Testing:**
1. Run `/refactor` with small scope → Verify direct execution works
2. Run `/refactor` with large scope → Verify spec generation works
3. Run `/refactor` with feature intent → Verify guardian routing works
4. Run `/refactor` with bug intent → Verify guardian routing works
5. Test user veto override → Verify refactor proceeds despite recommendation

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] `/refactor` command file created at `.cursor/commands/refactor.md`
- [ ] Clarification loop asks focused questions about intent, scope, motivation
- [ ] Guardian routing detects features/bugs and challenges appropriately
- [ ] User veto override works ("I disagree, but proceeding...")
- [ ] Complexity assessment analyzes files, dependencies, risk accurately
- [ ] Small scope refactoring executes directly without `.junior/` tracking
- [ ] Medium/Large scope refactoring generates complete improvement spec
- [ ] Refactoring contract includes all improvement-specific sections
- [ ] Story template includes Current State, Target State, Regression Prevention, Rollback Plan
- [ ] Final story "Future Improvements" captures out-of-scope work
- [ ] Command examples cover all major scenarios
- [ ] Decision tree documented (refactor vs feature vs bug)
- [ ] Date handling follows `02-current-date.md` rule
- [ ] No regressions in `.junior/` structure
- [ ] Code follows Junior's principles
- [ ] **User can run `/refactor` and get intelligent routing, accurate assessment, and appropriate workflow (direct or spec-based)**
- [ ] Tested with at least 5 different refactoring scenarios (small, large, feature-disguised, bug-disguised, vague)

