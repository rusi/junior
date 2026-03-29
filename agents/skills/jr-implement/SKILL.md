---
name: jr-implement
description: Execute feature stories systematically with TDD-first workflow, story discovery, and production-ready completion gates.
---

# Implement Command

## Purpose

Execute feature stories systematically using Test-Driven Development workflow with intelligent story discovery.

## Type

Direct execution - Immediate action with user confirmation when uncertain

## When to Use

- Ready to implement a specific feature story
- Want to work on the next story in sequence
- Need systematic implementation workflow with progress tracking
- Want TDD workflow guidance (for coding projects)

## Companion Command: `/jr-test` (Required Post-Implementation Gate)

`/jr-test` is mandatory after `/jr-implement` for coding stories.

- **Required default flow:**
  1. `/jr-implement [story]` for first-pass implementation
  2. `/jr-test [story]` to perform independent test-engineering audit, strengthen coverage, and detect implementation defects
  3. If `/jr-test` finds defects, return to `/jr-implement [story]` and repeat until clean

- **Optional advanced flow (explicit request only):**
  1. `/jr-test [story]` before implementation to establish test intent
  2. `/jr-implement [story]`
  3. `/jr-test [story]` again as final audit gate

Do not consider coding-story implementation complete until post-implementation `/jr-test` audit is executed and results are addressed.

## Scope: Universal Implementation Command

**This command works for ANY project type:**

- **Coding projects:** Python, JavaScript/TypeScript, Go, Rust, C/C++, Swift, Java, etc.
- **Documentation projects:** Writing docs, creating commands (like this one!)
- **Configuration projects:** System setup, environment configuration
- **Mixed projects:** Features with code, docs, and configuration

**TDD workflow applies ONLY to coding projects:**
- Projects where code can be automatically tested and coverage measured
- Automated test suites (unit, integration, end-to-end)
- For non-coding tasks: systematic implementation without TDD requirements

## CRITICAL REQUIREMENT: 100% Test Pass Rate & Coverage (Coding Projects Only)

**⚠️ ZERO TOLERANCE FOR FAILING TESTS OR INCOMPLETE COVERAGE ⚠️**

This command enforces strict test validation:
- **NO story can be marked "COMPLETED" with ANY failing tests**
- **100% test pass rate is MANDATORY before completion**
- **100% code coverage is REQUIRED for all new/modified code**
- **"Edge case" or "minor" test failures are NOT acceptable**
- **Incomplete coverage is NOT acceptable**
- **Implementation is considered incomplete until all tests pass AND coverage is 100%**

If tests fail or coverage is incomplete, the story remains "IN PROGRESS" until all failures are resolved and coverage reaches 100%.

## CRITICAL REQUIREMENT: Stateful Context E2E Matrix (Coding Projects)

If a story touches global or route-scoped context (for example: active scope selection, permission scope, locale scope, or equivalent), `/jr-implement` must include explicit e2e coverage proving data and route updates after context changes.

Minimum required matrix for those stories:
- At least one overview/aggregate view and one detail/edit view.
- Positive and negative assertions after switch:
  - new-context data appears
  - prior-context data is absent (stale-data rejection)
- One nested/deep-link route case verifies URL and rendered data coherence.
- At least one assertion proves new-context loader/API activity occurred.

