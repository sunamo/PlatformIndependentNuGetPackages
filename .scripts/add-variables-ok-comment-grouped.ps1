# EN: Add "// variables names: ok" comment to all .cs files in specified group of submodules
# CZ: Přidá "// variables names: ok" komentář do všech .cs souborů ve specifické skupině submodulů

param(
    [Parameter(Mandatory=$false)]
    [int]$GroupNumber = 0
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptDir
$groupedFile = Join-Path $scriptDir "submodules-grouped.md"
$comment = "// variables names: ok"

# Determine which submodules to process
if ($GroupNumber -eq 0) {
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "TIP: You can use -GroupNumber parameter to process only specific group" -ForegroundColor Yellow
    Write-Host "Example: .\.scripts\add-variables-ok-comment-grouped.ps1 -GroupNumber 4" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    # Get all submodules
    $submoduleDirs = Get-ChildItem -Path $rootPath -Directory | Where-Object { $_.Name -notmatch "^\." -and (Test-Path (Join-Path $_.FullName ".git")) }
    $submoduleNames = $submoduleDirs | Select-Object -ExpandProperty Name
} else {
    # Load submodules from specified group
    if (-not (Test-Path $groupedFile)) {
        Write-Host "Grouped submodules file not found: $groupedFile" -ForegroundColor Red
        Write-Host "Run .scripts\group-submodules.ps1 first" -ForegroundColor Yellow
        exit 1
    }

    # Read submodules from the specified group
    $content = Get-Content $groupedFile
    $inGroup = $false
    $submoduleNames = @()

    foreach ($line in $content) {
        if ($line -match "^## Group $GroupNumber$") {
            $inGroup = $true
            continue
        }
        if ($inGroup -and $line -match "^## Group \d+$") {
            break
        }
        if ($inGroup -and $line -match "^- ([^\s(]+)") {
            $submoduleNames += $matches[1].Trim()
        }
    }

    if ($submoduleNames.Count -eq 0) {
        Write-Host "No submodules found in group $GroupNumber" -ForegroundColor Red
        exit 1
    }

    Write-Host "Processing group $GroupNumber with $($submoduleNames.Count) submodules" -ForegroundColor Cyan
    Write-Host ""

    # Filter out missing submodules
    $existingNames = @()
    $missingNames = @()

    foreach ($name in $submoduleNames) {
        $submodulePath = Join-Path $rootPath $name
        if (Test-Path $submodulePath) {
            $existingNames += $name
        } else {
            $missingNames += $name
        }
    }

    if ($missingNames.Count -gt 0) {
        Write-Host "Skipping $($missingNames.Count) missing submodules:" -ForegroundColor Yellow
        foreach ($missing in $missingNames) {
            Write-Host "  - $missing" -ForegroundColor Yellow
        }
        Write-Host ""
    }

    $submoduleNames = $existingNames

    if ($submoduleNames.Count -eq 0) {
        Write-Host "No existing submodules found in group $GroupNumber" -ForegroundColor Red
        exit 1
    }
}

# Convert names to directory objects
$submodules = $submoduleNames | ForEach-Object { Get-Item (Join-Path $rootPath $_) }

Write-Host "Processing $($submodules.Count) submodules..." -ForegroundColor Cyan
Write-Host ""

$totalAdded = 0
$totalSkipped = 0
$totalProcessed = 0

foreach ($submodule in $submodules) {
    Write-Host "Processing: $($submodule.Name)" -ForegroundColor Yellow

    # Find all .cs files in submodule
    $csFiles = Get-ChildItem -Path $submodule.FullName -Filter "*.cs" -Recurse -File

    if ($csFiles.Count -eq 0) {
        Write-Host "  No .cs files found" -ForegroundColor Gray
        Write-Host ""
        continue
    }

    $addedCount = 0
    $skippedCount = 0

    foreach ($file in $csFiles) {
        $content = Get-Content $file.FullName -Raw

        if ($content -match "^\s*//\s*variables\s+names:\s*ok") {
            $skippedCount++
            continue
        }

        $newContent = "$comment`r`n$content"
        Set-Content -Path $file.FullName -Value $newContent -NoNewline

        $addedCount++
    }

    $totalAdded += $addedCount
    $totalSkipped += $skippedCount
    $totalProcessed += $csFiles.Count

    Write-Host "  Files: $($csFiles.Count) | Added: $addedCount | Skipped: $skippedCount" -ForegroundColor Cyan
    Write-Host ""
}

# Summary
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Total submodules processed: $($submodules.Count)" -ForegroundColor White
Write-Host "Total .cs files processed: $totalProcessed" -ForegroundColor White
Write-Host "Comments added: $totalAdded" -ForegroundColor Green
Write-Host "Files skipped (already has comment): $totalSkipped" -ForegroundColor Yellow
