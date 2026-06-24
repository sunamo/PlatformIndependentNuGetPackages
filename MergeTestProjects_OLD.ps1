# PowerShell skript pro sloučení test složek s hlavními projekty
# Autor: GitHub Copilot  
# Datum: 30.7.2025

param(
    [string]$MainDirectory = "E:\vs3\PlatformIndependentNuGetPackages",
    [string]$TestDirectory = "E:\vs3\_ut2\PlatformIndependentNuGetPackages.Tests",
    [switch]$WhatIf = $false  # Pokud je true, pouze zobrazí, co by se stalo
)

Write-Host "Začínám sloučení test projektů s hlavními projekty" -ForegroundColor Green
Write-Host "Hlavní adresář: $MainDirectory" -ForegroundColor Cyan
Write-Host "Test adresář: $TestDirectory" -ForegroundColor Cyan

# Kontrola existence adresářů
if (-not (Test-Path $MainDirectory)) {
    Write-Error "Hlavní adresář $MainDirectory neexistuje!"
    exit 1
}

if (-not (Test-Path $TestDirectory)) {
    Write-Error "Test adresář $TestDirectory neexistuje!"
    exit 1
}

# Získání seznamu složek v obou adresářích
$mainFolders = Get-ChildItem -Path $MainDirectory -Directory | Where-Object { 
    $_.Name -notin @('.git', '.vs', '.vscode', '_', 'bin', 'obj') -and 
    -not $_.Name.StartsWith('.') -and
    $_.Name -ne 'PlatformIndependentNuGetPackages.Tests'
}

$testFolders = Get-ChildItem -Path $TestDirectory -Directory | Where-Object { 
    $_.Name -notin @('.git', '.vs', '.vscode', '_', 'bin', 'obj', 'TestResults', 'TestValues', 'TestValues.Sql') -and 
    -not $_.Name.StartsWith('.') -and
    -not $_.Name.EndsWith('.Tests') -and
    -not $_.Name.EndsWith('.Tests2') -and
    $_.Name -ne 'sunamo.Tests.Data' -and
    $_.Name -ne 'SunamoCode.Tests' -and
    $_.Name -ne 'Roslyn.Tests' -and
    -not $_.Name.Contains('.sln')
}

# Najdeme společné složky
$commonFolders = @()
foreach ($mainFolder in $mainFolders) {
    $testFolder = $testFolders | Where-Object { $_.Name -eq $mainFolder.Name }
    if ($testFolder) {
        $commonFolders += @{
            Name = $mainFolder.Name
            MainPath = $mainFolder.FullName
            TestPath = $testFolder.FullName
            TargetPath = $mainFolder.FullName  # Cílová složka je hlavní složka
        }
    }
}

Write-Host "Nalezeno $($commonFolders.Count) společných složek k zpracování:" -ForegroundColor Yellow
foreach ($folder in $commonFolders) {
    Write-Host "  - $($folder.Name)" -ForegroundColor Cyan
}

if ($commonFolders.Count -eq 0) {
    Write-Host "Žádné společné složky k zpracování!" -ForegroundColor Yellow
    exit 0
}