Story completion is blocked until this matrix passes in isolated e2e execution.

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan`:

```json
{
  "todos": [
    {"id": "discover-story", "content": "Discover and select story to implement", "status": "in_progress"},
    {"id": "git-check", "content": "Check git status and recommend commit if needed", "status": "pending"},
    {"id": "context-gathering", "content": "Gather comprehensive context: specs, codebase analysis, patterns", "status": "pending"},
    {"id": "execute-tasks", "content": "Execute story tasks using TDD workflow", "status": "pending"},
    {"id": "final-verification", "content": "Run final test suite and coverage verification", "status": "pending"},
    {"id": "complete-story", "content": "Update story status and suggest next steps", "status": "pending"}
  ]
}
```

### Step 2: Smart Story Discovery

**Detect current stage:** Use stage detection logic from `01-structure.mdc` to determine which structure (Stage 1/2/3) the project uses. This determines feature path resolution.

**Parse user input for explicit or implicit story selection:**

**Input Patterns:**

1. **Explicit story ID:** `/jr-implement feat-1-story-2` or `/jr-implement feat-1-story-2-auth`
   - Parse story identifier from input
   - Validate story exists (using stage-aware path resolution)
   - **Confidence: 95%+** → Proceed directly

2. **Vague/implicit:** `/jr-implement` or `/jr-implement next` or `/jr-implement next story`
   - Scan `.junior/features/` for all features (stage-aware)
   - Load `user-stories/feat-{N}-stories.md` for each feature
   - Identify next incomplete story based on progress
   - **Confidence: <95%** → Confirm with user before proceeding

**Discovery Logic (Stage-Aware):**

Use stage-appropriate paths to find features. See `01-structure.mdc` for stage detection and path resolution patterns.

For each feature found, load `user-stories/feat-{N}-stories.md`, parse task completion, and identify first story with status "Not Started" or "In Progress".

**Confidence-Based Selection:**

- **95%+ certain** (explicit story ID matches existing story) → Start implementation
- **<95% certain** (ambiguous input or multiple options) → Present options and ask user to confirm

**Confirmation prompt (when uncertain):**

```
📋 Story Discovery

Based on current progress, next story appears to be:

**Feature:** feat-3-admin-panel
**Story:** Story 2: User Dashboard
**Status:** Not Started
**Tasks:** 5 tasks (0/5 completed)
**Priority:** High

Is this the story you want to implement? [yes/no/list]

Options:
- yes: Start implementing this story
- no: Cancel
- list: Show all available stories
```

**Smart Discovery Examples:**

**Explicit story reference (high confidence):**
```
User: /jr-implement feat-1-story-2
Junior: [Loads story directly and starts context gathering]
```

**Vague input (low confidence):**
```
User: /jr-implement
Junior: 📋 Story Discovery

        Based on current progress, next story appears to be:
        **Story:** Story 2: User Dashboard

        Is this the story you want to implement? [yes/no/list]
```

**Next story request:**
```
User: /jr-implement next story
Junior: 📋 Next Story

        Story 3: User Settings
        Status: Not Started

        Start implementing this story? [yes/no]
```

### Step 3: Git Status Check

**Check for uncommitted changes:**

```bash
git status --short
```

**If uncommitted changes exist:**

```
⚠️ Uncommitted changes detected

Scope check:
- Review changed paths from `git status --short`.
- If changes are clearly isolated from this story's scope, recommend proceeding.
- If changes touch related areas or scope is unclear, ask for explicit override.

