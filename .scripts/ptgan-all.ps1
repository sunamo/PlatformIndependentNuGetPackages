#requires -Version 7.0
<#
.SYNOPSIS
  Runs PushToGitAndNuget for every Sunamo* package in the repo (except SunamoString which was already done).
  Pipes 'y' to answer all interactive y/n prompts automatically.
#>
[CmdletBinding()]
param(
    [string[]]$Skip = @('SunamoString'),
    [string]$EngineExe = 'D:\SyncTrayzor\_sunamo\CommandsToAllCsprojs.Cmd\CommandsToAllCsprojs.Cmd.exe'
)

$ErrorActionPreference = 'Continue'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$logDir   = Join-Path $repoRoot '.scripts\ptgan-all-logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

$packages = Get-ChildItem -Path $repoRoot -Directory -Filter 'Sunamo*' |
    Where-Object { $Skip -notcontains $_.Name } |
    Sort-Object Name

$total   = $packages.Count
$success = 0
$failed  = 0
$i       = 0

Write-Host "=== ptgan-all: $total packages to process ==="

foreach ($pkg in $packages) {
    $i++
    $name    = $pkg.Name
    $pkgDir  = $pkg.FullName
    $logFile = Join-Path $logDir "$name.log"

    Write-Host "[$i/$total] $name ..."

    $output = "y`ny`ny`ny`ny" | & $EngineExe PushToGitAndNuget $name 2>&1 |
        ForEach-Object { $_ } |
        Out-String

    Set-Content -LiteralPath $logFile -Value $output -Encoding UTF8

    $ok = $output -match 'Completed: PushToGitAndNuget'
    if ($ok) {
        $success++
        Write-Host "  ✓ OK"
    } else {
        $failed++
        $lastLines = ($output -split "`n" | Select-Object -Last 5) -join ' | '
        Write-Host "  ✗ FAILED — $lastLines"
    }
}

Write-Host ""
Write-Host "=== DONE: $success OK, $failed FAILED (logs: $logDir) ==="