# Pokud je WhatIf, pouze zobrazí co by se stalo
if ($WhatIf) {
    Write-Host "`nPředhled změn (WhatIf mode):" -ForegroundColor Magenta
    foreach ($folder in $commonFolders) {
        Write-Host "  Složka: $($folder.Name)" -ForegroundColor White
        
        # Kontrola struktury
        $innerFolderPath = Join-Path $folder.MainPath $folder.Name
        if (Test-Path $innerFolderPath) {
            Write-Host "    1. Přesunout obsah z: $($folder.TestPath)" -ForegroundColor Yellow
            Write-Host "    2. Cíl: $($folder.TargetPath)" -ForegroundColor Yellow
            Write-Host "    3. Přesunout .git z: $innerFolderPath\.git do $($folder.TargetPath)\.git" -ForegroundColor Yellow
            
            # Kontrola .sln souborů
            $slnFiles = Get-ChildItem -Path $folder.TestPath -Filter "*.sln" -ErrorAction SilentlyContinue
            foreach ($slnFile in $slnFiles) {
                Write-Host "    4. Upravit .sln soubor: $($slnFile.FullName)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "    ! Složka není přestrukturalizovaná: $innerFolderPath" -ForegroundColor Red
        }
        Write-Host ""
    }
    exit 0
}

# Rozdělení na testovací složku a zbytek
$testFolder = $commonFolders | Where-Object { $_.Name -eq "SunamoAsync" }
$remainingFolders = $commonFolders | Where-Object { $_.Name -ne "SunamoAsync" }

# Najít SunamoAttributes pro zastavení
$stopAtFolder = $commonFolders | Where-Object { $_.Name -eq "SunamoAttributes" }
$foldersBeforeStop = @()
$foldersAfterStop = @()

if ($stopAtFolder) {
    foreach ($folder in $remainingFolders) {
        if ($folder.Name -eq "SunamoAttributes") {
            $foldersBeforeStop += $folder
            break
        } else {
            $foldersBeforeStop += $folder
        }
    }
    $foldersAfterStop = $remainingFolders | Where-Object { 
        $index = [array]::IndexOf($remainingFolders.Name, $_.Name)
        $stopIndex = [array]::IndexOf($remainingFolders.Name, "SunamoAttributes")
        $index -gt $stopIndex
    }
    Write-Host "Nalezena složka SunamoAttributes - script se zastaví po jejím zpracování" -ForegroundColor Yellow
}

if ($testFolder) {
    Write-Host "`nNejprve zpracuji testovací složku: SunamoAsync" -ForegroundColor Yellow
    $confirmation = Read-Host "Pokračovat s testovací složkou SunamoAsync? (y/n)"
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-Host "Operace zrušena uživatelem." -ForegroundColor Red
        exit 0
    }
} else {
    Write-Host "`nSunamoAsync nebyla nalezena nebo už je sloučená." -ForegroundColor Yellow
    $folderCount = if ($stopAtFolder) { $foldersBeforeStop.Count } else { $commonFolders.Count }
    Write-Host "Chystáte se sloučit $folderCount složek (zastavení u SunamoAttributes)." -ForegroundColor Yellow
    $confirmation = Read-Host "Pokračovat? (y/n)"
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-Host "Operace zrušena uživatelem." -ForegroundColor Red
        exit 0
    }
}