Default: use /jr-commit first.
Override: If you confirm the changes are unrelated, reply "override: proceed".
```

**Note:** This is a recommendation, not a hard blocker — user may be continuing same story.

### Step 4: Context Gathering & Analysis

**CRITICAL: Comprehensive context loading before implementation**

**Load story and feature context (use stage-aware paths):**

- Main story file: `{feature-path}/user-stories/feat-N-story-M-{name}.md`
- Progress tracking: `{feature-path}/user-stories/feat-N-stories.md`
- Feature spec: `{feature-path}/feat-N-overview.md`
- Related specs: `{feature-path}/specs/*.md` (if exist)
- Dependencies: Check other features referenced in story
- Roadmap tracking: `.junior/product/02-roadmap.md` (if exists) using `../_shared/references/roadmap-progress-sync.md`
- Session context contract: `../_shared/references/session-artifact-log.md`

Where `{feature-path}` is resolved using stage detection (see `01-structure.mdc` for path patterns).

**Parse story structure:**

- User story and acceptance criteria
- Implementation tasks list
- Definition of Done
- Technical notes and dependencies
- Reference implementation notes (if any)

**Analyze current codebase:**

Use `codebase_search` or `functions.shell_command` to understand:

- **Current architecture and patterns**
  - What design patterns are used?
  - What is the code organization structure?
  - Where do similar features live?

- **Related existing functionality**
  - Are there similar implementations to reference?
  - What existing utilities can be reused?
  - What components might be affected?

- **Integration points for new features**
  - Where will this feature integrate?
  - What interfaces need to be implemented?
  - What dependencies exist?

- **Testing frameworks and conventions**
  - What test framework is used? (Jest, Pytest, etc.)
  - Where are tests located?
  - What are the naming conventions?
  - Are there test utilities or helpers?

**Example codebase searches:**

```
# Understand architecture
"How is the codebase organized? What are the main directories?"

# Find similar implementations
"Where are similar [feature type] implemented?"

# Identify test patterns
"What testing framework and patterns are used?"

# Find integration points
"Where would [this feature] integrate with existing code?"
```

**Load project configuration:**

- Build configuration (package.json, Cargo.toml, go.mod, pyproject.toml, etc.)
- Test configuration (jest.config.js, pytest.ini, etc.)
- Linting and formatting rules
- CI/CD pipelines (if relevant to testing)

**Stateful context risk check (mandatory for coding projects):**

Before implementation, explicitly determine whether the story affects:
- global context selectors (active scope or equivalent)
- role/permission-scoped content boundaries
- route-param context boundaries
- cross-page context propagation

If yes:
- add a dedicated todo: `context-switch regression matrix (e2e)`
- list stale-state regressions that must be prevented
- define target pages and required assertions before coding begins

**🔴 CRITICAL: Read language-specific conventions:**

- **Python projects:** Read `~/.codex/rules/11-python-conventions.mdc` for `uv run` requirements
- **JavaScript/TypeScript projects:** Read relevant language convention rules
- **Other languages:** Check for language-specific rules in `~/.codex/rules/`
- **ALWAYS follow project-specific tool runners** (e.g., `uv run pytest` not `pytest`)

**Identify reusable code:**

- Search for utilities that can be reused
- Identify patterns to follow
- Note areas that might need refactoring
- Check for potential conflicts or breaking changes

**Validate testing setup (for coding projects):**

- Confirm testing framework is configured
- Verify test directories and naming conventions
- Check existing test patterns and utilities
- Ensure test runner is functional

**Review tasks and validate approach:**

- Parse all tasks from story file
- Identify task dependencies and order
- For coding projects: Verify first task writes tests
- For non-coding projects: Skip TDD-specific requirements
- Validate implementation strategy

**🔴 CRITICAL: Update TODOs to reflect story tasks**

**IMMEDIATELY after reviewing tasks**, replace generic TODOs with specific story tasks using `todo_write` or `functions.update_plan`:

```json
{
  "merge": false,
  "todos": [
    {"id": "story-2-task-1", "content": "1.1 Write tests for dashboard API (Story 2)", "status": "in_progress"},
    {"id": "story-2-task-2", "content": "1.2 Implement data fetching service (Story 2)", "status": "pending"},
    {"id": "story-2-task-3", "content": "1.3 Create dashboard UI components (Story 2)", "status": "pending"},
    {"id": "story-2-task-4", "content": "1.4 Add real-time updates (Story 2)", "status": "pending"},
    {"id": "story-2-task-5", "content": "1.5 Verify tests and coverage (Story 2)", "status": "pending"}
  ]
}
```

**Why this matters:**
- Provides precise progress tracking aligned with story structure
- Makes it clear which specific task is being worked on
- Enables accurate completion reporting
- Prevents generic "execute tasks" ambiguity

**This is mandatory, not optional.** Do not proceed to Step 5 without updating TODOs to match story tasks.

### Step 5: Story Task Execution (TDD Workflow)

**Execute story tasks in sequential order, one at a time:**

**For each task in sequence:**

#### Task 1: Write Tests (Test-First Approach) - Coding Projects Only

```
🧪 TDD Phase: RED (Write Failing Tests)

Write tests that define the expected behavior:
- Unit tests for core functionality
- Integration tests for component interaction
- Edge cases and error conditions
- Acceptance tests for user story validation
- Performance tests (if feature has performance requirements)
  → Use proper benchmark frameworks with statistical analysis
  → Document performance targets in test documentation

Tests should fail initially (no implementation yet).

Mark complete when tests are written and failing correctly.
```

**Test categories:**

- **Unit tests**: Individual function/method testing (e.g., `test_fetch_dashboard_data()`)
- **Integration tests**: Component interaction (e.g., `test_api_to_ui_data_flow()`)
- **Edge cases**: Boundary conditions (e.g., `test_empty_dataset()`, `test_max_connections()`)
- **Acceptance tests**: User story validation (e.g., `test_user_views_realtime_dashboard()`)
- **Performance tests**: Benchmark critical paths with statistical analysis (e.g., `test_parse_performance()`)

#### Tasks 2-N: Implementation (Green Phase)

```
✅ TDD Phase: GREEN (Make Tests Pass)

Implement the minimal code to make tests pass:
- Focus on current task functionality
- Keep implementation simple
- Ensure all related tests pass

Mark complete when implementation makes tests pass.
```

**Implementation approach:**

- Start with simplest implementation that passes tests
- Add complexity incrementally as required
- Maintain compatibility - no regressions
- Refactor when green - improve code quality while tests pass

**Additional execution gate for context-affecting stories:**
- Implement/upgrade e2e context-switch tests in the same story turn by default.
- Run one short exploratory pass after automation for context + navigation interactions:
  - dropdown/menu open-close behavior
  - pointer/keyboard movement continuity
  - switching context on nested routes
  - stale content not remaining visible
- Record result as `pass`/`fail` with route references in story notes.

**🔴 MANDATORY: After each task completion:**

1. **Update story file** - Mark task: `- [ ]` → `- ✅` (replace checkbox with emoji): `- ✅ Task description`
2. **Update feat-N-stories.md** - Recalculate progress (X/Y tasks, percentage)
3. **Update relevant checklists/docs** - If the story references a checklist (e.g., migration checklist), update it immediately
4. **Update roadmap execution tracking** - Sync `.junior/product/02-roadmap.md` checkbox + progress row for this feature (if roadmap exists), using `../_shared/references/roadmap-progress-sync.md`
5. **Append Session Artifact Log entry in the story file** - Use `../_shared/references/session-artifact-log.md` and list every file touched in this task with status (`created|modified|deleted|renamed`) plus evidence commands run.
6. **Update TODO** - Mark corresponding todo as completed using `todo_write` or `functions.update_plan`
7. **Show progress display** - Present current story progress to user:

```
📊 Story Progress

Story: Story 2: User Dashboard
Tasks: 5 total

✅ 1.1 Write tests for dashboard API
✅ 1.2 Implement data fetching service
🔵 1.3 Create dashboard UI components (current)
⚪ 1.4 Add real-time updates
⚪ 1.5 Verify tests and coverage

Progress: 2/5 tasks (40%)
```

**Symbols:**
- ✅ = Completed
- 🔵 = In Progress (next task)
- ⚪ = Not Started
- ⚠️ = Blocked

8. **Present next task** - Show next task details and start working on it

**This progress display must be shown after EVERY task completion.** It keeps the user informed and maintains transparency about story progress.

#### Final Task: Test & Acceptance Verification (Coding Projects)

```
🔍 TDD Phase: REFACTOR (Verify & Improve)

Verify all tests pass, coverage is 100%, and acceptance criteria are met:
- Run full test suite: 100% pass rate required
- Run coverage report: 100% coverage required
- Run performance benchmarks: All targets met (if applicable)
- Validate acceptance criteria
- Refactor if needed while keeping tests green

⚠️ Story cannot be marked complete with failing tests, incomplete coverage, or unmet performance targets.

Mark complete when all tests pass, coverage is 100%, criteria are met, and performance targets achieved.
```

**CRITICAL: 100% Test Pass Rate & Coverage Required**

**Test execution strategy (gradual approach):**

1. **First**: Run only tests for current story/jr-feature
2. **Then**: Run related test suites to check for regressions
3. **Finally**: Consider full test suite if significant changes made
4. **Acceptance**: Validate user story acceptance criteria are met

**⚠️ STORY CANNOT BE MARKED COMPLETE WITH ANY FAILING TESTS OR INCOMPLETE COVERAGE ⚠️**

If ANY tests fail or coverage is incomplete:
- **STOP IMMEDIATELY** - Do not mark story as complete
- Debug and fix each failing test
- Add tests to reach 100% coverage
- Re-run test suite until 100% pass rate AND 100% coverage achieved
- Only then proceed to mark story as complete

**⚠️ NEVER SKIP TYPE CHECKING OR FAILING TESTS TO "MOVE FORWARD" ⚠️**

- ❌ **FORBIDDEN:** Ignoring type checking errors to continue implementation
- ❌ **FORBIDDEN:** Commenting out failing tests to reach completion
- ❌ **FORBIDDEN:** Using `# type: ignore` or `@ts-ignore` without fixing root cause
- ✅ **REQUIRED:** Fix type errors immediately when they appear
- ✅ **REQUIRED:** Fix failing tests immediately - work is incomplete until tests pass
- **Exception:** User explicitly requests to skip OR you ask and they approve

**For non-coding projects:**

- Verify all tasks completed
- Review deliverables with user
- Validate acceptance criteria met
- Skip test/coverage requirements

### Step 6: Final Test & Coverage Verification (Coding Projects)

**CRITICAL: Comprehensive validation before story completion**

**Additional completion criteria for context-affecting stories:**
- Isolated e2e evidence for the context-switch matrix is mandatory.
- Selector-only assertions are insufficient; rendered data transition assertions are required.
- Missing stale-data negative assertions block completion.

After all tasks are executed, run final comprehensive verification:

**1. Run complete test suite:**

```bash
# ⚠️ CRITICAL: Use project-specific test runner
# Check language-specific rules in ~/.codex/rules/ for correct command

npm test                    # Node.js/JavaScript
uv run pytest --cov         # Python (this project uses uv)
go test -cover ./...        # Go
cargo test                  # Rust
make test                   # C/C++
swift test                  # Swift
```

**2. Generate and verify coverage report:**

```bash
npm test -- --coverage                       # Jest
uv run pytest --cov --cov-report=html       # Python (this project uses uv)
go test -coverprofile=coverage.out ./...    # Go
cargo tarpaulin --out Html                  # Rust
gcov / lcov                                 # C/C++
swift test --enable-code-coverage           # Swift
```

**3. Validate results:**

```
🔍 Final Verification Results

Tests:
✅ All tests passing: 45/45 (100%)
✅ No flaky tests
✅ No skipped tests

Coverage:
✅ Line coverage: 100%
✅ Branch coverage: 100%
✅ Function coverage: 100%

Acceptance Criteria:
✅ All 6 criteria met

Story is ready for completion!
```

**4. If verification fails:**

```
❌ Verification Failed

Tests:
❌ 2 tests failing
⚠️ 1 test skipped

Coverage:
❌ Line coverage: 87% (target: 100%)
❌ Missing coverage in: src/dashboard.ts lines 45-52

REQUIRED ACTIONS:
1. Fix failing tests
2. Remove skipped tests or document why skipped
3. Add tests to reach 100% coverage
4. Re-run verification

Story CANNOT be marked complete until all checks pass.
```

**Failure resolution process:**

1. **Identify root cause** - Analyze each failing test to understand why it fails
2. **Fix implementation** - Modify code to make the test pass
3. **Add missing tests** - Write tests for uncovered code paths to reach 100% coverage
4. **Re-run ALL tests** - Ensure 100% pass rate across entire test suite
5. **Check for regressions** - Verify no existing tests broke from changes
6. **Repeat if needed** - Continue until NO tests fail and coverage is 100%
7. **Only then complete** - Mark story as complete when all checks pass

**Specific failure scenarios:**

- **Performance issues**: Optimize implementation until all tests pass within acceptable time
- **Regressions found**: Fix regressions immediately - story completion is blocked until resolved
- **Flaky tests**: Identify and fix root cause - no "ignore flaky test" workarounds
- **Coverage gaps**: Add tests for uncovered lines/branches - no exceptions

**For non-coding projects:**
- Verify all tasks completed
- Review deliverables with user
- Validate acceptance criteria met
- Skip test/coverage requirements

### Step 7: Story Completion & Status Updates

**When all tasks are complete AND final verification passes:**

1. **Verify completion requirements:**
   - All tasks marked with ✅
   - All acceptance criteria met
   - 100% test pass rate (if applicable)
   - 100% code coverage (if applicable)
   - Definition of Done satisfied

2. **Update story status:**

```markdown
> **Status:** Completed
```

3. **Update feat-N-stories.md progress:**

```markdown
| Story | Title | Status | Tasks | Progress |
|-------|-------|--------|-------|----------|
| 2 | User Dashboard | Completed ✅ | 5 | 5/5 ✅ |
```

4. **Update feat-N-overview.md status if needed:**

Check if all stories in feature are complete:
- If yes: Update feature status to "Completed"
- If no: Update to "In Progress" if was "Planning"

5. **Update roadmap progress and status:**

- Sync `.junior/product/02-roadmap.md` execution tracking checklist and table using `../_shared/references/roadmap-progress-sync.md`.
- Ensure status reflects story completion (`Planning` / `In Progress` / `Completed`) and progress is up to date.

6. **Present completion summary:**

```
✅ Story Completed Successfully!

**Story:** Story 2: User Dashboard
**Tasks completed:** 5/5 ✅
**Acceptance criteria:** All met ✅
**Tests written:** 18 test cases
**Tests passing:** 18/18 (100%) ✅
**Coverage:** 100% ✅
**Files modified:** 8 files
**User value delivered:** Users can view real-time data on personalized dashboard

📊 Feature Progress: feat-3-admin-panel
- Total stories: 4
- Completed: 2/4 (50%)
- Remaining: 2 stories

🎯 Suggested Next Steps:
1. Run /jr-commit to commit these changes
2. Continue with Story 3: User Settings
3. Review feature progress

What would you like to do next?
```

## Document Update Policy

**🔴 CRITICAL: Checkbox Format Consistency**

**ALL checkboxes in story files MUST use this format:**
- Unchecked: `- [ ] Task description`
- Checked: `- ✅ Task description`

**NEVER generate:**
- ❌ `- [x] Task description` (markdown checked format)
- ❌ `- [x] Task description ✅` (mixed/redundant format)

This format is MANDATORY for consistency with commit validation.

**When task is marked complete, update:**

- **Story file:** Mark task with ✅ (replace `- [ ]` with `- ✅`)
- **feat-N-stories.md:** Update task count and percentage
- **feat-N-overview.md:** Update status if needed (Planning → In Progress → Completed)
- **Roadmap tracking (`02-roadmap.md`):** Update checklist and execution tracking progress (if roadmap exists; use `../_shared/references/roadmap-progress-sync.md`)
- **Related stories:** Note if dependencies affect other stories

**Automatic updates:**
- Task checkboxes in story file
- Progress percentages in feat-N-stories.md
- Story status when all tasks complete
- Roadmap execution-tracking checkbox/progress sync

**Where to put implementation documents:**

- ✅ **feat-N/docs/**: Validation reports, findings, analysis, implementation notes
  - `validation-*.md` - Test findings, validation results
  - `analysis-*.md` - Technical analysis documents
  - `implementation-*.md` - Implementation lessons learned
- ✅ **feat-N/user-stories/**: ONLY story specifications and progress tracking
  - `feat-N-story-{M}-{name}.md` - Individual stories
  - `feat-N-stories.md` - Progress tracking
- ❌ **NEVER** put findings/analysis/validation reports in user-stories/
- ❌ **NEVER** put story specifications in docs/

### ⚠️ CRITICAL: All Deliverables Must Be Timeless

**NEVER reference stories, tasks, or steps in ANY deliverable:**

❌ Code comments: `# Story 2: Add validation` or `# Task 1.2: Parse data`
❌ Code names: `test_story_2_validation()`, `story2_handler()`, `task_1_2_result`
❌ Documentation: "Story 3 will implement..." or "After Task 2.3..."

✅ **Instead, describe WHAT and WHY:**

✅ Code comments: `# Validate input format` or `# Parse protocol header`
✅ Code names: `test_validates_input_format()`, `handle_notification()`, `parse_result`
✅ Documentation: "System uses adapter pattern for..." or "Protocol state machine handles..."

**Test:** Would this be clear in 2 years with no story/task context? If no, remove references.

### ⚠️ CRITICAL: Follow Implementation Principles

**ALWAYS apply principles from `13-software-implementation-principles.mdc`:**

1. **Modularity & Encapsulation**
   - Extract utilities (logging, CLI UI, formatting)
   - Use established frameworks (typer, rich, click, etc.)
   - Main application = orchestration only, not implementation

2. **Conciseness**
   - **Target: 10-50 lines for simple operations (scan, connect, read)**
   - If main application > 100 lines, extract utilities
   - Don't inline configuration, progress bars, or boilerplate

3. **Single Responsibility**
   - One concern per module/class/function
   - No mixed responsibilities (e.g., validate AND save)

4. **Use Modern Tools**
   - See language-specific rules (e.g., `11-python-conventions.mdc`)
   - Python: typer + rich, not argparse + print
   - Don't reinvent solved problems

5. **Clean Console Output**
   - Concise timestamps (HH:MM:SS)
   - Progress bars with elapsed/remaining time
   - Visual indicators (✓, ✗, ℹ)

6. **No Purposeless Output**
   - **ZERO TOLERANCE for unnecessary documents**
   - Don't create validation checklists, summaries, recaps
   - Only create files explicitly required in story

**Red flags during implementation:**
- ❌ Main file approaching 200 lines
- ❌ Inline logging configuration
- ❌ Manual progress text (not visual progress bar)
- ❌ argparse with 50 lines of setup
- ❌ Repeated patterns not extracted
- ❌ "Story X" or "Task Y" references in code

**Action when red flags appear:**
1. STOP implementation
2. Extract utilities/frameworks
3. Refactor to follow principles
4. Continue with clean code

**Reminder to user:**
- Update specs if implementation differs from plan
- Update related documentation
- Note any follow-up work needed

## Tool Integration

**Primary tools:**

- `todo_write` or `functions.update_plan` - Progress tracking throughout execution
- `codebase_search` or `functions.shell_command` - **CRITICAL** - Understand architecture, patterns, existing functionality, test frameworks
- `glob_file_search` or `functions.shell_command` - Find feature and story files
- `list_dir` or `functions.shell_command` - Scan features directory
- `read_file` or `functions.shell_command` - Load story files, feat-N-stories.md, feat-N-overview.md, specs, project config
- `search_replace` or `functions.apply_patch` - Update task checkboxes and progress
- `run_terminal_cmd` or `functions.shell_command` - Git status check, run tests
- `grep` (via `functions.shell_command`) - Parse story files for tasks

**Parallel execution opportunities:**

- Context gathering (load multiple spec files, run multiple codebase searches)
- Test framework analysis (search for test patterns, load test configs)
- Architecture understanding (search for similar implementations, integration points)

**Git commands:**

```bash
git status --short           # Check for uncommitted changes
```

**File operations (stage-aware):**

Find features and story files using stage-appropriate paths (see `01-structure.mdc` for stage detection and path resolution).

## Progress Tracking

**Progress tracking happens at specific points in the workflow:**

1. **After Step 4 (Context Gathering):** Replace generic TODOs with story-specific tasks
2. **After each task completion (Step 5):** Show progress display, update files, mark TODO complete
3. **After final verification (Step 6):** Confirm all tasks complete, all tests pass
4. **At story completion (Step 7):** Update story status, update feature progress

**See Step 5 for the mandatory progress display format shown after each task.**

**Non-negotiable checklist updates (MANDATORY):**
- Update story file checkboxes (Acceptance Criteria + Implementation Tasks) as soon as evidence exists.
- Update `feat-N-stories.md` summary whenever task counts or status change.
- If tests fail or are not run, keep story **In Progress** (do NOT mark Completed).

**Progress tracking ensures:**
- User always knows current position in story
- Files stay synchronized (story file, feat-N-stories.md, TODOs)
- Transparent communication of progress
- Clear indication of what's next

## Quality Standards

**Test-Driven Development:**

- Write tests before implementation
- **100% test pass rate required** before story completion
- **100% code coverage required** before story completion
- No story can be marked complete with failing tests or incomplete coverage
- Comprehensive test coverage including edge cases

**Progress tracking:**

- Update story files immediately after task completion
- Recalculate progress percentages automatically
- Keep feat-N-stories.md synchronized with story status
- Update feature status when stories complete

**Documentation:**

- Update related documentation when implementation changes
- Note deviations from original plan
- Document technical decisions in story notes
- Highlight follow-up work or technical debt

## Error Handling

**Old structure detected (graceful migration prompt):**

If flat features exist without the 3-stage structure:

```
⚠️ Old Junior structure detected

Your project uses an older Junior structure.

Run /jr migrate to update to the current 3-stage progressive structure.

This is a one-time migration that preserves all your work.

Continue anyway? [no | yes]
```

**Note:** This is graceful, not blocking. User can continue if needed.

**No features found:**

```
❌ No features found

No feature specifications exist in .junior/features/

Create a feature first using /jr-feature command.
```

**Story not found:**

```
❌ Story not found

Could not find story: feat-3-story-5

Available stories in feat-3-admin-panel:
- Story 1: Admin Authentication
- Story 2: User Dashboard
- Story 3: User Settings
- Story 4: Analytics Reports

Use /jr-implement with a valid story ID or /jr-implement to discover next story.
```

**Ambiguous selection:**

```
⚠️ Multiple options available

Cannot determine which story to implement. Please specify:

Available stories:
1. feat-3-story-2-user-dashboard (Not Started)
2. feat-4-story-1-payment-gateway (In Progress, 3/5 tasks)

Use: /jr-implement feat-3-story-2 or /jr-implement feat-4-story-1
```

**Blocking issues:**

If blocked by technical issues during implementation:

```markdown
Task status in story file:
- [ ] 2.3 Implement API integration ⚠️ Blocking issue: Third-party API documentation incomplete

Update story notes section to document the blocking issue.
```

**Resolution strategies:**

1. **Evidence-based debugging** - Collect concrete evidence (logs, tests, measurements) before diagnosing
2. **Verify root cause** - Form hypothesis based on evidence, test it, confirm before fixing
3. **Check scope** - If feature doesn't work, check task scope or ask user before skipping
4. **Try alternative approach** - Is there another way to achieve the same goal?
5. **Research solution** - Use `/research` command for technical investigation
6. **Break down into smaller components** - Can this be split into manageable pieces?
7. **Maximum 3 attempts** - After 3 failed attempts, escalate or document as blocked

**⚠️ CRITICAL: NO speculation or assumptions. See `13-software-implementation-principles.mdc` section 9 for evidence-based debugging process.**

**Document blocked tasks:**
- Mark task with ⚠️ and blocking issue description
- Update story status to note blockers
- Continue with other non-blocked tasks if possible
- Revisit blocked tasks after resolution

## Best Practices

**Context gathering:**

- **Always** run comprehensive codebase analysis before implementing
- Use multiple parallel `codebase_search` or `functions.shell_command` calls to understand architecture
- Identify similar implementations to follow established patterns
- Understand test framework and conventions before writing tests
- Load all related specs and documentation
- Don't skip context gathering - it prevents mistakes and rework

**Story selection:**

- Default to explicit story IDs when uncertain
- Always confirm when confidence is below 95%
- Present clear options when multiple stories available
- Guide user to next logical story based on dependencies

**TDD workflow:**

- Provide clear phase reminders (RED → GREEN → REFACTOR)
- Guide test-first approach for new functionality
- Ensure tests pass and coverage is 100% before marking implementation complete
- Remind about 100% test pass rate and 100% coverage requirements
- **NEVER skip type checking errors or failing tests to "move forward"**
- Fix quality issues immediately - don't defer or ignore them

**Progress tracking:**

- Update documents immediately after task completion
- Keep all related files synchronized
- Show clear progress indicators
- Celebrate milestones (story completion, feature completion)

**User experience:**

- Make discovery feel natural, not intrusive
- Provide helpful context at each step
- Suggest next actions after completion
- Support both explicit and implicit workflows

---

Build systematically. Test thoroughly. Ship confidently.
