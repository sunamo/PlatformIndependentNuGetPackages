<#
.SYNOPSIS
Correctly identifies and adds the corresponding 'Runner' project to each Visual Studio Solution (.sln) file.

.DESCRIPTION
This script addresses a specific naming convention for runner projects. It iterates through project subfolders, finds the .sln file, and then constructs the expected runner project name.

The logic is as follows:
1. Takes the solution's base name (e.g., "SunamoArgs" from "SunamoArgs.sln").
2. Removes the "Sunamo" prefix, if present (resulting in "Args").
3. Prepends "Runner" to create the runner project name (e.g., "RunnerArgs.csproj").
4. It then checks if this runner project exists and adds it to the solution if it's not already included.

This script uses the 'dotnet sln add' command for safe modification of solution files.

.PARAMETER MainDirectory
The absolute path to the main directory containing the project folders.
Default: "E:\vs3\PlatformIndependentNuGetPackages"

.PARAMETER WhatIf
A switch parameter that, if present, causes the script to report the actions it would have taken without actually performing them.
#>
param(
    [string]$MainDirectory = "E:\vs3\PlatformIndependentNuGetPackages",
    [switch]$WhatIf
)

# --- 1. Get Project Directories ---
# Exclude common non-project folders
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
    
    # Find the solution file in the current project directory
    $slnFile = Get-ChildItem -Path $projectPath -Filter "*.sln" -File | Select-Object -First 1

    if ($null -eq $slnFile) {
        Write-Host "`n--- Skipping $projectName (No .sln file found) ---" -ForegroundColor Gray
        continue
    }

    # Correctly determine the runner project name based on the user's feedback
    $slnBaseName = $slnFile.BaseName # e.g., SunamoArgs
    $runnerBaseName = $slnBaseName
    if ($runnerBaseName.StartsWith("Sunamo")) {
        $runnerBaseName = $runnerBaseName.Substring("Sunamo".Length)
    }
    $runnerProjectFileName = "Runner$($runnerBaseName).csproj"
    
    $runnerProject = Get-ChildItem -Path $projectPath -Filter $runnerProjectFileName -File | Select-Object -First 1

    if ($null -eq $runnerProject) {
        Write-Host "`n--- Skipping $projectName (No runner project named '$runnerProjectFileName' found) ---" -ForegroundColor Gray
        continue
    }

    Write-Host "`n--- Processing: $projectName ---" -ForegroundColor Cyan
    Write-Host "  Solution: $($slnFile.Name)"
    Write-Host "  Runner:   $($runnerProject.Name)"

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
                # Use the dotnet CLI to safely add the project
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
