# EN: Script to find files with short variable names that were supposedly refactored in commit "feat: Replace variables names with self-describe names"
# CZ: Skript pro nalezení souborů s krátkými názvy proměnných, které byly údajně refactorovány v commitu "feat: Replace variables names with self-describe names"

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "Scanning all submodules for short variable names in refactored files..." -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

# EN: Get all submodule paths
# CZ: Získat všechny cesty submodulů
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -replace 'submodule\..*\.path ', ''
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in this repository." -ForegroundColor Yellow
    exit
}

$totalIssues = 0
$filesWithIssues = @()

foreach ($submodule in $submodules) {
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        continue
    }

    Push-Location $submodulePath

    try {
        # EN: Find commit with refactoring message
        # CZ: Najít commit s refactoringovou zprávou
        $commitHash = git log --all --oneline --grep="feat: Replace variables names with self-describe names" --format="%H" | Select-Object -First 1

        if (-not $commitHash) {
            Pop-Location
            continue
        }

        Write-Host "`nProcessing: $submodule" -ForegroundColor Green
        Write-Host "  Commit: $commitHash" -ForegroundColor Gray

        # EN: Get files changed in that commit
        # CZ: Získat soubory změněné v tom commitu
        $changedFiles = git show --name-only --pretty=format:"" $commitHash | Where-Object { $_ -like "*.cs" }

        foreach ($file in $changedFiles) {
            $fullPath = Join-Path $submodulePath $file

            if (-not (Test-Path $fullPath)) {
                continue
            }

            # EN: Read file content and check for short variable names
            # CZ: Přečíst obsah souboru a zkontrolovat krátké názvy proměnných
            $content = Get-Content $fullPath -Raw

            # EN: Pattern to find short variable names (1-2 characters) in common contexts
            # CZ: Vzor pro nalezení krátkých názvů proměnných (1-2 znaky) v běžných kontextech
            $patterns = @(
                '\b(int|string|var|object|bool|double|float|long|byte|char|decimal)\s+([a-z]{1,2})\s*[=;,)]',
                '\bforeach\s*\([^)]*\s+([a-z]{1,2})\s+in\b',
                '\bfor\s*\([^)]*\s+([a-z]{1,2})\s*[=;]',
                '\(([^)]*\s+[a-z]{1,2}\s*,|\s+[a-z]{1,2}\s*\))',
                '=>\s*([a-z]{1,2})\s*[.=;]'
            )

            $foundIssue = $false
            foreach ($pattern in $patterns) {
                if ($content -match $pattern) {
                    if (-not $foundIssue) {
                        Write-Host "  � ISSUE: $file" -ForegroundColor Red
                        $foundIssue = $true
                        $totalIssues++
                        $filesWithIssues += @{
                            Submodule = $submodule
                            File = $file
                            FullPath = $fullPath
                        }
                    }
                }
            }
        }

    } catch {
        Write-Host "  Error processing submodule: $_" -ForegroundColor Red
    } finally {
        Pop-Location
    }
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 80) -ForegroundColor Gray

if ($totalIssues -eq 0) {
    Write-Host "SUCCESS: No files with short variable names found!" -ForegroundColor Green
} else {
    Write-Host "Found $totalIssues file(s) with potential short variable names:" -ForegroundColor Yellow
    Write-Host ""
    foreach ($file in $filesWithIssues) {
        Write-Host "  $($file.Submodule)/$($file.File)" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "You can now run the refactor script on these files." -ForegroundColor Cyan
}
