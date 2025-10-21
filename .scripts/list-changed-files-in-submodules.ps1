# EN: Script to count unchanged and changed .cs files in all git submodules (excluding obj/bin folders)
# CZ: Skript pro spočítání nezměněných a změněných .cs souborů ve všech git submodules (mimo obj/bin složky)

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "Counting .cs files in all submodules (excluding obj/bin)..." -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

# EN: Get all submodule paths
# CZ: Získat všechny cesty k submodules
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -replace 'submodule\..*\.path ', ''
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in this repository." -ForegroundColor Yellow
    exit
}

$totalSubmodules = $submodules.Count
$currentIndex = 0

# EN: Totals for summary
# CZ: Součty pro souhrnný výpis
$totalUnchangedCs = 0
$totalChangedCs = 0

foreach ($submodule in $submodules) {
    $currentIndex++
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        Write-Host "[$currentIndex/$totalSubmodules] Skipping $submodule - path not found" -ForegroundColor Yellow
        continue
    }

    Push-Location $submodulePath

    try {
        # EN: Get all tracked .cs files (excluding obj/bin folders)
        # CZ: Získat všechny sledované .cs soubory (mimo obj/bin složky)
        $allTrackedFiles = git ls-files | Where-Object {
            $_ -like "*.cs" -and
            $_ -notmatch '[/\\]obj[/\\]' -and
            $_ -notmatch '[/\\]bin[/\\]'
        }

        # EN: Get files with changes (modified, added, deleted, untracked)
        # CZ: Získat soubory se změnami (modifikované, přidané, smazané, nesledované)
        $changedFilesRaw = git status --porcelain | ForEach-Object {
            # EN: Remove status prefix (first 3 characters like "M  ", "A  ", "?? ")
            # CZ: Odstranit status prefix (první 3 znaky jako "M  ", "A  ", "?? ")
            $_.Substring(3)
        }

        # EN: Filter changed files to only .cs files (excluding obj/bin)
        # CZ: Filtrovat změněné soubory pouze na .cs soubory (mimo obj/bin)
        $changedCsFiles = $changedFilesRaw | Where-Object {
            $_ -like "*.cs" -and
            $_ -notmatch '[/\\]obj[/\\]' -and
            $_ -notmatch '[/\\]bin[/\\]'
        }

        # EN: Convert to hashtable for faster lookup
        # CZ: Převést na hashtable pro rychlejší vyhledávání
        $changedFilesHash = @{}
        foreach ($file in $changedCsFiles) {
            $changedFilesHash[$file] = $true
        }

        # EN: Find unchanged .cs files (tracked but not changed)
        # CZ: Najít nezměněné .cs soubory (sledované ale nezměněné)
        $unchangedCsFiles = $allTrackedFiles | Where-Object {
            -not $changedFilesHash.ContainsKey($_)
        }

        $unchangedCount = ($unchangedCsFiles | Measure-Object).Count
        $changedCount = ($changedCsFiles | Measure-Object).Count

        # EN: Add to totals
        # CZ: Přidat k celkovým součtům
        $totalUnchangedCs += $unchangedCount
        $totalChangedCs += $changedCount

        # EN: Display results for this submodule
        # CZ: Zobrazit výsledky pro tento submodule
        Write-Host "[$currentIndex/$totalSubmodules] $submodule" -ForegroundColor Cyan
        Write-Host "  Unchanged .cs files: $unchangedCount" -ForegroundColor Green
        Write-Host "  Changed .cs files:   $changedCount" -ForegroundColor Yellow

    } catch {
        Write-Host "[$currentIndex/$totalSubmodules] Error processing $submodule : $_" -ForegroundColor Red
    } finally {
        Pop-Location
    }
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 80) -ForegroundColor Gray
Write-Host "SUMMARY (all submodules, excluding obj/bin):" -ForegroundColor Cyan
Write-Host "  Total submodules: $totalSubmodules" -ForegroundColor White
Write-Host "  Total unchanged .cs files: $totalUnchangedCs" -ForegroundColor Green
Write-Host "  Total changed .cs files:   $totalChangedCs" -ForegroundColor Yellow
