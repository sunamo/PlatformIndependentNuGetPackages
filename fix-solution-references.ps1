# PowerShell skript pro úpravu struktury solutions podle vzoru SunamoArgs
# Vzor: RunnerXxx odkazuje na SunamoXxx.Tests, SunamoXxx.Tests odkazuje na SunamoXxx

param(
    [switch]$WhatIf = $false
)

Write-Host "=== Úprava struktury solutions podle vzoru SunamoArgs ===" -ForegroundColor Green
if ($WhatIf) {
    Write-Host "REŽIM SIMULACE - žádné soubory nebudou upraveny" -ForegroundColor Yellow
}

# Funkce pro bezpečnou úpravu project references
function Update-ProjectReferences {
    param(
        [string]$ProjectPath,
        [string]$ExpectedReference,
        [string]$ProjectType
    )
    
    if (-not (Test-Path $ProjectPath)) {
        Write-Host "    ⚠ Projekt neexistuje: $ProjectPath" -ForegroundColor Red
        return $false
    }
    
    try {
        [xml]$project = Get-Content $ProjectPath -Encoding UTF8
        $modified = $false
        
        # Najdeme všechny ItemGroup prvky
        $itemGroups = $project.Project.ItemGroup
        
        # Odstraníme všechny stávající ProjectReference prvky
        foreach ($itemGroup in $itemGroups) {
            if ($itemGroup.ProjectReference) {
                $referencesToRemove = @()
                foreach ($ref in $itemGroup.ProjectReference) {
                    $referencesToRemove += $ref
                }
                
                foreach ($ref in $referencesToRemove) {
                    $itemGroup.RemoveChild($ref) | Out-Null
                    $modified = $true
                }
                
                # Pokud je ItemGroup prázdná a obsahovala jen ProjectReference, odstraníme ji
                if ($itemGroup.ChildNodes.Count -eq 0) {
                    $project.Project.RemoveChild($itemGroup) | Out-Null
                }
            }
        }
        
        # Přidáme nový ProjectReference do vhodné ItemGroup
        $targetItemGroup = $null
        
        # Najdeme ItemGroup s PackageReference
        foreach ($itemGroup in $project.Project.ItemGroup) {
            if ($itemGroup.PackageReference) {
                $targetItemGroup = $itemGroup
                break
            }
        }
        
        # Pokud nenajdeme ItemGroup s packages, najdeme první ItemGroup
        if (-not $targetItemGroup) {
            foreach ($itemGroup in $project.Project.ItemGroup) {
                $targetItemGroup = $itemGroup
                break
            }
        }
        
        # Pokud neexistuje žádná ItemGroup, vytvoříme novou
        if (-not $targetItemGroup) {
            $targetItemGroup = $project.CreateElement("ItemGroup")
            $project.Project.AppendChild($targetItemGroup) | Out-Null
        }
        
        # Přidáme ProjectReference
        $projectRef = $project.CreateElement("ProjectReference")
        $projectRef.SetAttribute("Include", $ExpectedReference)
        $targetItemGroup.AppendChild($projectRef) | Out-Null
        $modified = $true
        
        if ($modified) {
            if (-not $WhatIf) {
                $project.Save($ProjectPath)
                Write-Host "    ✓ $ProjectType projekt upraven: $ExpectedReference" -ForegroundColor Green
            } else {
                Write-Host "    → $ProjectType projekt by byl upraven: $ExpectedReference" -ForegroundColor Cyan
            }
        }
        
        return $modified
        
    } catch {
        Write-Host "    ✗ Chyba při úpravě $ProjectType projektu: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Získání všech složek začínajících na "Sunamo"
$sunamoFolders = Get-ChildItem -Path "." -Directory | Where-Object { 
    $_.Name -match "^Sunamo[A-Z]" 
}

Write-Host "Nalezeno $($sunamoFolders.Count) Sunamo složek`n" -ForegroundColor Cyan

$processedCount = 0
$successCount = 0

foreach ($folder in $sunamoFolders) {
    $moduleName = $folder.Name
    $solutionPath = Join-Path $folder.FullName "$moduleName.sln"
    
    # Přeskočíme složky bez .sln souboru
    if (-not (Test-Path $solutionPath)) {
        continue
    }
    
    $processedCount++
    Write-Host "[$processedCount] Zpracovávám: $moduleName" -ForegroundColor Yellow
    
    # Definice názvů projektů
    $mainProjectName = $moduleName
    $testProjectName = "$moduleName.Tests"
    $runnerProjectName = "Runner$($moduleName.Substring(6))"  # SunamoXxx -> RunnerXxx
    
    # Cesty k projektům
    $mainProjectPath = Join-Path $folder.FullName "$mainProjectName\$mainProjectName.csproj"
    $testProjectPath = Join-Path $folder.FullName "$testProjectName\$testProjectName.csproj"
    $runnerProjectPath = Join-Path $folder.FullName "$runnerProjectName\$runnerProjectName.csproj"
    
    # Kontrola existence projektů
    $mainExists = Test-Path $mainProjectPath
    $testExists = Test-Path $testProjectPath
    $runnerExists = Test-Path $runnerProjectPath
    
    Write-Host "  Nalezené projekty:"
    Write-Host "    $($mainExists ? '✓' : '✗') $mainProjectName" -ForegroundColor ($mainExists ? 'Green' : 'Red')
    Write-Host "    $($testExists ? '✓' : '✗') $testProjectName" -ForegroundColor ($testExists ? 'Green' : 'Red')
    Write-Host "    $($runnerExists ? '✓' : '✗') $runnerProjectName" -ForegroundColor ($runnerExists ? 'Green' : 'Red')
    
    # Pokud máme všechny 3 projekty, upravíme odkazy podle vzoru
    if ($mainExists -and $testExists -and $runnerExists) {
        Write-Host "  Upravuji project references..." -ForegroundColor Cyan
        
        $success = $true
        
        # 1. RunnerXxx má odkazovat na SunamoXxx.Tests
        $runnerRef = "..\$testProjectName\$testProjectName.csproj"
        if (-not (Update-ProjectReferences -ProjectPath $runnerProjectPath -ExpectedReference $runnerRef -ProjectType "Runner")) {
            $success = $false
        }
        
        # 2. SunamoXxx.Tests má odkazovat na SunamoXxx
        $testRef = "..\$mainProjectName\$mainProjectName.csproj"
        if (-not (Update-ProjectReferences -ProjectPath $testProjectPath -ExpectedReference $testRef -ProjectType "Test")) {
            $success = $false
        }
        
        if ($success) {
            $successCount++
            Write-Host "  ✅ Úspěšně upraven!" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Úprava se nezdařila!" -ForegroundColor Red
        }
        
    } else {
        Write-Host "  ⚠ Neúplná struktura projektů - přeskakuji" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

Write-Host "=== SHRNUTÍ ===" -ForegroundColor Green
Write-Host "Zpracováno solutions: $processedCount" -ForegroundColor White
Write-Host "Úspěšně upraveno: $successCount" -ForegroundColor Green
Write-Host "Přeskočeno/chyby: $($processedCount - $successCount)" -ForegroundColor $(if ($processedCount -eq $successCount) { 'Green' } else { 'Yellow' })

if ($WhatIf) {
    Write-Host "`n💡 Pro skutečné provedení spusťte skript bez parametru -WhatIf" -ForegroundColor Yellow
} else {
    Write-Host "`n💡 Doporučuji zkontrolovat změny a otestovat kompilaci projektů" -ForegroundColor Yellow
}

Write-Host "`n🎯 Vzor referencí:" -ForegroundColor Cyan
Write-Host "   RunnerXxx → SunamoXxx.Tests → SunamoXxx" -ForegroundColor White