# Funkce pro opravu .sln souboru
function Fix-SlnFile {
    param(
        [string]$SlnPath,
        [string]$ProjectName
    )
    
    try {
        Write-Host "    Opravuji .sln soubor pomocí pokročilé logiky..." -ForegroundColor Yellow
        
        # Standardní relativní cesta pro hlavní projekt
        $projectRelativePath = "$ProjectName\$ProjectName.csproj"
        
        # Načtení obsahu
        $content = Get-Content -Path $SlnPath -Raw
        
        # Vytvoření zálohy
        $backupPath = $SlnPath + ".backup_fix_" + (Get-Date -Format "yyyyMMdd_HHmmss")
        Copy-Item -Path $SlnPath -Destination $backupPath
        Write-Host "    Vytvořena záloha: $backupPath" -ForegroundColor Cyan
        
        $updatedContent = $content
        $changesMade = 0
        
        # Najdeme všechny projektové řádky
        $projectLines = @()
        $lines = $updatedContent -split "`r`n"
        $linesToRemove = @()
        $correctProjectGuid = $null
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            # Hledáme všechny Project řádky
            if ($line -match 'Project\([^)]+\)\s*=\s*"([^"]+)",\s*"([^"]+)",\s*"(\{[A-F0-9-]+\})"') {
                $projectName = $matches[1]
                $projectPath = $matches[2]
                $projectGuid = $matches[3]
                
                $projectInfo = @{
                    LineIndex = $i
                    Line = $line
                    Name = $projectName
                    Path = $projectPath
                    Guid = $projectGuid
                    IsMainProject = $projectName -eq $ProjectName -and -not $projectName.EndsWith(".Tests")
                    IsTestProject = $projectName.EndsWith(".Tests") -or $projectPath.Contains(".Tests")
                    IsOtherProject = $projectName -ne $ProjectName -and -not $projectName.EndsWith(".Tests")
                    IsCorrect = $false
                }
                
                # Určíme, zda je projekt správný
                if ($projectInfo.IsMainProject) {
                    $projectInfo.IsCorrect = $projectPath -eq $projectRelativePath
                    if ($projectInfo.IsCorrect) {
                        $correctProjectGuid = $projectGuid
                        Write-Host "    ✓ Správný hlavní projekt '$projectName' s GUID: $projectGuid" -ForegroundColor Green
                    } else {
                        Write-Host "    ✗ Nesprávný hlavní projekt '$projectName' s cestou '$projectPath' (bude odstraněn)" -ForegroundColor Red
                        $linesToRemove += $i
                        # Také najdeme a označíme EndProject
                        if ($i + 1 -lt $lines.Count -and $lines[$i + 1] -eq "EndProject") {
                            $linesToRemove += ($i + 1)
                        }
                    }
                } elseif ($projectInfo.IsTestProject) {
                    # Test projekty zachováváme
                    $projectInfo.IsCorrect = $true
                    Write-Host "    ✓ Test projekt '$projectName' (zachováváme)" -ForegroundColor Cyan
                } else {
                    # Všechny ostatní projekty také zachováváme (RunnerAsync, apod.)
                    $projectInfo.IsCorrect = $true
                    $projectInfo.IsOtherProject = $true
                    Write-Host "    ✓ Jiný projekt '$projectName' (zachováváme)" -ForegroundColor Cyan
                }
                
                $projectLines += $projectInfo
            }
        }
        
        # Odstranění nesprávných řádků (zpětně, aby se indexy neposunuly)
        $linesToRemove = $linesToRemove | Sort-Object -Descending
        foreach ($lineIndex in $linesToRemove) {
            $lines = $lines[0..($lineIndex-1)] + $lines[($lineIndex+1)..($lines.Count-1)]
            $changesMade++
            Write-Host "    ✓ Odstraněn nesprávný řádek" -ForegroundColor Green
        }
        
        $updatedContent = $lines -join "`r`n"
        
        # Kontrola, zda hlavní projekt existuje po vyčištění
        $mainProjectExists = $updatedContent -match """$([regex]::Escape($projectRelativePath))"""
        
        if (-not $mainProjectExists) {
            Write-Host "    Přidávám chybějící hlavní projekt..." -ForegroundColor Yellow
            
            # Použijeme existující GUID nebo vytvoříme nový
            if (-not $correctProjectGuid) {
                $correctProjectGuid = "{" + [System.Guid]::NewGuid().ToString().ToUpper() + "}"
            }
            
            # Nalezení místa pro vložení projektu (před Global sekcí)
            $globalIndex = $updatedContent.IndexOf("Global")
            if ($globalIndex -gt 0) {
                # Přidání projektu před Global sekci
                $projectEntry = "Project(`"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}`") = `"$ProjectName`", `"$projectRelativePath`", `"$correctProjectGuid`"`r`nEndProject`r`n"
                $updatedContent = $updatedContent.Insert($globalIndex, $projectEntry)
                
                $changesMade++
                Write-Host "    ✓ Přidán hlavní projekt s cestou: $projectRelativePath" -ForegroundColor Green
            }
        }
        
        # Vyčištění ProjectConfigurationPlatforms
        Write-Host "    Čistím ProjectConfigurationPlatforms..." -ForegroundColor Yellow
        
        # Najdeme všechny GUID projektů, které skutečně existují v .sln
        $validGuids = @()
        foreach ($projectInfo in $projectLines) {
            if ($projectInfo.IsCorrect) {
                $validGuids += $projectInfo.Guid
            }
        }
        
        # Odstranění konfiguračních řádků pro neplatné GUID
        $lines = $updatedContent -split "`r`n"
        $configLinesToRemove = @()
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            # Hledáme řádky s GUID v ProjectConfigurationPlatforms sekci
            if ($line -match '\s*(\{[A-F0-9-]+\})\.') {
                $foundGuid = $matches[1]
                if ($foundGuid -notin $validGuids) {
                    $configLinesToRemove += $i
                }
            }
        }
        
        # Odstranění konfiguračních řádků (zpětně)
        $configLinesToRemove = $configLinesToRemove | Sort-Object -Descending -Unique
        foreach ($lineIndex in $configLinesToRemove) {
            if ($lineIndex -lt $lines.Count) {
                $lines = $lines[0..($lineIndex-1)] + $lines[($lineIndex+1)..($lines.Count-1)]
                $changesMade++
            }
        }
        
        $updatedContent = $lines -join "`r`n"
        
        # Zápis upraveného obsahu
        if ($changesMade -gt 0) {
            Set-Content -Path $SlnPath -Value $updatedContent -Encoding UTF8
            Write-Host "    ✓ .sln soubor byl opraven ($changesMade změn)" -ForegroundColor Green
        } else {
            Write-Host "    ✓ .sln soubor je už v pořádku" -ForegroundColor Green
        }
        
    } catch {
        Write-Error "    ✗ Chyba při opravě .sln souboru: $($_.Exception.Message)"
    }
}

# Zpracování testovací složky (SunamoAsync)
$successCount = 0
$errorCount = 0
$processedFolders = @()

if ($testFolder) {
    Write-Host "`n" + "="*60 -ForegroundColor Magenta
    Write-Host "FÁZE 1: TESTOVACÍ ZPRACOVÁNÍ - SunamoAsync" -ForegroundColor Magenta
    Write-Host "="*60 -ForegroundColor Magenta
    
    $folder = $testFolder
    try {
        Write-Host "`nZpracovávám testovací složku: $($folder.Name)" -ForegroundColor Green
        
        # Kontrola, zda je hlavní složka přestrukturalizovaná
        $innerFolderPath = Join-Path $folder.MainPath $folder.Name
        if (-not (Test-Path $innerFolderPath)) {
            Write-Warning "  Složka $($folder.Name) není přestrukturalizovaná. Ukončuji..."
            exit 1
        }
        
        # 1. Přesun obsahu z test složky do hlavní složky
        Write-Host "  Přesouvám obsah z test složky..." -ForegroundColor Yellow
        
        $testItems = Get-ChildItem -Path $folder.TestPath -Force -ErrorAction SilentlyContinue
        foreach ($item in $testItems) {
            $destinationPath = Join-Path $folder.TargetPath $item.Name
            
            # Pokud cíl již existuje, přejmenuj
            if (Test-Path $destinationPath) {
                if ($item.PSIsContainer) {
                    Write-Host "    Složka $($item.Name) již existuje, přeskakuji..." -ForegroundColor Yellow
                    continue
                } else {
                    # Pro soubory vytvoříme backup
                    $backupPath = $destinationPath + ".backup_" + (Get-Date -Format "yyyyMMdd_HHmmss")
                    Move-Item -Path $destinationPath -Destination $backupPath -Force
                    Write-Host "    Vytvořena záloha: $backupPath" -ForegroundColor Cyan
                }
            }
            
            Move-Item -Path $item.FullName -Destination $destinationPath -Force
            Write-Host "    ✓ Přesunut: $($item.Name)" -ForegroundColor Green
        }
        
        # 2. Přesun .git složky z vnořené složky do hlavní složky
        $gitSourcePath = Join-Path $innerFolderPath ".git"
        $gitTargetPath = Join-Path $folder.TargetPath ".git"
        
        if (Test-Path $gitSourcePath) {
            Write-Host "  Přesouvám .git složku..." -ForegroundColor Yellow
            
            # Pokud už .git existuje v cíli, vytvoř zálohu
            if (Test-Path $gitTargetPath) {
                $gitBackupPath = $gitTargetPath + ".backup_" + (Get-Date -Format "yyyyMMdd_HHmmss")
                Move-Item -Path $gitTargetPath -Destination $gitBackupPath -Force
                Write-Host "    Vytvořena záloha .git: $gitBackupPath" -ForegroundColor Cyan
            }
            
            Move-Item -Path $gitSourcePath -Destination $gitTargetPath -Force
            Write-Host "    ✓ Přesunut .git" -ForegroundColor Green
        }
        
        # 3. Úprava .sln souborů pomocí pokročilé logiky
        $slnFiles = Get-ChildItem -Path $folder.TargetPath -Filter "*.sln" -ErrorAction SilentlyContinue
        foreach ($slnFile in $slnFiles) {
            Write-Host "  Upravuji .sln soubor: $($slnFile.Name)" -ForegroundColor Yellow
            Fix-SlnFile -SlnPath $slnFile.FullName -ProjectName $folder.Name
        }
        
        $processedFolders += $folder.Name
        $successCount++
        Write-Host "  ✓ Úspěšně zpracováno: $($folder.Name)" -ForegroundColor Green
        
    } catch {
        Write-Error "  ✗ Chyba při zpracování složky $($folder.Name): $($_.Exception.Message)"
        $errorCount++
    }
    
    # Souhrn testovací fáze
    Write-Host "`n" + "="*60 -ForegroundColor Cyan
    Write-Host "SOUHRN TESTOVACÍ FÁZE" -ForegroundColor Cyan
    Write-Host "="*60 -ForegroundColor Cyan
    Write-Host "Zpracována testovací složka: SunamoAsync" -ForegroundColor Green
    if ($errorCount -eq 0) {
        Write-Host "✓ Test proběhl úspěšně!" -ForegroundColor Green
    } else {
        Write-Host "✗ Během testu došlo k chybě!" -ForegroundColor Red
    }
    
    # Kontrola výsledku
    Write-Host "`nProsím zkontrolujte výsledek:" -ForegroundColor Yellow
    Write-Host "  - Zkontrolujte složku: $($folder.TargetPath)" -ForegroundColor Cyan
    Write-Host "  - Ověřte, že se projekt kompiluje" -ForegroundColor Cyan
    Write-Host "  - Zkontrolujte .sln soubor" -ForegroundColor Cyan
    
    # Potvrzení pokračování
    Write-Host "`nJe vše v pořádku a chcete pokračovat se zbývajícími složkami?" -ForegroundColor Yellow
    $continueConfirmation = Read-Host "Pokračovat se zbytkem? (y/n)"
    
    if ($continueConfirmation -ne 'y' -and $continueConfirmation -ne 'Y') {
        Write-Host "`nOperace zastavena uživatelem po testovací fázi." -ForegroundColor Yellow
        Write-Host "Testovací složka SunamoAsync byla zpracována." -ForegroundColor Green
        exit 0
    }
    
    Write-Host "`n" + "="*60 -ForegroundColor Magenta
    Write-Host "FÁZE 2: ZPRACOVÁNÍ ZBÝVAJÍCÍCH SLOŽEK" -ForegroundColor Magenta
    Write-Host "="*60 -ForegroundColor Magenta
}

# Zpracování zbývajících složek (s podporou zastavení u SunamoAttributes)
$foldersToProcessNow = if ($testFolder) { 
    if ($stopAtFolder) { $foldersBeforeStop } else { $remainingFolders }
} else { 
    if ($stopAtFolder) { $foldersBeforeStop } else { $commonFolders }
}

foreach ($folder in $foldersToProcessNow) {
    try {
        Write-Host "`nZpracovávám složku: $($folder.Name)" -ForegroundColor Green
        
        # Kontrola, zda je hlavní složka přestrukturalizovaná
        $innerFolderPath = Join-Path $folder.MainPath $folder.Name
        if (-not (Test-Path $innerFolderPath)) {
            Write-Warning "  Složka $($folder.Name) není přestrukturalizovaná. Přeskakuji..."
            continue
        }
        
        # 1. Přesun obsahu z test složky do hlavní složky
        Write-Host "  Přesouvám obsah z test složky..." -ForegroundColor Yellow
        
        $testItems = Get-ChildItem -Path $folder.TestPath -Force -ErrorAction SilentlyContinue
        foreach ($item in $testItems) {
            $destinationPath = Join-Path $folder.TargetPath $item.Name
            
            # Pokud cíl již existuje, přejmenuj
            if (Test-Path $destinationPath) {
                if ($item.PSIsContainer) {
                    Write-Host "    Složka $($item.Name) již existuje, přeskakuji..." -ForegroundColor Yellow
                    continue
                } else {
                    # Pro soubory vytvoříme backup
                    $backupPath = $destinationPath + ".backup_" + (Get-Date -Format "yyyyMMdd_HHmmss")
                    Move-Item -Path $destinationPath -Destination $backupPath -Force
                    Write-Host "    Vytvořena záloha: $backupPath" -ForegroundColor Cyan
                }
            }
            
            Move-Item -Path $item.FullName -Destination $destinationPath -Force
            Write-Host "    ✓ Přesunut: $($item.Name)" -ForegroundColor Green
        }
        
        # 2. Přesun .git složky z vnořené složky do hlavní složky
        $gitSourcePath = Join-Path $innerFolderPath ".git"
        $gitTargetPath = Join-Path $folder.TargetPath ".git"
        
        if (Test-Path $gitSourcePath) {
            Write-Host "  Přesouvám .git složku..." -ForegroundColor Yellow
            
            # Pokud už .git existuje v cíli, vytvoř zálohu
            if (Test-Path $gitTargetPath) {
                $gitBackupPath = $gitTargetPath + ".backup_" + (Get-Date -Format "yyyyMMdd_HHmmss")
                Move-Item -Path $gitTargetPath -Destination $gitBackupPath -Force
                Write-Host "    Vytvořena záloha .git: $gitBackupPath" -ForegroundColor Cyan
            }
            
            Move-Item -Path $gitSourcePath -Destination $gitTargetPath -Force
            Write-Host "    ✓ Přesunut .git" -ForegroundColor Green
        }
        
        # 3. Úprava .sln souborů pomocí pokročilé logiky
        $slnFiles = Get-ChildItem -Path $folder.TargetPath -Filter "*.sln" -ErrorAction SilentlyContinue
        foreach ($slnFile in $slnFiles) {
            Write-Host "  Upravuji .sln soubor: $($slnFile.Name)" -ForegroundColor Yellow
            Fix-SlnFile -SlnPath $slnFile.FullName -ProjectName $folder.Name
        }
        
        $processedFolders += $folder.Name
        $successCount++
        Write-Host "  ✓ Úspěšně zpracováno: $($folder.Name)" -ForegroundColor Green
        
        # Zastavení u SunamoAttributes
        if ($folder.Name -eq "SunamoAttributes") {
            Write-Host "`n" + "="*60 -ForegroundColor Red
            Write-Host "ZASTAVENÍ U SUNAMOATTRIBUTES" -ForegroundColor Red
            Write-Host "="*60 -ForegroundColor Red
            Write-Host "Složka SunamoAttributes byla zpracována." -ForegroundColor Green
            Write-Host "Zbývá zpracovat $($foldersAfterStop.Count) složek." -ForegroundColor Yellow
            Write-Host "Script se zastavuje dle požadavku." -ForegroundColor Yellow
            break
        }
        
    } catch {
        Write-Error "  ✗ Chyba při zpracování složky $($folder.Name): $($_.Exception.Message)"
        $errorCount++
    }
}

# Finální souhrn
Write-Host "`n" + "="*60 -ForegroundColor White
Write-Host "FINÁLNÍ SOUHRN OPERACE" -ForegroundColor White
Write-Host "="*60 -ForegroundColor White
Write-Host "Úspěšně zpracováno: $successCount složek" -ForegroundColor Green
Write-Host "Chyby: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { "Green" } else { "Red" })

if ($processedFolders.Count -gt 0) {
    Write-Host "Zpracované složky:" -ForegroundColor Yellow
    $testProcessed = $processedFolders | Where-Object { $_ -eq "SunamoAsync" }
    $othersProcessed = $processedFolders | Where-Object { $_ -ne "SunamoAsync" }
    
    if ($testProcessed) {
        Write-Host "  TESTOVACÍ FÁZE:" -ForegroundColor Cyan
        Write-Host "    - SunamoAsync" -ForegroundColor Cyan
    }
    
    if ($othersProcessed.Count -gt 0) {
        Write-Host "  HLAVNÍ FÁZE:" -ForegroundColor Cyan
        foreach ($folderName in $othersProcessed) {
            Write-Host "    - $folderName" -ForegroundColor Cyan
        }
    }
}

if ($stopAtFolder -and $foldersAfterStop.Count -gt 0) {
    Write-Host "`nNezpracované složky (po SunamoAttributes):" -ForegroundColor Yellow
    foreach ($folder in $foldersAfterStop) {
        Write-Host "  - $($folder.Name)" -ForegroundColor Red
    }
}

if ($successCount -gt 0) {
    Write-Host "`nSloučení dokončeno!" -ForegroundColor Green
    Write-Host "Doporučuji ověřit, že projekty se správně kompilují." -ForegroundColor Yellow
} else {
    Write-Host "`nŽádné změny nebyly provedeny." -ForegroundColor Yellow
}
