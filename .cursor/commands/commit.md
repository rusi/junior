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
    {"id": "update-docs", "content": "Update ALL documentation sections", "status": "pending"},
    {"id": "verify-docs", "content": "Verify documentation completeness with grep", "status": "pending"},
    {"id": "validate-tests", "content": "Run test validation if code changes present", "status": "pending"},
    {"id": "stage-files", "content": "Stage session files with user confirmation", "status": "pending"},
    {"id": "generate-message", "content": "Generate commit message", "status": "pending"},
    {"id": "commit-changes", "content": "Execute commit", "status": "pending"}
  ]
}
```

### Step 2: Git Status Analysis & Logical Grouping

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

### Step 2.5: Detect Logical Commit Groupings

**🔴 CRITICAL: Automatically detect when changes should be split into multiple commits**

**Pattern-based grouping analysis:**

Analyze session files to detect distinct concerns using these patterns:

1. **Different purposes/types:**
   - Implementation vs documentation vs configuration vs tests
   - New features vs bug fixes vs refactoring
   - Different modules/components being changed

2. **Different contexts:**
   - Files grouped by directory/module structure
   - Changes affecting different parts of the system
   - Separate work streams happening in parallel

3. **Natural boundaries:**
   - Infrastructure/framework changes vs application code
   - Spec/design documents vs implementation
   - Multiple unrelated features/fixes in same session

**Heuristics for splitting (NOT rigid rules):**

```
STRONG signals to split:
✅ Implementation files + infrastructure/config/rules files → Different concerns
✅ Multiple feature directories → Different features
✅ New feature + bug fix → Different types of work
✅ Frontend + backend changes for different purposes → Different modules

WEAK signals (usually keep together):
⚠️ Implementation + its tests → Same feature (keep together)
⚠️ Feature implementation + its documentation updates → Same work (keep together)
⚠️ Related changes in same module → Same concern (keep together)

ASK YOURSELF:
- Would these changes make sense in separate pull requests?
- Do they have different purposes/motivations?
- Could one be reverted without affecting the other?
- Would someone reviewing understand each commit independently?

If YES to most → Split
If NO to most → Keep together
```

**Present grouping proposal:**

```
📊 Detected Multiple Logical Groups

Your changes can be split into focused commits:

Group 1: Feature Specification
  📁 docs/features/new-dashboard/
     - overview.md
     - requirements.md
     - user-stories/ (4 files)

  Purpose: New feature specification
  Type: docs

Group 2: Infrastructure Updates
  📁 config/eslint.config.js
  📁 .github/workflows/ci.yml
  📁 package.json

  Purpose: Improve code quality tools
  Type: chore

Split into 2 commits? [yes/no/single]

Options:
- yes: Create 2 focused commits (recommended)
- no: Create single combined commit
- single: Let me write one commit message for all changes
```

**If user chooses "yes":**
- Proceed with grouped commits (one at a time)
- Stage group 1, commit, then stage group 2, commit

**If user chooses "no" or "single":**
- Continue with single commit (original flow)

### Step 3: Update Related Documentation

**🔴 CRITICAL: Update docs BEFORE staging - This step is MANDATORY, not optional**

**🔴 CRITICAL: PARTIAL UPDATES ARE NOT ACCEPTABLE - Update ALL sections or nothing**

**You MUST check for and update documentation EVERY TIME before staging files.**

**Process:**

**1. Find ALL related documentation:**
```bash
# Find story files related to your changes
find .junior/features -name "*story*.md" | xargs grep -l "filename_you_changed"

# OR if you know the feature number
ls .junior/features/feat-N/user-stories/
```

**2. For EACH story file, READ THE ENTIRE FILE (not just one section):**
```bash
# Use read_file tool to read the COMPLETE file from line 1 to end
# DO NOT scan or skim - READ EVERY SECTION
```

**3. Count ALL checkboxes BEFORE making changes:**
```bash
# Count unchecked boxes (should become 0 for completed stories)
grep -c "\[ \]" .junior/features/feat-N/user-stories/feat-N-story-X.md

# Count checked boxes (should increase)
grep -c "✅" .junior/features/feat-N/user-stories/feat-N-story-X.md
```

**4. Identify ALL sections with checkboxes in the story file:**

Common sections to check:
- ✅ Status field (at top: `> Status: In Progress` → `> Status: Completed ✅`)
- ✅ Acceptance Criteria section
- ✅ Implementation Tasks section
- ✅ Definition of Done section
- ✅ Any other sections with `- [ ]` checkboxes

**Use grep to find ALL checkbox sections:**
```bash
# Show line numbers of ALL checkboxes in file
grep -n "\[ \]" feat-N-story-X.md

