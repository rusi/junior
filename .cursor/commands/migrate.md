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
    {"id": "update-references", "content": "Update cross-references in markdown files", "status": "pending"},
    {"id": "generate-report", "content": "Generate migration report", "status": "pending"}
  ]
}
```

### Step 2: Detect Code Captain Installation

**Check for Code Captain directory:**

```bash
# Check if .code-captain exists
if [ -d ".code-captain" ]; then
  echo "Code Captain installation found"
else
  echo "No Code Captain installation detected"
  exit 1
fi
```

**Detect Code Captain version:**

Use `run_terminal_cmd` to detect structure (`.code-captain` is hidden, so use shell commands):

```bash
# Check for spec-N-name pattern (v2)
if [ -d ".code-captain/specs" ] && ls .code-captain/specs/spec-[0-9]* 2>/dev/null | head -1; then
  echo "Code Captain v2 detected (spec-N-name pattern)"
  CC_VERSION="v2"
# Check for date-prefixed pattern (v1)
elif [ -d ".code-captain/specs" ] && ls .code-captain/specs/20[0-9][0-9]-* 2>/dev/null | head -1; then
  echo "Code Captain v1 detected (date-prefixed pattern)"
  CC_VERSION="v1"
else
  echo "Code Captain detected but no specs directory (legacy or custom structure)"
  CC_VERSION="custom"
fi
```

**Check if Junior already exists:**

```bash
# Check if .junior already exists
if [ -d ".junior" ]; then
  echo "Junior structure detected - will merge Code Captain into Junior"
  MIGRATION_MODE="merge"
else
  echo "No Junior structure - will convert Code Captain to Junior"
  MIGRATION_MODE="convert"
fi
```

**Detect structure:**

**CRITICAL:** `.code-captain` and `.junior` are hidden directories. Use `run_terminal_cmd` with shell commands, NOT `list_dir`.

```bash
# Scan Code Captain structure
find .code-captain -type d -maxdepth 2 | sort

# List specs if exists
ls -1 .code-captain/specs/ 2>/dev/null || echo "No specs directory"

# List experiments if exists  
ls -1 .code-captain/experiments/ 2>/dev/null || echo "No experiments directory"

# Count files
find .code-captain -name "*.md" | wc -l
```

Identify:
- Features in `.code-captain/specs/` (both `spec-N-name` and `YYYY-MM-DD-name` patterns)
- Experiments in `.code-captain/experiments/` (looking for `exp-N-name` pattern)
- Research documents in `.code-captain/research/`
- Decision records in `.code-captain/decisions/` or `.code-captain/decision-records/`
- Other directories and content (legacy-*, docs/, etc.)

**Present detection results:**

```
🔍 Code Captain Installation Detected

Code Captain Version: v2 (spec-N-name pattern)
Migration Mode: Convert (no existing Junior structure)

Structure found:
✅ .code-captain/ directory exists
✅ Features: 3 specifications found (spec-1-core-commands, spec-2-api-design, spec-3-database)
✅ Experiments: 2 experiments found (exp-1-feasibility, exp-2-performance)
✅ Research: 5 documents found
✅ Decisions: 2 ADRs found

Status: Ready for migration
```

**Alternative: Date-prefixed version detected:**

```
🔍 Code Captain Installation Detected

Code Captain Version: v1 (date-prefixed pattern)
Migration Mode: Convert (no existing Junior structure)

Structure found:
✅ .code-captain/ directory exists
✅ Features: 3 specifications found
   • 2024-11-15-core-commands → will become feat-1-core-commands
   • 2024-11-18-api-design → will become feat-2-api-design
   • 2024-11-20-database → will become feat-3-database
✅ Experiments: 2 experiments found (exp-1-feasibility, exp-2-performance)
✅ Research: 5 documents found
✅ Decisions: 2 ADRs found

Status: Ready for migration
```

**Alternative: Both Junior and Code Captain exist:**

```
🔍 Code Captain Installation Detected

Code Captain Version: v2 (spec-N-name pattern)
Migration Mode: Merge (Junior structure already exists)

Code Captain (.code-captain/):
✅ Features: 3 specifications found (spec-1-core-commands, spec-2-api-design, spec-3-database)
✅ Experiments: 2 experiments found (exp-1-feasibility, exp-2-performance)
✅ Research: 5 documents found

