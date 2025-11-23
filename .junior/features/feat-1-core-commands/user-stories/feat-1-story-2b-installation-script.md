# Story 2b: Create Installation Script

> **Status:** Completed
> **Priority:** High
> **Dependencies:** Story 2 (needs /implement command complete to test workflow)
> **Deliverable:** Fully working installation script for easy Junior deployment to any project

## User Story

**As a** developer wanting to use Junior
**I want** a simple installation script
**So that** I can set up Junior in any project with one command

## Scope

**In Scope:**
- Adapt install-cursor.sh for Junior (macOS/Linux)
- Create install-cursor.ps1 for Junior (Windows PowerShell)
- Update install-config.json for Junior (commands, rules, README→JUNIOR.md, .junior/ structure)
- Create `.cursor/` and `.junior/` directories in target project per 01-structure.mdc
- Copy `.cursor/rules/` and `.cursor/commands/` from Junior source to target
- Copy README.md → JUNIOR.md in target project
- Generate `.junior/.junior-install.json` with version tracking
- Verify installation completeness with checksums
- Smart upgrade logic with user modification detection

**Out of Scope:**
- Auto-update mechanism
- Version management
- Plugin system for custom commands
- IDE integration beyond file copying
- Migration during installation (use `/migrate` command)

## Acceptance Criteria

- ✅ Given Junior source repository, when script runs, then verifies Junior git working directory is clean (needed for version timestamp)
- ✅ Given clean Junior git state, when installing, then creates `.junior/` structure and copies commands, rules, and README per install-config
- ✅ Given source files, when installing, then copies all files with SHA256 checksums
- ✅ Given installation complete, when metadata created, then includes version (commit timestamp) and file checksums
- ✅ Given installation complete, when user opens project, then Cursor recognizes commands
- ✅ Given fresh installation, when verified, then all commands accessible via `/`
- ✅ Given Windows system, when PowerShell script runs, then installation succeeds
- ✅ Given existing installation with user changes, when upgrading, then preserves user customizations (detects via checksum comparison)
- ✅ Given modified files, when using `--sync-back` flag, then syncs changes back to Junior source

## Implementation Tasks

- ✅ 2b.1 Research `reference-impl/scripts/install-cursor.sh`, `install-cursor.ps1`, and `install-config.json`
- ✅ 2b.2 Add git clean check at start (verify Junior source git is clean for version timestamp)
- ✅ 2b.3 Update `install-config.json` for Junior (commands, rules, README→JUNIOR.md, .junior/ directories per 01-structure.mdc)
- ✅ 2b.4 Implement metadata generation: version (commit timestamp from `git log -1 --format=%ct`), file SHA checksums
- ✅ 2b.5 Adapt `install-cursor.sh` for Junior (rename Code Captain → Junior, add metadata, checksum logic)
- ✅ 2b.6 Adapt `install-cursor.ps1` for Junior (Windows PowerShell with same features)
- ✅ 2b.7 Implement smart upgrade: compare checksums, preserve user changes, offer to pull changes back to source
- ✅ 2b.8 Update welcome message and available commands list for Junior
- ✅ 2b.9 User review: Test installation on clean directory (macOS/Linux with .sh, Windows with .ps1)
- ✅ 2b.10 User review: Test upgrade with user-modified files (verify preservation)
- ✅ 2b.11 Verify all directories and files created correctly with metadata (`.junior/.junior-install.json` created)
- ✅ 2b.12 Update main README.md with installation and upgrade instructions
- ✅ 2b.13 Finalize: Test re-installation (verify preserves customizations via checksum comparison)

## Technical Notes

**Installation Metadata:**

Create `.junior/.junior-install.json` in target project during installation:
```json
{
  "version": "1731974400",  // commit timestamp from git log -1 --format=%ct (Junior source)
  "installed_at": "2025-11-19T10:30:00Z",
  "commit_hash": "abc123def456",  // full commit hash from Junior source
  "source_repo": "https://github.com/user/junior",  // optional, if detectable
  "files": {
    ".cursor/rules/00-junior.mdc": {
      "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "size": 1234,
      "modified": false  // set to true during upgrade if checksum differs
    },
    ".cursor/commands/feature.md": {
      "sha256": "d14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f",
      "size": 5678,
      "modified": false
    },
    "JUNIOR.md": {
      "sha256": "a1b2c3d4e5f6...",
      "size": 2345,
      "modified": false
    }
    // ... all installed files per install-config.json
  }
}
```