# This tells you which sections need updating - UPDATE THEM ALL
```

**5. Update ALL sections systematically:**

For completed work, mark EVERY checkbox:
- Change `- [ ]` → `- ✅` for ALL completed items
- Change `Status: In Progress` → `Status: Completed ✅` in individual story files
- Update progress tracking in `feat-N-stories.md`:
  - Update **Status field at top** (Planning → In Progress → Completed ✅)
  - Update task counts (X/Y completed)
  - Update percentages
  - Update story table rows (status column)
- Update `feat-N-overview.md` Status field if all stories complete

**6. VERIFY completeness with grep AFTER updates:**
```bash
# Count remaining unchecked boxes (should be 0 for completed stories)
grep -c "\[ \]" feat-N-story-X.md

# If > 0, you missed checkboxes - GO BACK AND FIX
```

**7. Update other documentation:**
- READMEs that describe changed functionality
- Technical specs that document changed components
- API docs for changed endpoints

**🔴 MANDATORY CHECKLIST - Answer YES to ALL before proceeding:**

```
Documentation Update Checklist:

[ ] Did I read the ENTIRE story file (not just one section)?
[ ] Did I use grep to find ALL checkbox sections?
[ ] Did I update the Status field at the top of the story file?
[ ] Did I update ALL Acceptance Criteria checkboxes?
[ ] Did I update ALL Implementation Tasks checkboxes?
[ ] Did I update ALL Definition of Done checkboxes?
[ ] Did I update feat-N-stories.md Status field at the top?
[ ] Did I update feat-N-stories.md progress table and percentages?
[ ] Did I verify with grep that unchecked count is 0 (for completed stories)?
[ ] Did I update any related READMEs or technical docs?

If ANY answer is NO, STOP and complete that step before staging.
```

**Example:**
```bash
# Changed: app/auth.py from feat-1-story-2
# Must check: .junior/features/feat-1-auth/user-stories/feat-1-story-2-login.md

# Read entire file
cat .junior/features/feat-1-auth/user-stories/feat-1-story-2-login.md

# Count before
grep -c "\[ \]" feat-1-story-2-login.md  # Shows: 19

# Update ALL sections (Status, Acceptance Criteria, Tasks, Definition of Done)

# Count after
grep -c "\[ \]" feat-1-story-2-login.md  # Shows: 0 ✅
grep -c "✅" feat-1-story-2-login.md      # Shows: 19 ✅
```

**This step is NOT optional:**
- Even if changes seem trivial
- Even if you "think" docs are already up to date
- Even if you're in a hurry
- **Even if you already updated ONE section** ← Must update ALL sections

**⚠️ Common Mistakes to Avoid:**
- ❌ Updating only Implementation Tasks but not Acceptance Criteria
- ❌ Updating only one section and assuming others are done
- ❌ Not reading the entire file before updating
- ❌ Not verifying with grep after updates
- ❌ Trusting memory instead of checking the actual file

**Skip documentation updates ONLY if:**
- Changes are pure documentation updates (no code changed)
- Absolutely no related docs exist (extremely rare)

### Step 3.5: Verify Documentation Completeness

**🔴 MANDATORY: Run these verification commands before proceeding**

**This step MUST be completed - mark the verify-docs todo as complete only after running ALL checks**

**Verification Commands:**

```bash
# 1. Check for remaining unchecked boxes in ALL story files you touched
find .junior/features/feat-N -name "*story*.md" -exec echo "=== {} ===" \; -exec grep -c "\[ \]" {} \;

# 2. If any file shows count > 0, display those unchecked boxes
grep -n "\[ \]" .junior/features/feat-N/user-stories/feat-N-story-X.md

