# Installation Script Testing Guide

> **Purpose:** Comprehensive testing procedures for Junior installation scripts  
> **Scripts:** `install-junior.sh` (macOS/Linux), `install-junior.ps1` (Windows)  
> **Story:** feat-1-story-2b-installation-script

## Prerequisites

**Before testing, ensure:**
- Junior source repository has clean git state (no uncommitted changes)
- `jq` is installed (macOS: `brew install jq`, Linux: `apt-get install jq`)
- You have a test directory separate from production projects

## Test Suite

### Test 1: Fresh Installation (macOS/Linux)

**Objective:** Verify clean installation in empty directory

**Steps:**
```bash
# 1. Create test directory
mkdir -p /tmp/test-junior-fresh
cd /tmp/test-junior-fresh

# 2. Verify it's empty
ls -la

# 3. Run installation from Junior source
/path/to/junior/scripts/install-junior.sh /tmp/test-junior-fresh

# 4. Verify success message appears
# Expected: "Junior installation complete!" with green checkmarks
```

**Verification Checklist:**
- [ ] `.cursor/rules/` created with 4 files (00-junior.mdc, 01-structure.mdc, 02-current-date.mdc, 03-style-guide.mdc)
- [ ] `.cursor/commands/` created with 4 files (feature.md, implement.md, commit.md, new-command.md)
- [ ] `JUNIOR.md` created (copy of README.md)
- [ ] `.junior/` directory structure created (features, experiments, research, decisions, docs, ideas, bugs, enhancements)
- [ ] `.junior/.junior-install.json` metadata file created
- [ ] Metadata contains: version, installed_at, commit_hash, files with SHA256 checksums

**Verify metadata structure:**
```bash
cat .junior/.junior-install.json | jq '.'

# Expected structure:
# {
#   "version": "<commit_timestamp>",
#   "installed_at": "<ISO_timestamp>",
#   "commit_hash": "<git_hash>",
#   "files": {
#     ".cursor/rules/00-junior.mdc": {
#       "sha256": "<checksum>",
#       "size": <bytes>,
#       "modified": false
#     },
#     ...
#   }
# }
```

**Test commands in Cursor:**
- [ ] Open `/tmp/test-junior-fresh` in Cursor IDE
- [ ] Try `/feature` command - should be recognized immediately
- [ ] Try `/implement` command - should be recognized immediately
- [ ] Try `/commit` command - should be recognized immediately
- [ ] Try `/new-command` command - should be recognized immediately

---

### Test 2: Upgrade Without Modifications

**Objective:** Verify upgrade overwrites unmodified files

**Steps:**
```bash
# 1. Use fresh installation from Test 1
cd /tmp/test-junior-fresh

# 2. Check current version
cat .junior/.junior-install.json | jq '.version'

# 3. Make a commit in Junior source (to change version)
cd /path/to/junior
# Make trivial change, commit, note new commit hash

# 4. Run installation again
./scripts/install-junior.sh /tmp/test-junior-fresh

# 5. Verify upgrade message appears
# Expected: "Existing Junior installation detected - performing upgrade"
```

**Verification Checklist:**
- [ ] Shows current version and new version
- [ ] All files updated successfully
- [ ] No "user-modified" warnings (nothing was changed)
- [ ] Metadata updated with new version and commit_hash
- [ ] All checksums recalculated

---

### Test 3: Upgrade With User Modifications

**Objective:** Verify user changes are preserved, not overwritten

**Steps:**
```bash
# 1. Use existing installation
cd /tmp/test-junior-fresh

# 2. Modify a rule file (simulate user customization)
echo "" >> .cursor/rules/00-junior.mdc
echo "# My custom modification" >> .cursor/rules/00-junior.mdc

# 3. Modify a command file
echo "" >> .cursor/commands/feature.md
echo "<!-- Custom note -->" >> .cursor/commands/feature.md

# 4. Save current checksums for verification
BEFORE_RULE=$(shasum -a 256 .cursor/rules/00-junior.mdc | awk '{print $1}')
BEFORE_CMD=$(shasum -a 256 .cursor/commands/feature.md | awk '{print $1}')

# 5. Run installation again
/path/to/junior/scripts/install-junior.sh /tmp/test-junior-fresh

# 6. Verify warning appears
# Expected: "User-modified files detected (2 files)"
# Expected: List shows modified files
# Expected: Prompt to copy back to source
```

