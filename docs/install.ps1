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
$Python = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $Python) { $Python = Get-Command python -ErrorAction SilentlyContinue }
if (-not $Python) { throw "Python is required (python3 or python not found)." }

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
    & $Python.Source @BootstrapArgs
    exit $LASTEXITCODE
} finally {
    Remove-Item -LiteralPath $BootstrapDir -Recurse -Force
}
