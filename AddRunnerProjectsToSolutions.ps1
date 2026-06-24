<#
.SYNOPSIS
Safely adds a corresponding Runner project to each solution file in the specified directory.

.DESCRIPTION
This script iterates through each project subfolder in the main directory. For each folder, it finds the .sln file and looks for a corresponding .Runner.csproj file. If the Runner project exists but is not already included in the solution, the script uses the 'dotnet sln add' command to add it. This is the recommended, safe way to modify solution files.

This script does NOT move, delete, or manually edit any files. It only uses the dotnet CLI.

.PARAMETER MainDirectory
The absolute path to the main directory containing the project folders.
Default: "E:\vs3\PlatformIndependentNuGetPackages"

.PARAMETER WhatIf
A switch parameter that, if present, causes the script to report the actions it would have taken without actually performing them.

.EXAMPLE
# Perform a dry run to see which Runner projects would be added.
.\AddRunnerProjectsToSolutions.ps1 -WhatIf

.EXAMPLE
# Execute the script to add the missing Runner projects.
.\AddRunnerProjectsToSolutions.ps1
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
    
    # Find the solution file and runner project in the current project directory
    $slnFile = Get-ChildItem -Path $projectPath -Filter "*.sln" -File | Select-Object -First 1
    $runnerProject = Get-ChildItem -Path $projectPath -Filter "*.Runner.csproj" -File | Select-Object -First 1

    # Proceed only if both the solution and the runner project exist
    if ($null -eq $slnFile) {
        continue # Skip folders without a solution file
    }

    if ($null -eq $runnerProject) {
        # It's normal for some projects not to have a runner, so we just skip them quietly.
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
