# EN: Script to open unmodified files from each submodule in Visual Studio one by one
# CZ: Skript pro otevření nezměněných souborů z každého submodulu ve Visual Studiu po jednom

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$vsPath = "C:\Program Files\Microsoft Visual Studio\18\Insiders\Common7\IDE\devenv.exe"

Set-Location $rootPath

# Check if VS exists
if (-not (Test-Path $vsPath)) {
    Write-Host "Visual Studio not found at: $vsPath" -ForegroundColor Red
    exit 1
}

Write-Host "Opening unmodified files in Visual Studio - one submodule at a time" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray
Write-Host ""

# Get all submodule paths
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -replace 'submodule\..*\.path ', ''
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in this repository." -ForegroundColor Yellow
    exit
}

$totalSubmodules = $submodules.Count
$currentIndex = 0
$processedCount = 0
$skippedCount = 0

foreach ($submodule in $submodules) {
    $currentIndex++
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        Write-Host "[$currentIndex/$totalSubmodules] Skipping $submodule - path not found" -ForegroundColor Yellow
        $skippedCount++
        continue
    }

    Write-Host "`n" -NoNewline
    Write-Host ("=" * 80) -ForegroundColor DarkCyan
    Write-Host "[$currentIndex/$totalSubmodules] Processing: $submodule" -ForegroundColor Green
    Write-Host ("=" * 80) -ForegroundColor DarkCyan

    Push-Location $submodulePath

    try {
        # Get all tracked files (files that are in git)
        $trackedFiles = git ls-files

        # Get files with changes (modified, added, deleted, untracked)
        $changedFiles = git status --porcelain | ForEach-Object {
            # Remove status prefix (first 3 characters like "M  ", "A  ", "?? ")
            $_.Substring(3)
        }

        # Convert to hashtable for faster lookup
        $changedFilesHash = @{}
        foreach ($file in $changedFiles) {
            $changedFilesHash[$file] = $true
        }

        # Find files that are tracked but NOT changed
        $unmodifiedFiles = $trackedFiles | Where-Object {
            -not $changedFilesHash.ContainsKey($_)
        }

        if ($unmodifiedFiles.Count -gt 0) {
            Write-Host "Files NOT in changes: $($unmodifiedFiles.Count)" -ForegroundColor White
            Write-Host ""

            # Group by directory for better readability
            $filesByDir = $unmodifiedFiles | Group-Object { Split-Path $_ -Parent }

            foreach ($group in $filesByDir | Sort-Object Name) {
                $dirName = if ($group.Name) { $group.Name } else { "(root)" }
                Write-Host "  $dirName/:" -ForegroundColor Cyan

                foreach ($file in ($group.Group | Sort-Object)) {
                    $fileName = Split-Path $file -Leaf
                    Write-Host "    - $fileName" -ForegroundColor Gray
                }
            }

            Write-Host ""
            Write-Host "Opening these files in Visual Studio..." -ForegroundColor Yellow

            # Open all unmodified files in Visual Studio
            foreach ($file in $unmodifiedFiles) {
                $fullFilePath = Join-Path $submodulePath $file
                if (Test-Path $fullFilePath) {
                    # Start VS with the file
                    Start-Process -FilePath $vsPath -ArgumentList "`"$fullFilePath`""
                    # Small delay to not overwhelm VS
                    Start-Sleep -Milliseconds 200
                }
            }

            $processedCount++

            Write-Host ""
            Write-Host "Files opened in Visual Studio!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Press ENTER to continue to next submodule, or Ctrl+C to cancel..." -ForegroundColor Yellow
            $null = Read-Host

        } else {
            Write-Host "All tracked files have changes or no files tracked - skipping" -ForegroundColor DarkYellow
            $skippedCount++
        }

    } catch {
        Write-Host "Error processing submodule: $_" -ForegroundColor Red
        $skippedCount++
    } finally {
        Pop-Location
    }
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 80) -ForegroundColor Gray
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray
Write-Host "Total submodules: $totalSubmodules" -ForegroundColor White
Write-Host "Processed (opened files): $processedCount" -ForegroundColor Green
Write-Host "Skipped (no unmodified files or errors): $skippedCount" -ForegroundColor Yellow
Write-Host ""
Write-Host "Done!" -ForegroundColor Cyan
