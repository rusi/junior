# Junior install wrapper (PowerShell)
# Delegates to scripts/junior.py for cross-platform install/update logic.
#
# Usage:
#   .\scripts\install-junior.ps1 [-SyncBack] [-Target claude|codex|cursor|gemini|all|csv] [-IgnoreDirty] [-Force] [-Verbose]

param(
    [Parameter(Mandatory = $false)]
    [switch]$SyncBack,

    [Parameter(Mandatory = $false)]
    [string]$Target = "",

    [Parameter(Mandatory = $false)]
    [switch]$IgnoreDirty,

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PyScript = Join-Path $ScriptDir "junior.py"

$Python = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $Python) {
    $Python = Get-Command python -ErrorAction SilentlyContinue
}
if (-not $Python) {
    Write-Host "[ERROR] Python is required to install Junior (python3 or python not found)." -ForegroundColor Red
    exit 1
}

$mode = if ($SyncBack) { "sync-back" } else { "install" }
$argsList = @($PyScript, $mode)
if (-not $SyncBack -and -not $Target) {
    Write-Host "[ERROR] Missing required -Target: claude, codex, cursor, gemini, all, or a csv list." -ForegroundColor Red
    exit 1
}
if ($Target) { $argsList += @("--target", $Target) }

if ($Verbose) { $argsList += "--verbose" }
if ($IgnoreDirty) { $argsList += "--ignore-dirty" }
if ($Force) { $argsList += "--force" }

& $Python.Source @argsList
exit $LASTEXITCODE
