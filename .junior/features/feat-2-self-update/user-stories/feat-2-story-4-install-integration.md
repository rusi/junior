# Story 4: Install Integration & Documentation

> **Status:** Not Started
> **Priority:** High
> **Dependencies:** Story 3 (both update scripts must exist)
> **Deliverable:** Update scripts installed with Junior, documented and ready for users

## User Story

**As a** Junior user
**I want** the update script installed automatically with Junior
**So that** I can update my installation without manual setup

## Scope

**In Scope:**
- Add update scripts to `install-config.json`
- Update `JUNIOR.md` (installed as `JUNIOR.md` in user projects) with update instructions
- Update Junior repo `README.md` with update documentation
- Test installation of update scripts on fresh install
- Test upgrade scenario (existing Junior installations get update script)

**Out of Scope:**
- Script functionality changes (already complete)
- Automatic update checking (future enhancement)

## Acceptance Criteria

- [ ] Given fresh Junior install, when installed, then `.junior/update.sh` and `.junior/update.ps1` are present
- [ ] Given existing Junior install, when upgraded, then update scripts are added
- [ ] Given user reads `JUNIOR.md`, when looking for updates, then finds clear instructions
- [ ] Given user reads Junior repo `README.md`, when checking installation docs, then sees update section
- [ ] Given update scripts installed, when user runs them, then they work without additional setup

## Implementation Tasks

- [ ] 4.1 Add update scripts to `install-config.json` files array
- [ ] 4.2 Update `README.md` (becomes `JUNIOR.md` in user projects) with update instructions
- [ ] 4.3 Update Junior repo `README.md` with update feature documentation
- [ ] 4.4 Test fresh installation includes update scripts
- [ ] 4.5 Test upgrade scenario (re-run install on project with existing Junior)

## Technical Notes

**Update install-config.json:**
```json
{
  "files": [
    ...existing entries...,
    {
      "source": "scripts/update-junior.sh",
      "destination": ".junior/update.sh"
    },
    {
      "source": "scripts/update-junior.ps1",
      "destination": ".junior/update.ps1"
    }
  ]
}
```

**JUNIOR.md Update Instructions Section:**
```markdown
## Updating Junior

To update your Junior installation to the latest version:

**macOS / Linux:**
```bash
./.junior/update.sh
```

**Windows (PowerShell):**
```powershell
.\.junior\update.ps1
```

The update script will:
1. Check if an update is available
2. Show current and latest versions
3. Download and install the update (with confirmation)
4. Preserve your customizations

**Skip confirmation (automation):**
```bash
./.junior/update.sh --force
```
```

**README.md (Junior repo) Updates:**
- Add "Updating" section after "Installation"
- Mention automatic update script installation
- Link to update documentation

**File Locations:**
- Source: `scripts/update-junior.sh` and `scripts/update-junior.ps1` (in Junior repo)
- Destination: `.junior/update.sh` and `.junior/update.ps1` (in user projects)

See [specs/01-Technical.md](../specs/01-Technical.md) for detailed technical approach.

## Testing Strategy

**TDD Approach:**
- Tests first, implement, verify

**Integration Tests:**
- Fresh install test: Install Junior in new project, verify update scripts present
- Upgrade test: Re-install Junior in project with existing installation, verify update scripts added
- Functional test: Run update script after installation, verify it works

**Manual Testing:**
- Install Junior in fresh test project
- Check `.junior/update.sh` and `.junior/update.ps1` exist
- Run update script
- Verify documentation is clear and accurate
- Test upgrade scenario (re-install on existing Junior)

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] Update scripts added to `install-config.json`
- [ ] Documentation updated (JUNIOR.md and README.md)
- [ ] Fresh install includes update scripts
- [ ] Upgrade scenario adds update scripts
- [ ] **New Junior installations come with working update capability**
- [ ] **Documentation is clear and accurate**
- [ ] Feature complete and ready for release