**Verification Checklist:**
- [ ] Script detects 2 modified files
- [ ] Lists: `.cursor/rules/00-junior.mdc` and `.cursor/commands/feature.md`
- [ ] Shows warning: "These files have been preserved"
- [ ] Asks: "Would you like to copy your changes back to Junior source?"
- [ ] Modified files NOT overwritten (verify content still has custom changes)
- [ ] Unmodified files updated normally
- [ ] Metadata marks modified files with `"modified": true`

**Verify modified files preserved:**
```bash
# Check files still have custom content
tail -2 .cursor/rules/00-junior.mdc
# Expected: "# My custom modification"

tail -1 .cursor/commands/feature.md
# Expected: "<!-- Custom note -->"

# Verify checksums unchanged
AFTER_RULE=$(shasum -a 256 .cursor/rules/00-junior.mdc | awk '{print $1}')
AFTER_CMD=$(shasum -a 256 .cursor/commands/feature.md | awk '{print $1}')

echo "Rule file: $BEFORE_RULE == $AFTER_RULE"
echo "Command file: $BEFORE_CMD == $AFTER_CMD"
# Expected: Checksums match (files unchanged)
```

**Verify metadata reflects modifications:**
```bash
cat .junior/.junior-install.json | jq '.files[".cursor/rules/00-junior.mdc"].modified'
# Expected: true

cat .junior/.junior-install.json | jq '.files[".cursor/commands/feature.md"].modified'
# Expected: true
```

---

### Test 4: Copy Back to Source

**Objective:** Verify user changes can be copied back to Junior source

**Steps:**
```bash
# 1. Continue from Test 3 with modified files
cd /tmp/test-junior-fresh

# 2. Run installation and answer "yes" to copy back prompt
/path/to/junior/scripts/install-junior.sh /tmp/test-junior-fresh
# When prompted: "Would you like to copy your changes back to Junior source? [yes/no]"
# Answer: yes

# 3. Check Junior source for copied changes
cd /path/to/junior
tail -2 .cursor/rules/00-junior.mdc
# Expected: "# My custom modification"

tail -1 .cursor/commands/feature.md
# Expected: "<!-- Custom note -->"
```

**Verification Checklist:**
- [ ] Script shows: "Copying modified files back to Junior source..."
- [ ] Lists each file being copied back
- [ ] Shows: "Changes copied back to Junior source"
- [ ] Warns: "Don't forget to commit these changes in Junior repository!"
- [ ] Files in Junior source now contain user customizations
- [ ] JUNIOR.md changes copied to README.md (if modified)

---

### Test 5: Git Clean Check

**Objective:** Verify script enforces clean git state in Junior source

**Steps:**
```bash
# 1. Make uncommitted change in Junior source
cd /path/to/junior
echo "# test change" >> README.md

# 2. Try to run installation
./scripts/install-junior.sh /tmp/test-junior-fresh

# 3. Verify error message
# Expected: "Junior source git not clean. Commit or stash changes first."
# Expected: Exit code 1 (failure)
# Expected: Shows list of uncommitted changes
```

**Verification Checklist:**
- [ ] Script refuses to run with uncommitted changes
- [ ] Shows error message in red
- [ ] Explains why (version based on commit timestamp)
- [ ] Shows `git status --short` output
- [ ] Exits with error code 1

**Cleanup:**
```bash
cd /path/to/junior
git restore README.md
```

---

### Test 6: Missing Dependencies

**Objective:** Verify script checks for required tools

**Steps:**
```bash
# 1. Temporarily hide jq (if you can)
# macOS example (if jq installed via Homebrew):
mv /opt/homebrew/bin/jq /opt/homebrew/bin/jq.backup

# 2. Try to run installation
/path/to/junior/scripts/install-junior.sh /tmp/test-junior-fresh

# 3. Verify error message
# Expected: "jq is required but not installed"
# Expected: Shows installation instructions

# 4. Restore jq
mv /opt/homebrew/bin/jq.backup /opt/homebrew/bin/jq
```

**Verification Checklist:**
- [ ] Detects missing `jq`
- [ ] Shows error message with installation instructions
- [ ] Exits before attempting installation
- [ ] Instructions cover macOS, Linux, Windows

---

### Test 7: Windows PowerShell (Optional)

**Objective:** Verify PowerShell script works on Windows

**Prerequisites:**
- Windows machine or VM
- PowerShell 5.1 or later
- Git for Windows installed

