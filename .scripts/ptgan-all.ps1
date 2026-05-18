#requires -Version 7.0
<#
.SYNOPSIS
  Sets PackageProjectUrl → GitHub Pages mini-landing, then runs PushToGitAndNuget for every
  Sunamo* package. Must be run from the SUBMODULE root of each package.

  Strategy:
    1. Update PackageProjectUrl in <Pkg>/<Pkg>/<Pkg>.csproj to create a git diff.
    2. Run the engine (which checks for git diff, bumps version, packs, pushes).
    3. Pipe 'y' to answer all interactive y/n prompts automatically.
#>
[CmdletBinding()]
param(
    [string[]]$Skip     = @('SunamoString'),
    [string]  $EngineExe = 'D:\SyncTrayzor\_sunamo\CommandsToAllCsprojs.Cmd\CommandsToAllCsprojs.Cmd.exe'
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
$skipped = 0
$i       = 0

Write-Host "=== ptgan-all: $total packages to process ==="

foreach ($pkg in $packages) {
    $i++
    $name     = $pkg.Name
    $subRoot  = $pkg.FullName  # e.g. E:\...\SunamoAI
    $csproj   = Join-Path $subRoot "$name\$name.csproj"
    $logFile  = Join-Path $logDir "$name.log"
    $wantedUrl = "https://sunamo.github.io/PlatformIndependentNuGetPackages/$name/"

    Write-Host "[$i/$total] $name ..."

    # 1. Update PackageProjectUrl in csproj (creates git diff required by engine)
    if (-not (Test-Path -LiteralPath $csproj)) {
        Write-Host "  ⚠ csproj not found at $csproj — skipping"
        $skipped++
        continue
    }

    try {
        $content = Get-Content -LiteralPath $csproj -Raw
        $changed = $false

        if ($content -match '<PackageProjectUrl>([^<]*)</PackageProjectUrl>') {
            $existingUrl = $Matches[1]
            if ($existingUrl -eq $wantedUrl) {
                Write-Host "  → PackageProjectUrl already correct — skipping"
                $skipped++
                continue
            }
            $content = $content -replace '<PackageProjectUrl>[^<]*</PackageProjectUrl>', "<PackageProjectUrl>$wantedUrl</PackageProjectUrl>"
            $changed = $true
        } else {
            # Inject after first <Copyright> or <Authors> line, or before </PropertyGroup>
            if ($content -match '(<Copyright>[^<]*</Copyright>)') {
                $content = $content -replace '(<Copyright>[^<]*</Copyright>)', "`$1`n    <PackageProjectUrl>$wantedUrl</PackageProjectUrl>"
            } else {
                $content = $content -replace '(</PropertyGroup>)', "  <PackageProjectUrl>$wantedUrl</PackageProjectUrl>`n  `$1"
            }
            $changed = $true
        }

        if ($changed) {
            [System.IO.File]::WriteAllText($csproj, $content, [System.Text.Encoding]::UTF8)
            Write-Host "  → PackageProjectUrl set"
        }
    } catch {
        Write-Host "  ✗ csproj update error: $_"
        $failed++
        continue
    }

    # 2. Run ptgan from the submodule root
    Push-Location $subRoot
    try {
        $output = "y`ny`ny`ny`ny" | & $EngineExe PushToGitAndNuget $name 2>&1 |
            ForEach-Object { $_ } |
            Out-String
    } finally {
        Pop-Location
    }

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
Write-Host "=== DONE: $success OK, $failed FAILED, $skipped SKIPPED (logs: $logDir) ==="
