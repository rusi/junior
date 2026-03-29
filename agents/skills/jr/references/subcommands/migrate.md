
# Subcommand: /jr migrate

## Purpose

Convert Code Captain projects to Junior structure seamlessly, preserving all work, git history, and progress tracking.

## Type

Direct execution - Immediate action with user confirmation before migration

## When to Use

- Migrating from Code Captain to Junior
- Converting existing `.code-captain/` structure to `.junior/`
- Renaming specifications (`spec-N-name`) to features (`feat-N-name`)
- Preserving all completed work and git history

## Execution Flow

**CRITICAL: Execute Steps 1-4 continuously without stopping. Only stop at Step 4 to get user approval before proceeding with the migration.**

**VERIFICATION CRITICAL:**
- After renaming files (Steps 5-7), ALWAYS verify completeness (Step 8) BEFORE committing (Step 9). Never skip!
- After updating references (Step 10), ALWAYS verify completeness (Step 11) BEFORE committing (Step 12). Never skip!
- If ANY verification fails, fix the issues and re-verify before proceeding.

These rules are instructions FOR YOU (the LLM). Figure out the specific commands based on the principles. Don't stop between detection, validation, and presenting the plan.

## Process

### Step 0: Verify Git State

```bash
git status --short
```

If not clean:
```
⚠️ Uncommitted changes detected.

Scope check:
- Review changed paths from `git status --short`.
- If changes are clearly isolated from migration scope, recommend proceeding.
- If changes touch related areas or scope is unclear, ask for explicit override.

Default: use /jr-commit first.
Override: If you confirm the changes are unrelated, reply "override: proceed".
```

Proceed only if:
- Working directory is clean, OR
- You recommend proceeding based on isolated scope, OR
- User explicitly confirms override with "override: proceed".

### Step 1: Initialize Progress Tracking

Create todos using `todo_write` or `functions.update_plan`:

```json
{
  "todos": [
    {"id": "detect-installation", "content": "Detect Code Captain installation", "status": "in_progress"},
    {"id": "validate-structure", "content": "Validate project structure", "status": "pending"},
    {"id": "migration-plan", "content": "Create migration plan and get user approval", "status": "pending"},
    {"id": "rename-directories", "content": "Rename directories with git mv", "status": "pending"},
    {"id": "rename-story-files", "content": "Rename all story files to feat-N/exp-N prefixes", "status": "pending"},
    {"id": "rename-feature-files", "content": "Rename spec.md/spec-lite.md/sub-specs to Junior names", "status": "pending"},
    {"id": "verify-renames", "content": "Verify all renames are complete before commit", "status": "pending"},
    {"id": "commit-renames", "content": "Commit all renames before content changes", "status": "pending"},
    {"id": "update-references", "content": "Update cross-references in markdown files", "status": "pending"},
    {"id": "verify-references", "content": "Verify all references are updated before commit", "status": "pending"},
    {"id": "commit-content", "content": "Commit content/reference updates", "status": "pending"},
    {"id": "cleanup-docs", "content": "Remove outdated migration-guide.md if exists", "status": "pending"}
  ]
}
```

### Step 2: Detect Code Captain Installation

**CRITICAL:** `.code-captain` and `.junior` are hidden directories. Use `run_terminal_cmd` (or `functions.shell_command`) with shell commands, NOT `list_dir`.

**Use these detection commands:**

```bash
# Check if .code-captain exists (REQUIRED FIRST STEP)
test -d .code-captain && echo "EXISTS" || echo "NOT_FOUND"

# Check if .junior exists (to determine mode)
test -d .junior && echo "EXISTS" || echo "NOT_FOUND"

# Find features in Code Captain
find .code-captain/specs -maxdepth 1 -type d ! -name specs 2>/dev/null

# Find experiments
find .code-captain/experiments -maxdepth 1 -type d ! -name experiments 2>/dev/null

# Find bugs and enhancements
find .code-captain/bugs -maxdepth 1 -type d ! -name bugs 2>/dev/null
find .code-captain/enhancements -maxdepth 1 -type d ! -name enhancements 2>/dev/null

# Count docs and research files
find .code-captain/docs -type f -name "*.md" 2>/dev/null | wc -l
find .code-captain/research -type f -name "*.md" 2>/dev/null | wc -l
```

**Detection tasks:**

1. Check if `.code-captain/` exists - if not, show error and exit
2. Detect Code Captain version:
   - v2: `spec-N-name` pattern in `.code-captain/specs/`
   - v1: `YYYY-MM-DD-name` pattern in `.code-captain/specs/`
   - custom: Other structure
3. Check if `.junior/` exists - determines migration mode:
   - If exists: **merge** mode (renumber features to avoid conflicts)
   - If not exists: **convert** mode (direct conversion)
4. Scan and identify:
   - Features in `.code-captain/specs/`
   - Experiments in `.code-captain/experiments/`
   - Bugs in `.code-captain/bugs/` (will be nested under features)
   - Enhancements in `.code-captain/enhancements/` (will be nested under features)
   - Research docs in `.code-captain/research/`
   - Product docs in `.code-captain/product/`
   - Other docs in `.code-captain/docs/`
   - Decision records in `.code-captain/decisions/`

**Present detection results** - Show version, mode, counts, and migration strategy:

