# EN: Find and open .cs files that contain only empty classes or only comments
# CZ: Najdi a otevři .cs soubory které obsahují jen prázdné třídy nebo jen komentáře

param(
    [switch]$ListOnly,
    [switch]$SkipConfirmation
)

$rootDir = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$emptyFiles = @()

Write-Host "Searching for empty .cs files in submodules..." -ForegroundColor Cyan

$submodules = Get-ChildItem -Path $rootDir -Directory | Where-Object {
    $_.Name -notmatch '^\..*' -and $_.Name -ne 'obj' -and $_.Name -ne 'bin'
}

foreach ($submodule in $submodules) {
    Write-Host "  Scanning $($submodule.Name)..." -ForegroundColor Gray

    $csFiles = Get-ChildItem -Path $submodule.FullName -Filter "*.cs" -Recurse -File | Where-Object {
        $_.FullName -notmatch [regex]::Escape("\obj\") -and
        $_.FullName -notmatch [regex]::Escape("\bin\") -and
        $_.Name -ne "GlobalUsings.cs"
    }

    foreach ($file in $csFiles) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue

        if ([string]::IsNullOrWhiteSpace($content)) {
            $emptyFiles += @{ Path = $file.FullName; Reason = "Empty file"; Submodule = $submodule.Name }
            continue
        }

        $withoutComments = $content -replace '//.*?(\r?\n|$)', ' ' -replace '/\*.*?\*/', ' ' -replace '#region.*?(\r?\n|$)', ' ' -replace '#endregion.*?(\r?\n|$)', ' ' -replace '\s+', ' ' -replace '^\s+|\s+$', ''

        if ([string]::IsNullOrWhiteSpace($withoutComments)) {
            $emptyFiles += @{ Path = $file.FullName; Reason = "Only comments"; Submodule = $submodule.Name }
            continue
        }

        $classContent = $withoutComments -replace 'using[^;]+;', '' -replace 'namespace[^;{]+;', '' -replace 'namespace[^{]+\{', '' -replace '\}$', ''

        $hasClass = $classContent -match 'class'
        $hasMembers = $classContent -match '(\{(get|set);|\breturn\s+|\bnew\s+[\w<>]+\(|=[\w"(]|\w+\s+\w+\s*[=;(]|override\s+|virtual\s+|async\s+\w+\s*\()'

        if ($hasClass -and -not $hasMembers) {
            $emptyFiles += @{ Path = $file.FullName; Reason = "Empty class"; Submodule = $submodule.Name }
        }
    }
}

Write-Host "`nFound $($emptyFiles.Count) empty .cs file(s)" -ForegroundColor Yellow

if ($emptyFiles.Count -eq 0) {
    Write-Host "No empty files found!" -ForegroundColor Green
    exit 0
}

$emptyClassFiles = $emptyFiles | Where-Object { $_.Reason -eq "Empty class" }
$onlyCommentsFiles = $emptyFiles | Where-Object { $_.Reason -eq "Only comments" }
$completelyEmptyFiles = $emptyFiles | Where-Object { $_.Reason -eq "Empty file" }

if ($emptyClassFiles.Count -gt 0) {
    Write-Host "`n=== Empty Class Files ($($emptyClassFiles.Count)) ===" -ForegroundColor Cyan
    $emptyClassFiles | ForEach-Object { Write-Host "  [$($_.Submodule)] $($_.Path)" -ForegroundColor Gray }
}

if ($onlyCommentsFiles.Count -gt 0) {
    Write-Host "`n=== Only Comments Files ($($onlyCommentsFiles.Count)) ===" -ForegroundColor Cyan
    $onlyCommentsFiles | ForEach-Object { Write-Host "  [$($_.Submodule)] $($_.Path)" -ForegroundColor Gray }
}

if ($completelyEmptyFiles.Count -gt 0) {
    Write-Host "`n=== Completely Empty Files ($($completelyEmptyFiles.Count)) ===" -ForegroundColor Cyan
    $completelyEmptyFiles | ForEach-Object { Write-Host "  [$($_.Submodule)] $($_.Path)" -ForegroundColor Gray }
}

if ($ListOnly) {
    Write-Host "`nList-only mode. Exiting." -ForegroundColor Yellow
    exit 0
}

if (-not $SkipConfirmation) {
    Write-Host "`n============================================" -ForegroundColor Yellow
    Write-Host "Open all $($emptyFiles.Count) files in Cursor? (ENTER/Y)" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Yellow
    $confirmation = Read-Host "Continue? (Y/N)"
    if ($confirmation -ne 'Y' -and $confirmation -ne 'y' -and $confirmation -ne '') { exit 0 }
}

Write-Host "`nOpening files in batches of 20..." -ForegroundColor Cyan

$filePaths = $emptyFiles | ForEach-Object { $_.Path }
$batchSize = 20
$totalFiles = $filePaths.Count
$batchCount = [Math]::Ceiling($totalFiles / $batchSize)
$filesOpened = 0
$filesDeleted = 0
$previousBatch = @()

for ($i = 0; $i -lt $batchCount; $i++) {
    $start = $i * $batchSize
    $end = [Math]::Min($start + $batchSize, $totalFiles)
    $batch = $filePaths[$start..($end - 1)]

    Write-Host "`n========== Batch $($i + 1)/$batchCount (files $($start + 1)-$end) ==========" -ForegroundColor Cyan
    $batch | ForEach-Object { Write-Host "  [$(Split-Path -Parent $_ | Split-Path -Leaf)] $(Split-Path -Leaf $_)" -ForegroundColor Gray }

    & cursor $batch
    $filesOpened += $batch.Count
    Write-Host "Opened $($batch.Count) files ($filesOpened/$totalFiles total)" -ForegroundColor Green

    if ($i -lt $batchCount - 1) {
        Write-Host "`nOpen next 20 files? (ENTER/Y deletes previous 20!)" -ForegroundColor Yellow
        $confirmation = Read-Host "Continue? (Y/N)"
        if ($confirmation -ne 'Y' -and $confirmation -ne 'y' -and $confirmation -ne '') {
            Write-Host "Stopped. Opened $filesOpened/$totalFiles, Deleted $filesDeleted" -ForegroundColor Yellow
            exit 0
        }

        if ($previousBatch.Count -gt 0) {
            Write-Host "Deleting previous $($previousBatch.Count) files..." -ForegroundColor Red
            foreach ($f in $previousBatch) {
                Remove-Item $f -Force -ErrorAction SilentlyContinue
                $filesDeleted++
            }
            Write-Host "Deleted $($previousBatch.Count) files" -ForegroundColor Green
        }
    }

    $previousBatch = $batch
}

if ($previousBatch.Count -gt 0) {
    Write-Host "`nDelete last $($previousBatch.Count) files? (ENTER/Y)" -ForegroundColor Red
    $confirmation = Read-Host "Delete? (Y/N)"
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y' -or $confirmation -eq '') {
        foreach ($f in $previousBatch) {
            Remove-Item $f -Force -ErrorAction SilentlyContinue
            $filesDeleted++
        }
        Write-Host "Deleted $($previousBatch.Count) files" -ForegroundColor Green
    }
}

Write-Host "`n============================================" -ForegroundColor Green
Write-Host "DONE! Opened $filesOpened | Deleted $filesDeleted" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
