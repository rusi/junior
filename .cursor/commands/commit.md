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
    {"id": "analyze-status", "content": "Analyze git status and determine staging", "status": "in_progress"},
    {"id": "stage-files", "content": "Stage session files with user confirmation", "status": "pending"},
    {"id": "generate-message", "content": "Generate commit message", "status": "pending"},
    {"id": "commit-changes", "content": "Execute commit", "status": "pending"}
  ]
}
```

### Step 2: Git Status Analysis & Staging Strategy

**Check current git state:**

```bash
git status --porcelain
```

**Session-Based Staging Logic:**

**CRITICAL: Stage only files from current agent session**

**CRITICAL: NEVER use `git add .` - Always stage files explicitly file-by-file**

1. **If no staged files exist:**
   - Identify files edited/created in this session only
   - Exclude all other modified files
   - Present staging plan for confirmation
   - Stage explicitly: `git add file1.ts file2.ts file3.ts`

2. **If staged files exist:**
   - Review what's staged
   - Proceed or modify

3. **If no changes:**
   - Display clean status and exit

**Present staging plan:**
```
📁 Files to stage (from this session):
  M  src/auth.ts
  ?? src/auth.test.ts

📋 Excluding (not part of this session):
  M  backend/other.py
  M  frontend/widget.tsx

Stage these session files? [yes/no/all]
```

**Options:**
- **yes** - Stage session files (default)
- **no** - Cancel
- **all** - Stage all modified files (override default)

### Step 3: Generate Commit Message

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

1. Analyze file changes to determine primary type
2. Generate concise subject line (<80 characters)
3. Add optional detailed body with bullet points
4. Use imperative mood ("Add feature" not "Added")

**Format:**
```
[type]: [brief description]

[Optional details]
```

### Step 4: User Review & Commit Execution

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

**Execute commit:**

```bash
git commit -m "[generated message]"
```

**Show completion:**

```
✅ Commit completed successfully!

📝 Commit: a1b2c3d - feat: add JWT authentication system
📁 Files: 3 staged
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
- `codebase_search` - Context analysis (if needed)

**Git commands:**
- `git status --porcelain` - Check status
- `git add file1.ts file2.ts` - Stage files explicitly
- `git commit -m "[message]"` - Commit changes

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

**Feature:**
```
feat: add user authentication

- Implement JWT token generation
- Add login/logout endpoints
- Include authentication middleware
```

**Bug fix:**
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