Example for **convert mode** (no Junior):
```
🔍 Code Captain Installation Detected

Version: v1 (date-prefixed) or v2 (spec-N-name)
Mode: Convert (no existing Junior)

Found:
✅ N features (list first few with future names)
✅ N experiments
✅ N bugs (will be nested under features)
✅ N enhancements (will be nested under features)
✅ N research docs, N product docs, N other docs

Status: Ready for migration
```

Example for **merge mode** (Junior exists):
```
🔍 Code Captain Installation Detected

Version: v2 (spec-N-name pattern)
Mode: Merge (Junior exists)

Code Captain: N features, N experiments, N bugs, N enhancements, N docs
Junior: N features, N experiments, N docs

Strategy:
• Renumber Code Captain features (feat-X → feat-Y where Y is next available)
• Nest bugs under their parent features (prompt user for feature mapping)
• Nest enhancements under their parent features (prompt user for feature mapping)
• Merge product/docs/research intelligently
• Handle name conflicts with -cc suffix

Status: Ready for migration
```

**Error handling:** If no `.code-captain/` found, show error message suggesting `/jr-init` for new projects.

### Step 3: Validate Structure & Analyze Target Stage

**Part A: Structure Validation**

**Validation tasks:**

1. For each feature in `.code-captain/specs/`:
   - Verify naming pattern (v1 date-prefix or v2 spec-N-name)
   - Check for `spec.md` or `feat-N-overview.md`
   - Check for `user-stories/` directory
   - Count story files

2. For each experiment in `.code-captain/experiments/`:
   - Verify `exp-N-name` pattern
   - Check for `exp-N-overview.md`

3. Check git status:
   - Working directory should be clean
   - No uncommitted changes (warn if found)

**Present validation results** - Show summary with counts and any issues:

```
✅ Structure Validation Complete

Features (N): List with story counts
Experiments (N): List with status
Docs: Counts for research/product/other

Total: N stories across N features

⚠️  Issues: None (or list non-blocking issues)

Ready to proceed with migration.
```


**Part B: Complexity Analysis & Target Stage Determination**

**Analyze Code Captain specs to determine appropriate Junior stage:**

**Step 1: Count features**

```bash
# Count specs in Code Captain
find .code-captain/specs -maxdepth 1 -type d ! -name specs 2>/dev/null | wc -l
```

**Step 2: Determine analysis approach**

- **If <6 features:** Skip clustering analysis → **Target: Stage 1 (flat)**
  - Simple projects benefit from flat structure
  - Zero overhead, maintains simplicity

- **If 6+ features:** Proceed to semantic clustering analysis

**Step 3: Semantic Clustering Analysis (for 6+ features only)**

1. **Extract feature information:**
   - Read each spec's `spec.md` or main file
   - Extract feature name and brief description/purpose
   - Build list of features with metadata

2. **Keyword-based clustering:**
   - Extract keywords from feature names (remove stopwords: "feature", "system", "module", "spec")
   - Find features with shared keywords (2+ shared keywords = potential cluster)
   - Group features into potential components
   - Validate clusters: minimum 3 features per component

3. **Clustering threshold:**
   - **Recommend Stage 2 if:** 3-4+ features cluster into distinct groups
   - **Recommend Stage 1 if:** No clear clustering (artificial grouping avoided)

**Step 4: Present analysis results**

**Example A: Small project (<6 features) → Stage 1**

```
📊 Complexity Analysis

Features: 4 features
Target Stage: Stage 1 (flat structure)

Reasoning:
• Small project with <6 features
• Flat structure maintains simplicity
• Component organization unnecessary

Migration will create:
.junior/features/
├── feat-1-[name]/
├── feat-2-[name]/
├── feat-3-[name]/
└── feat-4-[name]/
```

**Example B: Large project with clustering → Stage 2**

```
📊 Complexity Analysis

Features: 8 features
Target Stage: Stage 2 (component organization)

Semantic Clustering Detected:
• comp-1-authentication: 3 features
  - spec-1-user-auth (keywords: auth, user, login)
  - spec-2-session-mgmt (keywords: auth, session, user)
  - spec-3-password-reset (keywords: auth, password, user)

• comp-2-analytics: 3 features
  - spec-4-dashboard (keywords: analytics, dashboard, metrics)
  - spec-5-reports (keywords: analytics, reports, data)
  - spec-6-tracking (keywords: analytics, tracking, metrics)

• comp-3-admin: 2 features
  - spec-7-admin-panel (keywords: admin, config, panel)
  - spec-8-settings (keywords: admin, config, settings)

Reasoning:
• Clear natural groupings identified
• 3 components with distinct purposes
• Improves organization from day one

Migration will create:
.junior/features/
├── comp-1-authentication/
│   ├── comp-1-overview.md
│   ├── feat-1-user-auth/
│   ├── feat-2-session-mgmt/
│   └── feat-3-password-reset/
├── comp-2-analytics/
│   ├── comp-2-overview.md
│   ├── feat-4-dashboard/
│   ├── feat-5-reports/
│   └── feat-6-tracking/
└── comp-3-admin/
    ├── comp-3-overview.md
    ├── feat-7-admin-panel/
    └── feat-8-settings/
```

**Example C: Large project without clustering → Stage 1**

