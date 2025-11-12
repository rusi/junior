# Commit Command

## Purpose

Intelligent git commit that stages files from current session, analyzes changes, and generates standardized commit messages.

## Type

Direct execution - Immediate action with user confirmation at key points

## When to Use

- Ready to commit changes from current session
- Need help writing clear commit message
- Want to review and confirm changes before committing

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write`:

```json
{
  "todos": [
    {"id": "analyze-status", "content": "Analyze git status and identify changes", "status": "in_progress"},
    {"id": "update-docs", "content": "Update related documentation", "status": "pending"},
    {"id": "stage-files", "content": "Stage session files with user confirmation", "status": "pending"},
    {"id": "generate-message", "content": "Generate commit message", "status": "pending"},
    {"id": "commit-changes", "content": "Execute commit", "status": "pending"}
  ]
}
```

### Step 2: Git Status Analysis

**Check current git state:**

```bash
git status --porcelain
```

**Analyze changes:**

1. **Identify session files:**
   - Files edited/created in current agent session
   - Exclude files from previous sessions

2. **If no changes:**
   - Display clean status and exit

3. **Categorize changes:**
   - Code files (implementation)
   - Test files (validation)
   - Configuration files
   - Documentation files

### Step 3: Update Related Documentation

**CRITICAL: Update docs BEFORE staging so they're included in commit**

Intelligently identify and update any documentation that relates to the code changes:

**What to look for:**
- READMEs that describe changed functionality
- Story files that track the changed code
- Technical specs that document changed components
- API docs for changed endpoints
- Any documentation referencing the changed files

**What to update:**
- Mark completed tasks: `- [ ]` → `- ✅`
- Update progress tracking
- Update status fields
- Add notes about implementation changes
- Keep documentation in sync with reality

**Skip if:**
- Changes are only documentation
- No related docs found

### Step 4: Stage Files

**Session-Based Staging Logic:**

**CRITICAL: Stage only files from current agent session**

**CRITICAL: NEVER use `git add .` - Always stage files explicitly file-by-file**

**Present staging plan:**
```
📁 Files to stage (from this session):

Code changes:
  M  src/auth.ts
  M  src/auth.test.ts

Documentation updates:
  M  .junior/features/feat-1-auth/user-stories/feat-1-story-2-login.md
  M  .junior/features/feat-1-auth/user-stories/README.md

📋 Excluding (not part of this session):
  M  backend/other.py
  M  frontend/widget.tsx

Stage these session files? [yes/no/all]
```

**Options:**
- **yes** - Stage session files (code + docs) (default)
- **no** - Cancel
- **all** - Stage all modified files (override default)

**Stage explicitly:**
```bash
git add src/auth.ts src/auth.test.ts .junior/features/feat-1-auth/user-stories/feat-1-story-2-login.md .junior/features/feat-1-auth/user-stories/README.md
```

### Step 5: Generate Commit Message

**Analyze changes to determine commit type:**

**Commit Types:**
- `feat` - New features
- `fix` - Bug fixes and corrections
- `docs` - Documentation updates
- `refactor` - Code restructuring without feature changes
- `test` - Adding or updating tests
- `chore` - Maintenance tasks (dependencies, cleanup)
- `config` - Configuration changes

**Message Generation Logic:**

1. **Analyze for work context:**
   - Determine if changes are part of specific work (features, experiments, bugfixes, etc.)
   - Extract context identifier if found: `feat-1-story-2`, `exp-3`, etc.
   - Add status: (WIP) if in progress, ✅ if completed, omit if not part of tracked work

2. Analyze file changes to determine primary type
3. Generate concise subject line with context if found
4. Add optional detailed body with bullet points
5. Use imperative mood ("Add feature" not "Added")

**Format (with context):**
```
[type]([context]): [status] [brief description]

[Optional details]
```

**Format (without context):**
```
[type]: [brief description]

[Optional details]
```

**Examples:**
- `feat(feat-1-story-2): ✅ implement login endpoint`
- `feat(feat-1-story-3): WIP add OAuth integration`
- `fix(exp-2): resolve memory leak in data processor`
- `docs: update API reference`

### Step 6: User Review & Commit Execution

**Present generated message:**

```
💬 Generated Commit Message:
┌─────────────────────────────────────────────
│ feat: add JWT authentication system
│ 
│ - Implement token generation and validation
│ - Add login/logout endpoints
│ - Include authentication middleware
│ - Add comprehensive tests
└─────────────────────────────────────────────

Proceed with this commit? [yes/no/edit]
```

**Options:**
- **yes** - Commit with generated message
- **no** - Cancel commit
- **edit** - Modify message before committing

**If changes needed:**

If user wants to make additional changes before committing:
- **DON'T reset** - Keep files staged
- User makes additional edits
- Stage the new changes: `git add [new files]`
- Re-review and commit when ready

**Execute commit:**

```bash
git commit -m "[generated message]"
```

**Show completion:**

```
✅ Commit completed successfully!

📝 Commit: a1b2c3d - feat: add JWT authentication system
📁 Files: 5 staged (3 code + 2 docs)
📊 Changes: +45 -12 lines
```

## Format Guidelines

**Subject Line:**
- Under 80 characters
- Capitalize first word after colon
- Use imperative mood
- No period at end

**Body (optional):**
- Blank line after subject
- Bullet points for multiple changes
- Wrap at 80 characters
- Explain what and why

## Tool Integration

**Primary tools:**
- `todo_write` - Progress tracking
- `run_terminal_cmd` - Git commands
- `read_file` - Read story files and documentation
- `search_replace` - Update documentation checkboxes and progress
- `glob_file_search` - Find related story files
- `grep` - Search for file references in documentation
- `codebase_search` - Context analysis (if needed)

**Git commands:**
- `git status --porcelain` - Check status
- `git add file1.ts file2.ts` - Stage files explicitly
- `git commit -m "[message]"` - Commit changes

**Documentation commands:**
- `find .junior -name "feat-*-story-*.md"` - Find story files
- `grep -r "filename" .junior/` - Find file references

**CRITICAL:** NEVER use `git add .` - Always stage files explicitly by name, one by one.

## Git Command Reference

**Checking status:**
```bash
git status                  # Overview
git status --porcelain      # Script-parseable format
```

**Viewing changes:**
```bash
git diff                    # Unstaged changes
git diff --cached           # Staged changes
git show HEAD               # Last commit
```

**Staging:**
```bash
git add file.ts             # Stage specific file
git add file1.ts file2.ts   # Stage multiple files explicitly
```

**CRITICAL:** NEVER use `git add .` or `git add -A` - Always list files explicitly.

## Examples

**With work context:**
```
feat(feat-1-story-2): ✅ implement login endpoint

- Add JWT token generation
- Implement password validation
- Add comprehensive tests
```

```
feat(feat-1-story-3): WIP add OAuth integration

- Google OAuth provider configured
- Callback endpoint implemented
- TODO: Add token refresh logic
- TODO: Handle error cases
```

```
fix(exp-2): resolve memory leak in data processor

Handle cleanup in destructor properly.
```

**Without context:**
```
fix: resolve Safari compatibility in auth flow

Handle edge case where localStorage is disabled.
```

**Documentation:**
```
docs: update API reference for authentication
```

**Refactor:**
```
refactor: extract validation logic to utils

Improve testability and reusability.
```

---

Clear commits. Clear intent. Simple.
