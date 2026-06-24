# PowerShell skript pro přestrukturalizaci adresářů a úpravu .sln souboru
# Autor: GitHub Copilot
# Datum: 30.7.2025

param(
    [string]$BaseDirectory = "E:\vs3\PlatformIndependentNuGetPackages",
    [switch]$WhatIf = $false  # Pokud je true, pouze zobrazí, co by se stalo
)

Write-Host "Začínám přestrukturalizaci složek v: $BaseDirectory" -ForegroundColor Green

# Kontrola existence základního adresáře
if (-not (Test-Path $BaseDirectory)) {
    Write-Error "Základní adresář $BaseDirectory neexistuje!"
    exit 1
}

# Získání všech podsložek (kromě speciálních složek)
$excludedFolders = @('.git', '.vs', '.vscode', '_', 'bin', 'obj')
$allFolders = Get-ChildItem -Path $BaseDirectory -Directory | Where-Object { 
    $_.Name -notin $excludedFolders -and 
    -not $_.Name.StartsWith('.') -and
    $_.Name -ne 'PlatformIndependentNuGetPackages.Tests'
}

Write-Host "Nalezeno $($allFolders.Count) složek k zpracování" -ForegroundColor Yellow

# Seznam složek k zpracování
$foldersToProcess = @()
foreach ($folder in $allFolders) {
    $folderPath = $folder.FullName
    $folderName = $folder.Name
    $targetSubfolder = Join-Path $folderPath $folderName
    
    # Kontrola, zda již není přestrukturalizováno
    if (-not (Test-Path $targetSubfolder)) {
        $foldersToProcess += @{
            OriginalPath = $folderPath
            FolderName = $folderName
            TargetSubfolder = $targetSubfolder
        }
        Write-Host "  - $folderName (bude zpracováno)" -ForegroundColor Cyan
    } else {
        Write-Host "  - $folderName (již přestrukturalizováno)" -ForegroundColor Gray
    }
}

if ($foldersToProcess.Count -eq 0) {
    Write-Host "Žádné složky k zpracování!" -ForegroundColor Yellow
    exit 0
}

# Pokud je WhatIf, pouze zobrazí co by se stalo
if ($WhatIf) {
    Write-Host "`nPředhled změn (WhatIf mode):" -ForegroundColor Magenta
    foreach ($folder in $foldersToProcess) {
        Write-Host "  Složka: $($folder.FolderName)" -ForegroundColor White
        Write-Host "    1. Vytvořit: $($folder.TargetSubfolder)" -ForegroundColor Yellow
        Write-Host "    2. Přesunout obsah z: $($folder.OriginalPath)" -ForegroundColor Yellow
        Write-Host "    3. Upravit odkazy v .sln souboru" -ForegroundColor Yellow
        Write-Host ""
    }
    exit 0
}

# Rozdělení na testovací složku a zbytek
$testFolder = $foldersToProcess | Where-Object { $_.FolderName -eq "SunamoArgs" }
$remainingFolders = $foldersToProcess | Where-Object { $_.FolderName -ne "SunamoArgs" }

if ($testFolder) {
    Write-Host "`nNejprve zpracuji testovací složku: SunamoArgs" -ForegroundColor Yellow
    $confirmation = Read-Host "Pokračovat s testovací složkou SunamoArgs? (y/n)"
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-Host "Operace zrušena uživatelem." -ForegroundColor Red
        exit 0
    }
} else {
    Write-Host "`nSunamoArgs nebyla nalezena nebo už je přestrukturalizovaná." -ForegroundColor Yellow
    Write-Host "Chystáte se přestrukturalizovat $($foldersToProcess.Count) složek." -ForegroundColor Yellow
    $confirmation = Read-Host "Pokračovat se všemi složkami? (y/n)"
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-Host "Operace zrušena uživatelem." -ForegroundColor Red
        exit 0
    }
}

# Zpracování testovací složky (SunamoArgs)
$successCount = 0
$errorCount = 0
$processedFolders = @()