```
📊 Complexity Analysis

Features: 8 features
Target Stage: Stage 1 (flat structure)

Reasoning:
• No clear semantic clustering detected
• Features are diverse with minimal shared keywords
• Component organization would be artificial
• Flat structure maintains clarity

Migration will create:
.junior/features/
├── feat-1-[name]/
├── feat-2-[name]/
├── feat-3-[name]/
...
└── feat-8-[name]/

Note: Can reorganize later with /jr maintenance if patterns emerge.
```

### Step 4: Create Migration Plan & Get Approval

**⚠️ THIS IS THE ONLY STEP THAT REQUIRES USER APPROVAL - STOP HERE**

**Generate migration plan based on target stage determined in Step 3:**


**Migration Plan A: Code Captain → Junior Stage 1 (Flat Structure)**

Use this plan when:
- Project has <6 features
- OR 6+ features but no clear clustering detected

```
📋 Migration Plan - Code Captain → Junior Stage 1

TARGET: Junior Stage 1 (flat features)
FEATURES: N features

STRUCTURE:
.junior/features/
├── feat-1-[name]/
├── feat-2-[name]/
├── feat-3-[name]/
...
└── feat-N-[name]/

FEATURE RENAMES:
• List all features with before → after names
• Show story counts that will be preserved

EXPERIMENTS:
• List experiments (usually unchanged if already exp-N-name)

BUGS (Nested Under Features):
• List bugs with proposed feature mapping
• Prompt user to confirm or adjust feature assignment
• Example: bug-1-login-issue → feat-3-auth/bugs/bug-1-login-issue

ENHANCEMENTS (Nested Under Features):
• List enhancements with proposed feature mapping
• Prompt user to confirm or adjust feature assignment
• Example: enh-1-ui-polish → feat-5-dashboard/enhancements/enh-1-ui-polish

PRODUCT & DOCUMENTATION:
• product/decisions.md → decisions/product-decisions.md
• Other product/*.md → docs/
• docs/ and research/ merged intelligently

REFERENCE UPDATES:
• Update markdown links (spec-N → feat-N, date-prefixes → feat-N)
• Update .code-captain/ → .junior/ references
• Update file references (spec.md → feat-N-overview.md, etc.)

GIT OPERATIONS:
• Use git mv for all renames (preserves history)
• Commit renames first (Step 9), then content changes (Step 12)
• Two separate commits for clear history
• User reviews before committing

ESTIMATED TIME: ~30-60 seconds
ESTIMATED CHANGES: ~X files renamed, ~Y reference updates

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proceed with migration? [Type 'yes' to proceed, 'cancel' to abort]
```


**Migration Plan B: Code Captain → Junior Stage 2 (Component Organization)**

Use this plan when:
- Project has 6+ features
- AND clear clustering detected (3-4+ features per group)

```
📋 Migration Plan - Code Captain → Junior Stage 2

TARGET: Junior Stage 2 (component organization)
FEATURES: N features organized into M components

STRUCTURE:
.junior/features/
├── comp-1-[name]/
│   ├── comp-1-overview.md
│   ├── feat-1-[name]/
│   ├── feat-2-[name]/
│   └── feat-3-[name]/
├── comp-2-[name]/
│   ├── comp-2-overview.md
│   ├── feat-4-[name]/
│   └── feat-5-[name]/
└── comp-3-[name]/
    ├── comp-3-overview.md
    ├── feat-6-[name]/
    └── feat-7-[name]/

COMPONENT GROUPING (Semantic Clustering):
• comp-1-[name]: K features
  - spec-1-[name] (keywords: ...)
  - spec-2-[name] (keywords: ...)
  - spec-3-[name] (keywords: ...)

• comp-2-[name]: L features
  - spec-4-[name] (keywords: ...)
  - spec-5-[name] (keywords: ...)

• comp-3-[name]: O features
  - spec-6-[name] (keywords: ...)
  - spec-7-[name] (keywords: ...)

You can adjust component grouping before proceeding.
Type 'adjust: [description]' to modify grouping.

EXPERIMENTS:
• List experiments (usually unchanged if already exp-N-name)

BUGS (Nested Under Features):
• List bugs with proposed feature mapping
• Prompt user to confirm or adjust feature assignment
• Example: bug-1-login-issue → feat-3-auth/bugs/bug-1-login-issue

ENHANCEMENTS (Nested Under Features):
• List enhancements with proposed feature mapping
• Prompt user to confirm or adjust feature assignment
• Example: enh-1-ui-polish → feat-5-dashboard/enhancements/enh-1-ui-polish

PRODUCT & DOCUMENTATION:
• product/decisions.md → decisions/product-decisions.md
• Other product/*.md → docs/
• docs/ and research/ merged intelligently

REFERENCE UPDATES:
• Update markdown links (spec-N → feat-N, date-prefixes → feat-N)
• Update .code-captain/ → .junior/ references
• Update file references (spec.md → feat-N-overview.md, etc.)
• Update paths for component organization (feat-N → comp-M/feat-N)

GIT OPERATIONS:
• Phase 1 commit: File moves (git mv preserves history)
• Phase 2 commit: Component overviews + reference updates
• Two separate commits for clear history

ESTIMATED TIME: ~45-90 seconds
ESTIMATED CHANGES: ~X files renamed, ~Y reference updates, M component overviews created

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proceed with migration? [Type 'yes' to proceed, 'adjust: [changes]' to modify, 'cancel' to abort]
```