**Note:** `modified` field is set to `true` during upgrades when SHA256 comparison detects user has changed the file.

**Smart Upgrade Logic:**
1. Read existing `.junior/.junior-install.json` from target project
2. For each file, compute current SHA256 in target project
3. Compare with metadata:
   - Match = original, safe to overwrite
   - Different = user modified, preserve and mark `modified: true`
4. If user modifications detected:
   - Show list of modified files
   - Ask: "Preserve local changes? (yes/no/diff)"
   - Option to copy user changes back to Junior source repository
5. Update metadata with new version (from Junior source git) and checksums

**Git Clean Check (Junior Source):**
```bash
# Run in Junior source repository
# Fail if uncommitted changes (needed for accurate version timestamp)
if [[ -n $(git status --porcelain) ]]; then
  echo "❌ Junior source git not clean. Commit or stash changes first."
  echo "   Version is based on commit timestamp - need clean state."
  exit 1
fi
```

**install-config.json Structure:**
```json
{
  "directories": [
    ".cursor/rules",
    ".cursor/commands",
    ".junior/features",
    ".junior/experiments",
    ".junior/research",
    ".junior/decisions",
    ".junior/docs",
    ".junior/ideas",
    ".junior/bugs",
    ".junior/enhancements"
  ],
  "files": [
    {
      "source": ".cursor/rules/00-junior.mdc",
      "destination": ".cursor/rules/00-junior.mdc"
    },
    {
      "source": ".cursor/rules/01-structure.mdc",
      "destination": ".cursor/rules/01-structure.mdc"
    },
    {
      "source": ".cursor/rules/02-current-date.mdc",
      "destination": ".cursor/rules/02-current-date.mdc"
    },
    {
      "source": ".cursor/rules/03-style-guide.mdc",
      "destination": ".cursor/rules/03-style-guide.mdc"
    },
    {
      "source": ".cursor/commands/",
      "destination": ".cursor/commands/",
      "isDirectory": true
    },
    {
      "source": "README.md",
      "destination": "JUNIOR.md"
    }
  ],
  "messages": {
    "welcome": "Installing Junior - Your expert AI developer...",
    "success": "Junior installation complete!",
    "nextSteps": [
      "Restart Cursor IDE to recognize new commands",
      "Try running: /feature for your first feature",
      "Use /status to check your project state",
      "Run /init if this is a new project"
    ],
    "availableCommands": "/feature, /implement, /status, /research, /experiment, /prototype, /init, /migrate, /idea, /bugfix, /enhancement, /update-feature, /commit, /new-command"
  }
}
```

**Installation Script Features:**
- Git clean check on Junior source (needed for version timestamp)
- Color-coded output (info, success, warning, error)
- Verify dependencies (git, jq, shasum/sha256sum)
- Check if already installed (compare checksums for smart upgrade)
- Create directories per install-config (`.cursor/` and `.junior/` structure per 01-structure.mdc)
- Copy files from Junior source to target project with SHA256 checksums
- Generate `.junior/.junior-install.json` with version and checksums
- Preserve user modifications (detect via checksum comparison, mark `modified: true`)
- Offer to pull user changes back to Junior source repository
- Generate installation/upgrade summary

**Usage:**
```bash
# macOS/Linux
./scripts/install-cursor.sh /path/to/project

# Windows PowerShell
.\scripts\install-cursor.ps1 "C:\path\to\project"
```

See [../feature.md](../feature.md) for overall feature context.

**Testing Guide:** See [../docs/installation-test-guide.md](../docs/installation-test-guide.md) for comprehensive testing procedures.

## Testing Strategy

**TDD Approach:**
- Write tests first (red)
- Implement to pass tests (green)
- Refactor (clean)

**Unit Tests:** 
- Config parsing
- Directory creation logic
- File copying logic

**Integration Tests:** 
- Complete installation on test directory
- Verify all files copied correctly
- Verify Cursor recognizes commands

**Manual Testing:** 
- Run on macOS (zsh/bash)
- Run on Linux (bash)
- Run on Windows (PowerShell)
- Test re-installation (preserves customizations)
- Test installation in project with existing .cursor/

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Script works on macOS, Linux, and Windows
- [ ] All tests passing (unit + integration + manual)
- [ ] No regressions in existing commands
- [ ] Code follows Junior's principles (simple, TDD, vertical slice)
- [ ] Documentation updated in main README.md
- [ ] **User can install Junior in < 1 minute**
- [ ] All commands immediately accessible after install
- [ ] Installation tested on clean projects

