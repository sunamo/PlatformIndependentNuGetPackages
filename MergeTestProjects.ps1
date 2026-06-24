# PowerShell skript pro sloučení test složek s hlavními projekty - OPRAVENÁ VERZE
# Autor: GitHub Copilot  
# Datum: 30.7.2025

param(
    [string]$MainDirectory = "E:\vs3\PlatformIndependentNuGetPackages",
    [string]$TestDirectory = "E:\vs3\_ut2\PlatformIndependentNuGetPackages.Tests",
    [switch]$WhatIf = $false
)

Write-Host "=== OPRAVENÁ VERZE - Sloučení test projektů s hlavními projekty ===" -ForegroundColor Green
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

# Získání seznamu složek
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
            TargetPath = $mainFolder.FullName
        }
    }
}

Write-Host "Nalezeno $($commonFolders.Count) společných složek k zpracování" -ForegroundColor Yellow

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
            Write-Host "    ✓ Složka je přestrukturalizovaná" -ForegroundColor Green
            Write-Host "    1. Přesunout obsah z: $($folder.TestPath)" -ForegroundColor Yellow
            Write-Host "    2. Cíl: $($folder.TargetPath)" -ForegroundColor Yellow
        } else {
            Write-Host "    ✗ Složka NENÍ přestrukturalizovaná: $innerFolderPath" -ForegroundColor Red
            Write-Host "    => BUDE PŘESKOČENA" -ForegroundColor Red
        }
        Write-Host ""
    }
    exit 0
}