if ($testFolder) {
    Write-Host "`n" + "="*60 -ForegroundColor Magenta
    Write-Host "FÁZE 1: TESTOVACÍ ZPRACOVÁNÍ - SunamoArgs" -ForegroundColor Magenta
    Write-Host "="*60 -ForegroundColor Magenta
    
    $folder = $testFolder
    try {
        Write-Host "`nZpracovávám testovací složku: $($folder.FolderName)" -ForegroundColor Green
        
        # 1. Vytvoření nové podsložky
        Write-Host "  Vytvářím podsložku: $($folder.TargetSubfolder)" -ForegroundColor Yellow
        New-Item -Path $folder.TargetSubfolder -ItemType Directory -Force | Out-Null
        
        # 2. Získání všech souborů a složek v původní složce (kromě nově vytvořené)
        $itemsToMove = Get-ChildItem -Path $folder.OriginalPath -Force | Where-Object { 
            $_.FullName -ne $folder.TargetSubfolder 
        }
        
        Write-Host "  Přesouvám $($itemsToMove.Count) položek..." -ForegroundColor Yellow
        
        # 3. Přesun všech položek do nové podsložky
        foreach ($item in $itemsToMove) {
            $destinationPath = Join-Path $folder.TargetSubfolder $item.Name
            Move-Item -Path $item.FullName -Destination $destinationPath -Force
        }
        
        $processedFolders += $folder.FolderName
        $successCount++
        Write-Host "  ✓ Úspěšně zpracováno: $($folder.FolderName)" -ForegroundColor Green
        
    } catch {
        Write-Error "  ✗ Chyba při zpracování složky $($folder.FolderName): $($_.Exception.Message)"
        $errorCount++
    }
    
    # Úprava .sln souboru pro testovací složku
    $slnPath = Join-Path $BaseDirectory "PlatformIndependentNuGetPackages.sln"
    if (Test-Path $slnPath) {
        Write-Host "`nUpravuji .sln soubor pro testovací složku: $slnPath" -ForegroundColor Green
        
        try {
            # Načtení obsahu .sln souboru
            $slnContent = Get-Content -Path $slnPath -Raw
            
            # Vytvoření zálohy
            $backupPath = $slnPath + ".backup_test_" + (Get-Date -Format "yyyyMMdd_HHmmss")
            Copy-Item -Path $slnPath -Destination $backupPath
            Write-Host "  Vytvořena záloha: $backupPath" -ForegroundColor Cyan
            
            # Úprava odkazů na .csproj soubory
            $updatedContent = $slnContent
            $updateCount = 0
            
            foreach ($folderName in $processedFolders) {
                # Původní vzor: "FolderName\FolderName.csproj"
                # Nový vzor: "FolderName\FolderName\FolderName.csproj"
                $oldPattern = """$folderName\\$folderName\.csproj"""
                $newPattern = """$folderName\\$folderName\\$folderName\.csproj"""
                
                if ($updatedContent -match [regex]::Escape($oldPattern)) {
                    $updatedContent = $updatedContent -replace [regex]::Escape($oldPattern), $newPattern
                    $updateCount++
                    Write-Host "  ✓ Aktualizován odkaz pro: $folderName" -ForegroundColor Green
                }
            }
            
            # Zápis upraveného obsahu
            Set-Content -Path $slnPath -Value $updatedContent -Encoding UTF8
            Write-Host "  ✓ .sln soubor úspěšně aktualizován ($updateCount odkazů)" -ForegroundColor Green
            
        } catch {
            Write-Error "  ✗ Chyba při úpravě .sln souboru: $($_.Exception.Message)"
            $errorCount++
        }
    }
    
    # Souhrn testovací fáze
    Write-Host "`n" + "="*60 -ForegroundColor Cyan
    Write-Host "SOUHRN TESTOVACÍ FÁZE" -ForegroundColor Cyan
    Write-Host "="*60 -ForegroundColor Cyan
    Write-Host "Zpracována testovací složka: SunamoArgs" -ForegroundColor Green
    if ($errorCount -eq 0) {
        Write-Host "✓ Test proběhl úspěšně!" -ForegroundColor Green
    } else {
        Write-Host "✗ Během testu došlo k chybě!" -ForegroundColor Red
    }
    
    # Kontrola výsledku
    Write-Host "`nProsím zkontrolujte výsledek:" -ForegroundColor Yellow
    Write-Host "  - Zkontrolujte složku: $($folder.TargetSubfolder)" -ForegroundColor Cyan
    Write-Host "  - Ověřte, že se projekt kompiluje" -ForegroundColor Cyan
    Write-Host "  - Zkontrolujte .sln soubor" -ForegroundColor Cyan
    
    # Potvrzení pokračování
    Write-Host "`nJe vše v pořádku a chcete pokračovat se zbývajícími $($remainingFolders.Count) složkami?" -ForegroundColor Yellow
    $continueConfirmation = Read-Host "Pokračovat se zbytkem? (y/n)"
    
    if ($continueConfirmation -ne 'y' -and $continueConfirmation -ne 'Y') {
        Write-Host "`nOperace zastavena uživatelem po testovací fázi." -ForegroundColor Yellow
        Write-Host "Testovací složka SunamoArgs byla zpracována." -ForegroundColor Green
        exit 0
    }
    
    Write-Host "`n" + "="*60 -ForegroundColor Magenta
    Write-Host "FÁZE 2: ZPRACOVÁNÍ ZBÝVAJÍCÍCH SLOŽEK" -ForegroundColor Magenta
    Write-Host "="*60 -ForegroundColor Magenta
}

# Zpracování zbývajících složek
$foldersToProcessNow = if ($testFolder) { $remainingFolders } else { $foldersToProcess }