**Wait for user approval before proceeding to Step 5.**

### Step 5: Execute Migration (File Moves)

**CRITICAL: Use git mv for all operations to preserve history**

**Branch based on target stage (determined in Step 3):**


**Path A: Migrate to Stage 1 (Flat Structure)**

Use when target is Stage 1 (flat features, no components).

**Convert mode** (no Junior exists):
1. Create `.junior/features/` directory
2. For each spec in `.code-captain/specs/`:
   - If `spec-N-name` pattern → rename to `feat-N-name`
   - If `YYYY-MM-DD-name` pattern → rename to `feat-N-name` (sequential: 1, 2, 3...)
   - Use `git mv` to move to `.junior/features/feat-N-name` (flat, no components)
3. Handle experiments (usually already `exp-N-name`, just move to `.junior/experiments/`)
4. Handle bugs (nest under features, see below)
5. Handle enhancements (nest under features, see below)
6. Merge documentation intelligently (see below)

**Merge mode** (Junior exists):
1. Determine next available feature/experiment numbers in Junior
2. Move Code Captain features with renumbering to avoid conflicts
3. Move Code Captain experiments with renumbering
4. Handle bugs (nest under features, see below)
5. Handle enhancements (nest under features, see below)
6. Merge documentation intelligently (see below)

**Show progress:** "✅ Phase 1 complete: [N] features migrated to Stage 1 (flat)"


**Path B: Migrate to Stage 2 (Component Organization) - Phase 1**

Use when target is Stage 2 (component-based organization).

**Phase 1: Create components and move features with git mv**

```bash
# Create .junior/features/ directory
mkdir -p .junior/features

# Create component directories based on clustering from Step 3
mkdir -p .junior/features/comp-1-[component-name]
mkdir -p .junior/features/comp-2-[component-name]
mkdir -p .junior/features/comp-3-[component-name]

# Move Code Captain specs to Junior features, organized by component
# Component 1
git mv .code-captain/specs/spec-1-[name] .junior/features/comp-1-[name]/feat-1-[name]
git mv .code-captain/specs/spec-2-[name] .junior/features/comp-1-[name]/feat-2-[name]
git mv .code-captain/specs/spec-3-[name] .junior/features/comp-1-[name]/feat-3-[name]

# Component 2
git mv .code-captain/specs/spec-4-[name] .junior/features/comp-2-[name]/feat-4-[name]
git mv .code-captain/specs/spec-5-[name] .junior/features/comp-2-[name]/feat-5-[name]

# Component 3
git mv .code-captain/specs/spec-6-[name] .junior/features/comp-3-[name]/feat-6-[name]
git mv .code-captain/specs/spec-7-[name] .junior/features/comp-3-[name]/feat-7-[name]

# ... continue for all features based on clustering proposal
```

**Handle experiments, bugs, enhancements (same as Stage 1):**
- Move experiments to `.junior/experiments/`
- Nest bugs under their parent features
- Nest enhancements under their parent features
- Merge documentation intelligently

**Verification after Phase 1:**

```bash
# Verify all features moved
find .code-captain/specs -maxdepth 1 -type d ! -name specs 2>/dev/null | wc -l  # Should be 0

# Verify features in components
find .junior/features/comp-* -maxdepth 1 -type d -name "feat-*" | wc -l  # Should match total features

# Check git status
git status
```

**Commit Phase 1:**

```bash
# Add moved directories explicitly (git mv already staged moves)
# Verify what's staged
git status

git commit -m "$(cat <<'EOF'
Migrate Code Captain to Junior Stage 2: organize features into components (file moves)

- Created [M] components based on semantic clustering
- Moved [N] features into component structure
- Components: [comp-1-name], [comp-2-name], [comp-3-name]
- Used git mv to preserve file history

Phase 1 of 2: File moves only (no content changes)
Next: Create component overviews and update references
EOF
)"
```

**Show progress:** "✅ Phase 1 complete: [N] features organized into [M] components"

**Note:** Continue to Steps 6-7 for file naming, then Step 10 will create component overviews (Phase 2).


**Bugs/Enhancements nesting** (both modes):

For each bug in `.code-captain/bugs/`:
1. Parse bug metadata to identify related feature (if mentioned)
2. Present user with feature options:
   - Existing features list
   - Create new feature (if bug reveals missing feature)
3. User selects parent feature
4. Move bug to `.junior/features/feat-N-name/bugs/bug-M-name/`
5. Renumber bug-M within each feature (sequential: bug-1, bug-2, etc.)

For each enhancement in `.code-captain/enhancements/`:
1. Parse enhancement metadata to identify related feature
2. Present user with feature options:
   - Existing features list
   - Skip if enhancement is actually a refactor (suggest moving to improvements/)
3. User selects parent feature
4. Move enhancement to `.junior/features/feat-N-name/enhancements/enh-M-name/`
5. Renumber enh-M within each feature (sequential: enh-1, enh-2, etc.)

**Documentation merging** (both modes):
- Create `.junior/decisions/` and `.junior/docs/` if needed
- `product/decisions.md` → `decisions/product-decisions.md`
- Other `product/*.md` → `docs/`
- `research/*.md` → `research/` (add `-cc` suffix if file exists)
- `docs/*.md` → `docs/` (add `-cc` suffix if file exists)
- `decisions/*.md` → `decisions/` (add `-cc` suffix if file exists)

