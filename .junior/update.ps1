# Junior Update Script (PowerShell)
# Usage: .\.junior\update.ps1 [-CheckOnly] [-Force] [-Verbose] [-LocalSource "C:\path"]
# Options:
#   -CheckOnly      Only check for updates (don't install)
#   -Force          Skip confirmation prompts
#   -Verbose        Show detailed update output
#   -LocalSource    Update from local source directory (testing)
# Compatible with PowerShell 5.1+

param(
    [Parameter(Mandatory=$false)]
    [switch]$CheckOnly,

    [Parameter(Mandatory=$false)]
    [switch]$Force,

    [Parameter(Mandatory=$false)]
    [switch]$Verbose,

    [Parameter(Mandatory=$false)]
    [string]$LocalSource = ""
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output (matching install-junior.ps1 style)
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

# Debug output (only shown with -Verbose)
function Write-Debug {
    param([string]$Message)
    if ($Verbose) {
        Write-Host "[DEBUG] $Message" -ForegroundColor $Colors.Blue
    }
}

# Function to prompt for confirmation
function Get-Confirmation {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Colors.Yellow
    $response = Read-Host "Continue? [y/N]"
    return ($response -eq "y") -or ($response -eq "Y")
}

# GitHub configuration
$GITHUB_OWNER = "rusi"
$GITHUB_REPO = "junior"
$GITHUB_BRANCH = "main"
$METADATA_FILE = ".junior\.junior-install.json"

# Function to read current version from metadata file
function Get-CurrentVersion {
    if (-not (Test-Path $METADATA_FILE -PathType Leaf)) {
        Write-ErrorMsg "Junior installation not found"
        Write-ErrorMsg "Metadata file missing: $METADATA_FILE"
        Write-Status "Please install Junior first using the installation script"
        return $null
    }

    try {
        $metadata = Get-Content $METADATA_FILE -Raw | ConvertFrom-Json

        # Validate required fields
        if (-not $metadata.version -or -not $metadata.commit_hash) {
            Write-ErrorMsg "Invalid metadata file: missing required fields"
            return $null
        }

        # Export for use by other functions
        $script:CURRENT_VERSION = $metadata.version
        $script:CURRENT_COMMIT = $metadata.commit_hash
        $script:CURRENT_INSTALLED_AT = $metadata.installed_at

        return $true
    } catch {
        Write-ErrorMsg "Failed to parse metadata file: $($_.Exception.Message)"
        return $null
    }
}

# Function to query GitHub API for latest commit
function Get-LatestVersion {
    $apiUrl = "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/commits/$GITHUB_BRANCH"

    Write-Status "Checking for updates from GitHub..."

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction Stop

        # Parse response
        $latestSha = $response.sha
        $latestDate = $response.commit.committer.date

        # Validate response
        if (-not $latestSha) {
            Write-ErrorMsg "Invalid response from GitHub API"
            return $null
        }

        # Export for use by other functions
        $script:LATEST_COMMIT = $latestSha
        $script:LATEST_DATE = $latestDate

        return $true
    } catch {
        if ($_.Exception.Message -match "rate limit") {
            Write-ErrorMsg "GitHub API rate limit exceeded"
            Write-Status "Please wait an hour or use a GitHub token for higher limits"
        } else {
            Write-ErrorMsg "Failed to connect to GitHub API"
            Write-Status "Please check your internet connection and try again"
        }
        return $null
    }
}

# Function to compare versions and display status
function Compare-And-Report {
    Write-Host ""
    Write-Status "═══════════════════════════════════════════════════"
    Write-Status "Junior Version Check"
    Write-Status "═══════════════════════════════════════════════════"
    Write-Host ""

    # Display current version
    Write-Status "Current version:"
    Write-Host "  Commit: $($script:CURRENT_COMMIT.Substring(0, 7))"
    Write-Host "  Installed: $script:CURRENT_INSTALLED_AT"
    Write-Host ""

    # Display latest version
    Write-Status "Latest version:"
    Write-Host "  Commit: $($script:LATEST_COMMIT.Substring(0, 7))"
    Write-Host "  Date: $script:LATEST_DATE"
    Write-Host ""

    # Compare versions
    if ($script:CURRENT_COMMIT -eq $script:LATEST_COMMIT) {
        Write-Success "✓ Junior is up-to-date!"
        Write-Host ""
        return 0
    } else {
        Write-Warning "⚠ Update available!"
        Write-Host ""
        return 2
    }
}

