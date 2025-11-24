# Status Command

## Purpose

Provide comprehensive project overview with git state, active work, all features, research/experiments, and smart next-action suggestions.

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

Create todos using `todo_write`:

```json
{
  "todos": [
    {"id": "git-status", "content": "Analyze git state", "status": "in_progress"},
    {"id": "active-work", "content": "Detect active work in features", "status": "pending"},
    {"id": "all-features", "content": "Scan all features with completion", "status": "pending"},
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
Last commit: "feat: add /implement command" (2 hours ago)
Uncommitted: 3 modified files
```

### Step 3: Active Work Detection

**Scan `.junior/features/` for in-progress features:**

```bash
# Find all feature directories
find .junior/features -name "feat-*" -type d -maxdepth 1

# For each feature, load user-stories/feat-N-stories.md
# Parse task completion and identify features with progress > 0%
```

**Identify active work:**
- Features with `Status: In Progress`
- Features with task progress > 0% and < 100%
- Show current story and next task for each
- Highlight most recently modified feature

**Output format:**

```
📋 ACTIVE WORK
2 features in progress:

1. feat-1-core-commands (Story 3/12, 15/98 tasks, 15%)
   • Current: Story 3 - Implement /status Command (In Progress)
   • Next: Task 3.2 - Create status.md command file

2. feat-2-advanced-features (Story 1/5, 2/15 tasks, 13%)
   • Current: Story 1 - Initialize command (In Progress)
   • Next: Task 1.3 - Create directory structure
```

### Step 4: All Features Summary

**Comprehensive feature view:**

```bash
# List ALL features
find .junior/features -name "feat-*" -type d -maxdepth 1 | sort

# For each feature:
# - Read feature.md for status
# - Read user-stories/feat-N-stories.md for task counts
# - Calculate completion percentage
# - Group by status: In Progress → Planning → Completed
```

**Status determination:**
- **In Progress:** Task progress > 0% and < 100%
- **Planning:** Task progress = 0%
- **Completed:** Task progress = 100%

**Output format:**

```
📊 ALL FEATURES
Total: 4 features | 35/98 tasks complete (36%)

In Progress (2):
1. feat-1-core-commands (15/98 tasks - 15%)
   • Next: Story 3 - Implement /status Command

2. feat-2-advanced-features (2/15 tasks - 13%)
   • Next: Story 1 - Initialize command

Planning (1):
• feat-3-integrations (0/22 tasks)
  • Start with: Story 1 - GitHub Integration

Completed (1):
• feat-0-bootstrap (8/8 tasks) ✅
```

### Step 5: Research & Experiments

**Scan knowledge base:**

```bash
# Research documents
ls -t .junior/research/*.md | head -5

# Experiments
find .junior/experiments -name "exp-*" -type d
```

**For experiments, check status:**
```bash
# Check experiment.md for Status field
grep "^> Status:" experiment.md

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

### Step 6: Smart Next-Action Suggestions

**Contextual decision tree:**

**Priority 1: Immediate Blockers**
- Merge conflicts exist → Resolve conflicts first
- Branch significantly behind (5+ commits) → Sync with main
- Uncommitted changes → Consider `/commit`

**Priority 2: Active Work (Continue Momentum)**
- In-progress features exist → Continue with `/implement feat-N-story-M`
- Current story complete → Start next story
- Feature nearly complete (>80%) → Push to completion

**Priority 3: Planning Work (Ready to Start)**
- Planning features ready → Start with `/implement`
- Recent research without features → Create feature with `/feature`
- Experiments with findings → Document as feature

**Priority 4: New Work (Starting Fresh)**
- No active work → Create new feature with `/feature`
- Multiple planning features → Review and prioritize
- No features → Start with `/feature` to plan first feature

**Priority 5: Maintenance (Always Available)**
- Always suggest `/commit` if uncommitted changes exist
- Code cleanup opportunities
- Documentation updates

**Output format:**

```
💡 NEXT ACTIONS
Priority 1: Continue Active Work
• Complete feat-1-story-3 (4 tasks remaining, ~2-3 hours)
  /implement feat-1-story-3

Priority 2: Maintenance
• Commit current changes: /commit

Priority 3: Planning
• Review feat-3-integrations (ready to start)
  /implement feat-3-story-1
```

### Step 7: Present Complete Status Report

**Present as clean, formatted text** (not in code blocks):

```
🔍 Junior Status Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 GIT STATUS
Branch: feat-1-implementation (3 commits ahead of main)
Last commit: "feat: add /implement command" (2 hours ago)
Uncommitted: 3 modified files

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 ACTIVE WORK
2 features in progress:

1. feat-1-core-commands (Story 3/12, 15/98 tasks, 15%)
   • Current: Story 3 - Implement /status Command (In Progress)
   • Next: Task 3.2 - Create status.md command file

2. feat-2-advanced-features (Story 1/5, 2/15 tasks, 13%)
   • Current: Story 1 - Initialize command (In Progress)
   • Next: Task 1.3 - Create directory structure

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 ALL FEATURES
Total: 4 features | 17/123 tasks complete (14%)

In Progress (2):
1. feat-1-core-commands (15/98 tasks - 15%)
   • Next: Story 3 - Implement /status Command

2. feat-2-advanced-features (2/15 tasks - 13%)
   • Next: Story 1 - Initialize command

Planning (1):
• feat-3-integrations (0/22 tasks)
  • Start with: Story 1 - GitHub Integration

Completed (1):
• feat-0-bootstrap (8/8 tasks) ✅

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
  /implement feat-1-story-3

Priority 2: Maintenance
• Commit current changes: /commit

Priority 3: Planning
• Review feat-3-integrations (ready to start)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ QUICK COMMANDS
/implement        # Continue or start implementation
/feature          # Create new feature
/commit           # Commit changes
/research         # Research new topic
```

## Tool Integration

**Primary tools:**

- `run_terminal_cmd` - Git status, log, branch analysis
- `list_dir` - Scan `.junior/` directories
- `glob_file_search` - Find feature/research/experiment directories
- `read_file` - Load feature specs, stories, experiment status
- `grep` - Parse task completion, status fields

**Parallel execution opportunities:**

- Git commands (status, log, branch info)
- Directory scans (features, research, experiments)
- File reads (multiple feature specs)

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
• Initialize Junior workflow: /init (coming soon)
• Create first feature: /feature
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