Show progress as directories are renamed.

### Step 6: Rename Story Files

**CRITICAL: Story files must follow Junior naming conventions with proper prefixes**

**For each feature in `.junior/features/feat-N-name/`:**

In `user-stories/` directory, rename ALL story files to match `feat-N-` prefix:

1. **Story tracking file:**
   - `README.md` → `feat-N-stories.md` (if exists)
   - `spec-N-stories.md` → `feat-N-stories.md` (if exists)
   - `YYYY-MM-DD-stories.md` → `feat-N-stories.md` (if exists)

2. **Individual story files:**
   - `spec-N-story-M-name.md` → `feat-N-story-M-name.md`
   - `YYYY-MM-DD-story-M-name.md` → `feat-N-story-M-name.md`
   - Any other `*.md` files that are stories → rename to `feat-N-story-M-name.md` pattern

**For each experiment in `.junior/experiments/exp-N-name/`:**

In `user-stories/` directory, rename ALL story files to match `exp-N-` prefix:

1. **Story tracking file:**
   - `README.md` → `exp-N-stories.md` (if exists)
   - `YYYY-MM-DD-stories.md` → `exp-N-stories.md` (if exists)

2. **Individual story files:**
   - `YYYY-MM-DD-story-M-name.md` → `exp-N-story-M-name.md`
   - Any story files with wrong prefix → `exp-N-story-M-name.md`

**CRITICAL IMPLEMENTATION:**
- Process EACH feature/experiment individually (loop through N=1 to total count)
- For each one, find the actual directory (handle `feat-N-*` pattern with wildcard expansion)
- Rename README.md first if it exists
- Then find ALL `story-*.md` files in that user-stories/ directory (use find, not wildcards)
- Rename each story file individually with `git mv`
- Handle edge cases: missing directories, no README, no stories, etc.

**Use `git mv` for all renames.** Show progress as story files are renamed. Report: "✅ Renamed N story tracking files and M individual story files"

### Step 7: Rename Feature Files

**CRITICAL: Code Captain uses `spec.md` / `spec-lite.md` / `sub-specs/` - Junior uses `feat-N-overview.md` / `feat-N-overview-lite.md` / `specs/`**

**For each feature:**
1. `spec.md` → `feat-N-overview.md`
2. `spec-lite.md` → `feat-N-overview-lite.md` (if exists)
3. `sub-specs/` → `specs/` (directory)
4. Any `feat-N-overview.md` → `feat-N-overview.md` (if already using Junior naming)
5. Any `README.md` in feature root → `feat-N-overview.md` or descriptive name

**For each experiment:**
1. `exp-N-overview.md` → `exp-N-overview.md`
2. `experiment-lite.md` → `exp-N-overview-lite.md` (if exists)
3. Any `README.md` in experiment root → `exp-N-overview.md` or descriptive name
4. Any `README.md` in findings/ → `exp-N-findings.md`

**CRITICAL IMPLEMENTATION:**
- Process EACH feature/experiment individually (loop through N=1 to total count)
- For each one, find the actual directory (handle `feat-N-*` or `exp-N-*` pattern)
- Check if each file/directory exists before attempting rename
- Use `git mv` for all renames
- Handle cases where files might not exist (lite versions are optional)

**Show progress.** Report: "✅ Renamed feature files for N features and M experiments"

### Step 8: Verify All Renames Are Complete

**CRITICAL: Verify every rename is done BEFORE committing. Nothing should be skipped!**

**Verification checklist - run these checks:**

1. **Verify feature/experiment main files:**
   - Search for any remaining `spec.md`, `spec-lite.md`, or `sub-specs/` in `.junior/`
   - Search for generic `feat-N-overview.md` or `exp-N-overview.md` (should be `feat-N-overview.md` / `exp-N-overview.md`)
   - Should find NOTHING - if any files found, renames are incomplete!

2. **Verify story tracking files (README.md → feat-N-stories.md):**
   - Search for any remaining `README.md` in `user-stories/` directories
   - Check both `.junior/features/` and `.junior/experiments/`
   - Should find NOTHING - if any found, renames are incomplete!

3. **Verify individual story files (story-M → feat-N-story-M):**
   - Search for story files that match `story-*.md` pattern but DON'T have `feat-` or `exp-` prefix
   - Look in all `user-stories/` directories (but exclude archived/ subdirectories)
   - Should find NOTHING - if any found, renames are incomplete!

4. **Verify README.md files outside user-stories/:**
   - Search for `README.md` files in features/experiments root or subdirectories (excluding user-stories/, backups/)
   - These should be renamed to descriptive names like `feat-N-overview.md`, `exp-N-findings.md`, etc.
   - Count: 0 remaining (excluding backups/)

5. **Count verification:**
   - Show count of renamed files vs expected
   - Compare: total features × (feature files + story files) = expected total
   - Display summary: "✅ X/X renames complete" or "⚠️ Missing N renames"

**If ANY verification fails:**
- Show which files still need renaming (list them explicitly)
- Fix the renames using individual `git mv` commands for each missed file
- Re-run verification
- DO NOT proceed to commit until ALL verifications pass

**Show verification results:**

