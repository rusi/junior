# Story 3: PowerShell Bootstrap Parity

> **Status:** Not Started
> **Priority:** Medium
> **Dependencies:** Story 1 (PowerShell mirrors bash)
> **Deliverable:** Working PowerShell bootstrap script with feature parity to bash version

## User Story

**As a** Windows developer wanting to use Junior
**I want** to install or update Junior with a single PowerShell command
**So that** I have the same streamlined experience as bash users

## Scope

**In Scope:**
- `docs/install.ps1` script mirroring bash functionality
- Uses native PowerShell commands (Invoke-WebRequest, Expand-Archive)
- Works when executed via `irm | iex` pattern
- Handles Windows paths correctly
- Same user experience as bash version
- Update README with PowerShell instructions

**Out of Scope:**
- Linux/macOS PowerShell support (focus on Windows)
- Custom domains (Story 4)
- Advanced features beyond bash parity

## Acceptance Criteria

- [ ] Given Windows user in project directory, when they run `irm <url> | iex`, then Junior installs successfully
- [ ] Given PowerShell bootstrap runs, when compared to bash, then same functionality works
- [ ] Given various Windows path formats, when bootstrap runs, then paths handled correctly
- [ ] Given error occurs, when PowerShell reports it, then message matches bash clarity
- [ ] Given README updated, when Windows user reads it, then clear PowerShell instructions present

## Implementation Tasks

- [ ] 3.1 Write tests for PowerShell tarball download (Invoke-WebRequest)
- [ ] 3.2 Implement download and extraction functions
- [ ] 3.3 Write tests for path handling (Windows-specific)
- [ ] 3.4 Implement main bootstrap flow matching bash logic
- [ ] 3.5 Update README with PowerShell installation section

## Technical Notes

**PowerShell Bootstrap Flow:**
```powershell
1. Detect current location → use as target
2. Create temp directory ($env:TEMP\.junior-bootstrap-XXXXX)
3. Download tarball via Invoke-WebRequest
4. Extract via Expand-Archive or tar (Windows 10+)
5. Run extracted scripts\install-junior.ps1 with current dir
6. Cleanup temp directory (try/finally)
7. Report success/failure
```

**Key Functions (mirror bash):**
- `Get-Tarball` - Invoke-WebRequest with progress
- `Expand-Tarball` - Expand-Archive or tar
- `Invoke-Install` - delegate to install script
- `Remove-TempFiles` - cleanup (finally block)
- Color output functions (Write-Host with colors)

**Windows Considerations:**
- Path separators: Use `Join-Path` consistently
- Temp directory: `$env:TEMP` or `[System.IO.Path]::GetTempPath()`
- Tar availability: Windows 10+ has tar.exe, fallback to Expand-Archive for .zip
- Execution policy: Document in README

**README Addition:**
```markdown
### Windows (PowerShell)

cd C:\path\to\your\project
irm https://USER.github.io/junior/install.ps1 | iex

Note: If you get execution policy errors:
powershell -ExecutionPolicy ByPass -c "irm https://USER.github.io/junior/install.ps1 | iex"
```

See [specs/01-Technical.md](../specs/01-Technical.md) for detailed technical approach.

## Testing Strategy

**TDD Approach:**
- Port bash tests to PowerShell (Pester framework)
- Test download, extraction, cleanup
- Test path handling (Windows-specific)

**Integration Tests:**
- Fresh install on Windows 10/11
- Upgrade existing Junior
- Network failure handling
- Install script failure handling

**Manual Testing:**
- Test on Windows 10
- Test on Windows 11
- Test with PowerShell 5.1 (built-in)
- Test with PowerShell 7+ (modern)
- Verify paths with spaces, Unicode characters

## Definition of Done

- [ ] All tasks completed
- [ ] All acceptance criteria met
- [ ] PowerShell bootstrap works end-to-end
- [ ] All tests passing (Pester tests)
- [ ] Feature parity with bash version
- [ ] Windows paths handled correctly
- [ ] README includes PowerShell instructions
- [ ] Tested on Windows 10 and Windows 11
- [ ] **Windows users can successfully install Junior with single PowerShell command**
- [ ] No regressions in existing install-junior.ps1

