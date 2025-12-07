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

**VERIFICATION CRITICAL:**
- After renaming files (Steps 5-7), ALWAYS verify completeness (Step 8) BEFORE committing (Step 9). Never skip!
- After updating references (Step 10), ALWAYS verify completeness (Step 11) BEFORE committing (Step 12). Never skip!
- If ANY verification fails, fix the issues and re-verify before proceeding.

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

**CRITICAL:** `.code-captain` and `.junior` are hidden directories. Use `run_terminal_cmd` with shell commands, NOT `list_dir`.

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
• Update file references (spec.md → feat-N-overview.md, etc.)

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

### Step 10: Update Cross-References

**Update all markdown references** using find/grep/sed:

**CRITICAL: Only update references to FEATURE/EXPERIMENT files in .junior/, NOT command files in .cursor/commands/!**
- ✅ Update: `.junior/features/feat-N-name/feature.md` → `feat-N-overview.md`
- ❌ Don't touch: `.cursor/commands/feature.md` (this is the command file!)

1. Find all `.md` files in `.junior/` and project README
2. Update references:
   - `spec-N` → `feat-N` (in links, mentions, etc.)
   - `YYYY-MM-DD-name` → `feat-N-name` (if any date references remain)
   - `.code-captain/` → `.junior/`
   - `spec.md` → `feat-N-overview.md` (in .junior/ paths only!)
   - `/feature.md` → `/feat-N-overview.md` (use path separator to avoid command file!)
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
   - Use loops with actual numbers to avoid hitting command files
   - NEVER do blanket sed on entire project - it will corrupt command file references!

Show progress: "Updated N references in M files"

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
   - .junior/docs/roadmap.md:45: "See 2025-10-13-responsive-grid-system"
   - .junior/features/feat-2-familyhub-os/feat-N-overview.md:23: "depends on 2025-10-01-familyhub-os"
   [... list all with file:line:content ...]

⚠️  .code-captain/ references: 3 remaining
   - .junior/docs/mission.md:15: "in .code-captain/specs/"
   - .junior/features/feat-5-layered-bundle-caching/feat-N-overview.md:78: "See .code-captain/docs/"

⚠️  spec.md references: 2 remaining
   - .junior/features/feat-1-school-menu-scrolling/feat-1-stories.md:10: "See spec.md"

❌ Cannot commit - fix these references first!
```

### Step 12: Commit Reference Updates

Stage and commit content changes:
```
Migrate Code Captain to Junior: update cross-references

- Update all spec-N → feat-N references
- Update all date-prefix → feat-N-name references
- Update file references (spec.md → feat-N-overview.md, etc.)
- Update directory references (.code-captain/ → .junior/)
- Update story file references (spec-N-story → feat-N-story, etc.)

All internal links now point to new Junior structure.
```

### Step 13: Clean Up Outdated Docs

**CRITICAL: Do NOT create migration-guide.md or any new documentation!**

If `.junior/docs/migration-guide.md` exists (Code Captain's spec→feat migration guide), delete it:
- Use `git rm`
- Commit: "Remove outdated Code Captain migration-guide.md"

**Do NOT delete:** Research, product decisions, architecture, mission/roadmap files.

### Step 14: Show Summary

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

### Step 15: Verification

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
- ALWAYS verify renames (Step 8) before committing (Step 9)
- ALWAYS verify references (Step 11) before committing (Step 12)
- Commit renames FIRST (Step 9), then content (Step 12)
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
- Verify renames are complete before committing (Step 8)
- Commit renames first (Step 9), then content changes (Step 12) - separate commits
- Verify references are updated before committing (Step 11)
- Show progress at each step
- Merge product/docs intelligently: `product/decisions.md` → `decisions/product-decisions.md`, others → `docs/`

**After:** Verify with `/status`, review commits, test commands.

**Recovery:** `git reset --hard HEAD` to rollback. Can re-run `/migrate` if needed.

## Examples

**Successful flow:**
1. User: `/migrate`
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
- No `.code-captain/` → Suggest `/init`
- Dirty git → Warn, offer to proceed
- Validation issues → Show issues, proceed if non-blocking
- Verification failures (Steps 8 or 11) → List missing items, fix them, re-verify, then proceed

---

Migrate seamlessly. Preserve history. Continue building.

