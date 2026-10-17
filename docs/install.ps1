# Install Junior's latest tagged release. An optional path selects project scope.
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Position = 0)][string]$Destination = "",
    [string[]]$Target = @(),
    [string]$Version = "",
    [switch]$Development,
    [switch]$ChooseVersion,
    [switch]$ListVersions,
    [switch]$Yes,
    [string]$Scope = "",
    [string]$ProjectRoot = ""
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Find-JuniorPython {
    param([string[]]$Targets)
    $Minimum = [version]'3.10.0'
    $Selected = @(($Targets -join ',').Split(',') | ForEach-Object { $_.Trim().ToLowerInvariant() })
    if ('codex' -in $Selected -or 'all' -in $Selected) { $Minimum = [version]'3.11.0' }
    $Best = $null
    $BestVersion = [version]'0.0.0'
    $Found = @()
    $Candidates = @(Get-Command python3, python, 'python3.*' -CommandType Application -All -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Source -Unique)
    foreach ($Candidate in $Candidates) {
        $Output = & $Candidate -c 'import sys; print(" ".join(map(str, sys.version_info[:3])))' 2>$null
        $Version = $null
        if ($LASTEXITCODE -ne 0 -or -not [version]::TryParse(($Output -join '' -replace ' ', '.'), [ref]$Version)) {
            $Found += "$Candidate (unusable)"
            continue
        }
        $Found += "$Candidate ($Version)"
        if ($Version -ge $Minimum -and $Version -gt $BestVersion) {
            $Best = $Candidate
            $BestVersion = $Version
        }
    }
    if (-not $Best) {
        $Inventory = if ($Found.Count) { $Found -join '; ' } else { 'none' }
        throw "Python $Minimum or newer is required for the selected targets (Codex requires 3.11+). Found: $Inventory."
    }
    return $Best
}

# Dot-sourcing exposes the selector without downloading or installing anything.
if ($MyInvocation.InvocationName -eq '.') { return }
$Python = Find-JuniorPython -Targets $(if ($ListVersions) { @('claude') } else { $Target })

$BootstrapDir = Join-Path ([System.IO.Path]::GetTempPath()) "junior-bootstrap-$([guid]::NewGuid().ToString('N'))"
New-Item -Path $BootstrapDir -ItemType Directory | Out-Null
try {
    $Bootstrap = Join-Path $BootstrapDir "release_source.py"
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/rusi/junior/main/scripts/release_source.py" -OutFile $Bootstrap
    $BootstrapArgs = @($Bootstrap)
    if ($Destination) { $BootstrapArgs += $Destination }
    foreach ($Entry in @{target=($Target -join ','); version=$Version; scope=$Scope; 'project-root'=$ProjectRoot}.GetEnumerator()) {
        if ($Entry.Value) { $BootstrapArgs += @("--$($Entry.Key)", $Entry.Value) }
    }
    foreach ($Entry in @{development=$Development; 'choose-version'=$ChooseVersion; 'list-versions'=$ListVersions; yes=$Yes}.GetEnumerator()) {
        if ($Entry.Value) { $BootstrapArgs += "--$($Entry.Key)" }
    }
    & $Python @BootstrapArgs
    exit $LASTEXITCODE
} finally {
    Remove-Item -LiteralPath $BootstrapDir -Recurse -Force
}
