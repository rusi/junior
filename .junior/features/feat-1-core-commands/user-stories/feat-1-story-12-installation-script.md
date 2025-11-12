# Story 12: Create Installation Script

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** All previous stories (needs complete command set to test)
> **Deliverable:** Fully working installation script for easy Junior deployment to any project

## User Story

**As a** developer wanting to use Junior
**I want** a simple installation script
**So that** I can set up Junior in any project with one command

## Scope

**In Scope:**
- Adapt install-cursor.sh for Junior (macOS/Linux)
- Create install-cursor.ps1 for Junior (Windows PowerShell)
- Update install-config.json for Junior structure
- Create `.junior/` directories
- Copy `.cursor/rules/` and `.cursor/commands/` files
- Generate helpful README or welcome message
- Verify installation completeness

**Out of Scope:**
- Auto-update mechanism
- Version management
- Plugin system for custom commands
- IDE integration beyond file copying
- Migration during installation (use `/migrate` command)

## Acceptance Criteria

- [ ] Given target directory, when script runs, then creates `.junior/` structure
- [ ] Given source files, when installing, then copies all rules and commands
- [ ] Given installation complete, when user opens project, then Cursor recognizes commands
- [ ] Given fresh installation, when verified, then all commands accessible via `/`
- [ ] Given Windows system, when PowerShell script runs, then installation succeeds
- [ ] Given existing installation, when re-run, then preserves local customizations

## Implementation Tasks

- [ ] 12.1 Research `reference-impl/scripts/install-cursor.sh`, `install-cursor.ps1`, and `install-config.json`
- [ ] 12.2 Update `install-config.json` for Junior structure (`.junior/` directories, rule files, commands)
- [ ] 12.3 Adapt `install-cursor.sh` for Junior (rename Code Captain → Junior, update paths and messages)
- [ ] 12.4 Adapt `install-cursor.ps1` for Junior (Windows PowerShell support with same changes)
- [ ] 12.5 Update welcome message and available commands list for Junior
- [ ] 12.6 User review: Test installation on clean directory (macOS/Linux with .sh, Windows with .ps1)
- [ ] 12.7 Verify all directories created and files copied correctly
- [ ] 12.8 Update main README.md with installation instructions
- [ ] 12.9 Finalize: Test re-installation (verify preserves customizations)

## Technical Notes

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
      "source": ".cursor/commands/",
      "destination": ".cursor/commands/",
      "isDirectory": true
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
    "availableCommands": "/feature, /implement, /status, /research, /experiment, /prototype, /init, /migrate, /idea, /bugfix, /enhancement, /commit, /new-command"
  }
}
```

**Installation Script Features:**
- Color-coded output (info, success, warning, error)
- Verify dependencies (git, jq)
- Check if already installed (don't overwrite customizations)
- Create all necessary directories
- Copy files from source to target
- Preserve existing work if re-installing
- Generate installation summary

**Usage:**
```bash
# macOS/Linux
./scripts/install-cursor.sh /path/to/project

# Windows PowerShell
.\scripts\install-cursor.ps1 "C:\path\to\project"
```

See [../feature.md](../feature.md) for overall feature context.

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

