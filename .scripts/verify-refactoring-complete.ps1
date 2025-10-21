# EN: Script to verify all files have been refactored
# CZ: Skript pro ověření že všechny soubory byly refaktorovány

param(
    [Parameter(Mandatory=$false)]
    [string]$BaseDir = "E:\vs\Projects\PlatformIndependentNuGetPackages"
)

$ErrorActionPreference = "Stop"

# EN: Read file lists
# CZ: Čtení seznamů souborů
$files1Path = Join-Path $BaseDir "files-to-refactor-1.txt"
$files2Path = Join-Path $BaseDir "files-to-refactor-2.txt"

$files1 = Get-Content $files1Path | Where-Object { $_ -and $_.Trim() }
$files2 = Get-Content $files2Path | Where-Object { $_ -and $_.Trim() }
$allFiles = $files1 + $files2

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "Refactoring Verification Report" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

$stats = @{
    Total = $allFiles.Count
    WithHeader = 0
    WithoutHeader = @()
    NotFound = @()
}

foreach ($relativePath in $allFiles) {
    $fullPath = Join-Path $BaseDir $relativePath

    if (-not (Test-Path $fullPath)) {
        $stats.NotFound += $relativePath
        continue
    }

    $content = Get-Content -Path $fullPath -Raw -Encoding UTF8

    if ($content -match "Variable names have been checked and replaced with self-descriptive names") {
        $stats.WithHeader++
    }
    else {
        $stats.WithoutHeader += $relativePath
    }
}

Write-Host "Total files: $($stats.Total)" -ForegroundColor White
Write-Host "Files with refactoring header: $($stats.WithHeader)" -ForegroundColor Green
Write-Host "Files without header: $($stats.WithoutHeader.Count)" -ForegroundColor $(if ($stats.WithoutHeader.Count -eq 0) { "Green" } else { "Red" })
Write-Host "Files not found: $($stats.NotFound.Count)" -ForegroundColor $(if ($stats.NotFound.Count -eq 0) { "Green" } else { "Yellow" })

if ($stats.WithoutHeader.Count -gt 0) {
    Write-Host "`nFiles still needing refactoring:" -ForegroundColor Red
    foreach ($file in $stats.WithoutHeader) {
        Write-Host "  - $file" -ForegroundColor Red
    }
}

if ($stats.NotFound.Count -gt 0) {
    Write-Host "`nFiles not found:" -ForegroundColor Yellow
    foreach ($file in $stats.NotFound) {
        Write-Host "  - $file" -ForegroundColor Yellow
    }
}

if ($stats.WithHeader -eq $stats.Total -and $stats.NotFound.Count -eq 0) {
    Write-Host "`n" -NoNewline
    Write-Host "SUCCESS! All $($stats.Total) files have been refactored!" -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
}

# EN: Export summary to JSON
# CZ: Export souhrnu do JSON
$summary = @{
    TotalFiles = $stats.Total
    FilesWithHeader = $stats.WithHeader
    FilesWithoutHeader = $stats.WithoutHeader
    FilesNotFound = $stats.NotFound
    CompletionPercentage = [math]::Round(($stats.WithHeader / $stats.Total) * 100, 2)
}

$summary | ConvertTo-Json -Depth 3 | Out-File (Join-Path $BaseDir "refactoring-verification-summary.json") -Encoding UTF8

Write-Host "Summary exported to: refactoring-verification-summary.json" -ForegroundColor Cyan
Write-Host ""
