# Junior Installation Script (PowerShell)
# Usage: .\scripts\install-junior.ps1 [-SyncBack] -TargetPath "C:\path\to\project"

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$SyncBack
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

# Function to calculate SHA256 checksum
function Get-FileChecksum {
    param([string]$FilePath)
    $hash = Get-FileHash -Path $FilePath -Algorithm SHA256
    return $hash.Hash.ToLower()
}

# Function to check file conflict type
# Returns: 0=no conflict, 1=user modified (preserve), 2=uncontrolled file (abort)
function Test-FileConflict {
    param([string]$DestFile)
    
    # File doesn't exist - no conflict
    if (-not (Test-Path $DestFile -PathType Leaf)) {
        return 0
    }
    
    # File exists - determine conflict type
    # First check: is this an upgrade (Junior was previously installed)?
    if (-not $script:IsUpgrade) {
        # Fresh install + file exists = uncontrolled file
        return 2
    }
    
    # This is an upgrade - check if file was installed by Junior
    $originalChecksum = if ($script:ExistingMetadata.files.$DestFile) { $script:ExistingMetadata.files.$DestFile.sha256 } else { $null }
    
    if (-not $originalChecksum) {
        # Upgrade but file NOT in metadata = uncontrolled file
        return 2
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
    
    # Check for file conflicts
    $conflictType = Test-FileConflict -DestFile $Dest
    
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
        
        Write-Success "Installed: $Source -> $Dest"
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
    Write-Status "Target directory: $TargetPath"
    Write-Status "Source directory: $RepoRoot"
    
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
    
    # Find modified files
    $SyncFiles = @()
    foreach ($file in $ExistingMetadata.files.PSObject.Properties.Name) {
        if (Test-Path $file -PathType Leaf) {
            $currentChecksum = Get-FileChecksum -FilePath $file
            $originalChecksum = $ExistingMetadata.files.$file.sha256
            
            if ($currentChecksum -ne $originalChecksum) {
                $SyncFiles += $file
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
    
    Write-Status "Sync these files back to Junior source? [yes/no]"
    $Confirm = Read-Host
    
    if (($Confirm -ne "yes") -and ($Confirm -ne "y")) {
        Write-Status "Sync cancelled"
        exit 0
    }
    
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
Write-Status "Installing Junior - Your expert AI developer..."
Write-Status "Target directory: $TargetPath"
Write-Status "Source directory: $RepoRoot"

# Verify we're in a Junior repository
$JuniorFile = Join-Path $RepoRoot ".cursor\rules\00-junior.mdc"
if (-not (Test-Path $JuniorFile)) {
    Write-ErrorMsg "Cannot find Junior files. Make sure you're running this from the Junior repository."
    exit 1
}

# Git clean check - verify Junior source is clean for accurate version tracking
Write-Status "Checking Junior source git status..."
Set-Location $RepoRoot

$GitDir = Join-Path $RepoRoot ".git"
if (-not (Test-Path $GitDir -PathType Container)) {
    Write-Warning "Junior source is not a git repository. Version tracking will be limited."
    $CommitHash = "unknown"
    $CommitTimestamp = "unknown"
} else {
    # Check for uncommitted changes
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        Write-ErrorMsg "Junior source git not clean. Commit or stash changes first."
        Write-ErrorMsg "Version is based on commit timestamp - need clean state."
        Write-Host ""
        Write-Status "Uncommitted changes:"
        git status --short
        exit 1
    }
    
    # Get version info from git
    $CommitHash = git rev-parse HEAD
    $CommitTimestamp = git log -1 --format=%ct
    $ShortHash = $CommitHash.Substring(0, 7)
    Write-Success "Junior source is clean (commit: $ShortHash)"
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
Write-Status "Working in: $(Get-Location)"

# Check for existing Cursor installation (Code Captain or other)
if (Test-Path ".cursor" -PathType Container) {
    Write-Warning "Existing .cursor directory detected!"
    
    # Check for Code Captain
    $hasCodeCaptain = (Test-Path ".cursor\rules\cc.mdc") -or (Test-Path "CODE_CAPTAIN.md") -or (Test-Path ".code-captain")
    
    if ($hasCodeCaptain) {
        Write-Host ""
        Write-Warning "═══════════════════════════════════════════════════"
        Write-Warning "Code Captain installation detected!"
        Write-Warning "═══════════════════════════════════════════════════"
        Write-Host ""
        Write-Status "Found:"
        if (Test-Path ".cursor\rules\cc.mdc") { Write-Host "  • .cursor\rules\cc.mdc" }
        if (Test-Path "CODE_CAPTAIN.md") { Write-Host "  • CODE_CAPTAIN.md" }
        if (Test-Path ".code-captain") { Write-Host "  • .code-captain\ directory" }
        Write-Host ""
        Write-Status "Recommendations before installing Junior:"
        Write-Host "  1. Review .cursor\commands\ for custom commands you want to keep"
        Write-Host "  2. Review .cursor\rules\ for custom rules you want to keep"
        Write-Host "  3. Consider backing up .code-captain\ if it contains work"
        Write-Host "  4. Use /migrate command (coming soon) for proper migration"
        Write-Host ""
        Write-Warning "Installing Junior will:"
        Write-Host "  • Install Junior files to .cursor\rules\ and .cursor\commands\"
        Write-Host "  • Code Captain files (cc.mdc, etc.) will remain untouched"
        Write-Host "  • Files with same names will be checked for conflicts"
        Write-Host "  • NOT touch .code-captain\ (you can delete manually later)"
        Write-Host "  • Create new .junior\ structure"
        Write-Host ""
        Write-Status "Continue with installation? [yes/no]"
        $Continue = Read-Host
        
        if (($Continue -ne "yes") -and ($Continue -ne "y")) {
            Write-Status "Installation cancelled. Review and clean up before installing."
            exit 0
        }
    } else {
        Write-Host ""
        Write-Status "Existing Cursor commands/rules found (not Code Captain)"
        Write-Status "Junior will install files to .cursor\rules\ and .cursor\commands\"
        Write-Status "Conflicts will be detected. Continue? [yes/no]"
        $Continue = Read-Host
        
        if (($Continue -ne "yes") -and ($Continue -ne "y")) {
            Write-Status "Installation cancelled."
            exit 0
        }
    }
    Write-Host ""
}

# Check for existing installation
$MetadataFile = ".junior\.junior-install.json"
$script:IsUpgrade = $false
$script:ExistingMetadata = $null

if (Test-Path $MetadataFile -PathType Leaf) {
    $IsUpgrade = $true
    $ExistingMetadata = Get-Content $MetadataFile -Raw | ConvertFrom-Json
    Write-Status "Existing Junior installation detected - performing upgrade"
    
    $ExistingVersion = if ($ExistingMetadata.version) { $ExistingMetadata.version } else { "unknown" }
    $ExistingCommit = if ($ExistingMetadata.commit_hash) { $ExistingMetadata.commit_hash.Substring(0, 7) } else { "unknown" }
    Write-Status "Current version: $ExistingVersion (commit: $ExistingCommit)"
}

# Create directory structure
Write-Status "Creating directory structure..."

foreach ($dir in $Config.directories) {
    if (-not (Test-Path $dir -PathType Container)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Write-Success "Created directory: $dir"
}

Write-Success "Directory structure created"

# Initialize metadata tracking
$script:FileMetadata = @{}
$script:ModifiedFiles = @()
$script:ConflictingFiles = @()

# Install files based on configuration
Write-Status "Installing files..."

foreach ($file in $Config.files) {
    $sourcePath = Join-Path $RepoRoot $file.source
    $destPath = $file.destination
    
    if ($file.isDirectory) {
        # Copy directory contents
        Write-Status "Installing directory: $($file.source) -> $destPath"
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
            Write-Status "Skipping existing file: $destPath (preserving local customizations)"
        } else {
            Write-Status "Installing file: $($file.source) -> $destPath"
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
Write-Status "Generating installation metadata..."

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
Write-Success "Metadata saved to $MetadataFile"

# Check for git repository
if (-not (Test-Path ".git" -PathType Container)) {
    Write-Warning "No git repository found. Consider running 'git init' to track your changes."
}

Write-Host ""
Write-Success "═══════════════════════════════════════════════════"
Write-Success $Config.messages.success
Write-Success "═══════════════════════════════════════════════════"
Write-Host ""

# Show installation summary
Write-Status "Installation summary:"
Write-Host "  ✓ Cursor rules: .cursor\rules\ (4 files)" -ForegroundColor $Colors.Green
Write-Host "  ✓ Commands: .cursor\commands\ (4 files)" -ForegroundColor $Colors.Green
Write-Host "  ✓ Junior guide: JUNIOR.md" -ForegroundColor $Colors.Green
Write-Host "  ✓ Working memory: .junior\ (structure created)" -ForegroundColor $Colors.Green
$ShortHash = if ($CommitHash -ne "unknown") { $CommitHash.Substring(0, 7) } else { "unknown" }
Write-Host "  ✓ Version: $CommitTimestamp (commit: $ShortHash)" -ForegroundColor $Colors.Green
Write-Host ""

Write-Status "Next steps:"
foreach ($step in $Config.messages.nextSteps) {
    Write-Host "  $step" -ForegroundColor $Colors.White
}
Write-Host ""

Write-Status "Available commands: $($Config.messages.availableCommands)"

