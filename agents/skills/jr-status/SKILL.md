---
name: jr-status
description: Produce a comprehensive project status report with git state, active work, progress analysis, and concrete next actions.
---

# Status Command

## Purpose

Provide comprehensive project overview with git state, active work, all features, research/experiments, an overall project completion percentage, and smart next-action suggestions.

## Type

Direct execution - Immediate action with no parameters

## When to Use

- Start your day with complete context
- Resume work after interruptions or context switches
- Decide what to work on next
- Track progress across the entire project
- Identify blockers early

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan`:

```json
{
  "todos": [
    {"id": "git-status", "content": "Analyze git state", "status": "in_progress"},
    {"id": "active-work", "content": "Detect active work in features", "status": "pending"},
    {"id": "all-features", "content": "Scan all features with completion", "status": "pending"},
    {"id": "roadmap-scope", "content": "Parse roadmap phases/features and establish total product scope", "status": "pending"},
    {"id": "roadmap-mapping", "content": "Map roadmap features to Junior features and compute feature-level completion", "status": "pending"},
    {"id": "project-completion", "content": "Calculate roadmap-weighted overall completion and execution-unit breakdown", "status": "pending"},
    {"id": "research-experiments", "content": "Summarize research and experiments", "status": "pending"},
    {"id": "smart-suggestions", "content": "Generate contextual next actions", "status": "pending"},
    {"id": "present-report", "content": "Present complete status report", "status": "pending"}
  ]
}
```

### Step 2: Git Status Analysis

**Analyze current git state:**

```bash
git branch --show-current              # Current branch
git status --porcelain                 # File changes
git log -1 --format="%s (%ar)"        # Last commit
git log main..HEAD --oneline           # Commits ahead
git log HEAD..main --online           # Commits behind
```

**Parse and present:**
- Branch name and position relative to main
- Last commit message and time
- Uncommitted changes (modified, added, deleted files)
- Branch divergence (ahead/behind main)

**Output format:**

```
📍 GIT STATUS
Branch: feat-1-implementation (3 commits ahead of main)
Last commit: "feat: add /jr-implement command" (2 hours ago)
Uncommitted: 3 modified files
```

### Step 3: Active Work Detection

**Detect current stage:** Use stage detection from `01-structure.mdc` to determine display format (flat vs component tree).

**Scan `.junior/features/` for in-progress features:**

Use stage-appropriate paths to find all features (see `01-structure.mdc` for path patterns).

For each feature, load `user-stories/feat-N-stories.md`, parse task completion, and identify features with progress > 0% and < 100%.

**Identify active work:**
- Features with `Status: In Progress`
- Features with task progress > 0% and < 100%
- Show current story and next task for each
- Highlight most recently modified feature

**Output format (Stage 1 - Flat):**

```
📋 ACTIVE WORK
2 features in progress:

1. feat-1-core-commands (Story 3/12, 15/98 tasks, 15%)
   • Current: Story 3 - Implement /jr-status Command (In Progress)
   • Next: Task 3.2 - Create status.md skill file

2. feat-2-advanced-features (Story 1/5, 2/15 tasks, 13%)
   • Current: Story 1 - Initialize command (In Progress)
   • Next: Task 1.3 - Create directory structure
```

**Output format (Stage 2+ - Component Grouped):**

```
📋 ACTIVE WORK
2 components with active features:

comp-1-core-framework (2 features active):
  1. feat-1-commands (Story 3/12, 15/98 tasks, 15%)
     • Current: Story 3 - Implement /jr-status Command (In Progress)
     • Next: Task 3.2 - Create status.md skill file

comp-2-installation (1 feature active):
  2. feat-5-installer (Story 1/5, 2/15 tasks, 13%)
     • Current: Story 1 - Bootstrap script (In Progress)
     • Next: Task 1.3 - Create directory structure
```

### Step 4: All Features Summary

**Comprehensive feature view:**

Use stage-appropriate scanning (see `01-structure.mdc` for path patterns).

For each feature:
- Read `feat-N-overview.md` for status
- Read `user-stories/feat-N-stories.md` for task counts
- Calculate completion percentage
- Group by status: In Progress → Planning → Completed

**Status determination:**
- **In Progress:** Task progress > 0% and < 100%
- **Planning:** Task progress = 0%
- **Completed:** Task progress = 100%

**Output format (Stage 1 - Flat):**

```
📊 ALL FEATURES
Total: 4 features | 35/98 tasks complete (36%)

