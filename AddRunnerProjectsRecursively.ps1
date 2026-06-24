<#
.SYNOPSIS
Correctly finds and adds Runner projects to their solutions, searching within subdirectories.

.DESCRIPTION
This script iterates through each project folder. For each solution file found, it determines the expected name of the corresponding runner project (e.g., RunnerYouTube.csproj for SunamoYouTube.sln).

Crucially, it then performs a RECURSIVE search within the project's directory to find that runner project, even if it's nested in a subdirectory (like 'RunnerYouTube/RunnerYouTube.csproj').

If a matching runner project is found, it is safely added to the solution using the 'dotnet sln add' command.

.PARAMETER MainDirectory
The absolute path to the main directory containing the project folders.
Default: "E:\vs3\PlatformIndependentNuGetPackages"

.PARAMETER WhatIf
A switch parameter for a dry run to see what actions would be taken.
#>
param(
    [string]$MainDirectory = "E:\vs3\PlatformIndependentNuGetPackages",
    [switch]$WhatIf
)

# --- 1. Get Project Directories ---
$excludedFolders = @('.git', '.vs', '.vscode', '_', 'bin', 'obj', 'packages', 'TestResults')
try {
    $projectFolders = Get-ChildItem -Path $MainDirectory -Directory -ErrorAction Stop | Where-Object { $_.Name -notin $excludedFolders }
} catch {
    Write-Error "Critical error reading source directory '$MainDirectory': $($_.Exception.Message)"
    return
}

Write-Host "Found $($projectFolders.Count) project folders to check." -ForegroundColor Yellow

if ($WhatIf) {
    Write-Host "--- SIMULATION MODE (WhatIf) ENABLED ---" -ForegroundColor Magenta
}

# --- 2. Process Each Project Folder ---
foreach ($folder in $projectFolders) {
    $projectPath = $folder.FullName
    $projectName = $folder.Name
    
    $slnFile = Get-ChildItem -Path $projectPath -Filter "*.sln" -File | Select-Object -First 1

    if ($null -eq $slnFile) {
        Write-Host "`n--- Skipping $projectName (No .sln file found) ---" -ForegroundColor Gray
        continue
    }

    # Determine the expected runner project filename
    $slnBaseName = $slnFile.BaseName
    $runnerBaseName = $slnBaseName
    if ($runnerBaseName.StartsWith("Sunamo")) {
        $runnerBaseName = $runnerBaseName.Substring("Sunamo".Length)
    }
    $runnerProjectFileName = "Runner$($runnerBaseName).csproj"
    
    # Search for the runner project RECURSIVELY within the project's folder
    $runnerProject = Get-ChildItem -Path $projectPath -Filter $runnerProjectFileName -File -Recurse | Select-Object -First 1

    if ($null -eq $runnerProject) {
        Write-Host "`n--- Skipping $projectName (No runner project named '$runnerProjectFileName' found within) ---" -ForegroundColor Gray
        continue
    }

    Write-Host "`n--- Processing: $projectName ---" -ForegroundColor Cyan
    Write-Host "  Solution: $($slnFile.Name)"
    Write-Host "  Found Runner: $($runnerProject.FullName)"

    # Check if the runner project is already in the solution
    $slnListResult = dotnet sln "$($slnFile.FullName)" list 2>&1
    if ($slnListResult -match [regex]::Escape($runnerProject.Name)) {
        Write-Host "  Status: Runner project is already in the solution." -ForegroundColor Green
    } else {
        Write-Host "  Status: Runner project is MISSING from the solution. Adding it..." -ForegroundColor Yellow
        
        if ($WhatIf) {
            Write-Host "    WHATIF: Would run 'dotnet sln `"$($slnFile.FullName)`" add `"$($runnerProject.FullName)`"'"
        } else {
            try {
                $addResult = dotnet sln "$($slnFile.FullName)" add "$($runnerProject.FullName)" 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "    SUCCESS: Successfully added $($runnerProject.Name) to $($slnFile.Name)." -ForegroundColor Green
                } else {
                    Write-Error "    FAILURE: 'dotnet sln add' command failed."
                    Write-Error "    $addResult"
                }
            } catch {
                Write-Error "    An exception occurred while trying to add the project: $($_.Exception.Message)"
            }
        }
    }
}

Write-Host "`n--- All operations complete. ---" -ForegroundColor Green
