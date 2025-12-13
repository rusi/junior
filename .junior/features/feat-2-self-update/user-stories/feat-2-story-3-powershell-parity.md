# Story 3: PowerShell Update Script with Platform Parity

> **Status:** Completed
> **Priority:** High
> **Dependencies:** Story 2 (bash implementation must be complete)
> **Deliverable:** Working `.junior/update.ps1` with feature parity to bash version

## User Story

**As a** Junior user on Windows
**I want** to update my Junior installation with the same features as bash
**So that** I have the same update experience regardless of platform

## Scope

**In Scope:**
- Create `.junior/update.ps1` mirroring bash functionality
- Version checking via GitHub API
- Tarball download and extraction (PowerShell native methods)
- Install script invocation (PowerShell version)
- Cleanup and error handling
- All flags (`-Force`) and options from bash version

**Out of Scope:**
- Install integration (Story 4)
- Bash script changes (already complete in Story 2)

## Acceptance Criteria

- [x] Given Junior installed on Windows, when user runs `.junior/update.ps1`, then checks version like bash ✅
- [x] Given update available, when user confirms, then downloads and extracts tarball ✅
- [x] Given source extracted, when install runs, then invokes `install-junior.ps1` with correct path ✅
- [x] Given install completes, when cleanup runs, then removes temp files ✅
- [x] Given `-Force` parameter, when script runs, then skips confirmation ✅
- [x] Given error occurs, when handling, then displays same quality messages as bash version ✅

## Implementation Tasks

### Phase 1: Bring install-junior.ps1 to Feature Parity

- [x] 3.1 Add Verbose mode to install-junior.ps1 (matching bash -v flag) ✅
- [x] 3.2 Add cleanup_code_captain function to install-junior.ps1 (~210 lines from bash) ✅
- [x] 3.3 Add .githash file support to install-junior.ps1 (for update script integration) ✅

### Phase 2: Create update.ps1 Script

- [x] 3.4 Create update.ps1 with parameter parsing (Force, CheckOnly, Verbose, LocalSource) ✅
- [x] 3.5 Implement version checking (read metadata, query GitHub API) ✅
- [x] 3.6 Implement tarball download and extraction (Invoke-WebRequest with progress) ✅
- [x] 3.7 Implement install script execution and temp cleanup ✅
- [x] 3.8 Add all utility functions (Write-Status, Write-Debug, etc.) ✅

## Technical Notes

**PowerShell Parameter:**
```powershell
param(
    [Parameter(Mandatory=$false)]
    [switch]$Force,

    [Parameter(Mandatory=$false)]
    [switch]$CheckOnly
)
```

**Metadata Reading:**
```powershell
$MetadataFile = ".junior\.junior-install.json"
$Metadata = Get-Content $MetadataFile -Raw | ConvertFrom-Json
$CurrentHash = $Metadata.commit_hash
```

**GitHub API Call:**
```powershell
$ApiUrl = "https://api.github.com/repos/$Owner/$Repo/commits/$Branch"
$Response = Invoke-RestMethod -Uri $ApiUrl -Method Get
$LatestHash = $Response.sha
```

**Temporary Directory:**
```powershell
$TempDir = New-Item -ItemType Directory -Path "$env:TEMP\.junior-update-$(Get-Random)"
try {
    # Update logic
} finally {
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}
```

**Tarball Download & Extract:**
```powershell
$TarballUrl = "https://github.com/$Owner/$Repo/archive/refs/heads/$Branch.tar.gz"
$TarballPath = Join-Path $TempDir "junior.tar.gz"
Invoke-WebRequest -Uri $TarballUrl -OutFile $TarballPath

# Extract using tar (Windows 10+ has built-in tar)
tar -xzf $TarballPath -C $TempDir

# Find extracted directory
$ExtractedDir = Get-ChildItem -Path $TempDir -Directory | Where-Object { $_.Name -like "$Repo-*" } | Select-Object -First 1
```

**Install Script Invocation:**
```powershell
$InstallScript = Join-Path $ExtractedDir.FullName "scripts\install-junior.ps1"
$ProjectRoot = (Get-Location).Path

& $InstallScript -TargetPath $ProjectRoot -IgnoreDirty -Force
```

**Color Output:**
Reuse from `install-junior.ps1`:
```powershell
Write-Host "[INFO] $Message" -ForegroundColor Blue
Write-Host "[SUCCESS] $Message" -ForegroundColor Green
Write-Host "[WARNING] $Message" -ForegroundColor Yellow
Write-Host "[ERROR] $Message" -ForegroundColor Red
```

See [specs/01-Technical.md](../specs/01-Technical.md) for detailed technical approach.

## Testing Strategy

**TDD Approach:**
- Write tests first (Pester framework)
- Implement to pass tests
- Refactor for clarity

**Unit Tests (Pester):**
- Metadata parsing
- GitHub API response handling
- Version comparison logic
- Path construction

**Integration Tests:**
- Full update flow with mocked GitHub
- Error scenarios
- Cleanup verification

**Manual Testing:**
- Run `.junior/update.ps1` on Windows test project
- Verify download progress
- Confirm installation succeeds
- Check temp cleanup
- Test `-Force` flag
- Compare output/behavior with bash version

## Definition of Done

- [x] All tasks completed ✅
- [x] All acceptance criteria met ✅
- [x] PowerShell script has feature parity with bash version ✅
- [x] install-junior.ps1 has full feature parity with install-junior.sh ✅
- [x] Error handling matches bash quality ✅
- [x] Code follows PowerShell best practices ✅
- [x] **Windows users can run `.junior/update.ps1` and update Junior** ✅
- [x] Ready for Story 4 (install integration) ✅