# Funkce pro opravu .sln souboru - KOMPLETNĚ PŘEPSANÁ
function Fix-SlnFile {
    param(
        [string]$SlnPath,
        [string]$ProjectName
    )
    
    try {
        Write-Host "    Opravuji .sln soubor: $SlnPath" -ForegroundColor Yellow
        
        # Načtení obsahu
        $content = Get-Content -Path $SlnPath -Raw
        if (-not $content) {
            Write-Warning "    .sln soubor je prázdný nebo neexistuje"
            return
        }
        
        # Vytvoření zálohy
        $backupPath = $SlnPath + ".backup_fix_" + (Get-Date -Format "yyyyMMdd_HHmmss")
        Copy-Item -Path $SlnPath -Destination $backupPath
        Write-Host "    Záloha vytvořena: $backupPath" -ForegroundColor Cyan
        
        # Analýza existujících projektů
        $lines = $content -split "`r`n"
        $projectsToKeep = @()
        $projectsToRemove = @()
        $needsMainProject = $true
        
        # Projdeme všechny Project řádky
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            if ($line -match 'Project\([^)]+\)\s*=\s*"([^"]+)",\s*"([^"]+)",\s*"(\{[A-F0-9-]+\})"') {
                $projectDisplayName = $matches[1]
                $projectPath = $matches[2]
                $projectGuid = $matches[3]
                
                # Určení typu projektu
                $isMainProject = $projectDisplayName -eq $ProjectName -and $projectPath -eq "$ProjectName\$ProjectName.csproj"
                $isTestProject = $projectDisplayName.EndsWith(".Tests") -or $projectPath.Contains(".Tests")
                $isRunnerProject = $projectDisplayName.StartsWith("Runner") -and -not $projectDisplayName.EndsWith(".Tests")
                
                if ($isMainProject) {
                    Write-Host "    ✓ Nalezen správný hlavní projekt: $projectDisplayName" -ForegroundColor Green
                    $needsMainProject = $false
                    $projectsToKeep += @{
                        Line = $line
                        EndProjectLine = if ($i + 1 -lt $lines.Count -and $lines[$i + 1] -eq "EndProject") { $lines[$i + 1] } else { "EndProject" }
                        Guid = $projectGuid
                        Type = "Main"
                    }
                } elseif ($isTestProject) {
                    Write-Host "    ✓ Zachovávám test projekt: $projectDisplayName" -ForegroundColor Cyan
                    $projectsToKeep += @{
                        Line = $line
                        EndProjectLine = if ($i + 1 -lt $lines.Count -and $lines[$i + 1] -eq "EndProject") { $lines[$i + 1] } else { "EndProject" }
                        Guid = $projectGuid
                        Type = "Test"
                    }
                } elseif ($isRunnerProject) {
                    Write-Host "    ✓ Zachovávám Runner projekt: $projectDisplayName" -ForegroundColor Cyan
                    $projectsToKeep += @{
                        Line = $line
                        EndProjectLine = if ($i + 1 -lt $lines.Count -and $lines[$i + 1] -eq "EndProject") { $lines[$i + 1] } else { "EndProject" }
                        Guid = $projectGuid
                        Type = "Runner"
                    }
                } else {
                    Write-Host "    ✗ Odstraňujem nesprávný projekt: $projectDisplayName (cesta: $projectPath)" -ForegroundColor Red
                    $projectsToRemove += @{
                        Line = $line
                        EndProjectLine = if ($i + 1 -lt $lines.Count -and $lines[$i + 1] -eq "EndProject") { $lines[$i + 1] } else { "EndProject" }
                        Guid = $projectGuid
                    }
                }
            }
        }
        
        # Vytvoření nového obsahu
        $newContent = @()
        $skipNext = $false
        
        # Hlavička
        $newContent += "Microsoft Visual Studio Solution File, Format Version 12.00"
        $newContent += "# Visual Studio Version 17"
        $newContent += "VisualStudioVersion = 17.0.31903.59"
        $newContent += "MinimumVisualStudioVersion = 10.0.40219.1"
        
        # Přidání hlavního projektu pokud chybí
        if ($needsMainProject) {
            $mainGuid = "{" + [System.Guid]::NewGuid().ToString().ToUpper() + "}"
            $newContent += "Project(`"{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}`") = `"$ProjectName`", `"$ProjectName\$ProjectName.csproj`", `"$mainGuid`""
            $newContent += "EndProject"
            Write-Host "    ✓ Přidán chybějící hlavní projekt: $ProjectName" -ForegroundColor Green
            
            # Přidáme do seznamu pro konfiguraci
            $projectsToKeep += @{
                Guid = $mainGuid
                Type = "Main"
            }
        }
        
        # Přidání zachovaných projektů
        foreach ($project in $projectsToKeep) {
            if ($project.Line) {
                $newContent += $project.Line
                $newContent += $project.EndProjectLine
            }
        }
        
        # Global sekce
        $newContent += "Global"
        $newContent += "`tGlobalSection(SolutionConfigurationPlatforms) = preSolution"
        $newContent += "`t`tDebug|Any CPU = Debug|Any CPU"
        $newContent += "`t`tRelease|Any CPU = Release|Any CPU"
        $newContent += "`tEndGlobalSection"
        
        # Projektové konfigurace
        $newContent += "`tGlobalSection(ProjectConfigurationPlatforms) = postSolution"
        foreach ($project in $projectsToKeep) {
            $guid = $project.Guid
            $newContent += "`t`t$guid.Debug|Any CPU.ActiveCfg = Debug|Any CPU"
            $newContent += "`t`t$guid.Debug|Any CPU.Build.0 = Debug|Any CPU"
            $newContent += "`t`t$guid.Release|Any CPU.ActiveCfg = Release|Any CPU"
            $newContent += "`t`t$guid.Release|Any CPU.Build.0 = Release|Any CPU"
        }
        $newContent += "`tEndGlobalSection"
        
        # Závěrečné sekce
        $newContent += "`tGlobalSection(SolutionProperties) = preSolution"
        $newContent += "`t`tHideSolutionNode = FALSE"
        $newContent += "`tEndGlobalSection"
        $newContent += "`tGlobalSection(ExtensibilityGlobals) = postSolution"
        $newContent += "`t`tSolutionGuid = {D1DF5167-A1CE-49FB-B2F1-8E51306E4286}"
        $newContent += "`tEndGlobalSection"
        $newContent += "EndGlobal"
        
        # Zápis nového obsahu
        $finalContent = $newContent -join "`r`n"
        Set-Content -Path $SlnPath -Value $finalContent -Encoding UTF8
        
        Write-Host "    ✓ .sln soubor byl úspěšně opraven" -ForegroundColor Green
        Write-Host "    - Zachované projekty: $($projectsToKeep.Count)" -ForegroundColor Cyan
        Write-Host "    - Odstraněné projekty: $($projectsToRemove.Count)" -ForegroundColor Cyan
        
    } catch {
        Write-Error "    ✗ Chyba při opravě .sln souboru: $($_.Exception.Message)"
    }
}

# Zpracování složek
$successCount = 0
$errorCount = 0
$skippedCount = 0
$processedFolders = @()

Write-Host "`n" + "="*60 -ForegroundColor Magenta
Write-Host "ZPRACOVÁNÍ SLOŽEK" -ForegroundColor Magenta
Write-Host "="*60 -ForegroundColor Magenta