In Progress (2):
1. feat-1-core-commands (15/98 tasks - 15%)
   • Next: Story 3 - Implement /jr-status Command

2. feat-2-advanced-features (2/15 tasks - 13%)
   • Next: Story 1 - Initialize command

Planning (1):
• feat-3-integrations (0/22 tasks)
  • Start with: Story 1 - GitHub Integration

Completed (1):
• feat-0-bootstrap (8/8 tasks) ✅
```

**Output format (Stage 2+ - Component Tree):**

```
📊 ALL FEATURES
Total: 3 components | 4 features | 35/98 tasks complete (36%)

comp-1-core-framework (2 features, 17/113 tasks - 15%):
  In Progress (2):
  • feat-1-commands (15/98 tasks - 15%)
    → Next: Story 3 - Implement /jr-status Command
  • feat-4-refactor (2/15 tasks - 13%)
    → Next: Story 1 - Initialize command

comp-2-installation (1 feature, 0/22 tasks):
  Planning (1):
  • feat-3-installer (0/22 tasks)
    → Start with: Story 1 - Bootstrap script

comp-3-integrations (1 feature, 8/8 tasks - 100%):
  Completed (1):
  • feat-0-bootstrap (8/8 tasks) ✅
```

### Step 5: Project Completion Percentage (Roadmap-Aware)

**Mission:** show one explicit `% complete` metric that reflects full product scope, not only drafted implementation tasks.

**Primary scope source (required when present):**
- `.junior/product/02-roadmap.md`

**Roadmap extraction rules (scope first):**
- Parse roadmap features from explicit feature headings first (e.g. `### Feature N: ...`) across roadmap sections.
- If explicit feature headings do not exist, parse feature lists in roadmap phase sections (`1. ...`, `- ...`, `* ...`) that clearly represent roadmap features.
- Use `## Execution Tracking` only as a status hint layer, never as the sole scope denominator when roadmap features are explicitly listed.
- Normalize feature labels before matching:
  - lowercase
  - remove numbering/punctuation
  - collapse whitespace
  - ignore wrapper text like "`/jr-feature` will define detailed scope"

**Roadmap-to-feature matching:**
- If roadmap sections provide explicit `Linked Spec` mapping, use it before fuzzy title matching.
- Match each roadmap feature to one Junior feature directory in `.junior/features/` using normalized slug/title similarity.
- Use feature title from `feat-N-overview.md` first; fallback to directory name.
- If multiple candidates match, choose the highest similarity and report ambiguity in notes.
- If no feature matches a roadmap item, treat it as planned-but-not-started (`0%`).

**Completion math (three-metric model):**
1. **Roadmap feature completion** (primary scope metric):
- For each roadmap feature:
  - `feature_percent = round((feature_task_done / feature_task_total) * 100)` when tasks exist
  - `feature_percent = 0` when no mapped feature/tasks exist
- Compute equal-weight roadmap feature progress:
  - `roadmap_units_done = sum(feature_percent / 100 for each roadmap feature)`
  - `roadmap_units_total = roadmap_feature_count`
  - `roadmap_feature_percent = round((roadmap_units_done / roadmap_units_total) * 100)` (0 if total is 0)
- This prevents one oversized feature backlog from dominating completion.

2. **Roadmap-declared evidence completion** (checklists/task lists):
- Parse evidence files referenced by roadmap (paths/links under progress sync or evidence sections).
- For each evidence markdown file:
  - Count checklist items (`- [ ]`, `- [x]`, `- ✅`) when present.
  - Parse explicit progress lines (`X/Y`) when present.
  - Compute file percent from available structures.
- Aggregate to:
  - `evidence_done_units`
  - `evidence_total_units`
  - `evidence_percent = round((evidence_done_units / evidence_total_units) * 100)` (0 if none)

3. **Execution workload completion** (always show as breakdown):
- `.junior/features/**/user-stories/*-stories.md` task totals/completed
- `.junior/improvements/**/user-stories/*-stories.md` task totals/completed
- `.junior/experiments/**/user-stories/*-stories.md` task totals/completed
- `.junior/debugging/dbg-*/` completion status (`dbg-N-resolution.md` present = completed)
- Compute:
  - `execution_done = task_done_total + debugging_done_units`
  - `execution_total = task_total + debugging_total_units`
  - `execution_percent = round((execution_done / execution_total) * 100)` (0 if total is 0)

**Overall completion rule (conservative):**
- If roadmap features exist and evidence exists:
  - `project_completion_percent = min(roadmap_feature_percent, evidence_percent)`
