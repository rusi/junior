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

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write`:

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

**Parse user input for explicit or implicit story selection:**

**Input Patterns:**

1. **Explicit story ID:** `/implement feat-1-story-2` or `/implement feat-1-story-2-auth`
   - Parse story identifier from input
   - Validate story exists
   - **Confidence: 95%+** → Proceed directly

2. **Vague/implicit:** `/implement` or `/implement next` or `/implement next story`
   - Scan `.junior/features/` for all features
   - Load `user-stories/feat-{N}-stories.md` for each feature
   - Identify next incomplete story based on progress
   - **Confidence: <95%** → Confirm with user before proceeding

**Discovery Logic:**

```bash
# Scan for features
find .junior/features -name "feat-*" -type d -maxdepth 1

# For each feature, load feat-{N}-stories.md
# Parse story status and progress
# Identify first story with status "Not Started" or "In Progress"
```

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
User: /implement feat-1-story-2
Junior: [Loads story directly and starts context gathering]
```

**Vague input (low confidence):**
```
User: /implement
Junior: 📋 Story Discovery
        
        Based on current progress, next story appears to be:
        **Story:** Story 2: User Dashboard
        
        Is this the story you want to implement? [yes/no/list]
```

**Next story request:**
```
User: /implement next story
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

You have uncommitted changes from previous work.
Consider committing before starting new story.

Use /commit to stage and commit changes.

Proceed anyway? [yes/no]
```

**Note:** This is a recommendation, not a hard blocker — user may be continuing same story.

### Step 4: Context Gathering & Analysis

**CRITICAL: Comprehensive context loading before implementation**

**Load story and feature context:**

- Main story file: `.junior/features/feat-N-{name}/user-stories/feat-N-story-M-{name}.md`
- Progress tracking: `.junior/features/feat-N-{name}/user-stories/feat-N-stories.md`
- Feature spec: `.junior/features/feat-N-{name}/feature.md`
- Related specs: `.junior/features/feat-N-{name}/specs/*.md` (if exist)
- Dependencies: Check other features referenced in story

**Parse story structure:**

- User story and acceptance criteria
- Implementation tasks list
- Definition of Done
- Technical notes and dependencies
- Reference implementation notes (if any)

**Analyze current codebase:**

Use `codebase_search` to understand:

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

- Build configuration (package.json, Cargo.toml, go.mod, etc.)
- Test configuration (jest.config.js, pytest.ini, etc.)
- Linting and formatting rules
- CI/CD pipelines (if relevant to testing)

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

**IMMEDIATELY after reviewing tasks**, replace generic TODOs with specific story tasks using `todo_write`:

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

**🔴 MANDATORY: After each task completion:**

1. **Update story file** - Mark task: `- [ ]` → `- ✅`
2. **Update feat-N-stories.md** - Recalculate progress (X/Y tasks, percentage)
3. **Update TODO** - Mark corresponding todo as completed using `todo_write`
4. **Show progress display** - Present current story progress to user:

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

5. **Present next task** - Show next task details and start working on it

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

1. **First**: Run only tests for current story/feature
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

**For non-coding projects:**

- Verify all tasks completed
- Review deliverables with user
- Validate acceptance criteria met
- Skip test/coverage requirements

### Step 6: Final Test & Coverage Verification (Coding Projects)

**CRITICAL: Comprehensive validation before story completion**

After all tasks are executed, run final comprehensive verification:

**1. Run complete test suite:**

```bash
# Language-agnostic - use project's test command
npm test              # Node.js/JavaScript
pytest --cov          # Python
go test -cover ./...  # Go
cargo test            # Rust
make test             # C/C++
swift test            # Swift
```

**2. Generate and verify coverage report:**

