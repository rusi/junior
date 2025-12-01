# Migrate Command

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

These rules are instructions FOR YOU (the LLM). Figure out the specific commands based on the principles. Don't stop between detection, validation, and presenting the plan.

## Process

### Step 1: Initialize Progress Tracking

Create todos using `todo_write`:

```json
{
  "todos": [
    {"id": "detect-installation", "content": "Detect Code Captain installation", "status": "in_progress"},
    {"id": "validate-structure", "content": "Validate project structure", "status": "pending"},
    {"id": "migration-plan", "content": "Create migration plan and get user approval", "status": "pending"},
    {"id": "rename-directories", "content": "Rename directories with git mv", "status": "pending"},
    {"id": "rename-feature-files", "content": "Rename spec.md/spec-lite.md/sub-specs/README.md", "status": "pending"},
    {"id": "commit-renames", "content": "Commit all renames before content changes", "status": "pending"},
    {"id": "update-references", "content": "Update cross-references in markdown files", "status": "pending"},
    {"id": "commit-content", "content": "Commit content/reference updates", "status": "pending"},
    {"id": "cleanup-docs", "content": "Remove outdated migration-guide.md if exists", "status": "pending"}
  ]
}
```

### Step 2: Detect Code Captain Installation

**CRITICAL:** `.code-captain` and `.junior` are hidden directories. Use `run_terminal_cmd` with shell commands, NOT `list_dir`.

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
✅ N research docs, N product docs, N other docs

Status: Ready for migration
```

Example for **merge mode** (Junior exists):
```
🔍 Code Captain Installation Detected

Version: v2 (spec-N-name pattern)
Mode: Merge (Junior exists)

Code Captain: N features, N experiments, N docs
Junior: N features, N experiments, N docs

Strategy:
• Renumber Code Captain features (feat-X → feat-Y where Y is next available)
• Merge product/docs/research intelligently
• Handle name conflicts with -cc suffix

Status: Ready for migration
```

**Error handling:** If no `.code-captain/` found, show error message suggesting `/init` for new projects.

### Step 3: Validate Structure

**Validation tasks:**

1. For each feature in `.code-captain/specs/`:
   - Verify naming pattern (v1 date-prefix or v2 spec-N-name)
   - Check for `spec.md` or `feature.md`
   - Check for `user-stories/` directory
   - Count story files

2. For each experiment in `.code-captain/experiments/`:
   - Verify `exp-N-name` pattern
   - Check for `experiment.md`

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

### Step 4: Create Migration Plan & Get Approval

**⚠️ THIS IS THE ONLY STEP THAT REQUIRES USER APPROVAL - STOP HERE**

**Generate migration plan showing:**

```
📋 Migration Plan

FEATURE RENAMES:
• List all features with before → after names
• Show story counts that will be preserved

EXPERIMENTS:
• List experiments (usually unchanged if already exp-N-name)

