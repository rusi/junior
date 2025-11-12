# Story 2: Implement /implement Command

> **Status:** Not Started
> **Priority:** Critical
> **Dependencies:** Story 1 (to have complete feature workflow)
> **Deliverable:** Working /implement command that executes feature stories using TDD workflow

## User Story

**As a** developer with planned features
**I want** to execute feature stories systematically with TDD workflow
**So that** I can build features incrementally with tests guiding implementation

## Scope

**In Scope:**
- Create `.cursor/commands/implement.md` command specification
- Task discovery from `.junior/features/feat-N-*/user-stories/`
- Interactive story and task selection
- TDD workflow: write tests → implement → verify
- Progress tracking with task completion checkboxes
- Git status check (recommendation, not blocker)
- Integration with existing `.junior/` structure

**Out of Scope:**
- Automatic test generation
- AI-assisted code writing (user writes code, Junior guides workflow)
- Parallel task execution
- Story editing or reorganization

## Acceptance Criteria

- [ ] Given `.junior/features/` has feature specs, when user runs `/implement`, then available features and stories are displayed
- [ ] Given multiple features exist, when user selects a feature, then its stories and tasks are shown
- [ ] Given a story is selected, when execution starts, then git status is checked and uncommitted changes are noted (as recommendation)
- [ ] Given a task is being executed, when user completes it, then task checkbox is updated in story markdown file
- [ ] Given TDD workflow is active, when implementing tasks, then user is reminded to: write test → implement → verify cycle
- [ ] Given all story tasks are complete, when marking story done, then user-stories/README.md progress is updated

## Implementation Tasks

- [ ] 2.1 Research `reference-impl/cursor/commands/execute-task.md` for implementation patterns
- [ ] 2.2 Use `/new-command` to create `implement.md` command specification
- [ ] 2.3 Design task discovery logic: scan `.junior/features/`, parse story files, extract tasks
- [ ] 2.4 Design interactive selection: feature → story → task with clear status display
- [ ] 2.5 Design task execution tracking: update with ✅ (not [x]), update README.md progress
- [ ] 2.6 Add TDD workflow reminders and document update instructions after task completion
- [ ] 2.7 User review: Test complete workflow, request refinements
- [ ] 2.8 Finalize: Verify all features work correctly

## Technical Notes

**Command Structure:**

```markdown
# Implement Command

## Purpose
Execute feature stories systematically using Test-Driven Development workflow.

## Process

### Step 1: Task Discovery
- Scan `.junior/features/` for all feature directories
- Load user-stories/README.md for each feature
- Parse individual story files for tasks
- Display available work organized by feature

### Step 2: Selection
- Interactive selection: feature → story → task
- Show current status and progress
- Indicate dependencies and recommended order

### Step 3: Git Check
- Run `git status --short`
- Warn about uncommitted changes (recommendation)
- Allow user to proceed or commit first

### Step 4: TDD Execution Loop
- Guide user through TDD cycle for each task
- Remind: Write test → Implement → Verify
- Update task checkboxes in story markdown
- Track progress in user-stories/README.md

### Step 5: Completion
- Verify all acceptance criteria met
- Update story status
- Suggest next story or commit
```

**Reference Implementation:**
- Adapt from `reference-impl/cursor/commands/execute-task.md`
- Simplify to focus on TDD workflow guidance
- Remove Code Captain naming (`.code-captain/` → `.junior/`, `spec-N` → `feat-N`)

**File Operations:**
- Read: `.junior/features/feat-N-*/user-stories/*.md`
- Update: Task checkboxes `- [ ]` → `- [✅]` (use green checkmark emoji, not [x])
- Update: `user-stories/README.md` progress percentages and status
- Update: All related documents when task is marked complete

**Document Update Policy:**
When a task is completed, `/implement` must remind user to update:
- Story file: Mark task with ✅
- README.md: Update task count and percentage
- feature.md: Update status if needed (Planning → In Progress → Completed)
- specs/: Update technical specs if implementation differs from plan
- Related stories: Note if dependencies or integrations affect other stories

**Workflow Strategy:**

**Research → Create → Review → Refine:**
1. Research `reference-impl/cursor/commands/execute-task.md` for patterns and structure
2. Use `/new-command` to generate implement.md specification
3. User review: Test with `feat-1-core-commands` (this feature!), implement a story
4. Refine based on user experience and feedback

**Key Features to Test:**
- Task discovery from multiple features
- Interactive selection (feature → story → task)
- Task completion with ✅ checkmark (verify green checkmark shows correctly)
- Progress tracking in README.md (verify percentages update)
- Document updates after task completion (verify related docs are updated)
- TDD workflow guidance (verify reminders are helpful)

**Validation Testing:**
- Use `/implement` to work on Story 3 or later stories in this feature
- Verify task selection is intuitive
- Ensure ✅ checkmarks display correctly (not [x])
- Confirm all related documents update when task completes

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] `/implement` command file created at `.cursor/commands/implement.md`
- [ ] Command discovers features and stories correctly
- [ ] Interactive selection works smoothly
- [ ] Task checkboxes update in markdown files
- [ ] Progress tracking updates in README.md
- [ ] TDD workflow guidance is clear throughout
- [ ] Git status check provides helpful recommendations
- [ ] No regressions in `.junior/` structure
- [ ] Code follows Junior's principles
- [ ] Documentation complete in implement.md
- [ ] **User can run /implement and execute tasks from this feature**
- [ ] Tested by implementing at least one complete story