foreach ($folder in $commonFolders) {
    try {
        Write-Host "`n📁 Zpracovávám: $($folder.Name)" -ForegroundColor Green
        
        # KRITICKÁ KONTROLA: Je hlavní složka přestrukturalizovaná?
        $innerFolderPath = Join-Path $folder.MainPath $folder.Name
        if (-not (Test-Path $innerFolderPath)) {
            Write-Warning "  ⚠️  Složka $($folder.Name) není přestrukturalizovaná (chybí $innerFolderPath)"
            Write-Host "      => PŘESKAKUJI..." -ForegroundColor Yellow
            $skippedCount++
            continue
        }
        
        Write-Host "  ✓ Složka je přestrukturalizovaná" -ForegroundColor Green
        
        # 1. Přesun obsahu z test složky do hlavní složky
        Write-Host "  📦 Přesouvám obsah z test složky..." -ForegroundColor Yellow
        
        $testItems = Get-ChildItem -Path $folder.TestPath -Force -ErrorAction SilentlyContinue
        $movedItems = 0
        
        foreach ($item in $testItems) {
            $destinationPath = Join-Path $folder.TargetPath $item.Name
            
            # Pokud cíl již existuje
            if (Test-Path $destinationPath) {
                if ($item.PSIsContainer) {
                    Write-Host "    ⚠️  Složka $($item.Name) již existuje, přeskakuji..." -ForegroundColor Yellow
                    continue
                } else {
                    # Pro soubory vytvoříme backup
                    $backupPath = $destinationPath + ".backup_" + (Get-Date -Format "yyyyMMdd_HHmmss")
                    Move-Item -Path $destinationPath -Destination $backupPath -Force
                    Write-Host "    📄 Záloha souboru: $($item.Name)" -ForegroundColor Cyan
                }
            }
            
            Move-Item -Path $item.FullName -Destination $destinationPath -Force
            Write-Host "    ✅ Přesunut: $($item.Name)" -ForegroundColor Green
            $movedItems++
        }
        
        Write-Host "  ✓ Přesunuto $movedItems položek" -ForegroundColor Green
        
        # 2. Přesun .git složky z vnořené složky do hlavní složky
        $gitSourcePath = Join-Path $innerFolderPath ".git"
        $gitTargetPath = Join-Path $folder.TargetPath ".git"
        
        if (Test-Path $gitSourcePath) {
            Write-Host "  🔧 Přesouvám .git složku..." -ForegroundColor Yellow
            
            # Pokud už .git existuje v cíli, vytvoř zálohu
            if (Test-Path $gitTargetPath) {
                $gitBackupPath = $gitTargetPath + ".backup_" + (Get-Date -Format "yyyyMMdd_HHmmss")
                Move-Item -Path $gitTargetPath -Destination $gitBackupPath -Force
                Write-Host "    📁 Záloha .git složky vytvořena" -ForegroundColor Cyan
            }
            
            Move-Item -Path $gitSourcePath -Destination $gitTargetPath -Force
            Write-Host "  ✅ .git složka přesunuta" -ForegroundColor Green
        }
        
        # 3. Úprava .sln souborů
        $slnFiles = Get-ChildItem -Path $folder.TargetPath -Filter "*.sln" -ErrorAction SilentlyContinue
        foreach ($slnFile in $slnFiles) {
            Write-Host "  🔧 Upravuji .sln soubor: $($slnFile.Name)" -ForegroundColor Yellow
            Fix-SlnFile -SlnPath $slnFile.FullName -ProjectName $folder.Name
        }
        
        $processedFolders += $folder.Name
        $successCount++
        Write-Host "  ✅ Úspěšně zpracováno: $($folder.Name)" -ForegroundColor Green
        
        # Zastavení u SunamoAttributes
        if ($folder.Name -eq "SunamoAttributes") {
            Write-Host "`n" + "="*60 -ForegroundColor Red
            Write-Host "🛑 ZASTAVENÍ U SUNAMOATTRIBUTES" -ForegroundColor Red
            Write-Host "="*60 -ForegroundColor Red
            break
        }
        
    } catch {
        Write-Error "  ❌ Chyba při zpracování složky $($folder.Name): $($_.Exception.Message)"
        $errorCount++
    }
}

# Finální souhrn
Write-Host "`n" + "="*60 -ForegroundColor White
Write-Host "📊 FINÁLNÍ SOUHRN" -ForegroundColor White
Write-Host "="*60 -ForegroundColor White
Write-Host "✅ Úspěšně zpracováno: $successCount složek" -ForegroundColor Green
Write-Host "⚠️  Přeskočeno: $skippedCount složek (nepřestrukturalizované)" -ForegroundColor Yellow
Write-Host "❌ Chyby: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { "Green" } else { "Red" })

if ($processedFolders.Count -gt 0) {
    Write-Host "`n📁 Zpracované složky:" -ForegroundColor Yellow
    foreach ($folderName in $processedFolders) {
        Write-Host "    ✓ $folderName" -ForegroundColor Green
    }
}

$remainingFolders = $commonFolders | Where-Object { $_.Name -notin $processedFolders }
if ($remainingFolders.Count -gt 0) {
    Write-Host "`n📋 Nezpracované složky:" -ForegroundColor Yellow
    foreach ($folder in $remainingFolders) {
        Write-Host "    ⏳ $($folder.Name)" -ForegroundColor Yellow
    }
}

if ($successCount -gt 0) {
    Write-Host "`n🎉 Sloučení dokončeno!" -ForegroundColor Green
    Write-Host "💡 Doporučuji ověřit, že projekty se správně kompilují." -ForegroundColor Yellow
} else {
    Write-Host "`n⚠️  Žádné změny nebyly provedeny." -ForegroundColor Yellow
}