```bash
npm test -- --coverage                    # Jest
pytest --cov --cov-report=html           # Python
go test -coverprofile=coverage.out ./... # Go
cargo tarpaulin --out Html               # Rust
gcov / lcov                              # C/C++
swift test --enable-code-coverage        # Swift
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

4. **Update feature.md status if needed:**

Check if all stories in feature are complete:
- If yes: Update feature status to "Completed"
- If no: Update to "In Progress" if was "Planning"

5. **Present completion summary:**

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
1. Run /commit to commit these changes
2. Continue with Story 3: User Settings
3. Review feature progress

What would you like to do next?
```

## Document Update Policy

**When task is marked complete, update:**

- **Story file:** Mark task with ✅
- **feat-N-stories.md:** Update task count and percentage
- **feature.md:** Update status if needed (Planning → In Progress → Completed)
- **Related stories:** Note if dependencies affect other stories

**Automatic updates:**
- Task checkboxes in story file
- Progress percentages in feat-N-stories.md
- Story status when all tasks complete

**Reminder to user:**
- Update specs if implementation differs from plan
- Update related documentation
- Note any follow-up work needed

## Tool Integration

**Primary tools:**

- `todo_write` - Progress tracking throughout execution
- `codebase_search` - **CRITICAL** - Understand architecture, patterns, existing functionality, test frameworks
- `glob_file_search` - Find feature and story files
- `list_dir` - Scan features directory
- `read_file` - Load story files, feat-N-stories.md, feature.md, specs, project config
- `search_replace` - Update task checkboxes and progress
- `run_terminal_cmd` - Git status check, run tests
- `grep` - Parse story files for tasks

**Parallel execution opportunities:**

- Context gathering (load multiple spec files, run multiple codebase searches)
- Test framework analysis (search for test patterns, load test configs)
- Architecture understanding (search for similar implementations, integration points)

**Git commands:**

```bash
git status --short           # Check for uncommitted changes
```

**File operations:**

```bash
# Find features
find .junior/features -name "feat-*" -type d -maxdepth 1

# Find story files
find .junior/features/feat-N-name/user-stories -name "feat-*-story-*.md"
```

## Progress Tracking

**Progress tracking happens at specific points in the workflow:**

1. **After Step 4 (Context Gathering):** Replace generic TODOs with story-specific tasks
2. **After each task completion (Step 5):** Show progress display, update files, mark TODO complete
3. **After final verification (Step 6):** Confirm all tasks complete, all tests pass
4. **At story completion (Step 7):** Update story status, update feature progress

**See Step 5 for the mandatory progress display format shown after each task.**

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

**No features found:**

```
❌ No features found

No feature specifications exist in .junior/features/

Create a feature first using /feature command.
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

Use /implement with a valid story ID or /implement to discover next story.
```

**Ambiguous selection:**

```
⚠️ Multiple options available

Cannot determine which story to implement. Please specify:

Available stories:
1. feat-3-story-2-user-dashboard (Not Started)
2. feat-4-story-1-payment-gateway (In Progress, 3/5 tasks)

Use: /implement feat-3-story-2 or /implement feat-4-story-1
```

**Blocking issues:**

If blocked by technical issues during implementation:

```markdown
Task status in story file:
- [ ] 2.3 Implement API integration ⚠️ Blocking issue: Third-party API documentation incomplete

Update story notes section to document the blocking issue.
```

**Resolution strategies:**

1. **Try alternative implementation approach** - Is there another way to achieve the same goal?
2. **Research solution** - Use `/research` command for technical investigation
3. **Break down into smaller components** - Can this be split into manageable pieces?
4. **Maximum 3 attempts** - After 3 failed attempts, escalate or document as blocked

**Document blocked tasks:**
- Mark task with ⚠️ and blocking issue description
- Update story status to note blockers
- Continue with other non-blocked tasks if possible
- Revisit blocked tasks after resolution

## Best Practices

**Context gathering:**

- **Always** run comprehensive codebase analysis before implementing
- Use multiple parallel `codebase_search` calls to understand architecture
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