Junior (.junior/):
✅ Features: 2 features found (feat-1-onboarding, feat-2-dashboard)
✅ Experiments: 1 experiment found (exp-1-prototype)
✅ Research: 3 documents found

Migration Strategy:
• Code Captain features will be renumbered to avoid conflicts
  - spec-1-core-commands → feat-3-core-commands (next available)
  - spec-2-api-design → feat-4-api-design
  - spec-3-database → feat-5-database
• Experiments will be renumbered similarly
  - exp-1-feasibility → exp-2-feasibility (next available)
  - exp-2-performance → exp-3-performance
• Research and decisions will be merged into Junior directories

Status: Ready for merge migration
```

**Error cases:**

```
❌ No Code Captain Installation Found

Could not find .code-captain/ directory.

This command migrates Code Captain projects to Junior.
If you're starting fresh, use /init instead.
```

```
✅ Both Junior and Code Captain Detected

Will merge Code Captain into existing Junior structure.

Strategy:
• Renumber Code Captain features to avoid conflicts
• Merge research and decision documents
• Preserve all work from both systems

Proceeding with merge migration...
```

### Step 3: Validate Structure

**Parse and validate Code Captain structure:**

For each directory in `.code-captain/specs/`:
- Verify it follows `spec-N-name` pattern
- Check for required files: `spec.md` or `feature.md`
- Check for `user-stories/` directory
- Parse story files to count tasks and progress

For each directory in `.code-captain/experiments/`:
- Verify it follows `exp-N-name` pattern
- Check for `experiment.md`
- Check for `user-stories/` directory

**Validation checks:**

- Spec directories follow naming convention (both v1 and v2 patterns)
- Story files exist and are parseable
- Markdown file integrity
- Git repository is clean (no merge conflicts)

**Present validation results:**

```
✅ Structure Validation Complete

Features (3):
✅ spec-1-core-commands (12 stories, 98 tasks, 42% complete)
✅ spec-2-api-design (5 stories, 32 tasks, 15% complete)
✅ spec-3-database (8 stories, 54 tasks, 0% complete)

Experiments (2):
✅ exp-1-feasibility (3 stories, completed)
✅ exp-2-performance (2 stories, in progress)

Research & Docs:
✅ 5 research documents
✅ 2 decision records

⚠️  Validation Issues: None

Ready to proceed with migration.
```

**Validation with issues (non-blocking):**

```
⚠️  Structure Validation Complete with Issues

Features (3):
✅ spec-1-core-commands (12 stories, 98 tasks, 42% complete)
⚠️  spec-2-api-design (5 stories, 32 tasks, 15% complete)
    • 3 story files have parse errors
    • Will be migrated, flagged for post-migration review
✅ spec-3-database (8 stories, 54 tasks, 0% complete)

Experiments (2):
⚠️  exp-1-feasibility (3 stories, completed)
    • experiment.md has syntax errors
    • Will be migrated, flagged for post-migration review
✅ exp-2-performance (2 stories, in progress)

Research & Docs:
✅ 5 research documents
✅ 2 decision records

⚠️  Validation Issues: 4 issues found (non-blocking)

Migration will proceed. Issues will be documented in post-migration fix list.
```

### Step 4: Create Migration Plan & Get Approval

**Generate migration plan:**

```
📋 Migration Plan

DIRECTORY CHANGES:
.code-captain/ → .junior/

FEATURE RENAMES (spec → feat):
✅ spec-1-core-commands → feat-1-core-commands
   • 12 stories will be renamed (spec-1-story-1 → feat-1-story-1)
   • 98 tasks preserved
   • 42% progress preserved

✅ spec-2-api-design → feat-2-api-design
   • 5 stories will be renamed
   • 32 tasks preserved
   • 15% progress preserved

✅ spec-3-database → feat-3-database
   • 8 stories will be renamed
   • 54 tasks preserved
   • 0% progress preserved

EXPERIMENTS (no change):
✅ exp-1-feasibility (unchanged)
✅ exp-2-performance (unchanged)

REFERENCE UPDATES:
✅ Update markdown links: spec-N- → feat-N-
✅ Update directory references: .code-captain/ → .junior/
✅ Preserve exp-N- references unchanged
✅ Update README.md if it references old structure

