# Commit Command

## Purpose

Intelligent git commit that stages files from current session, analyzes changes, and generates standardized commit messages.

## 🔴 CRITICAL: Session-Only Commits

**This command commits ONLY files created/modified in THIS conversation thread.**

What gets committed:
- ✅ Files you created in this session
- ✅ Files you edited in this session
- ✅ Documentation updated in this session

What does NOT get committed:
- ❌ Files from previous sessions/conversations
- ❌ Unrelated changes showing in git status
- ❌ Files you didn't touch in THIS thread
- ❌ Random modified files from other work

**The agent tracks what was done in THIS conversation and only stages those specific files.**

If you see files in git status that aren't from this session, they will be EXCLUDED from staging.

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
    {"id": "validate-tests", "content": "Run test validation if code changes present", "status": "pending"},
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

**🔴 CRITICAL: Analyze changes to identify ONLY session files**

1. **Identify session files (THIS conversation thread only):**
   - Review conversation history to track files created/edited
   - Files you explicitly worked on in THIS session
   - **Exclude ALL files from previous sessions/threads**
   - **Exclude ALL unrelated changes in git status**

2. **If no session changes:**
   - Display "No files from this session to commit" and exit

3. **Categorize session changes:**
   - Code files (implementation)
   - Test files (validation)
   - Configuration files
   - Documentation files

**Example:**
```
Session files (THIS thread):
  ✅ feat-2-overview.md (created in this session)
  ✅ feat-2-story-1.md (created in this session)

Non-session files (EXCLUDE):
  ❌ other.py (from different work)
  ❌ widget.tsx (from previous session)
  ❌ submodules (not touched in this session)
```

### Step 3: Update Related Documentation

**🔴 CRITICAL: Update docs BEFORE staging - This step is MANDATORY, not optional**

**You MUST check for and update documentation EVERY TIME before staging files.**

**Process:**
1. **Check for story files** related to the changes:
   ```bash
   # Find story files in .junior/features/
   find .junior/features -name "*story*.md" | xargs grep -l "filename_you_changed"
   ```

2. **Read the story files** to see if tasks need updating

3. **Update story progress:**
   - Mark completed tasks: `- [ ]` → `- ✅`
   - Update story status if all tasks complete: `Status: In Progress` → `Status: Completed`
   - Update progress tracking in `feat-N-stories.md`
   - Update task counts and percentages

4. **Update other documentation:**
   - READMEs that describe changed functionality
   - Technical specs that document changed components
   - API docs for changed endpoints
   - Any documentation referencing the changed files

**Example:**
```bash
# Changed: .cursor/commands/migrate.md
# Must check: .junior/features/feat-1-core-commands/user-stories/feat-1-story-8-migrate-command.md
# Must update: Task checkboxes, status, progress counts
```

**This step is NOT optional:**
- Even if changes seem trivial
- Even if you "think" docs are already up to date
- Even if you're in a hurry

**Skip ONLY if:**
- Changes are pure documentation updates (no code changed)
- Absolutely no related docs exist (rare)

### Step 4: Test & Coverage Validation

**CRITICAL: Validate quality before committing code changes**

**Check if code changes exist:**

If session files include code changes (not just documentation/config):
- Detect code files: `.ts`, `.js`, `.py`, `.go`, `.rs`, `.c`, `.cpp`, `.h`, `.hpp`, `.swift`, etc.
- Skip if only documentation, config, or non-code files changed

**Prompt user for validation:**

```
🧪 Code changes detected

You're about to commit code changes:
  M  src/auth.ts
  M  src/auth.test.ts

Run test validation before committing? [yes/no/skip]

Options:
- yes: Run full test suite and coverage check (recommended)
- no: Skip validation (not recommended for code changes)
- skip: I've already run tests manually
```

**If user chooses "yes", run validation:**

**1. Run test suite:**

```bash
# Use project's test command (language-agnostic)
npm test              # Node.js/JavaScript
pytest --cov          # Python
go test -cover ./...  # Go
cargo test            # Rust
make test             # C/C++ (typical)
swift test            # Swift
# etc. (detect from project structure)
```