- If roadmap features exist and no evidence exists:
  - `project_completion_percent = roadmap_feature_percent`
- If roadmap features do not exist:
  - `project_completion_percent = evidence_percent` when evidence exists, else `execution_percent`
  - Print note: `Roadmap feature scope not found; using fallback completion sources.`

**Output format:**

```
🎯 PROJECT COMPLETION
Overall: 18% (conservative)
Breakdown:
• Roadmap features: 2.70/15.00 (18%)
• Roadmap evidence (checklists/tasks): 24/120 (20%)
• Execution units (tasks+debug): 36/77 (47%)
• Coverage note: 8/15 roadmap features currently mapped to Junior feature specs
```

### Step 6: Research & Experiments

**Scan knowledge base:**

```bash
# Research documents
ls -t .junior/research/*.md | head -5

# Experiments
find .junior/experiments -name "exp-*" -type d
```

**For experiments, check status:**
```bash
# Check exp-N-overview.md for Status field
grep "^> Status:" exp-N-overview.md

# Or check for findings directory
[ -d "findings" ] && echo "Completed" || echo "In Progress"
```

**Output format:**

```
🔬 RESEARCH & EXPERIMENTS
Recent Research (3):
• 2025-11-10: TDD Patterns for Command Development
• 2025-11-09: Command Structure Best Practices
• 2025-11-08: Git Workflow Integration

Experiments:
• exp-1-command-generation (Completed ✅, 2 findings)
• exp-2-status-formatting (In Progress 🚧)
```

### Step 7: Smart Next-Action Suggestions

**Contextual decision tree:**

**Priority 1: Immediate Blockers**
- Merge conflicts exist → Resolve conflicts first
- Branch significantly behind (5+ commits) → Sync with main
- Uncommitted changes → Consider `/jr-commit`

**Priority 2: Active Work (Continue Momentum)**
- In-progress features exist → Continue with `/jr-implement feat-N-story-M`
- Current story complete → Start next story
- Feature nearly complete (>80%) → Push to completion

**Priority 3: Planning Work (Ready to Start)**
- Planning features ready → Start with `/jr-implement`
- Recent research without features → Create feature with `/jr-feature`
- Experiments with findings → Document as feature

**Priority 4: New Work (Starting Fresh)**
- No active work → Create new feature with `/jr-feature`
- Multiple planning features → Review and prioritize
- No features → Start with `/jr-feature` to plan first feature

**Priority 5: Maintenance (Always Available)**
- Always suggest `/jr-commit` if uncommitted changes exist
- Code cleanup opportunities
- Documentation updates

**Output format:**

```
💡 NEXT ACTIONS
Priority 1: Continue Active Work
• Complete feat-1-story-3 (4 tasks remaining, ~2-3 hours)
  /jr-implement feat-1-story-3

Priority 2: Maintenance
• Commit current changes: /jr-commit

Priority 3: Planning
• Review feat-3-integrations (ready to start)
  /jr-implement feat-3-story-1
```

### Step 8: Present Complete Status Report

**Present as clean, formatted text** (not in code blocks):

```
🔍 Junior Status Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 GIT STATUS
Branch: feat-1-implementation (3 commits ahead of main)
Last commit: "feat: add /jr-implement command" (2 hours ago)
Uncommitted: 3 modified files

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 ACTIVE WORK
2 features in progress:

1. feat-1-core-commands (Story 3/12, 15/98 tasks, 15%)
   • Current: Story 3 - Implement /jr-status Command (In Progress)
   • Next: Task 3.2 - Create status.md skill file

2. feat-2-advanced-features (Story 1/5, 2/15 tasks, 13%)
   • Current: Story 1 - Initialize command (In Progress)
   • Next: Task 1.3 - Create directory structure

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 ALL FEATURES
Total: 4 features | 17/123 tasks complete (14%)

In Progress (2):
1. feat-1-core-commands (15/98 tasks - 15%)
   • Next: Story 3 - Implement /jr-status Command

2. feat-2-advanced-features (2/15 tasks - 13%)
   • Next: Story 1 - Initialize command

Planning (1):
• feat-3-integrations (0/22 tasks)
  • Start with: Story 1 - GitHub Integration

Completed (1):
• feat-0-bootstrap (8/8 tasks) ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 PROJECT COMPLETION
Overall: 21% (roadmap-weighted: 1.05/5.00 features)
Breakdown:
• Roadmap features tracked: 5
• Execution units (tasks+debug): 36/77 (47%)
• Coverage note: 3/5 roadmap features currently mapped to Junior feature specs

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔬 RESEARCH & EXPERIMENTS
Recent Research (3):
• 2025-11-10: TDD Patterns for Command Development
• 2025-11-09: Command Structure Best Practices
• 2025-11-08: Git Workflow Integration

Experiments:
• exp-1-command-generation (Completed ✅, 2 findings)
• exp-2-status-formatting (In Progress 🚧)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 NEXT ACTIONS
Priority 1: Continue Active Work
• Complete feat-1-story-3 (4 tasks remaining, ~2-3 hours)
  /jr-implement feat-1-story-3

Priority 2: Maintenance
• Commit current changes: /jr-commit

Priority 3: Planning
• Review feat-3-integrations (ready to start)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ QUICK COMMANDS
/jr-implement        # Continue or start implementation
/jr-feature          # Create new feature
/jr-commit           # Commit changes
/research         # Research new topic
```