Example success:
```
🔍 Verification Results:

✅ Feature/experiment main files: All renamed (0 spec.md, 0 spec-lite.md, 0 sub-specs/)
✅ Story tracking files: All README.md renamed (0 remaining in user-stories/)
✅ Individual story files: All have feat-/exp- prefix (0 unprefixed)
✅ Other README.md files: All renamed (0 remaining outside user-stories/)
✅ Ready to commit!

Total renames: 243 files
```

Example failure:
```
🔍 Verification Results:

⚠️  Feature/experiment main files: 2 files still need renaming:
   - .junior/features/feat-5-name/spec.md
   - .junior/features/feat-8-name/sub-specs/

⚠️  Story tracking files: 3 README.md files remaining:
   - .junior/features/feat-3-name/user-stories/README.md
   - .junior/features/feat-7-name/user-stories/README.md
   - .junior/experiments/exp-1-name/user-stories/README.md

⚠️  Individual story files: 15 unprefixed story files:
   - .junior/features/feat-1-name/user-stories/story-1-name.md
   - .junior/features/feat-1-name/user-stories/story-2-name.md
   [... list all ...]

❌ Cannot commit - fix these renames first!
```

### Step 9: Commit Renames (Before Content Changes!)

**CRITICAL: Commit all file renames BEFORE editing content/references**

This preserves git history better - git tracks file moves separately from content changes.

1. Check `git status` to see all renames
2. Commit with message like:
   ```
   Migrate Code Captain to Junior: rename all files

   - Rename N features to feat-N-name
   - Rename N experiments to exp-N-name
   - Rename spec.md → feat-N-overview.md, spec-lite.md → feature-lite.md
   - Rename sub-specs/ → specs/
   - Rename all story files: README.md → feat-N-stories.md, stories to feat-N-story-M-name.md
   - Move product/docs/research to Junior structure

   All renames via git mv to preserve history.
   Next: Update cross-references in content.
   ```

### Step 10: Update Cross-References & Create Component Overviews

**Branch based on target stage:**


**Path A: Stage 1 Cross-Reference Updates Only**

Use when target is Stage 1 (flat structure, no components).

**Update all markdown references** using find/grep/sed:

**CRITICAL: Only update references to FEATURE/EXPERIMENT files in `.junior/` content.**
- ✅ Update: `.junior/features/feat-N-name/feature.md` → `feat-N-overview.md`
- ❌ Don't touch Junior framework docs/skills (for example: `.agents/skills/jr-feature/SKILL.md` in the Junior source repo)

1. Find all `.md` files in `.junior/` and project README
2. Update references:
   - `spec-N` → `feat-N` (in links, mentions, etc.)
   - `YYYY-MM-DD-name` → `feat-N-name` (if any date references remain)
   - `.code-captain/` → `.junior/`
   - `spec.md` → `feat-N-overview.md` (in .junior/ paths only!)
   - `/feature.md` → `/feat-N-overview.md` (use path separator to avoid skill file!)
   - `/experiment.md` → `/exp-N-overview.md` (use path separator!)
   - `spec-lite.md` → `feat-N-overview-lite.md`
   - `sub-specs/` → `specs/`
   - Story file references: `spec-N-story` → `feat-N-story`, date-story → `feat-N-story`
   - Story tracking references: `README.md` → `feat-N-stories.md`, etc.

3. **CRITICAL: Update story links in feat-N-stories.md and exp-N-stories.md files:**
   - For EACH feature N, update `feat-N-stories.md`: `](./story-` → `](./feat-N-story-`
   - For EACH experiment N, update `exp-N-stories.md`: `](./story-` → `](./exp-N-story-`
   - Use sed with loop: `for n in {1..16}; do sed -i '' -E "s|\(\.\/story-|(.\/feat-$n-story-|g" .junior/features/feat-$n-*/user-stories/feat-$n-stories.md; done`
   - These are the story quicklinks that users click - MUST be updated!

4. **CRITICAL: Update feature/experiment file references with context:**
   - Process EACH feature individually: In `.junior/features/feat-N-*/`, replace `feature.md` with `feat-N-overview.md`
   - Process EACH experiment individually: In `.junior/experiments/exp-N-*/`, replace `experiment.md` with `exp-N-overview.md`
   - Use loops with actual numbers to avoid hitting skill files
   - NEVER do blanket sed on entire project - it will corrupt skill file references!

Show progress: "Updated N references in M files"


**Path B: Stage 2 Phase 2 - Component Overviews & References**

Use when target is Stage 2 (component organization).

**10.1: Create component overview files**

For each component created in Step 5 Phase 1, create `comp-N-overview.md`:

Use template from `/jr maintenance` command (see 01-structure.mdc for reference):

```markdown
# [Component Name]

> Created: [current date from date command]
> Status: Active

## Purpose

[1-2 sentences describing component purpose - inferred from feature names/descriptions]

## Scope

[What this component covers, boundaries with other components]

## Features

| ID | Title | Status | Description |
|----|-------|--------|-------------|
| feat-1 | [Feature Name] | [Status from feat-1-overview.md] | [Brief description] |
| feat-2 | [Feature Name] | [Status] | [Brief description] |

## Improvements

| ID | Title | Status | Description |
|----|-------|--------|-------------|
| imp-1 | [Improvement Name] | [Status] | [Brief description] |

## Dependencies

**Depends on:**
- [Other components this depends on, if any]

**Used by:**
- [Components that depend on this one, if any]

## Technical Notes

[Any component-level technical considerations]
```