GIT OPERATIONS:
✅ Use git mv for all renames (preserves history)
✅ All changes will be staged but not committed
✅ You can review changes before committing

ESTIMATED TIME: ~30 seconds
ESTIMATED CHANGES: ~45 files renamed, ~120 reference updates

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  IMPORTANT: Ensure you have no uncommitted changes or commit them first.

Proceed with migration? [yes/no/cancel]
```

**User options:**

- **yes** - Proceed with migration
- **dry-run** - Show detailed report without making changes
- **cancel** - Exit without changes

**Dry-run mode:**

If user selects "dry-run":

```
🔍 DRY RUN - No changes will be made

These changes would be performed:

DIRECTORIES:
git mv .code-captain .junior

FEATURES:
git mv .junior/specs/spec-1-core-commands .junior/features/feat-1-core-commands
git mv .junior/specs/spec-2-api-design .junior/features/feat-2-api-design
git mv .junior/specs/spec-3-database .junior/features/feat-3-database

STORY FILES (example - spec-1):
git mv feat-1-core-commands/user-stories/spec-1-story-1-update-feature.md \
      feat-1-core-commands/user-stories/feat-1-story-1-update-feature.md
... (11 more story files)

REFERENCE UPDATES (example):
feat-1-core-commands/user-stories/feat-1-stories.md:
  Line 72: - [Story 1: ...](./spec-1-story-1-update-feature.md)
         → - [Story 1: ...](./feat-1-story-1-update-feature.md)
... (119 more reference updates)

Proceed with migration? [yes/cancel]
```

### Step 5: Rename Directories Using Git

**Execute directory renames based on migration mode and Code Captain version:**

**CRITICAL: Use git mv for all operations to preserve history**

**Mode 1: Convert (no existing Junior) with v2 (spec-N-name):**

```bash
# Step 1: Rename root directory
git mv .code-captain .junior

# Step 2: Rename specs directory to features
git mv .junior/specs .junior/features

# Step 3: Rename each spec-N-name to feat-N-name
cd .junior/features
for dir in spec-*; do
  if [ -d "$dir" ]; then
    # Extract number and name: spec-1-core-commands → 1, core-commands
    num=$(echo "$dir" | sed 's/spec-\([0-9]*\)-.*/\1/')
    name=$(echo "$dir" | sed 's/spec-[0-9]*-//')
    
    # Rename: spec-N-name → feat-N-name
    git mv "$dir" "feat-${num}-${name}"
  fi
done
cd ../..
```

**Mode 2: Convert (no existing Junior) with v1 (date-prefixed):**

```bash
# Step 1: Rename root directory
git mv .code-captain .junior

# Step 2: Rename specs directory to features
git mv .junior/specs .junior/features