**2. Generate coverage report:**

```bash
# Generate coverage with detailed output
npm test -- --coverage                    # Jest
pytest --cov --cov-report=term-missing   # Python
go test -coverprofile=coverage.out ./... # Go
cargo tarpaulin                          # Rust
gcov / lcov                              # C/C++
swift test --enable-code-coverage        # Swift
```

**3. Display validation results:**

```
🔍 Test Validation Results

Tests:
✅ All tests passing: 45/45 (100%)
✅ No failing tests

Coverage:
✅ Overall coverage: 98%
⚠️ Changed files coverage: 95%
  - src/auth.ts: 98%
  - src/auth.test.ts: 100%

✅ Safe to commit!
```

**4. If validation fails:**

```
❌ Test Validation Failed

Tests:
❌ 2 tests failing
  - src/auth.test.ts:45 - Login with invalid password
  - src/auth.test.ts:67 - Token expiration

Coverage:
❌ Overall coverage: 87% (target: 90%+)
❌ Changed files:
  - src/auth.ts: 75% (missing lines: 45-52, 89-95)

⚠️ NOT RECOMMENDED TO COMMIT

Options:
1. Fix failing tests and improve coverage (recommended)
2. Commit anyway (not recommended - may break builds)
3. Cancel and fix issues first

Proceed with commit anyway? [yes/no]
```

**Validation outcomes:**

- **All tests pass + coverage good (90%+)**: Proceed to staging normally
- **Tests fail or coverage low (<90%) AND user commits anyway**: Mark as WIP and add warning note
- **User chose "no" or "skip"**: Proceed to staging with warning note

**Commit marking based on validation:**

**If user skipped validation (chose "no" or "skip"):**
```
⚠️ Note: Committed without test validation
```

**If validation FAILED but user committed anyway:**
- Automatically prefix commit type with WIP
- Add warning note about failures
```
WIP: [original commit message]

⚠️ WARNING: Committed with failing tests/incomplete coverage
- Tests failing: 2
- Coverage: 87% (target: 90%+)
```

### Step 5: Stage Files

**🔴 CRITICAL: Session-Based Staging Logic**

**Stage ONLY files from THIS conversation thread - nothing else!**

**NEVER use `git add .` - Always stage files explicitly file-by-file**

**How to identify session files:**
1. Review conversation history - what files did the agent create/edit?
2. Cross-reference with git status
3. **When in doubt, ASK the user which files are from this session**

**Present staging plan with clear separation:**
```
📁 Files to stage (from THIS session):

Code changes:
  M  src/auth.ts              ← Created in this thread
  M  src/auth.test.ts         ← Modified in this thread

Documentation updates:
  M  .junior/features/feat-1-auth/user-stories/feat-1-stories.md     ← Updated in this thread
  M  .junior/features/feat-1-auth/user-stories/feat-1-story-2-login.md ← Created in this thread

📋 Excluding (NOT part of this session):
  M  backend/other.py         ← From different work
  M  frontend/widget.tsx      ← From previous session
  M  submodule/              ← Not touched in this thread

Stage these session files? [yes/no/all]
```

**Options:**
- **yes** - Stage session files (code + docs) (default)
- **no** - Cancel
- **all** - Stage all modified files (override default)

**Stage explicitly:**
```bash
git add src/auth.ts src/auth.test.ts .junior/features/feat-1-auth/user-stories/feat-1-story-2-login.md .junior/features/feat-1-auth/user-stories/feat-1-stories.md
```

### Step 6: Generate Commit Message

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

### Step 7: User Review & Commit Execution

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

**Test validation commands (language-agnostic):**
- `npm test` / `npm test -- --coverage` - Node.js/JavaScript
- `pytest --cov --cov-report=term-missing` - Python
- `go test -cover ./...` - Go
- `cargo test` / `cargo tarpaulin` - Rust
- `make test` / `gcov` / `lcov` - C/C++
- `swift test --enable-code-coverage` - Swift

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
