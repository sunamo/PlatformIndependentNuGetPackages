<#
.SYNOPSIS
Finds all Runner projects and adds them to their corresponding solutions, regardless of their location.

.DESCRIPTION
This script performs a comprehensive search to fix solution files.
1. It finds all solution files (.sln) within the main directory.
2. It finds all runner projects (Runner*.csproj) within the main directory.
3. It then intelligently matches them. For each solution (e.g., SunamoArgs.sln), it looks for a corresponding runner (RunnerArgs.csproj).
4. If a match is found and the runner is not already in the solution, it adds it using the safe 'dotnet sln add' command.

This method is robust and does not depend on the projects being in the same folder.

.PARAMETER MainDirectory
The absolute path to the main directory to search within.
Default: "E:\vs3\PlatformIndependentNuGetPackages"

.PARAMETER WhatIf
A switch parameter for a dry run to see what actions would be taken.
#>
param(
    [string]$MainDirectory = "E:\vs3\PlatformIndependentNuGetPackages",
    [switch]$WhatIf
)

# --- 1. Find All Solutions and Runner Projects ---
Write-Host "Searching for all solution and runner project files..."
$allSolutionFiles = Get-ChildItem -Path $MainDirectory -Filter "*.sln" -Recurse -File
$allRunnerProjects = Get-ChildItem -Path $MainDirectory -Filter "Runner*.csproj" -Recurse -File

Write-Host "Found $($allSolutionFiles.Count) solution files."
Write-Host "Found $($allRunnerProjects.Count) runner projects."

if ($WhatIf) {
    Write-Host "--- SIMULATION MODE (WhatIf) ENABLED ---" -ForegroundColor Magenta
}

# --- 2. Create a Lookup for Runner Projects ---
$runnerLookup = @{}
foreach ($runner in $allRunnerProjects) {
    # Key: "Args" from "RunnerArgs.csproj"
    $key = $runner.BaseName.Replace("Runner", "")
    $runnerLookup[$key] = $runner
}

# --- 3. Process Each Solution ---
foreach ($slnFile in $allSolutionFiles) {
    $slnBaseName = $slnFile.BaseName # e.g., "SunamoArgs"
    
    # Key: "Args" from "SunamoArgs"
    $lookupKey = $slnBaseName.Replace("Sunamo", "")

    if ($runnerLookup.ContainsKey($lookupKey)) {
        $runnerProject = $runnerLookup[$lookupKey]
        
        Write-Host "`n--- Processing: $($slnFile.Name) ---" -ForegroundColor Cyan
        Write-Host "  Found matching runner: $($runnerProject.Name) at $($runnerProject.DirectoryName)"

        # Check if the runner project is already in the solution
        $slnListResult = dotnet sln "$($slnFile.FullName)" list 2>&1
        if ($slnListResult -match [regex]::Escape($runnerProject.Name)) {
            Write-Host "  Status: Runner project is already in the solution." -ForegroundColor Green
        } else {
            Write-Host "  Status: Runner project is MISSING. Adding it..." -ForegroundColor Yellow
            
            if ($WhatIf) {
                Write-Host "    WHATIF: Would run 'dotnet sln `"$($slnFile.FullName)`" add `"$($runnerProject.FullName)`"'"
            } else {
                try {
                    $addResult = dotnet sln "$($slnFile.FullName)" add "$($runnerProject.FullName)" 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "    SUCCESS: Added $($runnerProject.Name) to $($slnFile.Name)." -ForegroundColor Green
                    } else {
                        Write-Error "    FAILURE: 'dotnet sln add' command failed."
                        Write-Error "    $addResult"
                    }
                } catch {
                    Write-Error "    An exception occurred: $($_.Exception.Message)"
                }
            }
        }
    }
}

Write-Host "`n--- All operations complete. ---" -ForegroundColor Green
