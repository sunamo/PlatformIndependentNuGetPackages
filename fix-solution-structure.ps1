# PowerShell skript pro úpravu struktury solutions podle vzoru SunamoArgs
# Vzor: RunnerXxx -> SunamoXxx.Tests -> SunamoXxx (všechny v jedné solution)

Write-Host "Začínám úpravu struktury solutions..." -ForegroundColor Green

# Získání všech .sln souborů
$solutionFiles = Get-ChildItem -Path "." -Filter "*.sln" -Recurse | Where-Object { $_.Directory.Name -notmatch "^Sunamo.*\.Tests$" }

foreach ($solutionFile in $solutionFiles) {
    $solutionDir = $solutionFile.Directory.FullName
    $moduleName = $solutionFile.BaseName
    
    Write-Host "`nZpracovávám solution: $moduleName" -ForegroundColor Yellow
    
    # Definice očekávaných projektů
    $mainProject = "$moduleName\$moduleName.csproj"
    $testProject = "$moduleName.Tests\$moduleName.Tests.csproj"
    $runnerProject = "Runner$($moduleName.Substring(6))\Runner$($moduleName.Substring(6)).csproj"  # SunamoXxx -> RunnerXxx
    
    # Cesty k projektům
    $mainProjectPath = Join-Path $solutionDir $mainProject
    $testProjectPath = Join-Path $solutionDir $testProject
    $runnerProjectPath = Join-Path $solutionDir $runnerProject
    
    Write-Host "  Kontrolujem existenci projektů:"
    Write-Host "    Main: $(Test-Path $mainProjectPath) - $mainProjectPath"
    Write-Host "    Test: $(Test-Path $testProjectPath) - $testProjectPath"
    Write-Host "    Runner: $(Test-Path $runnerProjectPath) - $runnerProjectPath"
    
    # Pokud všechny 3 projekty existují, upravíme je
    if ((Test-Path $mainProjectPath) -and (Test-Path $testProjectPath) -and (Test-Path $runnerProjectPath)) {
        Write-Host "  Všechny projekty nalezeny, upravuji odkazy..." -ForegroundColor Cyan
        
        # 1. Úprava RunnerXxx.csproj - má odkazovat na SunamoXxx.Tests.csproj
        $runnerContent = Get-Content $runnerProjectPath -Raw
        
        # Odstraníme stávající ProjectReference odkazy
        $runnerContent = $runnerContent -replace '<ProjectReference[^>]*Include="[^"]*\.csproj"[^/>]*/?>', ''
        
        # Najdeme ItemGroup s PackageReference a přidáme ProjectReference
        if ($runnerContent -match '(\s*)<ItemGroup>\s*\n(\s*)<PackageReference[^>]*Microsoft\.Extensions\.Logging\.Abstractions[^>]*>\s*\n(\s*)</ItemGroup>') {
            $indent = $matches[1]
            $replacement = "$($matches[0])`n$indent  <ProjectReference Include=`"..\$moduleName.Tests\$moduleName.Tests.csproj`" />"
            $runnerContent = $runnerContent -replace [regex]::Escape($matches[0]), $replacement
        } elseif ($runnerContent -match '(\s*)<ItemGroup>\s*\n[^<]*<PackageReference[^>]*>\s*\n(\s*)</ItemGroup>') {
            $indent = $matches[1]
            $replacement = $matches[0] -replace '(</ItemGroup>)', "$indent  <ProjectReference Include=`"..\$moduleName.Tests\$moduleName.Tests.csproj`" />`n$indent</ItemGroup>"
            $runnerContent = $runnerContent -replace [regex]::Escape($matches[0]), $replacement
        } else {
            # Pokud nenajdeme vhodné místo, přidáme nový ItemGroup
            $runnerContent = $runnerContent -replace '(\s*)<PropertyGroup Condition', "  <ItemGroup>`n    <ProjectReference Include=`"..\$moduleName.Tests\$moduleName.Tests.csproj`" />`n    <PackageReference Include=`"Microsoft.Extensions.Logging.Abstractions`" Version=`"*`" Pack=`"True`" />`n  </ItemGroup>`n$1<PropertyGroup Condition"
        }
        
        Set-Content -Path $runnerProjectPath -Value $runnerContent -Encoding UTF8
        Write-Host "    ✓ Upraven Runner projekt" -ForegroundColor Green
        
        # 2. Úprava SunamoXxx.Tests.csproj - má odkazovat na SunamoXxx.csproj
        $testContent = Get-Content $testProjectPath -Raw
        
        # Zkontrolujeme, jestli už má správný odkaz
        if ($testContent -notmatch "<ProjectReference[^>]*Include=`"\.\.\$moduleName\\$moduleName\.csproj`"") {
            # Odstraníme stávající ProjectReference odkazy na hlavní projekt
            $testContent = $testContent -replace '<ProjectReference[^>]*Include="[^"]*\\' + $moduleName + '\.csproj"[^/>]*/?>', ''
            
            # Přidáme správný odkaz
            if ($testContent -match '(\s*)</ItemGroup>\s*\n(\s*)<PropertyGroup Condition') {
                $indent = $matches[1]
                $replacement = "$indent  <ProjectReference Include=`"..\$moduleName\$moduleName.csproj`" />`n$indent</ItemGroup>`n$($matches[2])<PropertyGroup Condition"
                $testContent = $testContent -replace '(\s*)</ItemGroup>\s*\n(\s*)<PropertyGroup Condition', $replacement
            }
            
            Set-Content -Path $testProjectPath -Value $testContent -Encoding UTF8
            Write-Host "    ✓ Upraven Test projekt" -ForegroundColor Green
        } else {
            Write-Host "    - Test projekt už má správný odkaz" -ForegroundColor Gray
        }
        
        # 3. Kontrola solution souboru - musí obsahovat všechny 3 projekty
        $solutionContent = Get-Content $solutionFile.FullName -Raw
        
        $projectsToAdd = @()
        
        # Kontrola hlavního projektu
        if ($solutionContent -notmatch [regex]::Escape($mainProject)) {
            $projectsToAdd += @{
                Name = $moduleName
                Path = $mainProject
                Guid = [System.Guid]::NewGuid().ToString().ToUpper()
            }
        }
        
        # Kontrola test projektu
        if ($solutionContent -notmatch [regex]::Escape($testProject)) {
            $projectsToAdd += @{
                Name = "$moduleName.Tests"
                Path = $testProject
                Guid = [System.Guid]::NewGuid().ToString().ToUpper()
            }
        }
        
        # Kontrola runner projektu
        if ($solutionContent -notmatch [regex]::Escape($runnerProject)) {
            $projectsToAdd += @{
                Name = "Runner$($moduleName.Substring(6))"
                Path = $runnerProject
                Guid = [System.Guid]::NewGuid().ToString().ToUpper()
            }
        }
        
        if ($projectsToAdd.Count -gt 0) {
            Write-Host "    Přidávám chybějící projekty do solution..." -ForegroundColor Cyan
            
            # Najdeme místo kde přidat projekty (před Global sekcí)
            $insertPosition = $solutionContent.IndexOf("Global")
            
            $projectEntries = ""
            $configEntries = ""
            
            foreach ($project in $projectsToAdd) {
                $projectEntries += "Project(`"{9A19103F-16F7-4668-BE54-9A1E7A4F7556}`") = `"$($project.Name)`", `"$($project.Path)`", `"{$($project.Guid)}`"`n"
                $projectEntries += "EndProject`n"
                
                # Přidání konfiguračních sekcí
                $configEntries += "`t`t{$($project.Guid)}.Debug|Any CPU.ActiveCfg = Debug|Any CPU`n"
                $configEntries += "`t`t{$($project.Guid)}.Debug|Any CPU.Build.0 = Debug|Any CPU`n"
                $configEntries += "`t`t{$($project.Guid)}.Debug|x64.ActiveCfg = Debug|Any CPU`n"
                $configEntries += "`t`t{$($project.Guid)}.Debug|x64.Build.0 = Debug|Any CPU`n"
                $configEntries += "`t`t{$($project.Guid)}.Debug|x86.ActiveCfg = Debug|Any CPU`n"
                $configEntries += "`t`t{$($project.Guid)}.Debug|x86.Build.0 = Debug|Any CPU`n"
                $configEntries += "`t`t{$($project.Guid)}.Release|Any CPU.ActiveCfg = Release|Any CPU`n"
                $configEntries += "`t`t{$($project.Guid)}.Release|Any CPU.Build.0 = Release|Any CPU`n"
                $configEntries += "`t`t{$($project.Guid)}.Release|x64.ActiveCfg = Release|Any CPU`n"
                $configEntries += "`t`t{$($project.Guid)}.Release|x64.Build.0 = Release|Any CPU`n"
                $configEntries += "`t`t{$($project.Guid)}.Release|x86.ActiveCfg = Release|Any CPU`n"
                $configEntries += "`t`t{$($project.Guid)}.Release|x86.Build.0 = Release|Any CPU`n"
            }
            
            # Vložení projektů
            $solutionContent = $solutionContent.Insert($insertPosition, $projectEntries)
            
            # Vložení konfiguračních sekcí
            $endSolutionPos = $solutionContent.LastIndexOf("EndGlobalSection`nEndGlobal")
            $solutionContent = $solutionContent.Insert($endSolutionPos, $configEntries)
            
            Set-Content -Path $solutionFile.FullName -Value $solutionContent -Encoding UTF8
            Write-Host "    ✓ Upraven solution soubor" -ForegroundColor Green
        } else {
            Write-Host "    - Solution už obsahuje všechny projekty" -ForegroundColor Gray
        }
        
    } else {
        Write-Host "  ⚠ Nepodařilo se najít všechny 3 projekty, přeskakuji..." -ForegroundColor Red
    }
}

Write-Host "`nÚprava dokončena!" -ForegroundColor Green
Write-Host "Poznámka: Zkontrolujte, zda všechny solution soubory a project references odpovídají vzoru SunamoArgs." -ForegroundColor Yellow
