# Junior Installation Script (PowerShell)
# Usage: .\scripts\install-junior.ps1 [-SyncBack] [-IgnoreDirty] [-Force] -TargetPath "C:\path\to\project"

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetPath,

    [Parameter(Mandatory=$false)]
    [switch]$SyncBack,

    [Parameter(Mandatory=$false)]
    [switch]$IgnoreDirty,

    [Parameter(Mandatory=$false)]
    [switch]$Force,

    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Colors = @{
    Green = "Green"
    Red = "Red"
    Yellow = "Yellow"
    Blue = "Blue"
    White = "White"
}

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Colors.Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Colors.Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Colors.Yellow
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Colors.Red
}

function Write-Debug {
    param([string]$Message)
    if ($Verbose) {
        Write-Host "[DEBUG] $Message" -ForegroundColor $Colors.Blue
    }
}

# Function to cleanup Code Captain files
function Invoke-CodeCaptainCleanup {
    param(
        [Parameter(Mandatory=$true)]
        $Config
    )

    Write-Host ""
    Write-Status "═══════════════════════════════════════════════════"
    Write-Status "Code Captain Cleanup"
    Write-Status "═══════════════════════════════════════════════════"
    Write-Host ""

    # Extract Junior files from config (to exclude from uncertain files)
    $JuniorRules = @()
    $JuniorCommands = @()

    foreach ($file in $Config.files) {
        $dest = $file.destination
        if ($dest -like ".cursor\rules\*") {
            $JuniorRules += (Split-Path -Leaf $dest)
        } elseif ($dest -like ".cursor\commands\*") {
            $JuniorCommands += (Split-Path -Leaf $dest)
        }
    }

    # Known Code Captain files (95% confidence)
    $KnownCCFiles = @()
    $KnownCCCommands = @()
    $KnownCCRules = @()

    # Check for known Code Captain files
    if (Test-Path "CODE_CAPTAIN.md" -PathType Leaf) {
        $KnownCCFiles += "CODE_CAPTAIN.md"
    }
    if (Test-Path ".cursor\rules\cc.mdc" -PathType Leaf) {
        $KnownCCRules += ".cursor\rules\cc.mdc"
    }

    # Known Code Captain commands (including overlaps with Junior)
    $CCCommandPatterns = @(
        "commit.md",                        # CC and Junior both have this
        "create-adr.md",
        "create-experiment.md",
        "create-idea.md",
        "create-spec.md",
        "edit-spec.md",
        "enhancement.md",
        "execute-task.md",
        "explain-code.md",
        "fix-bug.md",
        "initialize.md",
        "initialize-python.md",
        "initialize-cursor-vscode.md",
        "new-command.md",                   # CC and Junior both have this
        "plan-product.md",
        "research.md",
        "status.md",                        # CC and Junior both have this
        "swab.md",
        "update-story.md"
    )

    foreach ($cmd in $CCCommandPatterns) {
        $cmdPath = ".cursor\commands\$cmd"
        if (Test-Path $cmdPath -PathType Leaf) {
            $KnownCCCommands += $cmdPath
        }
    }

    # Scan for other commands/rules (uncertain)
    $UncertainCommands = @()
    $UncertainRules = @()

    if (Test-Path ".cursor\commands" -PathType Container) {
        $commands = Get-ChildItem -Path ".cursor\commands" -Filter "*.md" -File -ErrorAction SilentlyContinue

        foreach ($cmd in $commands) {
            $cmdPath = $cmd.FullName.Replace((Get-Location).Path + "\", "")

            # Check if it's not in known CC commands list
            $isKnown = $false
            foreach ($known in $KnownCCCommands) {
                if ($cmdPath -eq $known) {
                    $isKnown = $true
                    break
                }
            }

            # Also skip Junior commands (extracted from config)
            $baseName = $cmd.Name
            foreach ($juniorCmd in $JuniorCommands) {
                if ($baseName -eq $juniorCmd) {
                    $isKnown = $true
                    break
                }
            }

            if (-not $isKnown) {
                $UncertainCommands += $cmdPath
            }
        }
    }

    if (Test-Path ".cursor\rules" -PathType Container) {
        $rules = Get-ChildItem -Path ".cursor\rules" -Filter "*.mdc" -File -ErrorAction SilentlyContinue

        foreach ($rule in $rules) {
            $rulePath = $rule.FullName.Replace((Get-Location).Path + "\", "")

            # Check if it's not in known CC rules list
            $isKnown = $false
            foreach ($known in $KnownCCRules) {
                if ($rulePath -eq $known) {
                    $isKnown = $true
                    break
                }
            }

            # Also skip Junior rules (extracted from config)
            $baseName = $rule.Name
            foreach ($juniorRule in $JuniorRules) {
                if ($baseName -eq $juniorRule) {
                    $isKnown = $true
                    break
                }
            }

            if (-not $isKnown) {
                $UncertainRules += $rulePath
            }
        }
    }

    # Present files to user
    Write-Host ""
    Write-Status "Files to remove (95% confidence from Code Captain):"
    Write-Host ""

    if ($KnownCCFiles.Count -gt 0) {
        Write-Host "  Documentation:"
        foreach ($file in $KnownCCFiles) {
            Write-Host "    • $file"
        }
        Write-Host ""
    }

    if ($KnownCCRules.Count -gt 0) {
        Write-Host "  Rules:"
        foreach ($file in $KnownCCRules) {
            Write-Host "    • $file"
        }
        Write-Host ""
    }

    if ($KnownCCCommands.Count -gt 0) {
        Write-Host "  Commands ($($KnownCCCommands.Count) files):"
        foreach ($file in $KnownCCCommands) {
            Write-Host "    • $file"
        }
        Write-Host ""
    }

    if (($UncertainCommands.Count -gt 0) -or ($UncertainRules.Count -gt 0)) {
        Write-Host ""
        Write-Status "Files with uncertain origin (will be KEPT):"
        Write-Host ""

        if ($UncertainCommands.Count -gt 0) {
            Write-Host "  Commands:"
            foreach ($file in $UncertainCommands) {
                Write-Host "    • $file"
            }
            Write-Host ""
        }

        if ($UncertainRules.Count -gt 0) {
            Write-Host "  Rules:"
            foreach ($file in $UncertainRules) {
                Write-Host "    • $file"
            }
            Write-Host ""
        }

        Write-Status "These files might be custom. They will NOT be removed."
        Write-Status "Review them manually after installation if needed."
        Write-Host ""
    }

    Write-Host ""
    if (Test-Path ".code-captain" -PathType Container) {
        Write-Warning "Note: .code-captain\ directory is NOT removed by this cleanup."
        Write-Warning "Use /migrate command after installation to migrate your work."
    }
    Write-Host ""

    # Confirm cleanup
    if (-not $Force) {
        $response = Read-Host "Remove Code Captain files and continue with installation? [yes/cancel]"

        if (($response -ne "yes") -and ($response -ne "y")) {
            Write-Status "Installation cancelled. No changes made."
            exit 0
        }
    } else {
        Write-Warning "Auto-confirming cleanup (--force enabled)"
    }

    # Perform cleanup (ONLY known CC files)
    Write-Status "Removing Code Captain files..."

    foreach ($file in ($KnownCCFiles + $KnownCCRules + $KnownCCCommands)) {
        if (Test-Path $file -PathType Leaf) {
            Remove-Item -Path $file -Force
            Write-Success "Removed: $file"
        }
    }

    # Clean up empty directories
    if ((Test-Path ".cursor\commands" -PathType Container) -and ((Get-ChildItem ".cursor\commands" -Force | Measure-Object).Count -eq 0)) {
        Remove-Item -Path ".cursor\commands" -Force -ErrorAction SilentlyContinue
    }
    if ((Test-Path ".cursor\rules" -PathType Container) -and ((Get-ChildItem ".cursor\rules" -Force | Measure-Object).Count -eq 0)) {
        Remove-Item -Path ".cursor\rules" -Force -ErrorAction SilentlyContinue
    }
    if ((Test-Path ".cursor" -PathType Container) -and ((Get-ChildItem ".cursor" -Force | Measure-Object).Count -eq 0)) {
        Remove-Item -Path ".cursor" -Force -ErrorAction SilentlyContinue
    }

    Write-Host ""
    Write-Success "Code Captain cleanup complete!"
    Write-Host ""
}

# Function to calculate SHA256 checksum
function Get-FileChecksum {
    param([string]$FilePath)
    $hash = Get-FileHash -Path $FilePath -Algorithm SHA256
    return $hash.Hash.ToLower()
}

# Function to check file conflict type
# Returns: 0=no conflict, 1=user modified (preserve), 2=uncontrolled file (abort)
function Test-FileConflict {
    param(
        [string]$DestFile,
        [string]$SourceFile
    )

    # File doesn't exist - no conflict
    if (-not (Test-Path $DestFile -PathType Leaf)) {
        return 0
    }

    # File exists - determine conflict type
    # Helper: Check if file matches what we're installing
    $matchesSource = $false
    $sourcePath = Join-Path $script:RepoRoot $SourceFile
    if (Test-Path $sourcePath -PathType Leaf) {
        $newSourceChecksum = Get-FileChecksum -FilePath $sourcePath
        $currentChecksum = Get-FileChecksum -FilePath $DestFile
        $matchesSource = ($currentChecksum -eq $newSourceChecksum)
    }

    # First check: is this an upgrade (Junior was previously installed)?
    if (-not $script:IsUpgrade) {
        # Fresh install + file exists
        if ($matchesSource) {
            return 0  # Identical to source - no conflict
        }
        return 2  # Different from source - uncontrolled file
    }

    # This is an upgrade - check if file was installed by Junior
    $originalChecksum = if ($script:ExistingMetadata.files.$DestFile) { $script:ExistingMetadata.files.$DestFile.sha256 } else { $null }

    if (-not $originalChecksum) {
        # Upgrade but file NOT in metadata
        if ($matchesSource) {
            return 0  # Identical to source - no conflict
        }
        return 2  # Different from source - uncontrolled file
    }

    # File was installed by Junior - check if user modified it
    $currentChecksum = Get-FileChecksum -FilePath $DestFile
    if ($currentChecksum -ne $originalChecksum) {
        return 1  # User modified Junior file
    }

    # Unchanged Junior file - safe to overwrite
    return 0
}

# Function to install a single file with checksum tracking
function Install-SingleFile {
    param(
        [string]$Source,
        [string]$Dest
    )

    $fileExisted = Test-Path $Dest -PathType Leaf

    # Check for file conflicts
    $conflictType = Test-FileConflict -DestFile $Dest -SourceFile $Source

    if ($conflictType -eq 1) {
        # User modified Junior file - preserve
        Write-Warning "User-modified: $Dest (preserving)"
        $script:ModifiedFiles += $Dest

        $checksum = Get-FileChecksum -FilePath $Dest
        $size = (Get-Item $Dest).Length
        $script:FileMetadata[$Dest] = @{
            sha256 = $checksum
            size = $size
            modified = $true
        }
        return

    } elseif ($conflictType -eq 2) {
        # Uncontrolled file exists - conflict
        Write-ErrorMsg "Conflict: $Dest exists but was not installed by Junior"
        $script:ConflictingFiles += $Dest
        return
    }

    # Safe to install - copy file
    $sourcePath = Join-Path $script:RepoRoot $Source
    if (Test-Path $sourcePath -PathType Leaf) {
        Copy-Item -Path $sourcePath -Destination $Dest -Force

        $checksum = Get-FileChecksum -FilePath $Dest
        $size = (Get-Item $Dest).Length
        $script:FileMetadata[$Dest] = @{
            sha256 = $checksum
            size = $size
            modified = $false
        }

        if ($fileExisted) {
            Write-Debug "Updated: $Dest"
        } else {
            Write-Debug "Installed: $Dest"
        }
    } else {
        Write-Warning "Source file not found: $sourcePath"
    }
}

# Get script directory and repository root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$ConfigPath = Join-Path $ScriptDir "install-config.json"

# Handle SyncBack mode
if ($SyncBack) {
    Write-Status "Syncing modifications back to Junior source..."
    Write-Debug "Target directory: $TargetPath"
    Write-Debug "Source directory: $RepoRoot"

    Set-Location $TargetPath

    # Check for metadata file
    $MetadataFile = ".junior\.junior-install.json"
    if (-not (Test-Path $MetadataFile -PathType Leaf)) {
        Write-ErrorMsg "No Junior installation found in $TargetPath"
        Write-ErrorMsg "Metadata file not found: $MetadataFile"
        exit 1
    }

    # Load metadata
    $ExistingMetadata = Get-Content $MetadataFile -Raw | ConvertFrom-Json

    # Find files marked as modified (or compare against source)
    $SyncFiles = @()
    foreach ($file in $ExistingMetadata.files.PSObject.Properties.Name) {
        if (Test-Path $file -PathType Leaf) {
            # Check if file is marked as modified in metadata
            $isModified = $ExistingMetadata.files.$file.modified

            if ($isModified) {
                $SyncFiles += $file
            } else {
                # Also check if file differs from source (for files modified after last install)
                $sourceFile = $null
                if ($file -like ".cursor\rules\*" -or $file -like ".cursor\commands\*") {
                    $sourceFile = Join-Path $RepoRoot $file
                } elseif ($file -eq "JUNIOR.md") {
                    $sourceFile = Join-Path $RepoRoot "README.md"
                }

                if ($sourceFile -and (Test-Path $sourceFile -PathType Leaf)) {
                    $currentChecksum = Get-FileChecksum -FilePath $file
                    $sourceChecksum = Get-FileChecksum -FilePath $sourceFile

                    if ($currentChecksum -ne $sourceChecksum) {
                        $SyncFiles += $file
                    }
                }
            }
        }
    }

    if ($SyncFiles.Count -eq 0) {
        Write-Success "No modified files to sync"
        exit 0
    }

    Write-Host ""
    Write-Status "Modified files found ($($SyncFiles.Count)):"
    foreach ($file in $SyncFiles) {
        Write-Host "  • $file"
    }
    Write-Host ""
    Write-Status "Syncing files back to Junior source..."

    # Sync files back
    Write-Status "Syncing files..."
    foreach ($file in $SyncFiles) {
        # Determine source path
        $srcPath = $null
        if ($file -like ".cursor\rules\*") {
            $srcPath = Join-Path $RepoRoot $file
        } elseif ($file -like ".cursor\commands\*") {
            $srcPath = Join-Path $RepoRoot $file
        } elseif ($file -eq "JUNIOR.md") {
            $srcPath = Join-Path $RepoRoot "README.md"
        } else {
            Write-Warning "Skipping: $file (unknown mapping)"
            continue
        }

        Copy-Item -Path $file -Destination $srcPath -Force
        Write-Success "Synced: $file -> $srcPath"
    }

    Write-Host ""
    Write-Success "═══════════════════════════════════════════════════"
    Write-Success "Sync complete! $($SyncFiles.Count) files copied to Junior source"
    Write-Success "═══════════════════════════════════════════════════"
    Write-Host ""
    Write-Warning "Don't forget to commit these changes in Junior repository!"

    exit 0
}

# Normal installation mode
Write-Debug "Installing Junior - Your expert AI developer..."
Write-Debug "Target directory: $TargetPath"
Write-Debug "Source directory: $RepoRoot"

# Show simple progress message (unless verbose)
if (-not $Verbose) {
    Write-Host "Installing Junior..."
}

# Verify we're in a Junior repository
$JuniorFile = Join-Path $RepoRoot ".cursor\rules\00-junior.mdc"
if (-not (Test-Path $JuniorFile)) {
    Write-ErrorMsg "Cannot find Junior files. Make sure you're running this from the Junior repository."
    exit 1
}

# Git clean check - verify Junior source is clean for accurate version tracking
Write-Debug "Checking Junior source git status..."
Set-Location $RepoRoot

$GitDir = Join-Path $RepoRoot ".git"
if (-not (Test-Path $GitDir -PathType Container)) {
    # Check for .githash file (created by update script when installing from tarball)
    $GitHashFile = Join-Path $RepoRoot ".githash"
    if (Test-Path $GitHashFile -PathType Leaf) {
        Write-Debug "Reading version info from .githash file..."
        $gitHashContent = Get-Content $GitHashFile -Raw

        # Parse COMMIT_HASH=...
        if ($gitHashContent -match 'COMMIT_HASH=(.+)') {
            $CommitHash = $matches[1].Trim()
        } else {
            $CommitHash = "unknown"
        }

        # Parse COMMIT_DATE=...
        if ($gitHashContent -match 'COMMIT_DATE=(.+)') {
            $CommitDate = $matches[1].Trim()
        }

        # Parse COMMIT_TIMESTAMP=...
        if ($gitHashContent -match 'COMMIT_TIMESTAMP=(.+)') {
            $CommitTimestamp = $matches[1].Trim()
        } else {
            $CommitTimestamp = "unknown"
        }

        $ShortHash = if ($CommitHash -ne "unknown") { $CommitHash.Substring(0, 7) } else { "unknown" }
        Write-Debug "Version info loaded from tarball metadata (commit: $ShortHash, date: $CommitDate)"
    } else {
        Write-Warning "Junior source is not a git repository. Version tracking will be limited."
        $CommitHash = "unknown"
        $CommitTimestamp = "unknown"
    }
} else {
    # Check for uncommitted changes
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        if ($IgnoreDirty) {
            Write-Warning "Git has uncommitted changes (ignored via -IgnoreDirty)"
            Write-Warning "Note: Version may not reflect actual state"
        } else {
            Write-ErrorMsg "Junior source git not clean. Commit or stash changes first."
            Write-ErrorMsg "Version is based on commit timestamp - need clean state."
            Write-Host ""
            Write-Status "Uncommitted changes:"
            git status --short
            Write-Host ""
            Write-Status "Options:"
            Write-Host "  1. Commit or stash changes"
            Write-Host "  2. Use -IgnoreDirty flag (for testing only)"
            exit 1
        }
    }

    # Get version info from git
    $CommitHash = git rev-parse HEAD
    $CommitTimestamp = git log -1 --format=%ct
    $ShortHash = $CommitHash.Substring(0, 7)

    if ($IgnoreDirty) {
        Write-Debug "Using commit: $ShortHash (with local changes)"
    } else {
        Write-Debug "Junior source is clean (commit: $ShortHash)"
    }
}

# Verify target directory exists
if (-not (Test-Path $TargetPath -PathType Container)) {
    Write-ErrorMsg "Target directory does not exist: $TargetPath"
    exit 1
}

# Load configuration
if (-not (Test-Path $ConfigPath)) {
    Write-ErrorMsg "Configuration file not found: $ConfigPath"
    exit 1
}

try {
    $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
} catch {
    Write-ErrorMsg "Failed to parse configuration file: $($_.Exception.Message)"
    exit 1
}

# Change to target directory
Set-Location $TargetPath
Write-Debug "Working in: $(Get-Location)"

# Track if Code Captain cleanup was performed
$CCCleanedUp = $false

# Check for Code Captain (offer cleanup or force installation)
# Skip if Junior is already installed (upgrade scenario)
if ((-not (Test-Path $MetadataFile -PathType Leaf)) -and ((Test-Path ".cursor\rules\cc.mdc") -or (Test-Path "CODE_CAPTAIN.md"))) {
    Write-Host ""
    Write-Warning "═══════════════════════════════════════════════════"
    Write-Warning "Code Captain installation detected!"
    Write-Warning "═══════════════════════════════════════════════════"
    Write-Host ""
    Write-Status "Found:"
    if (Test-Path ".cursor\rules\cc.mdc") { Write-Host "  • .cursor\rules\cc.mdc" }
    if (Test-Path "CODE_CAPTAIN.md") { Write-Host "  • CODE_CAPTAIN.md" }
    Write-Host ""

    if (-not $Force) {
        Write-Status "Recommended workflow:"
        Write-Host "  1. Cleanup Code Captain interface (rules, commands, docs)"
        Write-Host "  2. Install Junior"
        Write-Host "  3. After installation, run /migrate to convert .code-captain\ work to Junior"
        Write-Host ""
        if (Test-Path ".code-captain" -PathType Container) {
            Write-Warning "Note: Your .code-captain\ work directory will be preserved."
            Write-Warning "Only the Code Captain rules, commands, and docs will be removed."
        } else {
            Write-Status "Code Captain rules, commands, and docs will be removed."
        }
        Write-Host ""

        $response = Read-Host "Proceed with cleanup and installation? [yes/cancel]"

        if (($response -eq "yes") -or ($response -eq "y")) {
            Invoke-CodeCaptainCleanup -Config $Config
            $CCCleanedUp = $true
            # Continue with installation after cleanup
        } else {
            Write-Status "Installation cancelled."
            Write-Host ""
            Write-Status "To install Junior, you can:"
            Write-Status "  1. Manually remove Code Captain files and re-run this script"
            Write-Status "  2. Use -Force flag to install alongside (may cause conflicts)"
            exit 0
        }
    } else {
        Write-Warning "Proceeding with installation (-Force enabled)"
        Write-Warning "Code Captain files will not be removed automatically."
        Write-Host ""
    }
}

# Note: If Junior is already installed (has metadata), upgrade proceeds automatically
# Conflict detection happens during file installation - only uncontrolled files abort

# Check for existing installation
$MetadataFile = ".junior\.junior-install.json"
$script:IsUpgrade = $false
$script:ExistingMetadata = $null

if (Test-Path $MetadataFile -PathType Leaf) {
    $IsUpgrade = $true
    $ExistingMetadata = Get-Content $MetadataFile -Raw | ConvertFrom-Json
    Write-Debug "Existing Junior installation detected - performing upgrade"

    $ExistingVersion = if ($ExistingMetadata.version) { $ExistingMetadata.version } else { "unknown" }
    $ExistingCommit = if ($ExistingMetadata.commit_hash) { $ExistingMetadata.commit_hash.Substring(0, 7) } else { "unknown" }
    Write-Debug "Current version: $ExistingVersion (commit: $ExistingCommit)"
}

# Create directory structure
Write-Debug "Creating directory structure..."

foreach ($dir in $Config.directories) {
    if (-not (Test-Path $dir -PathType Container)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Write-Debug "Created directory: $dir"
}

Write-Debug "Directory structure created"

# Initialize metadata tracking
$script:FileMetadata = @{}
$script:ModifiedFiles = @()
$script:ConflictingFiles = @()

# Install files based on configuration
Write-Debug "Installing files..."

# Detect current platform
$currentPlatform = if ($IsWindows -or $env:OS -match "Windows") { "windows" } else { "unix" }

foreach ($file in $Config.files) {
    # Skip files that don't match current platform
    if ($file.platform -and $file.platform -ne $currentPlatform) {
        Write-Debug "Skipping platform-specific file: $($file.source) (requires: $($file.platform), current: $currentPlatform)"
        continue
    }

    $sourcePath = Join-Path $RepoRoot $file.source
    $destPath = $file.destination

    if ($file.isDirectory) {
        # Copy directory contents
        Write-Debug "Installing directory: $($file.source) -> $destPath"
        if (Test-Path $sourcePath -PathType Container) {
            $sourceFiles = Get-ChildItem -Path $sourcePath -File

            foreach ($srcFile in $sourceFiles) {
                $destFile = Join-Path $destPath $srcFile.Name
                $relativeSource = "$($file.source)$($srcFile.Name)"
                Install-SingleFile -Source $relativeSource -Dest $destFile
            }
        } else {
            Write-Warning "Source directory not found: $sourcePath"
        }
    } else {
        # Check if file should be skipped if it exists
        if ($file.skipIfExists -and (Test-Path $destPath -PathType Leaf)) {
            Write-Debug "Skipping existing file: $destPath (preserving local customizations)"
        } else {
            Write-Debug "Installing file: $($file.source) -> $destPath"
            Install-SingleFile -Source $file.source -Dest $destPath
        }
    }
}

# Check for conflicting files - abort if found
if ($script:ConflictingFiles.Count -gt 0) {
    Write-Host ""
    Write-ErrorMsg "═══════════════════════════════════════════════════"
    Write-ErrorMsg "INSTALLATION ABORTED - File conflicts detected!"
    Write-ErrorMsg "═══════════════════════════════════════════════════"
    Write-Host ""
    Write-ErrorMsg "These files exist but were NOT installed by Junior:"
    foreach ($file in $script:ConflictingFiles) {
        Write-Host "  • $file" -ForegroundColor $Colors.Red
    }
    Write-Host ""
    Write-Status "Resolution options:"
    Write-Host "  1. Back up and remove these files, then re-run installation"
    Write-Host "  2. Use /migrate command if migrating from Code Captain"
    Write-Host "  3. Manually review and resolve conflicts"
    Write-Host ""
    exit 1
}

# Report modified files
if ($script:ModifiedFiles.Count -gt 0) {
    Write-Host ""
    Write-Warning "═══════════════════════════════════════════════════"
    Write-Warning "User-modified files preserved ($($script:ModifiedFiles.Count) files):"
    foreach ($modFile in $script:ModifiedFiles) {
        Write-Host "  • $modFile" -ForegroundColor $Colors.Yellow
    }
    Write-Host ""
    Write-Status "Your customizations were NOT overwritten."
    Write-Status "To sync changes back: .\scripts\install-junior.ps1 -SyncBack -TargetPath `"$TargetPath`""
    Write-Warning "═══════════════════════════════════════════════════"
    Write-Host ""
}

# Generate installation metadata
Write-Debug "Generating installation metadata..."

# Get current timestamp
$InstalledAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# Create metadata object
$Metadata = @{
    version = $CommitTimestamp
    installed_at = $InstalledAt
    commit_hash = $CommitHash
    files = $script:FileMetadata
}

# Write metadata file
$Metadata | ConvertTo-Json -Depth 10 | Set-Content $MetadataFile -Encoding UTF8
Write-Debug "Metadata saved to $MetadataFile"

# Check for git repository
if (-not (Test-Path ".git" -PathType Container)) {
    Write-Warning "No git repository found. Consider running 'git init' to track your changes."
}

Write-Host ""
Write-Success "✓ $($Config.messages.success)"
Write-Host ""

# Show installation summary (verbose only)
if ($Verbose) {
    Write-Status "Installation summary:"
    Write-Host "  ✓ Cursor rules: .cursor\rules\ (5 files)" -ForegroundColor $Colors.Green
    Write-Host "  ✓ Commands: .cursor\commands\ (4 files)" -ForegroundColor $Colors.Green
    Write-Host "  ✓ Junior guide: JUNIOR.md" -ForegroundColor $Colors.Green
    Write-Host "  ✓ Working memory: .junior\ (structure created)" -ForegroundColor $Colors.Green
    $ShortHash = if ($CommitHash -ne "unknown") { $CommitHash.Substring(0, 7) } else { "unknown" }
    Write-Host "  ✓ Version: $CommitTimestamp (commit: $ShortHash)" -ForegroundColor $Colors.Green
    Write-Host ""
}

Write-Status "Next steps:"
if ($CCCleanedUp -and (Test-Path ".code-captain" -PathType Container)) {
    Write-Host "  1. Run /migrate to convert your .code-captain\ work to Junior"
    Write-Host "  2. Try /status to see all your features"
    Write-Host "  3. Use /implement to continue working on features"
    Write-Host ""
} else {
    foreach ($step in $Config.messages.nextSteps) {
        Write-Host "  $step" -ForegroundColor $Colors.White
    }
    Write-Host ""
}

if ($Verbose) {
    Write-Status "Available commands: $($Config.messages.availableCommands)"
}

