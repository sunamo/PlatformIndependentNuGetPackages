<#
.SYNOPSIS
Merges test project directories into the main project directories, fixing issues from previous versions.

.DESCRIPTION
This script identifies common directories between a main project folder and a test project folder.
For each common directory, it performs the following actions:
1. Moves all contents from the test directory to the main directory.
2. Updates the Visual Studio solution file (.sln) to reflect the new project structure.
3. Moves a nested .git directory (if it exists) to the root of the project folder.

.PARAMETER MainDirectory
The path to the main project directory. Default: "E:\vs3\PlatformIndependentNuGetPackages"

.PARAMETER TestDirectory
The path to the test project directory. Default: "E:\vs3\_ut2\PlatformIndependentNuGetPackages.Tests"

.PARAMETER WhatIf
A switch to simulate the script's actions without making any actual changes.

.EXAMPLE
# Run in simulation mode to see what changes would be made
.\MergeTestProjects_Final.ps1 -WhatIf

.EXAMPLE
# Execute the merge operation
.\MergeTestProjects_Final.ps1

.LINK
https://github.com/sunamo/PlatformIndependentNuGetPackages
#>

param(
    [string]$MainDirectory = "E:\vs3\PlatformIndependentNuGetPackages",
    [string]$TestDirectory = "E:\vs3\_ut2\PlatformIndependentNuGetPackages.Tests",
    [switch]$WhatIf
)

function Merge-Projects {
    param(
        [string]$mainDir,
        [string]$testDir,
        [switch]$simulate
    )

    # Získání seznamu složek v hlavním a testovacím adresáři
    try {
        $mainFolders = Get-ChildItem -Path $mainDir -Directory -ErrorAction Stop
        $testFolders = Get-ChildItem -Path $testDir -Directory -ErrorAction Stop
    } catch {
        Write-Error "Chyba při čtení adresářů: $($_.Exception.Message)"
        return
    }

    # Nalezení společných složek porovnáním jejich jmen
    $commonFolderPairs = @()
    foreach ($mainFolder in $mainFolders) {
        $matchingTestFolder = $testFolders | Where-Object { $_.Name -eq $mainFolder.Name }
        if ($null -ne $matchingTestFolder) {
            $commonFolderPairs += @{
                Main = $mainFolder
                Test = $matchingTestFolder
            }
        }
    }

    if ($commonFolderPairs.Count -eq 0) {
        Write-Host "Nebyly nalezeny žádné společné složky k zpracování."
        return
    }

    Write-Host "Nalezeno $($commonFolderPairs.Count) společných složek k zpracování:" -ForegroundColor Yellow
    $commonFolderPairs | ForEach-Object { Write-Host "  - $($_.Main.Name)" }
    Write-Host ""

    if ($simulate) {
        Write-Host "--- SIMULAČNÍ MÓD (WhatIf) ---" -ForegroundColor Magenta
        Write-Host "Níže uvedené akce nebudou provedeny, pouze zobrazeny." -ForegroundColor Magenta
    } else {
        $confirmation = Read-Host "Opravdu chcete pokračovat a sloučit $($commonFolderPairs.Count) složek? (y/n)"
        if ($confirmation -ne 'y') {
            Write-Host "Operace zrušena uživatelem."
            return
        }
    }

    foreach ($pair in $commonFolderPairs) {
        $mainPath = $pair.Main.FullName
        $testPath = $pair.Test.FullName
        $folderName = $pair.Main.Name

        Write-Host "`n--- Zpracovávám: $folderName ---" -ForegroundColor Cyan

        # 1. Přesun obsahu z testovací složky
        $itemsToMove = Get-ChildItem -Path $testPath -Force
        if ($itemsToMove) {
            Write-Host "  Přesouvám obsah z '$testPath' do '$mainPath'..."
            foreach ($item in $itemsToMove) {
                $destinationPath = Join-Path $mainPath $item.Name
                if ($simulate) {
                    Write-Host "    WHATIF: Přesunout '$($item.FullName)' do '$destinationPath'"
                } else {
                    try {
                        Move-Item -Path $item.FullName -Destination $destinationPath -Force -ErrorAction Stop
                        Write-Host "    Přesunuto: $($item.Name)" -ForegroundColor Green
                    } catch {
                        Write-Error "    Chyba při přesunu '$($item.FullName)': $($_.Exception.Message)"
                    }
                }
            }
        } else {
            Write-Host "  Testovací složka '$testPath' je prázdná, není co přesouvat." -ForegroundColor Gray
        }

        # 2. Aktualizace .sln souboru
        $slnFile = Get-ChildItem -Path $mainPath -Filter "*.sln" -File | Select-Object -First 1
        if ($slnFile) {
            Write-Host "  Aktualizuji .sln soubor: $($slnFile.FullName)"
            if ($simulate) {
                 Write-Host "    WHATIF: Soubor '$($slnFile.FullName)' by byl upraven."
            } else {
                try {
                    $slnContent = Get-Content $slnFile.FullName -Raw
                    $originalSlnContent = $slnContent
                    
                    # Nahradí cesty jako "..\..\..\<něco>\<projekt>.csproj" na "<projekt>.csproj"
                    $pattern = '", "([.\\]+)([^"\\]+\\){0,5}([^"\\]+\.csproj)"'
                    $replacement = '", "$3"'
                    
                    $slnContent = $slnContent -replace $pattern, $replacement

                    if ($originalSlnContent -ne $slnContent) {
                        Write-Host "    Nalezeny a aktualizovány cesty v .sln souboru." -ForegroundColor Green
                        $backupPath = "$($slnFile.FullName).backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                        Write-Host "    Vytvářím zálohu: $backupPath"
                        Copy-Item -Path $slnFile.FullName -Destination $backupPath -Force
                        Set-Content -Path $slnFile.FullName -Value $slnContent -Encoding UTF8
                    } else {
                        Write-Host "    V .sln souboru nebyly nalezeny žádné cesty k aktualizaci." -ForegroundColor Gray
                    }
                } catch {
                    Write-Error "    Chyba při aktualizaci .sln souboru: $($_.Exception.Message)"
                }
            }
        }

        # 3. Přesun .git složky (pokud existuje vnořená)
        $nestedGitPath = Join-Path $mainPath $folderName ".git"
        if (Test-Path $nestedGitPath) {
            $targetGitPath = Join-Path $mainPath ".git"
            Write-Host "  Přesouvám .git složku z '$nestedGitPath' do '$targetGitPath'..."
            if ($simulate) {
                Write-Host "    WHATIF: Přesunout '$nestedGitPath' do '$targetGitPath'"
            } else {
                try {
                    Move-Item -Path $nestedGitPath -Destination $targetGitPath -Force -ErrorAction Stop
                    Write-Host "    .git složka přesunuta." -ForegroundColor Green
                } catch {
                    Write-Error "    Chyba při přesunu .git složky: $($_.Exception.Message)"
                }
            }
        }
    }

    Write-Host "`n--- Sloučení dokončeno ---" -ForegroundColor Green
}

Merge-Projects -MainDir $MainDirectory -TestDir $TestDirectory -Simulate:$WhatIf
