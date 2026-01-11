#!/usr/bin/env pwsh
# EN: Count C# files in all submodules
# CZ: Spočítá všechny C# soubory ve všech submodulech

$rootPath = Split-Path -Parent $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "C# FILES COUNTER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Find all directories (potential submodules)
$allDirs = Get-ChildItem -Path $rootPath -Directory | Where-Object {
    $_.Name -notmatch '^\.' -and
    $_.Name -ne 'bin' -and
    $_.Name -ne 'obj' -and
    $_.Name -ne 'packages'
}

$submodules = @()
foreach ($dir in $allDirs) {
    $hasCsFiles = (Get-ChildItem -Path $dir.FullName -Filter "*.cs" -Recurse -ErrorAction SilentlyContinue).Count -gt 0
    if ($hasCsFiles) {
        $csCount = (Get-ChildItem -Path $dir.FullName -Filter "*.cs" -Recurse -ErrorAction SilentlyContinue).Count
        $submodules += [PSCustomObject]@{
            Name = $dir.Name
            Path = $dir.FullName
            CsFiles = $csCount
        }
    }
}

Write-Host "Found $($submodules.Count) submodules with C# files" -ForegroundColor Green
Write-Host ""

$totalFiles = 0
$submodules | Sort-Object -Property CsFiles -Descending | ForEach-Object {
    $totalFiles += $_.CsFiles
    Write-Host ("  {0,-40} {1,6} files" -f $_.Name, $_.CsFiles) -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ("TOTAL: {0} C# files in {1} submodules" -f $totalFiles, $submodules.Count) -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