# 3. Verify checked boxes increased
grep -c "✅" .junior/features/feat-N/user-stories/feat-N-story-X.md
```

**Expected Results:**

For completed stories:
- ✅ Unchecked count (`\[ \]`): **0**
- ✅ Checked count (`✅`): **> 0** (should equal total tasks)

For in-progress stories:
- ⚠️ Unchecked count: Some remaining (document which tasks are pending)
- ✅ Checked count: Increased from before

**If verification fails:**
- ❌ Any completed story still has unchecked boxes → GO BACK to Step 3
- ❌ Checked count didn't increase → GO BACK to Step 3
- ❌ You can't explain which sections you updated → GO BACK to Step 3

**Only proceed to Step 4 after:**
- ✅ All verification commands run
- ✅ Results match expectations
- ✅ verify-docs todo marked as completed

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

### Step 5: Stage Files (Per Logical Group)

**🔴 CRITICAL: Session-Based Staging Logic**

**Stage ONLY files from THIS conversation thread - nothing else!**

**NEVER use `git add .` - Always stage files explicitly file-by-file**

**If multiple logical groups detected (Step 2.5):**
- Stage and commit ONE group at a time
- After each commit, move to next group
- This creates focused, atomic commits

**For current group, present staging plan:**
```
📁 Files to stage (Group 1 of 2):

Feature Specification (feat-4):
  A  .junior/features/feat-4-component-organization/feat-4-overview.md
  A  .junior/features/feat-4-component-organization/user-stories/feat-4-stories.md
  A  .junior/features/feat-4-component-organization/user-stories/feat-4-story-1-structure-and-detection.md
  ... (6 more story files)
  A  .junior/features/feat-4-component-organization/specs/01-Technical.md

📋 Excluding (will commit in Group 2):
  M  .cursor/rules/00-junior.mdc
  M  .cursor/rules/03-style-guide.mdc
  M  .cursor/commands/feature.md

📋 Excluding (NOT part of this session):
  M  backend/other.py         ← From different work
  M  frontend/widget.tsx      ← From previous session

Stage Group 1? [yes/no]
```

**Options:**
- **yes** - Stage current group and proceed to commit
- **no** - Cancel

**Stage explicitly (for current group):**
```bash
git add .junior/features/feat-4-component-organization/
```

**After committing Group 1, repeat for Group 2:**
- Present Group 2 staging plan
- Stage Group 2 files
- Generate Group 2 commit message
- Commit Group 2

### Step 6: Generate Commit Message (Per Logical Group)

**For current logical group, analyze changes to determine commit type:**

**Commit Types:**
- `feat` - New features
- `fix` - Bug fixes and corrections
- `docs` - Documentation updates
- `refactor` - Code restructuring without feature changes
- `test` - Adding or updating tests
- `chore` - Maintenance tasks (dependencies, cleanup)
- `config` - Configuration changes

**Message Generation Logic:**

1. **Analyze for work context (current group only):**
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

**Examples (Group-Specific):**

Group 1 (New feature implementation):
- `feat(auth): add JWT authentication system`
- `feat(dashboard): implement real-time analytics`

Group 2 (Infrastructure/config):
- `chore: update ESLint rules and CI pipeline`
- `docs: improve API documentation and examples`

Single commit (related work):
- `feat(login): implement OAuth with tests and docs`
- `fix(payment): resolve race condition in checkout flow`

### Step 7: User Review & Commit Execution (Per Logical Group)

**Present generated message for current group:**

```
💬 Generated Commit Message (Group 1 of 2):
┌─────────────────────────────────────────────
│ feat(feat-4): create progressive component organization spec
│
│ Add 3-stage progressive structure that adapts to project complexity:
│ - Stage 1: Flat features (simple, default)
│ - Stage 2: Component organization (clustering emerges)
│ - Stage 3: Grouped structure (optional, for large components)
│
│ Key capabilities:
│ - Semantic clustering for intelligent component grouping
│ - /maintenance command for structure reorganization
│ - Stage detection with future detection
│ - Git discipline (two-phase commits preserve history)
└─────────────────────────────────────────────

Proceed with this commit? [yes/no/edit]
```

**Options:**
- **yes** - Commit with generated message, proceed to next group
- **no** - Cancel commit
- **edit** - Modify message before committing

**Execute commit:**

```bash
git commit -m "[generated message]"
```

**Show completion:**

```
✅ Commit 1 of 2 completed!

📝 Commit: f802180 - feat(feat-4): create progressive component organization spec
📁 Files: 9 staged
📊 Changes: +1225 lines

Moving to Group 2...
```

**If multiple groups:**
- Repeat Steps 5-7 for each group
- After all groups committed, show final summary

**Final summary (after all groups):**

```
✅ All commits completed successfully!

📝 Commit 1: f802180 - feat(feat-4): create progressive component organization spec
   📁 9 files, +1225 lines

📝 Commit 2: a3b4c5d - docs: strengthen DRY and SIMPLICITY rules
   📁 3 files, +156 lines

Total: 2 commits, 12 files, +1381 lines
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