# Step 3: Rename date-prefixed specs to feat-N-name (sequential numbering)
cd .junior/features
counter=1
for dir in 20*-*; do
  if [ -d "$dir" ]; then
    # Extract name part after date: 2024-11-15-core-commands → core-commands
    name=$(echo "$dir" | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//')
    
    # Rename to feat-N-name
    git mv "$dir" "feat-${counter}-${name}"
    ((counter++))
  fi
done
cd ../..
```

**Mode 3: Merge (Junior already exists):**

```bash
# Determine next available numbers
NEXT_FEAT=$(find .junior/features -name "feat-*" -type d | \
            sed 's/.*feat-\([0-9]*\)-.*/\1/' | sort -n | tail -1)
NEXT_FEAT=$((NEXT_FEAT + 1))

NEXT_EXP=$(find .junior/experiments -name "exp-*" -type d | \
           sed 's/.*exp-\([0-9]*\)-.*/\1/' | sort -n | tail -1)
NEXT_EXP=$((NEXT_EXP + 1))

# Move Code Captain features one by one with renumbering
cd .code-captain/specs
for dir in spec-* 20*-*; do
  if [ -d "$dir" ]; then
    # Extract or derive name
    if [[ "$dir" == spec-* ]]; then
      name=$(echo "$dir" | sed 's/spec-[0-9]*-//')
    else
      name=$(echo "$dir" | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//')
    fi
    
    # Move to Junior with new number
    git mv "$dir" "../../.junior/features/feat-${NEXT_FEAT}-${name}"
    ((NEXT_FEAT++))
  fi
done

# Move experiments with renumbering
cd ../experiments
for dir in exp-*; do
  if [ -d "$dir" ]; then
    name=$(echo "$dir" | sed 's/exp-[0-9]*-//')
    git mv "$dir" "../../.junior/experiments/exp-${NEXT_EXP}-${name}"
    ((NEXT_EXP++))
  fi
done

# Merge research (move files)
cd ../research
for file in *.md; do
  if [ -f "$file" ]; then
    # Check if file exists in Junior, if so, rename with -cc suffix
    if [ -f "../../.junior/research/$file" ]; then
      base="${file%.md}"
      git mv "$file" "../../.junior/research/${base}-cc.md"
    else
      git mv "$file" "../../.junior/research/$file"
    fi
  fi
done

# Merge decisions
cd ../decisions
for file in *.md; do
  if [ -f "$file" ]; then
    if [ -f "../../.junior/decisions/$file" ]; then
      base="${file%.md}"
      git mv "$file" "../../.junior/decisions/${base}-cc.md"
    else
      git mv "$file" "../../.junior/decisions/$file"
    fi
  fi
done

# Remove empty .code-captain directory
cd ../..
rmdir .code-captain/specs .code-captain/experiments .code-captain/research .code-captain/decisions
rmdir .code-captain
```

**Progress tracking:**

```
🔄 Renaming directories...

✅ .code-captain → .junior
✅ .junior/specs → .junior/features
✅ spec-1-core-commands → feat-1-core-commands
✅ spec-2-api-design → feat-2-api-design
✅ spec-3-database → feat-3-database

Experiments (unchanged):
✅ exp-1-feasibility
✅ exp-2-performance

Directory migration complete (5/5)
```

### Step 6: Rename Story Files

**Rename story files within each feature:**

```bash
cd .junior/features

# For each feature directory
for feat_dir in feat-*; do
  if [ -d "$feat_dir/user-stories" ]; then
    cd "$feat_dir/user-stories"
    
    # Extract feature number
    feat_num=$(echo "$feat_dir" | sed 's/feat-\([0-9]*\)-.*/\1/')
    
    # Rename story files: spec-N-story-M-name.md → feat-N-story-M-name.md
    for story_file in spec-${feat_num}-story-*.md; do
      if [ -f "$story_file" ]; then
        # Replace spec- with feat- in filename
        new_story_file=$(echo "$story_file" | sed "s/spec-${feat_num}/feat-${feat_num}/")
        git mv "$story_file" "$new_story_file"
      fi
    done
    
    # Rename tracking file if exists
    if [ -f "spec-${feat_num}-stories.md" ]; then
      git mv "spec-${feat_num}-stories.md" "feat-${feat_num}-stories.md"
    fi
    
    cd ../..
  fi
done

# Also rename story files in experiments (same pattern)
cd ../experiments
for exp_dir in exp-*; do
  if [ -d "$exp_dir/user-stories" ]; then
    cd "$exp_dir/user-stories"
    
    # Extract experiment number
    exp_num=$(echo "$exp_dir" | sed 's/exp-\([0-9]*\)-.*/\1/')
    
    # Rename story files: spec-N-story-M → exp-N-story-M if any exist
    # (Most experiments should already use exp-N-story-M, but check)
    for story_file in spec-${exp_num}-story-*.md; do
      if [ -f "$story_file" ]; then
        new_story_file=$(echo "$story_file" | sed "s/spec-${exp_num}/exp-${exp_num}/")
        git mv "$story_file" "$new_story_file"
      fi
    done
    
    cd ../..
  fi
done

cd ../..
```

**Progress tracking:**

```
🔄 Renaming story files...

Feature 1 (feat-1-core-commands):
✅ spec-1-story-1-update-feature.md → feat-1-story-1-update-feature.md
✅ spec-1-story-2-implement-command.md → feat-1-story-2-implement-command.md
... (10 more stories)
✅ spec-1-stories.md → feat-1-stories.md

Feature 2 (feat-2-api-design):
✅ spec-2-story-1-api-design.md → feat-2-story-1-api-design.md
... (4 more stories)
✅ spec-2-stories.md → feat-2-stories.md

Feature 3 (feat-3-database):
✅ spec-3-story-1-schema-design.md → feat-3-story-1-schema-design.md
... (7 more stories)
✅ spec-3-stories.md → feat-3-stories.md

Experiments:
✅ All experiment stories already use exp-N-story-M pattern

Story file migration complete (25/25)
```

### Step 7: Update Cross-References

**Parse and update markdown references:**

**CRITICAL: Update all internal links to use new naming**

```bash
# Find all markdown files in .junior/
find .junior -name "*.md" -type f > /tmp/junior-md-files.txt

# For each markdown file
while IFS= read -r file; do
  # Update spec-N- references to feat-N-
  # Pattern: spec-(\d+) → feat-\1
  sed -i.bak 's/spec-\([0-9]\+\)/feat-\1/g' "$file"
  
  # Update .code-captain/ references to .junior/
  sed -i.bak 's/\.code-captain\//\.junior\//g' "$file"
  
  # Remove backup files
  rm "${file}.bak"
done < /tmp/junior-md-files.txt

# Also check README.md if it exists
if [ -f "README.md" ]; then
  sed -i.bak 's/spec-\([0-9]\+\)/feat-\1/g' README.md
  sed -i.bak 's/\.code-captain\//\.junior\//g' README.md
  rm README.md.bak
fi
```

**Using Cursor tools for reference updates:**

Use `grep` to find all references, then `search_replace` to update them:

```bash
# Find all spec-N references
grep -r "spec-[0-9]" .junior/ --include="*.md"

# Update each file with search_replace
# Example: In feat-1-stories.md
# Old: - [Story 1: ...](./spec-1-story-1-update-feature.md)
# New: - [Story 1: ...](./feat-1-story-1-update-feature.md)
```

**Progress tracking:**

```
🔄 Updating cross-references...

Scanning markdown files...
✅ Found 47 markdown files to process

Updating references:
✅ feat-1-core-commands/feature.md (12 references updated)
✅ feat-1-core-commands/user-stories/feat-1-stories.md (18 references updated)
✅ feat-1-core-commands/user-stories/feat-1-story-1-update-feature.md (5 references updated)
... (44 more files)

✅ README.md (7 references updated)

Summary:
✅ 127 spec-N → feat-N references updated
✅ 15 .code-captain/ → .junior/ references updated
✅ 0 exp-N references (unchanged as expected)

Cross-reference migration complete (142 updates)
```

### Step 8: Generate Migration Report & Post-Migration Fix List

**Create comprehensive migration report:**

```
✅ Migration Completed Successfully!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 MIGRATION SUMMARY

DIRECTORIES:
✅ .code-captain/ → .junior/
✅ .junior/specs/ → .junior/features/

FEATURES MIGRATED (3):
✅ spec-1-core-commands → feat-1-core-commands
   • 12 stories renamed
   • 98 tasks preserved
   • 42% progress preserved

✅ spec-2-api-design → feat-2-api-design
   • 5 stories renamed
   • 32 tasks preserved
   • 15% progress preserved

✅ spec-3-database → feat-3-database
   • 8 stories renamed
   • 54 tasks preserved
   • 0% progress preserved

EXPERIMENTS (unchanged) (2):
✅ exp-1-feasibility (3 stories)
✅ exp-2-performance (2 stories)

STORY FILES:
✅ 25 story files renamed
✅ 3 tracking files updated (feat-N-stories.md)

CROSS-REFERENCES:
✅ 127 spec-N → feat-N updates
✅ 15 .code-captain/ → .junior/ updates
✅ 47 markdown files processed

GIT STATUS:
✅ All changes staged using git mv
✅ Git history preserved
⚠️  Changes not committed yet

TOTAL FILES AFFECTED: 72 files

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ VERIFICATION

Run these commands to verify migration:

1. Check git status:
   git status

2. Review changes:
   git diff --cached

3. Test with Junior commands:
   /status

4. Commit when ready:
   /commit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 NEXT STEPS

1. Review the staged changes: git diff --cached
2. Test Junior commands: /status, /implement
3. Commit migration: /commit with message "Migrate from Code Captain to Junior"
4. Update any project documentation referencing Code Captain
5. Continue working with Junior commands

Your project is now ready to use Junior! 🚀

All work, progress, and git history have been preserved.
```

**If validation issues were found, append post-migration fix list:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 POST-MIGRATION FIX LIST

The following issues were detected during validation but did not block migration.
Please review and fix these items:

PARSE ERRORS (2):
1. feat-2-api-design/user-stories/feat-2-story-3-endpoints.md
   • Line 45: Unclosed code block
   • Fix: Add closing ``` to code block

2. feat-2-api-design/user-stories/feat-2-story-5-validation.md
   • Line 78: Invalid markdown table syntax
   • Fix: Review and correct table formatting

MISSING FILES (1):
3. exp-1-feasibility/experiment.md
   • Expected file not found
   • Fix: Create experiment.md or verify if work was documented elsewhere

SYNTAX ISSUES (1):
4. feat-2-api-design/feature.md
   • Line 23: Malformed YAML frontmatter
   • Fix: Correct YAML syntax in frontmatter

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 NEXT STEPS FOR FIXES

1. Review each item in the fix list above
2. Use your editor to correct the issues
3. Test with /status to verify structure is valid
4. Remove this section from migration-report.md when complete

These issues don't prevent Junior from working, but fixing them will ensure
optimal functionality and prevent potential problems.
```

**Save migration report to file:**

```bash
# Save report to .junior/migration-report.md
# Include:
# - Timestamp
# - Migration mode and Code Captain version
# - Complete list of changes made
# - Verification steps
# - Post-migration fix list (if validation issues found)
# - Next steps
```

### Step 9: Verification Prompts

**Prompt user to verify migration:**

```
🔍 Verification Recommended

Before committing, please verify:

1. Run: /status
   • Check all features appear correctly
   • Verify progress percentages match

2. Check: git status
   • All files show as renamed (not deleted/added)
   • Preserves git history

3. Review: git diff --cached
   • Spot-check reference updates
   • Ensure no broken links

4. Test: Open a feature file
   • Links work correctly
   • Structure looks good

Would you like to commit these changes now? [yes/no/review]

Options:
- yes: Run /commit to commit migration
- no: Leave changes staged for manual review
- review: Show detailed change summary
```

## Tool Integration

**Primary tools:**

- `run_terminal_cmd` - **REQUIRED** for detecting hidden directories (`.code-captain/`, `.junior/`), execute git mv commands, git status
- `read_file` - Read feature/story files for validation
- `grep` - Find all spec-N references in markdown files
- `search_replace` - Update references in markdown files
- `write` - Generate migration report

**CRITICAL:** Never use `list_dir` for `.code-captain/` or `.junior/` - they are hidden directories and won't appear. Always use shell commands via `run_terminal_cmd`.

**Git commands:**

```bash
# Detection
test -d .code-captain && echo "found" || echo "not found"
test -d .junior && echo "exists" || echo "new"

# Migration
git mv .code-captain .junior
git mv .junior/specs .junior/features
git mv .junior/features/spec-N-name .junior/features/feat-N-name

# Verification
git status --short
git diff --cached --stat
git log --follow -- .junior/features/feat-1-core-commands
```

**Parallel execution opportunities:**

- Directory scanning and file validation
- Reading multiple feature files for validation
- Finding references in multiple markdown files

## Error Handling

**No Code Captain installation:**

```
❌ No Code Captain Installation Found

Could not find .code-captain/ directory.

This command migrates Code Captain projects to Junior.

Options:
• If starting fresh: Use /init to bootstrap Junior project
• If Code Captain was deleted: Cannot migrate without source
• If in wrong directory: Navigate to project root and retry

Use /init for new projects.
```

**Junior already exists:**

```
⚠️  Migration Conflict

Both .code-captain/ and .junior/ exist.

This usually means:
• Migration was already attempted
• You created .junior/ manually
• Project uses both systems

Resolution:
1. Backup .junior/ if it has important work
2. Delete .junior/ to allow migration
3. Run /migrate again

Or manually merge the structures.

Cancel migration? [yes/no]
```

**Git conflicts or dirty working directory:**

```
⚠️  Git Working Directory Not Clean

Uncommitted changes detected:
 M src/auth.ts
 M README.md
?? temp-file.txt

⚠️  Migration uses git mv to preserve history.
⚠️  Uncommitted changes may cause conflicts.

Options:
1. Commit changes first: /commit
2. Stash changes: git stash
3. Proceed anyway (risky)
4. Cancel migration

Which option? [1/2/3/4]
```

**Corrupted structure:**

```
❌ Structure Validation Failed

Issues found in Code Captain structure:

Features:
❌ spec-1-core-commands/feature.md is missing
❌ spec-2-api-design has invalid markdown syntax
⚠️  spec-3-database has no user-stories/ directory

Experiments:
✅ All experiments valid

🔧 Fix these issues before migrating:

1. Restore or recreate missing feature.md files
2. Fix markdown syntax errors
3. Create user-stories/ directories for all features

After fixing, run /migrate again.

Need help? Use /research to investigate file structure issues.
```

**Migration interrupted:**

```
⚠️  Migration Interrupted

Migration was started but not completed.

Current state:
✅ .code-captain → .junior (completed)
✅ spec-1 → feat-1 (completed)
⚠️  spec-2 (in progress - partially renamed)
❌ spec-3 (not started)

Recovery options:
1. Rollback: git reset --hard HEAD
2. Continue: Re-run /migrate (will skip completed work)
3. Manual: Fix remaining renames manually

Which option? [1/2/3]
```

**Filesystem permission errors:**

```
❌ Migration Failed: Permission Denied

Could not rename: .code-captain → .junior
Error: Permission denied

Possible causes:
• File/directory is open in another program
• Insufficient filesystem permissions
• Filesystem is read-only

Resolution:
1. Close all files in .code-captain/
2. Check file permissions: ls -la .code-captain
3. Ensure you have write access
4. Try running with appropriate permissions

Run /migrate again after resolving permissions.
```

## Best Practices

**Before migration:**

1. **Commit all work** - Clean working directory prevents conflicts (git provides version control)
2. **Review structure** - Ensure Code Captain structure is valid
3. **Close editors** - Close all files to prevent lock issues
4. **Check git status** - Verify repository is clean

**During migration:**

1. **Use git mv** - Preserves complete git history
2. **Stage but don't commit** - Allow user to review changes
3. **Validate at each step** - Catch errors early
4. **Show progress** - Keep user informed of long operations

**After migration:**

1. **Verify with /status** - Ensure all features recognized
2. **Review git changes** - `git diff --cached` to spot-check
3. **Test commands** - Try `/implement`, `/status` to confirm functionality
4. **Commit migration** - `/commit` with clear migration message
5. **Update docs** - Update any external documentation referencing Code Captain

**Error recovery:**

1. **Git provides rollback** - `git reset --hard HEAD` to undo
2. **Idempotent design** - Can re-run /migrate safely
3. **Clear error messages** - Guide user to resolution
4. **Validation first** - Catch issues before making changes

## Security & Safety

**Data preservation:**

- All renames use `git mv` to preserve complete git history
- No files are deleted during migration (only moved/renamed)
- All task progress and completion status preserved
- Changes are staged but not auto-committed
- Git provides version control (no separate backups needed)

**Validation:**

- Detect existing .junior/ to prevent overwrites
- Validate structure before starting migration
- Check for git conflicts before proceeding
- Verify all files exist before renaming

**Rollback:**

- All changes are staged, allowing rollback with `git reset --hard HEAD`
- No destructive operations without user confirmation
- Clear recovery instructions for interrupted migrations

**User control:**

- Dry-run mode available to preview changes
- User approval required before migration starts
- Changes staged but not committed (user commits manually)
- Clear verification steps provided

## Examples

**Successful migration:**

```
User: /migrate
Junior: 🔍 Code Captain Installation Detected
        Structure: 3 features, 2 experiments
        Ready for migration
        
        [Shows migration plan]
        
        Proceed with migration? [yes/no/cancel]
User: yes
Junior: [Performs migration]
        ✅ Migration Completed Successfully!
        [Shows migration report]
        
        Verify with /status and commit when ready.
```

**Already migrated:**

```
User: /migrate
Junior: ⚠️  Junior structure already exists
        
        Migration may have already been completed.
        Run /status to verify.
```

**No Code Captain found:**

```
User: /migrate
Junior: ❌ No Code Captain Installation Found
        
        This command migrates from Code Captain to Junior.
        If starting fresh, use /init instead.
```

---

Migrate seamlessly. Preserve history. Continue building.

