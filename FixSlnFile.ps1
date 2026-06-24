# PowerShell skript pro opravu .sln souboru - přidání chybějících projektů
# Autor: GitHub Copilot  
# Datum: 30.7.2025

param(
    [string]$SlnPath = "E:\vs3\PlatformIndependentNuGetPackages\SunamoAsync\SunamoAsync.sln",
    [string]$ProjectName = "SunamoAsync"
)

Write-Host "Opravuji .sln soubor: $SlnPath" -ForegroundColor Green

# Kontrola existence .sln souboru
if (-not (Test-Path $SlnPath)) {
    Write-Error ".sln soubor neexistuje: $SlnPath"
    exit 1
}

# Kontrola existence .csproj souboru
$slnDir = Split-Path $SlnPath -Parent
$csprojPath = Join-Path $slnDir "$ProjectName\$ProjectName.csproj"

# Pokud hlavní cesta neexistuje, zkusíme vnořenou strukturu
if (-not (Test-Path $csprojPath)) {
    $csprojPath = Join-Path $slnDir "$ProjectName\$ProjectName\$ProjectName.csproj"
    if (-not (Test-Path $csprojPath)) {
        $standardPath = Join-Path $slnDir "$ProjectName\$ProjectName.csproj"
        Write-Error ".csproj soubor neexistuje ani v: $standardPath ani v: $csprojPath"
        exit 1
    }
    $projectRelativePath = "$ProjectName\$ProjectName\$ProjectName.csproj"
    Write-Host "Použiji vnořenou strukturu: $projectRelativePath" -ForegroundColor Cyan
} else {
    $projectRelativePath = "$ProjectName\$ProjectName.csproj"
    Write-Host "Použiji standardní strukturu: $projectRelativePath" -ForegroundColor Cyan
}

try {
    # Načtení obsahu .sln souboru
    $slnContent = Get-Content -Path $SlnPath -Raw
    
    # Vytvoření zálohy
    $backupPath = $SlnPath + ".backup_fix_" + (Get-Date -Format "yyyyMMdd_HHmmss")
    Copy-Item -Path $SlnPath -Destination $backupPath
    Write-Host "Vytvořena záloha: $backupPath" -ForegroundColor Cyan
    
    $updatedContent = $slnContent
    # Odstranění duplicitních a nesprávných záznamů projektů
    Write-Host "Kontroluji duplicitní a nesprávné záznamy..." -ForegroundColor Yellow
    
    # Najdeme všechny řádky s Project pro tento projekt
    $projectLines = @()
    $lines = $updatedContent -split "`r`n"
    $linesToRemove = @()
    $correctProjectGuid = $null
    
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
                    Write-Host "    Nalezen správný hlavní projekt '$projectName' s GUID: $projectGuid" -ForegroundColor Green
                } else {
                    Write-Host "    Nalezen nesprávný hlavní projekt '$projectName' s cestou '$projectPath' (bude odstraněn)" -ForegroundColor Red
                    $linesToRemove += $i
                    # Také najdeme a označíme EndProject
                    if ($i + 1 -lt $lines.Count -and $lines[$i + 1] -eq "EndProject") {
                        $linesToRemove += ($i + 1)
                    }
                }
            } elseif ($projectInfo.IsTestProject) {
                # Test projekty zachováváme
                $projectInfo.IsCorrect = $true
                Write-Host "    Nalezen test projekt '$projectName' s GUID: $projectGuid (zachováváme)" -ForegroundColor Cyan
            } else {
                # Všechny ostatní projekty také zachováváme (RunnerAsync, apod.)
                $projectInfo.IsCorrect = $true
                $projectInfo.IsOtherProject = $true
                Write-Host "    Nalezen jiný projekt '$projectName' s GUID: $projectGuid (zachováváme)" -ForegroundColor Cyan
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
        Write-Host "Přidávám chybějící hlavní projekt..." -ForegroundColor Yellow
        
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
            Write-Host "✓ Přidán hlavní projekt do .sln souboru s cestou: $projectRelativePath" -ForegroundColor Green
        } else {
            Write-Warning "Nepodařilo se najít Global sekci v .sln souboru"
        }
    } else {
        Write-Host "Správný hlavní projekt již existuje v .sln souboru" -ForegroundColor Green
    }
    
    # Vyčištění ProjectConfigurationPlatforms od všech nesprávných GUID
    Write-Host "Čistím ProjectConfigurationPlatforms..." -ForegroundColor Yellow
    
    # Najdeme všechny GUID projektů, které skutečně existují v .sln
    $validGuids = @()
    foreach ($projectInfo in $projectLines) {
        if ($projectInfo.IsCorrect) {
            $validGuids += $projectInfo.Guid
        }
    }
    
    Write-Host "Nalezené platné GUID: $($validGuids -join ', ')" -ForegroundColor Cyan
    
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
                Write-Host "    ✓ Označen k odstranění neplatný konfigurační řádek: $($line.Trim())" -ForegroundColor Yellow
            }
        }
    }
    
    # Odstranění konfiguračních řádků (zpětně)
    $configLinesToRemove = $configLinesToRemove | Sort-Object -Descending -Unique
    foreach ($lineIndex in $configLinesToRemove) {
        if ($lineIndex -lt $lines.Count) {
            $lines = $lines[0..($lineIndex-1)] + $lines[($lineIndex+1)..($lines.Count-1)]
            $changesMade++
            Write-Host "    ✓ Odstraněn neplatný konfigurační řádek" -ForegroundColor Green
        }
    }
    
    $updatedContent = $lines -join "`r`n"
    
    # Oprava relativních cest (pokud jsou špatné)
    $oldPattern1 = """\.\.\\\.\.\\\.\.\\PlatformIndependentNuGetPackages\\$ProjectName\\$ProjectName\\$ProjectName\.csproj"""
    $oldPattern2 = """\.\.\\\.\.\\\.\.\\PlatformIndependentNuGetPackages\\$ProjectName\\$ProjectName\.csproj"""
    $newPattern = """$([regex]::Escape($projectRelativePath))"""
    
    if ($updatedContent -match $oldPattern1) {
        $updatedContent = $updatedContent -replace $oldPattern1, """$projectRelativePath"""
        $changesMade++
        Write-Host "✓ Opravena relativní cesta (vnořená struktura)" -ForegroundColor Green
    }
    
    if ($updatedContent -match $oldPattern2) {
        $updatedContent = $updatedContent -replace $oldPattern2, """$projectRelativePath"""
        $changesMade++
        Write-Host "✓ Opravena relativní cesta (původní struktura)" -ForegroundColor Green
    }
    
    # Zápis upraveného obsahu
    if ($changesMade -gt 0) {
        Set-Content -Path $SlnPath -Value $updatedContent -Encoding UTF8
        Write-Host "✓ .sln soubor byl aktualizován ($changesMade změn)" -ForegroundColor Green
    } else {
        Write-Host "Žádné změny nebyly potřeba" -ForegroundColor Yellow
    }
    
} catch {
    Write-Error "Chyba při zpracování .sln souboru: $($_.Exception.Message)"
    exit 1
}

Write-Host "Hotovo!" -ForegroundColor Green