**10.2: Update cross-references (Stage 2-specific)**

Update all markdown references + component-specific paths:

1. **Standard reference updates (same as Stage 1):**
   - `spec-N` → `feat-N` (in links, mentions, etc.)
   - `YYYY-MM-DD-name` → `feat-N-name` (if any date references remain)
   - `.code-captain/` → `.junior/`
   - `spec.md` → `feat-N-overview.md` (in .junior/ paths only!)
   - Story file references: `spec-N-story` → `feat-N-story`, date-story → `feat-N-story`
   - Story tracking references: `README.md` → `feat-N-stories.md`, etc.

2. **Component-specific path updates:**
   - Update cross-references: `feat-N` → `comp-M/feat-N` for features now in components
   - Update: `.junior/features/feat-1-name` → `.junior/features/comp-1-name/feat-1-name`
   - Process systematically for each component and its features

**10.3: Verification after Phase 2**

```bash
# Search for old path references (should find none)
grep -r ".junior/features/feat-" .junior --include="*.md" | grep -v "comp-"

# Verify component overviews exist
find .junior/features -name "comp-*-overview.md"

# Check structure
tree .junior/features -L 2
```

Show progress: "✅ Phase 2 complete: Created [M] component overviews, updated [N] cross-references"


### Step 11: Verify All References Are Updated

**CRITICAL: Verify every reference is updated BEFORE committing. Don't assume grep/sed caught everything!**

**Verification checklist - search for OLD references:**

1. **Check for date-prefixed references:**
   - Search `.junior/` for patterns like `2025-09-28`, `2025-10-13`, etc.
   - These should now be `feat-N` or `exp-N` references
   - Exclude: actual dates in content (commit dates, timestamps), focus on feature/experiment names

2. **Check for .code-captain/ references:**
   - Search `.junior/` for `.code-captain/` string
   - Should be replaced with `.junior/`
   - Count: 0 remaining

3. **Check for spec.md / spec-lite.md / sub-specs/ references:**
   - Search `.junior/` for `spec.md`, `spec-lite.md`, `sub-specs/` in markdown links/mentions
   - Should be `feat-N-overview.md`, `feature-lite.md`, `specs/`
   - Count: 0 remaining

4. **Check for unprefixed story file references:**
   - Search for patterns like `story-1-`, `story-2-` in links (should be `feat-N-story-` or `exp-N-story-`)
   - Search for `README.md` in user-stories context (should be `feat-N-stories.md`)
   - Count: 0 remaining

5. **CRITICAL: Check story links in feat-N-stories.md files:**
   - Search for `](./story-` pattern in all `*-stories.md` files
   - These are the quicklinks users click - MUST be `](./feat-N-story-` or `](./exp-N-story-`
   - Count: 0 remaining
   - Command: `grep -r "](./story-" .junior --include="*stories.md" | wc -l` should return 0

6. **Spot-check samples:**
   - Pick 2-3 random feature files and verify their internal links are correct
   - Check the main roadmap/decisions files for correct references

**If ANY verification fails:**
- Show which files still have old references (list file + line number + the old reference)
- Update those specific references using search_replace tool
- Re-run verification
- DO NOT proceed to commit until ALL verifications pass

**Show verification results:**

Example success:
```
🔍 Reference Verification:

✅ Date-prefixed references: 0 remaining
✅ .code-captain/ references: 0 remaining
✅ spec.md/spec-lite.md/sub-specs/ references: 0 remaining
✅ Unprefixed story references: 0 remaining
✅ Story links in feat-N-stories.md: All updated (0 ](./story- patterns)
✅ Ready to commit!

Updated references in N files
```

Example failure:
```
🔍 Reference Verification:

⚠️  Date-prefixed references: 12 remaining
   - .junior/docs/roadmap.md:45: "See 2025-10-13-data-visualization"
   - .junior/features/feat-2-user-auth/feat-N-overview.md:23: "depends on 2025-10-01-user-auth"
   [... list all with file:line:content ...]

⚠️  .code-captain/ references: 3 remaining
   - .junior/docs/mission.md:15: "in .code-captain/specs/"
   - .junior/features/feat-5-data-processing/feat-N-overview.md:78: "See .code-captain/docs/"

⚠️  spec.md references: 2 remaining
   - .junior/features/feat-1-list-view/feat-1-stories.md:10: "See spec.md"

❌ Cannot commit - fix these references first!
```

### Step 12: Commit Content Updates

**CRITICAL: Add files explicitly, never use `git add -A`**

**Branch based on target stage:**


**For Stage 1 Migration:**

Stage and commit content/reference updates:

```bash
# Add modified files explicitly (reference updates in .junior/)
git add .junior/
git add README.md  # if project README was updated

git commit -m "$(cat <<'EOF'
Migrate Code Captain to Junior Stage 1: update cross-references

- Updated all spec-N → feat-N references
- Updated all date-prefix → feat-N-name references
- Updated file references (spec.md → feat-N-overview.md, etc.)
- Updated directory references (.code-captain/ → .junior/)
- Updated story file references (spec-N-story → feat-N-story, etc.)

Phase 2 of 2: Content updates and reference corrections

All internal links now point to Junior Stage 1 structure.
EOF
)"
```


**For Stage 2 Migration (Phase 2 commit):**