# Function to download tarball from GitHub
function Get-Tarball {
    param([string]$TempDir)

    $tarballUrl = "https://github.com/$GITHUB_OWNER/$GITHUB_REPO/archive/refs/heads/$GITHUB_BRANCH.tar.gz"
    $tarballPath = Join-Path $TempDir "junior.tar.gz"

    Write-Status "Downloading Junior from GitHub..."
    Write-Host "  URL: $tarballUrl"
    Write-Host ""

    try {
        # Download with progress indicator
        Invoke-WebRequest -Uri $tarballUrl -OutFile $tarballPath -ErrorAction Stop

        # Verify download succeeded and file is not empty
        if ((-not (Test-Path $tarballPath -PathType Leaf)) -or ((Get-Item $tarballPath).Length -eq 0)) {
            Write-ErrorMsg "Downloaded file is missing or empty"
            return $null
        }

        Write-Success "✓ Download complete"
        Write-Host ""

        return $tarballPath
    } catch {
        Write-ErrorMsg "Failed to download tarball from GitHub"
        Write-Status "Please check your internet connection and try again"
        return $null
    }
}

# Function to create tarball from local source directory (for testing)
function New-TarballFromLocalSource {
    param(
        [string]$TempDir,
        [string]$SourceDir
    )

    $tarballPath = Join-Path $TempDir "junior.tar.gz"

    Write-Debug "Creating tarball from local source: $SourceDir"

    # Verify source directory exists and looks like Junior
    if (-not (Test-Path $SourceDir -PathType Container)) {
        Write-ErrorMsg "Source directory does not exist: $SourceDir"
        return $null
    }

    $juniorFile = Join-Path $SourceDir ".cursor\rules\00-junior.mdc"
    if (-not (Test-Path $juniorFile -PathType Leaf)) {
        Write-ErrorMsg "Source directory does not appear to be Junior repository"
        Write-Status "Expected to find: $juniorFile"
        return $null
    }

    # Create tarball with same structure as GitHub (nested directory)
    # GitHub creates: junior-main/
    # We'll create: junior-local/
    $stagingDir = Join-Path $TempDir "staging"
    $nestedDir = Join-Path $stagingDir "junior-local"

    New-Item -ItemType Directory -Path $nestedDir -Force | Out-Null

    # Copy source files (excluding .git, temp files, etc.)
    Write-Debug "Copying source files..."

    # Use robocopy for efficient directory copying (Windows built-in)
    $excludeDirs = @(".git", "__pycache__")
    $excludeFiles = @("*.pyc", ".DS_Store", ".junior-install.json")

    robocopy $SourceDir $nestedDir /E /NFL /NDL /NJH /NJS /NC /NS /NP `
        /XD $excludeDirs `
        /XF $excludeFiles `
        | Out-Null

    # robocopy returns 1 for successful copy with files, so don't treat as error
    if ($LASTEXITCODE -gt 7) {
        Write-ErrorMsg "Failed to copy source files"
        Remove-Item -Path $stagingDir -Recurse -Force -ErrorAction SilentlyContinue
        return $null
    }

    # Create tarball using tar (Windows 10+ has built-in tar)
    Write-Debug "Creating tarball..."
    Push-Location $stagingDir
    try {
        tar -czf $tarballPath junior-local 2>&1 | Out-Null

        if ($LASTEXITCODE -ne 0) {
            throw "tar command failed"
        }
    } catch {
        Write-ErrorMsg "Failed to create tarball"
        Pop-Location
        Remove-Item -Path $stagingDir -Recurse -Force -ErrorAction SilentlyContinue
        return $null
    } finally {
        Pop-Location
    }

    # Clean up staging directory
    Remove-Item -Path $stagingDir -Recurse -Force -ErrorAction SilentlyContinue

    # Verify tarball
    if ((-not (Test-Path $tarballPath -PathType Leaf)) -or ((Get-Item $tarballPath).Length -eq 0)) {
        Write-ErrorMsg "Tarball creation failed or file is empty"
        return $null
    }

    Write-Debug "✓ Tarball created from local source"

    return $tarballPath
}

# Function to extract tarball and find extracted directory
function Expand-Tarball {
    param([string]$TempDir)

    $tarballPath = Join-Path $TempDir "junior.tar.gz"

    Write-Debug "Extracting tarball..."

    # Extract tarball using tar (Windows 10+ has built-in tar)
    Push-Location $TempDir
    try {
        tar -xzf $tarballPath 2>&1 | Out-Null

        if ($LASTEXITCODE -ne 0) {
            throw "tar extraction failed"
        }
    } catch {
        Write-ErrorMsg "Failed to extract tarball"
        Write-Status "The downloaded file may be corrupted"
        Pop-Location
        return $null
    } finally {
        Pop-Location
    }

    # Find extracted directory (GitHub creates nested directory like junior-main/)
    $extractedDirs = Get-ChildItem -Path $TempDir -Directory | Where-Object { $_.Name -like "$GITHUB_REPO-*" }

    if ($extractedDirs.Count -eq 0) {
        Write-ErrorMsg "Could not find extracted directory"
        Write-Status "Expected directory pattern: $GITHUB_REPO-*"
        return $null
    }

    $extractedDir = $extractedDirs[0].FullName

    # Export for use by other functions
    $script:EXTRACTED_DIR = $extractedDir

    Write-Debug "✓ Extraction complete (path: $extractedDir)"

    return $extractedDir
}

# Function to run install script from extracted source
function Invoke-Install {
    param(
        [string]$ExtractedDir,
        [string]$ProjectRoot
    )

    Write-Debug "Running install script (source: $ExtractedDir, target: $ProjectRoot)"

    # Verify install script exists
    $installScript = Join-Path $ExtractedDir "scripts\install-junior.ps1"
    if (-not (Test-Path $installScript -PathType Leaf)) {
        Write-ErrorMsg "Install script not found: $installScript"
        return $null
    }

    # Run install script
    # Note: No flags needed because:
    #   - Install script auto-detects non-git repos (tarball) and handles gracefully
    #   - Install script auto-detects existing installation and runs upgrade mode
    #   - No confirmation prompts during upgrades (only on fresh installs with Code Captain)
    try {
        & $installScript -TargetPath $ProjectRoot 2>&1 | Out-Host

        if ($LASTEXITCODE -ne 0) {
            throw "Install script returned error code: $LASTEXITCODE"
        }

        Write-Success "✓ Installation complete"
        Write-Host ""

        return $true
    } catch {
        Write-ErrorMsg "Install script failed"
        Write-Status "Check the output above for details"
        return $null
    }
}

# Validate -LocalSource if provided
if ($LocalSource) {
    # Convert to absolute path
    $LocalSource = Resolve-Path $LocalSource -ErrorAction SilentlyContinue
    if (-not $LocalSource) {
        Write-ErrorMsg "Local source directory does not exist or is not accessible"
        exit 1
    }

    Write-Warning "═══════════════════════════════════════════════════"
    Write-Warning "TEST MODE: Using local source directory"
    Write-Warning "Source: $LocalSource"
    Write-Warning "═══════════════════════════════════════════════════"
    Write-Host ""
}

# Main update flow
Write-Status "Junior Update"
Write-Host ""

# Step 1: Read current version
if (-not (Get-CurrentVersion)) {
    exit 1
}

# Step 2: Query GitHub for latest version
if (-not (Get-LatestVersion)) {
    exit 1
}

# Step 3: Compare versions
$versionCheckResult = Compare-And-Report

# If up-to-date or check-only mode, exit here
if ($versionCheckResult -eq 0) {
    # Already up-to-date
    exit 0
}

if ($CheckOnly) {
    # Check-only mode, don't proceed with update
    Write-Status "Use '.\.junior\update.ps1' (without -CheckOnly) to install update"
    Write-Host ""
    exit 2
}

# Step 4: Confirm update (unless -Force)
if (-not $Force) {
    Write-Host ""
    if (-not (Get-Confirmation "Download and install Junior update?")) {
        Write-Status "Update cancelled by user"
        exit 0
    }
    Write-Host ""
}

# Step 5: Create temp directory with cleanup
$TempDir = Join-Path $env:TEMP ".junior-update-$(Get-Random)"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# Track whether update succeeded
$UpdateSuccess = $false

# Cleanup function
function Remove-TempDirectory {
    if ($UpdateSuccess) {
        # Success - clean up temp directory
        if (Test-Path $TempDir -PathType Container) {
            Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    } else {
        # Failure - preserve temp directory for debugging
        if (Test-Path $TempDir -PathType Container) {
            Write-ErrorMsg "Update failed!"
            Write-Status "Temporary files preserved for debugging: $TempDir"
            Write-Status "After reviewing, remove with: Remove-Item -Path '$TempDir' -Recurse -Force"
        }
    }
}

# Register cleanup on exit
try {
    # Step 6: Download or create tarball
    if ($LocalSource) {
        # Test mode: create tarball from local source
        $tarballPath = New-TarballFromLocalSource -TempDir $TempDir -SourceDir $LocalSource
        if (-not $tarballPath) {
            throw "Failed to create tarball from local source"
        }
    } else {
        # Normal mode: download from GitHub
        $tarballPath = Get-Tarball -TempDir $TempDir
        if (-not $tarballPath) {
            throw "Failed to download tarball"
        }
    }

    # Step 7: Extract tarball
    $extractedDir = Expand-Tarball -TempDir $TempDir
    if (-not $extractedDir) {
        throw "Failed to extract tarball"
    }

    # Step 8: Write git hash file for version tracking
    if ($LocalSource) {
        # Local source mode: try to get git info from source directory
        Write-Status "Reading version info from local source..."

        $gitDir = Join-Path $LocalSource ".git"
        if (Test-Path $gitDir -PathType Container) {
            Push-Location $LocalSource
            try {
                $localCommit = git rev-parse HEAD 2>$null
                if (-not $localCommit) { $localCommit = "local-test" }

                $localDate = git log -1 --format=%cI 2>$null
                if (-not $localDate) { $localDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ") }

                $localTimestamp = git log -1 --format=%ct 2>$null
                if (-not $localTimestamp) { $localTimestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() }

                $gitHashContent = @"
COMMIT_HASH=$localCommit
COMMIT_DATE=$localDate
COMMIT_TIMESTAMP=$localTimestamp
"@
                $gitHashContent | Set-Content (Join-Path $extractedDir ".githash") -Encoding UTF8

                Write-Debug "Version info from local git repository (commit: $($localCommit.Substring(0, 7)), date: $localDate)"
            } finally {
                Pop-Location
            }
        } else {
            $gitHashContent = @"
COMMIT_HASH=local-test
COMMIT_DATE=$(Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
COMMIT_TIMESTAMP=$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
"@
            $gitHashContent | Set-Content (Join-Path $extractedDir ".githash") -Encoding UTF8
            Write-Warning "Local source has no git repository - using test values"
        }
    } else {
        # Normal mode: use GitHub API data
        $gitHashContent = @"
COMMIT_HASH=$($script:LATEST_COMMIT)
COMMIT_DATE=$($script:LATEST_DATE)
COMMIT_TIMESTAMP=$(Get-Date).ToUniversalTime().ToString("o")
"@
        $gitHashContent | Set-Content (Join-Path $extractedDir ".githash") -Encoding UTF8

        Write-Status "Git hash info written for version tracking"
        Write-Host "  Commit: $($script:LATEST_COMMIT.Substring(0, 7))"
        Write-Host "  Date: $script:LATEST_DATE"
        Write-Host ""
    }

    # Step 9: Determine project root (parent of .junior directory)
    $scriptPath = $MyInvocation.MyCommand.Path
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $scriptPath)

    # Step 10: Run install script
    if (-not (Invoke-Install -ExtractedDir $extractedDir -ProjectRoot $ProjectRoot)) {
        throw "Install script failed"
    }

    # Mark update as successful
    $UpdateSuccess = $true

    # Step 11: Success message
    Write-Host ""
    Write-Success "✓ Junior updated successfully!"
    Write-Host ""
    Write-Status "Updated to commit: $($script:LATEST_COMMIT.Substring(0, 7))"
    if ($Verbose) {
        Write-Debug "Temporary files cleaned up"
    }
    Write-Host ""

    exit 0

} catch {
    Write-ErrorMsg "Update failed: $($_.Exception.Message)"
    exit 1
} finally {
    Remove-TempDirectory
}