## Tool Integration

**Primary tools:**

- `run_terminal_cmd` or `functions.shell_command` - Git status, log, branch analysis
- `list_dir` or `functions.shell_command` - Scan `.junior/` directories
- `glob_file_search` or `functions.shell_command` - Find feature/research/experiment directories
- `glob_file_search` or `functions.shell_command` - Find improvements/debugging directories
- `read_file` or `functions.shell_command` - Load feature specs, stories, experiment status
- `grep` (via `functions.shell_command`) - Parse task completion, status fields

**Parallel execution opportunities:**

- Git commands (status, log, branch info)
- Directory scans (features, improvements, debugging, research, experiments)
- File reads (multiple `*-stories.md` files and debug resolution files)

## Output Formatting Rules

**Critical formatting requirements:**

1. **Present as clean text** - NOT wrapped in code blocks
2. **Visual separators** - Use `━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━` between major sections
3. **Unicode icons** - 📍🔍📋📊🔬💡⚡✅🚧⚠️
4. **Numbered lists** - For in-progress features (1. 2. 3.)
5. **Bullet points** - For planning/completed features
6. **Sub-bullets** - For "Current:", "Next:", "Start with:" (indented)
7. **Scannable hierarchy** - Clear visual structure with proper indentation
8. **No section dividers within categories** - Use simple "In Progress (X):" headers

## Error Handling

**Old structure detected (graceful migration prompt):**

If flat features exist without the 3-stage structure:

```
⚠️ Old Junior structure detected

Your project uses an older Junior structure.

Run /jr migrate to update to the current 3-stage progressive structure.

This is a one-time migration that preserves all your work.

Continuing with status report...
```

**Note:** Status report continues - this is informational, not blocking.

**Not a git repository:**

```
❌ Not in a git repository

Initialize git first: git init
```

**No Junior structure:**

```
🔍 Junior Status Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 GIT STATUS
Branch: main (up to date)
Last commit: "Initial commit" (1 hour ago)
Working directory: Clean ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 ACTIVE WORK
No Junior features found
Project structure: Standard git repository

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 NEXT ACTIONS
• Initialize Junior workflow: /jr-init (coming soon)
• Create first feature: /jr-feature
```

**Corrupted state:**

```
⚠️  PROJECT ISSUES DETECTED
• File parsing errors in feat-2-advanced-features/user-stories/
• Missing feat-1-stories.md
• Invalid task format in feat-3-story-1.md

🔧 SUGGESTED FIXES
• Review and fix story file formats
• Ensure all features have user-stories/feat-N-stories.md
• Follow Junior's structure conventions
```

## Best Practices

**Performance:**
- Target <5 second execution time
- Limit git log queries to reasonable ranges
- Cache file reads when analyzing multiple features

**Accuracy:**
- Always calculate status from actual task completion
- Always calculate project completion from roadmap feature scope when `.junior/product/02-roadmap.md` exists
- Never use stage buckets as the only denominator when roadmap lists individual features
- Treat each roadmap feature as equal-weight for the roadmap scope `% complete`
- Parse roadmap-declared checklist/task evidence files and include them in completion analysis
- Use conservative overall completion (cap with roadmap evidence when available)
- Always include execution progress (features + improvements + experiments + debugging) as supporting breakdown
- Don't rely on manual status fields alone
- Validate file structure before parsing

**Clarity:**
- Keep output scannable and concise
- Prioritize actionable information
- Group related information logically

**Smart suggestions:**
- Analyze actual project state, not assumptions
- Prioritize based on developer flow (continue momentum)
- Always provide clear command examples

---

**Know where you are. See what's next. Build with focus.**