foreach ($folder in $foldersToProcessNow) {
    try {
        Write-Host "`nZpracovávám složku: $($folder.FolderName)" -ForegroundColor Green
        
        # 1. Vytvoření nové podsložky
        Write-Host "  Vytvářím podsložku: $($folder.TargetSubfolder)" -ForegroundColor Yellow
        New-Item -Path $folder.TargetSubfolder -ItemType Directory -Force | Out-Null
        
        # 2. Získání všech souborů a složek v původní složce (kromě nově vytvořené)
        $itemsToMove = Get-ChildItem -Path $folder.OriginalPath -Force | Where-Object { 
            $_.FullName -ne $folder.TargetSubfolder 
        }
        
        Write-Host "  Přesouvám $($itemsToMove.Count) položek..." -ForegroundColor Yellow
        
        # 3. Přesun všech položek do nové podsložky
        foreach ($item in $itemsToMove) {
            $destinationPath = Join-Path $folder.TargetSubfolder $item.Name
            Move-Item -Path $item.FullName -Destination $destinationPath -Force
        }
        
        $processedFolders += $folder.FolderName
        $successCount++
        Write-Host "  ✓ Úspěšně zpracováno: $($folder.FolderName)" -ForegroundColor Green
        
    } catch {
        Write-Error "  ✗ Chyba při zpracování složky $($folder.FolderName): $($_.Exception.Message)"
        $errorCount++
    }
}

# Úprava .sln souboru pro zbývající složky (pokud byly nějaké zpracovány)
if ($foldersToProcessNow.Count -gt 0 -and ($processedFolders | Where-Object { $_ -ne "SunamoArgs" }).Count -gt 0) {
    $slnPath = Join-Path $BaseDirectory "PlatformIndependentNuGetPackages.sln"
    if (Test-Path $slnPath) {
        Write-Host "`nUpravuji .sln soubor pro zbývající složky: $slnPath" -ForegroundColor Green
        
        try {
            # Načtení obsahu .sln souboru
            $slnContent = Get-Content -Path $slnPath -Raw
            
            # Vytvoření zálohy (pouze pokud nebyla vytvořena v testovací fázi)
            if (-not $testFolder) {
                $backupPath = $slnPath + ".backup_" + (Get-Date -Format "yyyyMMdd_HHmmss")
                Copy-Item -Path $slnPath -Destination $backupPath
                Write-Host "  Vytvořena záloha: $backupPath" -ForegroundColor Cyan
            }
            
            # Úprava odkazů na .csproj soubory pro zbývající složky
            $updatedContent = $slnContent
            $updateCount = 0
            
            $remainingProcessedFolders = $processedFolders | Where-Object { $_ -ne "SunamoArgs" }
            foreach ($folderName in $remainingProcessedFolders) {
                # Původní vzor: "FolderName\FolderName.csproj"
                # Nový vzor: "FolderName\FolderName\FolderName.csproj"
                $oldPattern = """$folderName\\$folderName\.csproj"""
                $newPattern = """$folderName\\$folderName\\$folderName\.csproj"""
                
                if ($updatedContent -match [regex]::Escape($oldPattern)) {
                    $updatedContent = $updatedContent -replace [regex]::Escape($oldPattern), $newPattern
                    $updateCount++
                    Write-Host "  ✓ Aktualizován odkaz pro: $folderName" -ForegroundColor Green
                }
            }
            
            # Zápis upraveného obsahu
            Set-Content -Path $slnPath -Value $updatedContent -Encoding UTF8
            Write-Host "  ✓ .sln soubor úspěšně aktualizován ($updateCount odkazů)" -ForegroundColor Green
            
        } catch {
            Write-Error "  ✗ Chyba při úpravě .sln souboru: $($_.Exception.Message)"
            $errorCount++
        }
    } else {
        Write-Warning "  .sln soubor nenalezen: $slnPath"
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
    $testProcessed = $processedFolders | Where-Object { $_ -eq "SunamoArgs" }
    $othersProcessed = $processedFolders | Where-Object { $_ -ne "SunamoArgs" }
    
    if ($testProcessed) {
        Write-Host "  TESTOVACÍ FÁZE:" -ForegroundColor Cyan
        Write-Host "    - SunamoArgs" -ForegroundColor Cyan
    }
    
    if ($othersProcessed.Count -gt 0) {
        Write-Host "  HLAVNÍ FÁZE:" -ForegroundColor Cyan
        foreach ($folderName in $othersProcessed) {
            Write-Host "    - $folderName" -ForegroundColor Cyan
        }
    }
}

if ($successCount -gt 0) {
    Write-Host "`nPřestrukturalizace dokončena!" -ForegroundColor Green
    Write-Host "Doporučuji ověřit, že projekt se správně kompiluje." -ForegroundColor Yellow
} else {
    Write-Host "`nŽádné změny nebyly provedeny." -ForegroundColor Yellow
}
