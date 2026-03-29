# Junior bootstrap script (PowerShell)
# Install or update Junior with:
#   irm https://rusi.github.io/junior/install.ps1 | iex

param(
    [Parameter(Mandatory = $false)]
    [string]$Target = "codex"
)

$ErrorActionPreference = "Stop"

$GitHubRepo = "rusi/junior"
$GitHubBranch = "main"
$TarballUrl = "https://github.com/$GitHubRepo/archive/refs/heads/$GitHubBranch.tar.gz"
$ApiUrl = "https://api.github.com/repos/$GitHubRepo/commits/$GitHubBranch"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Err {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

$Python = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $Python) {
    $Python = Get-Command python -ErrorAction SilentlyContinue
}
if (-not $Python) {
    Write-Err "Python is required (python3 or python not found)."
    exit 1
}

if ($Target -eq "codex") {
    Write-Info "Installing Junior global assets (~/.codex, ~/.cursor/rules)"
} elseif ($Target -eq "gemini") {
    Write-Info "Installing Junior global assets (~/.gemini)"
} elseif ($Target -eq "claude") {
    Write-Info "Installing Junior global assets (~/.claude)"
} elseif ($Target -eq "all" -or $Target.Contains(",")) {
    Write-Info "Installing Junior global assets for multiple targets: $Target"
} else {
    Write-Info "Installing Junior global assets for target: $Target"
}

$TempDir = Join-Path $env:TEMP ".junior-bootstrap-$([guid]::NewGuid().ToString('N'))"
New-Item -Path $TempDir -ItemType Directory -Force | Out-Null

try {
    $Tarball = Join-Path $TempDir "junior.tar.gz"

    Write-Info "Downloading Junior..."
    Invoke-WebRequest -Uri $TarballUrl -OutFile $Tarball -UseBasicParsing

    Write-Info "Extracting..."
    tar -xzf $Tarball -C $TempDir
    if ($LASTEXITCODE -ne 0) {
        throw "Tar extraction failed"
    }

    $ExtractedDir = Get-ChildItem -Path $TempDir -Directory | Where-Object { $_.Name -like "junior-*" } | Select-Object -First 1
    if (-not $ExtractedDir) {
        throw "Could not find extracted Junior directory"
    }

    $CommitHash = "unknown"
    $CommitDate = "unknown"
    $CommitTimestamp = "unknown"
    try {
        $Latest = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing
        if ($Latest.sha) {
            $CommitHash = $Latest.sha
        }
        if ($Latest.commit.committer.date) {
            $CommitDate = $Latest.commit.committer.date
            try {
                $CommitTimestamp = [string][int][double]::Parse((([DateTime]$CommitDate).ToUniversalTime() - [DateTime]::new(1970,1,1,0,0,0,[DateTimeKind]::Utc)).TotalSeconds)
            } catch {
                $CommitTimestamp = "unknown"
            }
        }
    } catch {
        # Best effort only.
    }

    $GitHash = @"
COMMIT_HASH=$CommitHash
COMMIT_DATE=$CommitDate
COMMIT_TIMESTAMP=$CommitTimestamp
"@
    $GitHashPath = Join-Path $ExtractedDir.FullName ".githash"
    Set-Content -Path $GitHashPath -Value $GitHash -NoNewline

    $Installer = Join-Path $ExtractedDir.FullName "scripts\junior.py"
    if (-not (Test-Path $Installer -PathType Leaf)) {
        throw "Missing installer: $Installer"
    }

    Write-Info "Running installer..."
    & $Python.Source $Installer install --force --target $Target
    if ($LASTEXITCODE -ne 0) {
        throw "Installer exited with code $LASTEXITCODE"
    }

    Write-Info "Junior bootstrap complete."
}
catch {
    Write-Err $_.Exception.Message
    exit 1
}
finally {
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
