# Story 3: Implement /status Command

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** None (can run parallel to Story 2)
> **Deliverable:** Working /status command providing complete project overview and smart next-action suggestions

## User Story

**As a** developer working with Junior
**I want** to see complete project status at a glance
**So that** I can quickly understand what's happening and decide what to work on next

## Scope

**In Scope:**
- Create `.cursor/commands/status.md` command specification
- Display git status (branch, commits, uncommitted changes)
- Show active work (features in progress with current tasks)
- List all features with completion percentages
- Display research and experiments
- Provide smart next-action suggestions based on context
- Simple invocation: `/status` with no parameters

**Out of Scope:**
- Product planning integration (mission, roadmap - defer to /init)
- Build/CI status checking
- External tool integrations
- Historical analytics and trends

## Acceptance Criteria

- [ ] Given a git repository, when user runs `/status`, then current branch and commit status are displayed
- [ ] Given uncommitted changes exist, when `/status` runs, then modified files are listed with counts
- [ ] Given features exist in `.junior/features/`, when `/status` runs, then all features are listed with completion percentages
- [ ] Given features have progress > 0%, when `/status` runs, then they are highlighted as "In Progress"
- [ ] Given current context (git state, active work), when `/status` completes, then smart next-action suggestions are provided
- [ ] Given `.junior/research/` or `.junior/experiments/` exist, when `/status` runs, then they are summarized

## Implementation Tasks

- [ ] 3.1 Research `reference-impl/cursor/commands/status.md` for status display patterns
- [ ] 3.2 Run `/new-command` with prompt: "Create status command that displays comprehensive project overview with git state (branch, commits, uncommitted changes), all features from `.junior/features/` with completion percentages, active work highlighting, research/experiments summary, and smart next-action suggestions. Simple invocation (no parameters). Implements feat-1-story-3."
- [ ] 3.3 User review: Run `/status` in this project, verify all sections display correctly
- [ ] 3.4 Refine output format based on readability and usefulness
- [ ] 3.5 Test with various project states (clean git, uncommitted changes, multiple features)
- [ ] 3.6 Finalize: Verify smart suggestions are helpful and actionable

## Technical Notes

**Command Structure:**

```markdown
# Status Command

## Purpose
Provide comprehensive project overview with git state, active work, all features, and smart next-action suggestions.

## Process

### Step 1: Git Status Analysis
- Run `git status --porcelain` for file status
- Run `git branch --show-current` for branch name
- Run `git log -1 --format=%s` for last commit message
- Parse and format output clearly

### Step 2: Feature Discovery
- Scan `.junior/features/` for all feat-N-* directories
- Load user-stories/README.md for each feature
- Calculate completion percentages from task counts
- Categorize: In Progress (0% < progress < 100%), Planning (0%), Completed (100%)

### Step 3: Research & Experiments
- Scan `.junior/research/` for research documents
- Scan `.junior/experiments/` for experiment directories
- Show counts and most recent items

### Step 4: Smart Suggestions
- If uncommitted changes: "Consider running /commit"
- If in-progress features exist: "Continue with /implement on feat-N"
- If no features: "Start with /feature to plan your first feature"
- If features complete: "Create new feature with /feature or capture ideas with /idea"

### Output Format

```
🔍 Project Status

**Git Status:**
📍 Branch: feat-1-implementation
🔄 Last commit: "feat: add /implement command structure"
⚠️  3 uncommitted changes (M 2, A 1)

**Active Work:**
✨ 2 features in progress:
  - feat-1-core-commands (Story 2/12, 8/69 tasks, 12%)
  - feat-2-advanced-features (Story 1/5, 2/15 tasks, 13%)

**All Features:**
📋 In Progress (2): feat-1-core-commands, feat-2-advanced-features  
📝 Planning (1): feat-3-integrations
✅ Completed (0): none

**Research & Experiments:**
📚 3 research documents, 2 experiments
📊 Latest: 2025-11-09-tdd-patterns-research.md

**Next Actions:**
→ Continue Story 2: /implement feat-1-story-2
→ Or commit current changes: /commit
```
```

**Reference Implementation:**
- Adapt from `reference-impl/cursor/commands/status.md`
- Simplify to focus on Junior's core workflow
- Remove product planning aspects (defer to /init command)

**Workflow Strategy:**

**Research → Create → Review → Refine:**
1. Research `reference-impl/cursor/commands/status.md` for comprehensive status patterns
2. Use `/new-command` to generate status.md specification
3. User review: Run `/status` at various project checkpoints
4. Refine output format, suggestions, and display based on feedback

**Validation Testing:**
- Test with clean git state (verify displays correctly)
- Test with uncommitted changes (verify warnings)
- Test with multiple features (verify categorization: in-progress, planning, completed)
- Test with research/experiments (verify summaries)
- Test smart suggestions (verify relevance to current state)
- Verify output is scannable and actionable

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] `/status` command file created at `.cursor/commands/status.md`
- [ ] Git status displayed clearly (branch, commits, changes)
- [ ] All features listed with accurate completion percentages
- [ ] Active work highlighted properly
- [ ] Research and experiments summarized
- [ ] Smart suggestions provided based on context
- [ ] Output is scannable and well-formatted
- [ ] No regressions in project structure
- [ ] Code follows Junior's principles
- [ ] Documentation complete in status.md
- [ ] **User can run /status and see complete project overview**
- [ ] Tested on Junior project at different stages