PRODUCT & DOCUMENTATION:
• product/decisions.md → decisions/product-decisions.md
• Other product/*.md → docs/
• docs/ and research/ merged intelligently

REFERENCE UPDATES:
• Update markdown links (spec-N → feat-N, date-prefixes → feat-N)
• Update .code-captain/ → .junior/ references
• Update file references (spec.md → feature.md, etc.)

GIT OPERATIONS:
• Use git mv for all renames (preserves history)
• Commit renames first, then content changes
• User reviews before committing

ESTIMATED TIME: ~30-60 seconds
ESTIMATED CHANGES: ~X files renamed, ~Y reference updates

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proceed with migration? [Type 'yes' to proceed, 'cancel' to abort]
```

**Wait for user approval before proceeding to Step 5.**

### Step 5: Rename Directories Using Git

**CRITICAL: Use git mv for all operations to preserve history**

**Migration tasks based on mode:**

**Convert mode** (no Junior exists):
1. If `.code-captain/` exists as root, create `.junior/features/` directory
2. For each spec in `.code-captain/specs/`:
   - If `spec-N-name` pattern → rename to `feat-N-name`
   - If `YYYY-MM-DD-name` pattern → rename to `feat-N-name` (sequential: 1, 2, 3...)
   - Use `git mv` to move to `.junior/features/feat-N-name`
3. Handle experiments (usually already `exp-N-name`, just move to `.junior/experiments/`)
4. Merge documentation intelligently (see below)

**Merge mode** (Junior exists):
1. Determine next available feature/experiment numbers in Junior
2. Move Code Captain features with renumbering to avoid conflicts
3. Move Code Captain experiments with renumbering
4. Merge documentation intelligently (see below)

**Documentation merging** (both modes):
- Create `.junior/decisions/` and `.junior/docs/` if needed
- `product/decisions.md` → `decisions/product-decisions.md`
- Other `product/*.md` → `docs/`
- `research/*.md` → `research/` (add `-cc` suffix if file exists)
- `docs/*.md` → `docs/` (add `-cc` suffix if file exists)
- `decisions/*.md` → `decisions/` (add `-cc` suffix if file exists)

Show progress as directories are renamed.

### Step 6: Rename Story Files

**For each feature in `.junior/features/`:**
1. In `user-stories/` directory, rename story files:
   - `spec-N-story-M-name.md` → `feat-N-story-M-name.md`
   - `spec-N-stories.md` → `feat-N-stories.md` (tracking file)
   - `README.md` → `feat-N-stories.md` (if exists)
2. Use `git mv` for all renames

**For each experiment:** Check for any `spec-N-story` files and rename to `exp-N-story` (most should already use correct pattern).

Show progress as story files are renamed.

### Step 7: Rename Feature Files

**CRITICAL: Code Captain uses `spec.md` / `spec-lite.md` / `sub-specs/` - Junior uses `feature.md` / `feature-lite.md` / `specs/`**

**For each feature:**
1. `spec.md` → `feature.md`
2. `spec-lite.md` → `feature-lite.md`
3. `sub-specs/` → `specs/` (directory)

Use `git mv` for all renames. Show progress.

### Step 8: Commit Renames (Before Content Changes!)

**CRITICAL: Commit all file renames BEFORE editing content/references**

This preserves git history better - git tracks file moves separately from content changes.

1. Check `git status` to see all renames
2. Commit with message like:
   ```
   Migrate Code Captain to Junior: rename all files
   
   - Rename N features to feat-N-name
   - Rename spec.md → feature.md, spec-lite.md → feature-lite.md
   - Rename sub-specs/ → specs/, story files
   - Move product/docs/research to Junior structure
   
   All renames via git mv to preserve history.
   Next: Update cross-references in content.
   ```

### Step 9: Update Cross-References

**Update all markdown references** using find/grep/sed:

1. Find all `.md` files in `.junior/` and project README
2. Update references:
   - `spec-N` → `feat-N` (in links, mentions, etc.)
   - `YYYY-MM-DD-name` → `feat-N-name` (if any date references remain)
   - `.code-captain/` → `.junior/`
   - `spec.md` → `feature.md`
   - `spec-lite.md` → `feature-lite.md`
   - `sub-specs/` → `specs/`

Show progress: "Updated N references in M files"

### Step 10: Commit Reference Updates

Stage and commit content changes:
```
Migrate Code Captain to Junior: update cross-references

- Update all spec-N → feat-N references
- Update file references (spec.md → feature.md, etc.)
- Update directory references (.code-captain/ → .junior/)

All internal links now point to new Junior structure.
```

### Step 11: Clean Up Outdated Docs

**CRITICAL: Do NOT create migration-guide.md or any new documentation!**

If `.junior/docs/migration-guide.md` exists (Code Captain's spec→feat migration guide), delete it:
- Use `git rm`
- Commit: "Remove outdated Code Captain migration-guide.md"

**Do NOT delete:** Research, product decisions, architecture, mission/roadmap files.

### Step 12: Show Summary

**CRITICAL: DO NOT generate migration-guide.md, migration reports, or ANY documentation files!**

Show concise terminal summary:
```
✅ Migration complete! (N commits)

✅ N features migrated
✅ N experiments migrated
✅ File renames completed
✅ All references updated
✅ All changes committed

Done!
```

### Step 13: Verification

Suggest verification steps:
```
Verify with:
- git log --oneline -3
- /status
- ls .junior/features/

All done!
```

## Tool Integration

**Primary tools:**
- `run_terminal_cmd` - For hidden directories (`.code-captain/`, `.junior/`), git commands
- `read_file` - Validation
- `grep` / `search_replace` - Update references

**CRITICAL:** 
- Never use `list_dir` for `.code-captain/` or `.junior/` - they're hidden. Use `run_terminal_cmd`.
- Commit renames FIRST (Step 8), then content (Step 9-10).
- NEVER use `write` for migration reports or documentation.

## Error Handling

**No Code Captain:** If `.code-captain/` not found, show error suggesting `/init` for new projects.

**Dirty git:** If uncommitted changes exist, warn user and suggest committing/stashing first. Offer to proceed anyway.

**Validation failures:** Show issues found, mark as non-blocking if minor. For critical issues (missing files), ask user to fix first.

**Migration interrupted:** Offer rollback via `git reset --hard HEAD` or retry.

**Permissions:** If git mv fails, suggest closing files, checking permissions.

## Best Practices

**Before:** Ensure clean git status, close files, validate structure.

**During:** 
- Use `git mv` for all renames (preserves history)
- Commit renames first, then content changes (separate commits)
- Show progress
- Merge product/docs intelligently: `product/decisions.md` → `decisions/product-decisions.md`, others → `docs/`

**After:** Verify with `/status`, review commits, test commands.

**Recovery:** `git reset --hard HEAD` to rollback. Can re-run `/migrate` if needed.

## Examples

**Successful flow:**
1. User: `/migrate`
2. Detect & validate (Steps 1-3, no stopping)
3. Show plan, get approval (Step 4, STOP HERE)
4. User: `yes`
5. Execute migration (Steps 5-13)
6. Show summary

**Error cases:**
- No `.code-captain/` → Suggest `/init`
- Dirty git → Warn, offer to proceed
- Validation issues → Show issues, proceed if non-blocking

---

Migrate seamlessly. Preserve history. Continue building.

