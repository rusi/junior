# Junior install wrapper (PowerShell)
# Delegates to scripts/junior.py for cross-platform install/update logic.
#
# Usage:
#   .\scripts\install-junior.ps1 [-SyncBack] [-Target claude|cursor|codex|all|csv]
#       [-Scope global|project] [-ProjectRoot <path>] [-IgnoreDirty] [-Yes] [-Overwrite] [-Verbose]

[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Position = 0)]
    [string]$Destination = "",

    [Parameter(Mandatory = $false)]
    [switch]$SyncBack,

    [Parameter(Mandatory = $false)]
    [string[]]$Target = @(),

    # A param block binds only what it declares and rejects the rest, so every flag the
    # shell wrapper forwards by default has to be named here for the two to be equivalent.
    [Parameter(Mandatory = $false)]
    [string]$Scope = "",

    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = "",

    [Parameter(Mandatory = $false)]
    [switch]$IgnoreDirty,

    [Parameter(Mandatory = $false)]
    [switch]$Yes,

    [Parameter(Mandatory = $false)]
    [switch]$Overwrite,

    # Retired, and still bound so it can be refused by name. See junior.py.
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

if ($Force) {
    Write-Host ("[ERROR] -Force is retired: one switch granted two unrelated permissions. " +
        "Use -Yes to answer prompts without a terminal, -Overwrite to replace installed " +
        "files you have modified, or both to grant what -Force used to.") -ForegroundColor Red
    exit 1
}

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
    Write-Host "[ERROR] Missing required -Target: claude, cursor, codex, all, or a csv list." -ForegroundColor Red
    exit 1
}
if ($Target) { $argsList += @("--target", ($Target -join ',')) }
if ($Destination) { $argsList += $Destination }
if ($Scope) { $argsList += @("--scope", $Scope) }
if ($ProjectRoot) { $argsList += @("--project-root", $ProjectRoot) }

if ($PSBoundParameters['Verbose']) { $argsList += "--verbose" }
if ($IgnoreDirty) { $argsList += "--ignore-dirty" }
if ($Yes) { $argsList += "--yes" }
if ($Overwrite) { $argsList += "--overwrite" }

& $Python.Source @argsList
exit $LASTEXITCODE