**Steps:**
```powershell
# 1. Create test directory
New-Item -ItemType Directory -Path "C:\temp\test-junior-fresh"

# 2. Run installation
.\scripts\install-junior.ps1 -TargetPath "C:\temp\test-junior-fresh"

# 3. Verify success message appears
```

**Verification Checklist:**
- [ ] Script runs without errors
- [ ] All directories created under `C:\temp\test-junior-fresh`
- [ ] All files copied correctly
- [ ] Metadata file created with correct structure
- [ ] Commands work in Cursor on Windows

**Test modifications (Windows):**
```powershell
# Modify file
Add-Content -Path "C:\temp\test-junior-fresh\.cursor\rules\00-junior.mdc" -Value "`n# Windows custom modification"

# Run upgrade
.\scripts\install-junior.ps1 -TargetPath "C:\temp\test-junior-fresh"

# Verify preservation
Get-Content "C:\temp\test-junior-fresh\.cursor\rules\00-junior.mdc" | Select-Object -Last 1
# Expected: "# Windows custom modification"
```

---

### Test 8: Installation in Existing Project

**Objective:** Verify installation works alongside existing project files

**Steps:**
```bash
# 1. Create project with existing files
mkdir -p /tmp/test-junior-existing-project
cd /tmp/test-junior-existing-project

# Create some project files
mkdir -p src
echo "console.log('hello');" > src/index.js
echo "# My Project" > README.md
git init

# 2. Run installation
/path/to/junior/scripts/install-junior.sh /tmp/test-junior-existing-project

# 3. Verify no conflicts
ls -la
```

**Verification Checklist:**
- [ ] Existing files untouched (src/index.js, README.md)
- [ ] `.cursor/` directory added
- [ ] `.junior/` directory added
- [ ] `JUNIOR.md` added (README.md still exists)
- [ ] Project files coexist with Junior files
- [ ] Git repository unaffected

---

## Acceptance Criteria Validation

After completing all tests, verify these acceptance criteria from the story:

- [ ] Given Junior source repository, when script runs, then verifies git working directory is clean ✅ (Test 5)
- [ ] Given clean git state, when installing, then creates `.junior/` structure and copies commands, rules, and README ✅ (Test 1)
- [ ] Given source files, when installing, then copies all files with SHA256 checksums ✅ (Test 1)
- [ ] Given installation complete, when metadata created, then includes version (commit timestamp) and file checksums ✅ (Test 1)
- [ ] Given installation complete, when user opens project, then Cursor recognizes commands ✅ (Test 1)
- [ ] Given fresh installation, when verified, then all commands accessible via `/` ✅ (Test 1)
- [ ] Given Windows system, when PowerShell script runs, then installation succeeds ✅ (Test 7)
- [ ] Given existing installation with user changes, when upgrading, then preserves user customizations ✅ (Test 3)
- [ ] Given existing installation with user changes, when detected, then offers to pull changes back to source ✅ (Test 4)

## Definition of Done Validation

- [ ] All tasks completed (13/13)
- [ ] All acceptance criteria met (9/9)
- [ ] Script works on macOS, Linux, and Windows
- [ ] All tests passing (8 tests)
- [ ] No regressions in existing commands
- [ ] Code follows Junior's principles (simple, vertical slice)
- [ ] Documentation updated in main README.md ✅
- [ ] **User can install Junior in < 1 minute** (time Test 1)
- [ ] All commands immediately accessible after install ✅
- [ ] Installation tested on clean projects ✅

---

## Cleanup After Testing

```bash
# Remove test directories
rm -rf /tmp/test-junior-fresh
rm -rf /tmp/test-junior-existing-project

# Restore Junior source if you made test changes
cd /path/to/junior
git restore .
```

## Troubleshooting

**"jq not found" error:**
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq
```

**"shasum not found" error:**
- Script should use `sha256sum` as fallback on Linux
- If both missing, install coreutils package

**PowerShell execution policy error:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Checksum mismatch on re-run:**
- This is expected if you're testing - files change between runs
- For real testing, make a commit in Junior source between tests

---

## Success Criteria

**Story 2b is complete when:**
- ✅ All 8 tests pass
- ✅ All 9 acceptance criteria validated
- ✅ Installation works on macOS/Linux (Test 1-6)
- ✅ Installation works on Windows (Test 7) - optional if no Windows access
- ✅ User can install and use Junior in under 1 minute
- ✅ Smart upgrade preserves user customizations
- ✅ Documentation is clear and accurate

**Current Status:** Ready for testing  
**Estimated Testing Time:** 30-45 minutes for full suite

