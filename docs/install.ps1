# Junior Bootstrap Script (PowerShell)
# Install or update Junior with a single command:
#   irm https://USER.github.io/junior/install.ps1 | iex
#
# This script downloads the latest Junior release, extracts it,
# and runs the install script with the current directory as target.

$ErrorActionPreference = "Stop"

# ============================================================================
# Configuration
# ============================================================================

$GITHUB_REPO = "rusi/junior"
$GITHUB_BRANCH = "main"
$TARBALL_URL = "https://github.com/$GITHUB_REPO/archive/refs/heads/$GITHUB_BRANCH.tar.gz"

# Colors for output
$Colors = @{
    Green = "Green"
    Red = "Red"
    Blue = "Blue"
}

# ============================================================================
# Output Functions
# ============================================================================

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Colors.Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Colors.Green
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Colors.Red
}

# ============================================================================
# Core Functions
# ============================================================================

# Download tarball using Invoke-WebRequest
function Get-Tarball {
    param(
        [string]$Url,
        [string]$Destination
    )

    try {
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
        return $true
    }
    catch {
        Write-ErrorMsg "Download failed: $($_.Exception.Message)"
        return $false
    }
}

# Extract tarball to destination directory
function Expand-Tarball {
    param(
        [string]$TarballPath,
        [string]$DestinationDir
    )

    try {
        # Windows 10+ has tar.exe built-in
        if (Get-Command tar -ErrorAction SilentlyContinue) {
            tar -xzf $TarballPath -C $DestinationDir
            return $true
        }
        else {
            Write-ErrorMsg "tar command not found. Please install tar or use Windows 10+."
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Extraction failed: $($_.Exception.Message)"
        return $false
    }
}

# Run install script from extracted directory
function Invoke-Install {
    param(
        [string]$ExtractedDir,
        [string]$TargetDir
    )

    $installScript = Join-Path $ExtractedDir "scripts\install-junior.ps1"

    if (-not (Test-Path $installScript)) {
        Write-ErrorMsg "Install script not found in extracted directory"
        return $false
    }

    try {
        Push-Location $ExtractedDir
        & $installScript -TargetPath $TargetDir
        Pop-Location
        return $true
    }
    catch {
        Write-ErrorMsg "Installation script failed: $($_.Exception.Message)"
        Pop-Location
        return $false
    }
}

# Main bootstrap flow
function Invoke-Bootstrap {
    Write-Status "Installing Junior..."

    # Detect current directory as target
    $targetDir = Get-Location
    Write-Status "Target directory: $targetDir"

    # Create temporary directory
    $tempDir = Join-Path $env:TEMP ".junior-bootstrap-$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Write-Status "Using temp directory: $tempDir"

    try {
        # Download tarball
        Write-Status "Downloading Junior..."
        $tarballFile = Join-Path $tempDir "junior.tar.gz"
        if (-not (Get-Tarball -Url $TARBALL_URL -Destination $tarballFile)) {
            throw "Failed to download Junior tarball"
        }
        Write-Status "Download complete"

        # Extract tarball
        Write-Status "Extracting..."
        if (-not (Expand-Tarball -TarballPath $tarballFile -DestinationDir $tempDir)) {
            throw "Failed to extract tarball"
        }

        # Find extracted directory (handles junior-main, junior-master, etc.)
        $extractedDir = Get-ChildItem -Path $tempDir -Directory -Filter "junior-*" | Select-Object -First 1 -ExpandProperty FullName
        if (-not $extractedDir) {
            throw "Could not find extracted Junior directory"
        }
        Write-Status "Extracted to: $extractedDir"

        # Run install script
        Write-Status "Running install script..."
        if (-not (Invoke-Install -ExtractedDir $extractedDir -TargetDir $targetDir)) {
            throw "Installation failed"
        }

        # Success!
        Write-Success "Junior bootstrap complete!"
        Write-Status "Junior has been installed to: $targetDir"
    }
    catch {
        Write-ErrorMsg $_
        exit 1
    }
    finally {
        # Cleanup temporary directory
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# ============================================================================
# Entry Point
# ============================================================================

Invoke-Bootstrap

