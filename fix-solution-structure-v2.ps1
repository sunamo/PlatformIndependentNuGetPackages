# PowerShell skript pro úpravu struktury solutions podle vzoru SunamoArgs
# Vzor: RunnerXxx -> SunamoXxx.Tests -> SunamoXxx (všechny v jedné solution)

param(
    [switch]$WhatIf = $false
)

Write-Host "Začínám úpravu struktury solutions..." -ForegroundColor Green
if ($WhatIf) {
    Write-Host "REŽIM SIMULACE - žádné soubory nebudou upraveny" -ForegroundColor Yellow
}

# Funkce pro úpravu XML obsahu
function Update-ProjectReference {
    param(
        [string]$FilePath,
        [string]$NewReference,
        [string]$ProjectType
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "    ⚠ Soubor neexistuje: $FilePath" -ForegroundColor Red
        return $false
    }
    
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $modified = $false
    
    # Odstraníme všechny ProjectReference prvky
    $originalContent = $content
    $content = $content -replace '<ProjectReference[^>]*Include="[^"]*"[^/>]*/?>\s*', ''
    
    if ($content -ne $originalContent) {
        $modified = $true
        Write-Host "    - Odstraněny stávající ProjectReference odkazy" -ForegroundColor Gray
    }
    
    # Přidáme nový ProjectReference
    if ($content -notmatch [regex]::Escape($NewReference)) {
        # Najdeme vhodné místo pro vložení (před posledním </ItemGroup> nebo před PropertyGroup)
        if ($content -match '(\s*)<PackageReference[^>]*Microsoft\.Extensions\.Logging\.Abstractions[^>]*>\s*\n(\s*)</ItemGroup>') {
            $indent = $matches[2]
            $replacement = $matches[0] -replace '(</ItemGroup>)', "    <ProjectReference Include=`"$NewReference`" />`n$indent</ItemGroup>"
            $content = $content -replace [regex]::Escape($matches[0]), $replacement
            $modified = $true
        } elseif ($content -match '(\s*)</ItemGroup>\s*\n(\s*)<PropertyGroup') {
            $indent = $matches[1]
            $replacement = "$indent  <ProjectReference Include=`"$NewReference`" />`n$indent</ItemGroup>`n$($matches[2])<PropertyGroup"
            $content = $content -replace '(\s*)</ItemGroup>\s*\n(\s*)<PropertyGroup', $replacement
            $modified = $true
        }
        
        if ($modified) {
            Write-Host "    + Přidán odkaz: $NewReference" -ForegroundColor Green
        }
    }
    
    if ($modified -and -not $WhatIf) {
        Set-Content -Path $FilePath -Value $content -Encoding UTF8
        Write-Host "    ✓ Uložen soubor: $FilePath" -ForegroundColor Green
    }
    
    return $modified
}

# Získání všech složek s .sln soubory
$solutionDirs = Get-ChildItem -Path "." -Directory | Where-Object { 
    $_.Name -match "^Sunamo[A-Z]" -and 
    (Test-Path (Join-Path $_.FullName "$($_.Name).sln")) 
}

Write-Host "Nalezeno $($solutionDirs.Count) solution složek`n" -ForegroundColor Cyan

foreach ($solutionDir in $solutionDirs) {
    $moduleName = $solutionDir.Name
    $solutionPath = Join-Path $solutionDir.FullName "$moduleName.sln"
    
    Write-Host "Zpracovávám: $moduleName" -ForegroundColor Yellow
    
    # Definice očekávaných projektů
    $mainProjectName = $moduleName
    $testProjectName = "$moduleName.Tests"
    $runnerProjectName = "Runner$($moduleName.Substring(6))"  # SunamoXxx -> RunnerXxx
    
    # Cesty k projektům
    $mainProjectPath = Join-Path $solutionDir.FullName "$mainProjectName\$mainProjectName.csproj"
    $testProjectPath = Join-Path $solutionDir.FullName "$testProjectName\$testProjectName.csproj"
    $runnerProjectPath = Join-Path $solutionDir.FullName "$runnerProjectName\$runnerProjectName.csproj"
    
    # Kontrola existence projektů
    $mainExists = Test-Path $mainProjectPath
    $testExists = Test-Path $testProjectPath
    $runnerExists = Test-Path $runnerProjectPath
    
    Write-Host "  Projekty:"
    Write-Host "    Main: $($mainExists ? '✓' : '✗') $mainProjectName" -ForegroundColor ($mainExists ? 'Green' : 'Red')
    Write-Host "    Test: $($testExists ? '✓' : '✗') $testProjectName" -ForegroundColor ($testExists ? 'Green' : 'Red')
    Write-Host "    Runner: $($runnerExists ? '✓' : '✗') $runnerProjectName" -ForegroundColor ($runnerExists ? 'Green' : 'Red')
    
    # Pokud všechny 3 projekty existují, upravíme odkazy
    if ($mainExists -and $testExists -and $runnerExists) {
        Write-Host "  Upravuji odkazy..." -ForegroundColor Cyan
        
        # 1. Runner -> Tests
        $runnerModified = Update-ProjectReference -FilePath $runnerProjectPath -NewReference "..\$testProjectName\$testProjectName.csproj" -ProjectType "Runner"
        
        # 2. Tests -> Main
        $testModified = Update-ProjectReference -FilePath $testProjectPath -NewReference "..\$mainProjectName\$mainProjectName.csproj" -ProjectType "Test"
        
        if ($runnerModified -or $testModified) {
            Write-Host "  ✓ Odkazy upraveny" -ForegroundColor Green
        } else {
            Write-Host "  - Odkazy už jsou správně nastavené" -ForegroundColor Gray
        }
        
    } else {
        Write-Host "  ⚠ Chybí některé projekty, přeskakuji..." -ForegroundColor Yellow
    }
    
    Write-Host ""
}

Write-Host "Úprava dokončena!" -ForegroundColor Green

if ($WhatIf) {
    Write-Host "`nPro skutečné provedení spusťte skript bez parametru -WhatIf" -ForegroundColor Yellow
} else {
    Write-Host "`nDoporučuji zkontrolovat změny v Git a otestovat kompilaci projektů." -ForegroundColor Yellow
}