Stage and commit Phase 2 changes:

```bash
# Add component overviews explicitly
git add .junior/features/comp-*/comp-*-overview.md

# Add modified files (reference updates)
git add .junior/
git add README.md  # if project README was updated

git commit -m "$(cat <<'EOF'
Migrate Code Captain to Junior Stage 2: add component overviews and update references

- Created comp-N-overview.md for [M] components
- Updated all cross-references (feat-N → comp-M/feat-N)
- Updated all spec-N → feat-N references
- Updated file references (spec.md → feat-N-overview.md, etc.)
- Verified no broken references remain

Phase 2 of 2: Content updates and reference corrections

Migration to Stage 2 complete!
EOF
)"
```


### Step 13: Clean Up Outdated Docs

**CRITICAL: Do NOT create migration-guide.md or any new documentation!**

If `.junior/docs/migration-guide.md` exists (Code Captain's spec→feat migration guide), delete it:
- Use `git rm`
- Commit: "Remove outdated Code Captain migration-guide.md"

**Do NOT delete:** Research, product decisions, architecture, mission/roadmap files.

### Step 14: Show Summary

**CRITICAL: DO NOT generate migration-guide.md, migration reports, or ANY documentation files!**

Show concise terminal summary based on target stage:


**For Stage 1 Migration:**

```
✅ Migration to Junior Stage 1 complete! (2 commits)

✅ N features migrated to flat structure
✅ N experiments migrated
✅ File renames completed (commit 1)
✅ All references updated (commit 2)
✅ All changes committed

Structure:
.junior/features/
├── feat-1-[name]/
├── feat-2-[name]/
...
└── feat-N-[name]/

Done! Can reorganize later with /jr maintenance if patterns emerge.
```


**For Stage 2 Migration:**

```
✅ Migration to Junior Stage 2 complete! (2 commits)

✅ N features organized into M components
✅ Component overviews created
✅ All cross-references updated
✅ Git history preserved

Components:
- comp-1-[name]: K features
- comp-2-[name]: L features
- comp-3-[name]: O features

Structure:
.junior/features/
├── comp-1-[name]/
│   ├── comp-1-overview.md
│   ├── feat-1-[name]/
│   └── feat-2-[name]/
├── comp-2-[name]/
│   ├── comp-2-overview.md
│   └── feat-3-[name]/
└── comp-3-[name]/
    ├── comp-3-overview.md
    └── feat-4-[name]/

Done!
```


### Step 15: Verification

Suggest verification steps:
```
Verify with:
- git log --oneline -3
- /jr-status
- ls .junior/features/

All done!
```

## Tool Integration

**Primary tools:**
- `run_terminal_cmd` or `functions.shell_command` - For hidden directories (`.code-captain/`, `.junior/`), git commands
- `read_file` or `functions.shell_command` - Validation
- `grep` (via `functions.shell_command`) / `search_replace` or `functions.apply_patch` - Update references

**CRITICAL:**
- Never use `list_dir` for `.code-captain/` or `.junior/` - they're hidden. Use `run_terminal_cmd` (or `functions.shell_command`).
- ALWAYS verify renames (Step 8) before committing (Step 9)
- ALWAYS verify references (Step 11) before committing (Step 12)
- Commit renames FIRST (Step 9), then content (Step 12)
- NEVER use `write` or `functions.apply_patch` for migration reports or documentation.

## Error Handling

**No Code Captain:** If `.code-captain/` not found, show error suggesting `/jr-init` for new projects.

**Dirty git:** If uncommitted changes exist, warn user and suggest committing/stashing first. Offer to proceed anyway.

**Validation failures:** Show issues found, mark as non-blocking if minor. For critical issues (missing files), ask user to fix first.

**Migration interrupted:** Offer rollback via `git reset --hard HEAD` or retry.

**Permissions:** If git mv fails, suggest closing files, checking permissions.

## Best Practices

**Before:** Ensure clean git status, close files, validate structure.

**During:**
- Use `git mv` for all renames (preserves history)
- Verify renames are complete before committing (Step 8)
- Commit renames first (Step 9), then content changes (Step 12) - separate commits
- Verify references are updated before committing (Step 11)
- Show progress at each step
- Merge product/docs intelligently: `product/decisions.md` → `decisions/product-decisions.md`, others → `docs/`

**After:** Verify with `/jr-status`, review commits, test commands.

**Recovery:** `git reset --hard HEAD` to rollback. Can re-run `/jr migrate` if needed.

## Examples

**Successful flow:**
1. User: `/jr migrate`
2. Detect & validate (Steps 1-3, no stopping)
3. Show plan, get approval (Step 4, STOP HERE)
4. User: `yes`
5. Execute migration (Steps 5-15)
   - Steps 5-7: Rename files
   - Step 8: Verify renames ✓
   - Step 9: Commit renames
   - Step 10: Update references
   - Step 11: Verify references ✓
   - Step 12: Commit references
   - Step 13-15: Cleanup & summary
6. Show summary

**Error cases:**
- No `.code-captain/` → Suggest `/jr-init`
- Dirty git → Warn, offer to proceed
- Validation issues → Show issues, proceed if non-blocking
- Verification failures (Steps 8 or 11) → List missing items, fix them, re-verify, then proceed


Migrate seamlessly. Preserve history. Continue building.
