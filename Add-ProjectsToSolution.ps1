function Add-ProjectsToSolution {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SolutionPath
    )
    
    # Zkontroluj, zda .sln soubor existuje
    if (-not (Test-Path $SolutionPath)) {
        Write-Error "Solution file '$SolutionPath' not found."
        return
    }
    
    # Získej cestu k složce s .sln souborem
    $solutionDir = Split-Path -Parent $SolutionPath
    $solutionFileName = Split-Path -Leaf $SolutionPath
    
    Write-Host "Processing solution: $solutionFileName"
    Write-Host "Solution directory: $solutionDir"
    
    # Vytvoř zálohu .sln souboru
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupPath = $SolutionPath + ".backup_$timestamp"
    Copy-Item $SolutionPath $backupPath
    Write-Host "Created backup: $backupPath"
    
    # Načti obsah .sln souboru
    $solutionContent = Get-Content $SolutionPath -Encoding UTF8
    
    # KROK 1: Odstraň projekty s vadnými cestami
    Write-Host "`n=== REMOVING PROJECTS WITH INVALID PATHS ==="
    
    $validContent = @()
    $projectsToRemove = @()
    $skipNextLine = $false
    
    for ($i = 0; $i -lt $solutionContent.Length; $i++) {
        $line = $solutionContent[$i]
        
        if ($skipNextLine) {
            $skipNextLine = $false
            continue
        }
        
        # Najdi řádky s definicí projektů
        if ($line -match '^Project\(.*?\)\s*=\s*"([^"]+)",\s*"([^"]+)",\s*"(\{[^}]+\})"') {
            $projectName = $matches[1]
            $projectPath = $matches[2]
            $projectGuid = $matches[3]
            
            # Vytvoř absolutní cestu k projektu
            $absoluteProjectPath = Join-Path $solutionDir $projectPath
            
            # Zkontroluj, zda projekt existuje
            if (-not (Test-Path $absoluteProjectPath)) {
                Write-Host "REMOVING invalid project: $projectName (path: $projectPath)" -ForegroundColor Red
                $projectsToRemove += $projectGuid
                
                # Přeskoč i následující "EndProject" řádek
                if ($i + 1 -lt $solutionContent.Length -and $solutionContent[$i + 1].Trim() -eq "EndProject") {
                    $skipNextLine = $true
                }
                continue
            } else {
                Write-Host "KEEPING valid project: $projectName (path: $projectPath)" -ForegroundColor Green
            }
        }
        
        $validContent += $line
    }
    
    # Odstraň konfigurace pro smazané projekty z ProjectConfigurationPlatforms sekce
    if ($projectsToRemove.Count -gt 0) {
        Write-Host "Removing configurations for $($projectsToRemove.Count) invalid project(s)..."
        
        $finalContent = @()
        foreach ($line in $validContent) {
            $shouldSkip = $false
            
            # Zkontroluj, zda řádek obsahuje konfiguraci pro smazaný projekt
            foreach ($guidToRemove in $projectsToRemove) {
                if ($line -match [regex]::Escape($guidToRemove)) {
                    $shouldSkip = $true
                    break
                }
            }
            
            if (-not $shouldSkip) {
                $finalContent += $line
            }
        }
        $validContent = $finalContent
    }
    
    # KROK 2: Přidej nové projekty ze složek
    Write-Host "`n=== ADDING NEW PROJECTS FROM SUBFOLDERS ==="
    
    # Najdi všechny podsložky ve složce s .sln souborem
    $subfolders = Get-ChildItem -Path $solutionDir -Directory
    
    # Seznam projektů k přidání
    $projectsToAdd = @()
    
    foreach ($subfolder in $subfolders) {
        # Hledej .csproj soubory přímo v podsložce (ne rekurzivně)
        $csprojFiles = Get-ChildItem -Path $subfolder.FullName -Filter "*.csproj" -File
        
        foreach ($csprojFile in $csprojFiles) {
            $relativePath = "$($subfolder.Name)\$($csprojFile.Name)"
            $projectName = [System.IO.Path]::GetFileNameWithoutExtension($csprojFile.Name)
            
            # Zkontroluj, zda projekt už není v .sln souboru
            $projectExists = $validContent | Where-Object { $_ -match [regex]::Escape($relativePath) }
            
            if (-not $projectExists) {
                Write-Host "ADDING new project: $projectName at $relativePath" -ForegroundColor Cyan
                
                # Vygeneruj nový GUID pro projekt
                $projectGuid = [System.Guid]::NewGuid().ToString().ToUpper()
                
                $projectsToAdd += @{
                    Name = $projectName
                    Path = $relativePath
                    Guid = $projectGuid
                }
            } else {
                Write-Host "Project already exists in solution: $projectName" -ForegroundColor Yellow
            }
        }
    }
    
    if ($projectsToAdd.Count -eq 0) {
        Write-Host "No new projects found to add." -ForegroundColor Yellow
    }
    
    # Najdi pozici, kde vložit nové projekty (před Global sekcí)
    $newContent = @()
    $globalSectionFound = $false
    
    foreach ($line in $validContent) {
        if ($line.Trim() -eq "Global" -and -not $globalSectionFound) {
            # Přidej nové projekty před Global sekci
            foreach ($project in $projectsToAdd) {
                $projectLine = "Project(""{9A19103F-16F7-4668-BE54-9A1E7A4F7556}"") = ""$($project.Name)"", ""$($project.Path)"", ""{$($project.Guid)}"""
                $newContent += $projectLine
                $newContent += "EndProject"
                Write-Host "Added project: $($project.Name)" -ForegroundColor Green
            }
            $globalSectionFound = $true
        }
        $newContent += $line
    }
    
    # Pro ProjectConfigurationPlatforms - přidej konfigurace pro nové projekty
    $finalContent = @()
    $inProjectConfigSection = $false
    
    foreach ($line in $newContent) {
        $finalContent += $line
        
        if ($line.Trim() -match "GlobalSection\(ProjectConfigurationPlatforms\) = postSolution") {
            $inProjectConfigSection = $true
        }
        elseif ($inProjectConfigSection -and $line.Trim() -eq "EndGlobalSection") {
            # Přidej konfigurace pro nové projekty před EndGlobalSection
            foreach ($project in $projectsToAdd) {
                $guid = $project.Guid
                $finalContent += "`t`t{$guid}.Debug|Any CPU.ActiveCfg = Debug|Any CPU"
                $finalContent += "`t`t{$guid}.Debug|Any CPU.Build.0 = Debug|Any CPU"
                $finalContent += "`t`t{$guid}.Debug|x64.ActiveCfg = Debug|Any CPU"
                $finalContent += "`t`t{$guid}.Debug|x64.Build.0 = Debug|Any CPU"
                $finalContent += "`t`t{$guid}.Debug|x86.ActiveCfg = Debug|Any CPU"
                $finalContent += "`t`t{$guid}.Debug|x86.Build.0 = Debug|Any CPU"
                $finalContent += "`t`t{$guid}.Release|Any CPU.ActiveCfg = Release|Any CPU"
                $finalContent += "`t`t{$guid}.Release|Any CPU.Build.0 = Release|Any CPU"
                $finalContent += "`t`t{$guid}.Release|x64.ActiveCfg = Release|Any CPU"
                $finalContent += "`t`t{$guid}.Release|x64.Build.0 = Release|Any CPU"
                $finalContent += "`t`t{$guid}.Release|x86.ActiveCfg = Release|Any CPU"
                $finalContent += "`t`t{$guid}.Release|x86.Build.0 = Release|Any CPU"
            }
            $inProjectConfigSection = $false
        }
    }
    
    # Ulož upravený .sln soubor
    $finalContent | Out-File -FilePath $SolutionPath -Encoding UTF8
    
    Write-Host "`n=== SUMMARY ===" -ForegroundColor White
    Write-Host "Removed $($projectsToRemove.Count) project(s) with invalid paths." -ForegroundColor Red
    Write-Host "Added $($projectsToAdd.Count) new project(s) to solution." -ForegroundColor Green
    
    if ($projectsToAdd.Count -gt 0) {
        Write-Host "Projects added:" -ForegroundColor Green
        foreach ($project in $projectsToAdd) {
            Write-Host "  - $($project.Name) ($($project.Path))" -ForegroundColor Green
        }
    }
    
    Write-Host "Backup created: $backupPath" -ForegroundColor Cyan
}

# Příklad použití:
# Add-ProjectsToSolution -SolutionPath "C:\path\to\your\solution.sln"