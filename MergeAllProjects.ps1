<#
.SYNOPSIS
Merges test projects into their corresponding main project directories and updates the solution files.

.DESCRIPTION
This script automates the restructuring of the project folders. For each test project found in the tests directory, it performs the following actions:
1.  Determines the corresponding main project directory.
2.  Moves all contents (including files, subdirectories, and hidden items like .git) from the test project folder to the main project folder.
3.  Finds the solution file (.sln) in the main project folder.
4.  Finds the test project file (.csproj) that was just moved.
5.  Uses the 'dotnet sln add' command to ensure the test project is correctly referenced in the solution file from its new location. This command will update the existing reference if necessary.
6.  After a successful move and solution update, it removes the original, now-empty, test project directory.

.PARAMETER MainProjectsDir
The path to the directory containing the main projects.
Default: "E:\vs3\PlatformIndependentNuGetPackages"

.PARAMETER TestProjectsDir
The path to the directory containing the test projects.
Default: "E:\vs3\_ut2\PlatformIndependentNuGetPackages.Tests"

.PARAMETER WhatIf
A switch parameter for a dry run to see what actions would be taken without executing them.
#>
param(
    [string]$MainProjectsDir = "E:\vs3\PlatformIndependentNuGetPackages",
    [string]$TestProjectsDir = "E:\vs3\_ut2\PlatformIndependentNuGetPackages.Tests",
    [switch]$WhatIf
)

if (! (Test-Path -Path $TestProjectsDir)) {
    Write-Error "The specified test projects directory does not exist: $TestProjectsDir"
    return
}

# Get all the test project folders
$testProjectFolders = Get-ChildItem -Path $TestProjectsDir -Directory

Write-Host "Found $($testProjectFolders.Count) test project folders to process."

if ($WhatIf) {
    Write-Host "--- SIMULATION MODE (WhatIf) ENABLED ---" -ForegroundColor Magenta
}

foreach ($testFolder in $testProjectFolders) {
    # Derive the main project name, e.g., "SunamoArgs" from "SunamoArgs.Tests"
    $mainProjectName = $testFolder.Name.Replace(".Tests", "")
    $destPath = Join-Path -Path $MainProjectsDir -ChildPath $mainProjectName

    Write-Host "`n--- Processing: $($testFolder.Name) -> $mainProjectName ---" -ForegroundColor Cyan

    if (-not (Test-Path -Path $destPath)) {
        Write-Warning "  Destination folder not found, skipping: $destPath"
        continue
    }

    # 1. Move contents
    $itemsToMove = Get-ChildItem -Path $testFolder.FullName -Force -Recurse
    Write-Host "  Found $($itemsToMove.Count) items to move from $($testFolder.FullName)"

    if ($WhatIf) {
        Write-Host "    WHATIF: Would move contents of '$($testFolder.FullName)' to '$destPath'."
    } else {
        try {
            Move-Item -Path ($testFolder.FullName + '\*') -Destination $destPath -Force -ErrorAction Stop
            Write-Host "    SUCCESS: Moved contents to '$destPath'." -ForegroundColor Green
        } catch {
            Write-Error "    FAILURE: Could not move contents from '$($testFolder.FullName)'. Error: $($_.Exception.Message)"
            continue # Skip to the next folder if move fails
        }
    }

    # 2. Update Solution File
    $slnFile = Get-ChildItem -Path $destPath -Filter "*.sln" -File | Select-Object -First 1
    $testProjectFile = Get-ChildItem -Path $destPath -Filter "*$($mainProjectName).Tests.csproj" -File -Recurse | Select-Object -First 1

    if ($slnFile -and $testProjectFile) {
        Write-Host "  Updating solution: $($slnFile.Name)"
        if ($WhatIf) {
            Write-Host "    WHATIF: Would run 'dotnet sln `"$($slnFile.FullName)`" add `"$($testProjectFile.FullName)`"'"
        } else {
            try {
                $addResult = dotnet sln "$($slnFile.FullName)" add "$($testProjectFile.FullName)" 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "    SUCCESS: Ensured test project '$($testProjectFile.Name)' is in the solution." -ForegroundColor Green
                } else {
                    Write-Error "    FAILURE: 'dotnet sln add' command failed."
                    Write-Error "    $addResult"
                }
            } catch {
                Write-Error "    An exception occurred while updating the solution: $($_.Exception.Message)"
            }
        }
    } else {
        if (-not $slnFile) { Write-Warning "  Could not find .sln file in '$destPath'." }
        if (-not $testProjectFile) { Write-Warning "  Could not find .Tests.csproj file in '$destPath' after move." }
    }

    # 3. Remove original test folder
    if ($WhatIf) {
        Write-Host "    WHATIF: Would remove the original empty folder '$($testFolder.FullName)'."
    } else {
        # Check if the directory is now empty before deleting
        if ((Get-ChildItem -Path $testFolder.FullName -Force).Count -eq 0) {
            try {
                Remove-Item -Path $testFolder.FullName -Recurse -Force -ErrorAction Stop
                Write-Host "  SUCCESS: Removed original test folder." -ForegroundColor Green
            } catch {
                Write-Error "  FAILURE: Could not remove original test folder '$($testFolder.FullName)'. Error: $($_.Exception.Message)"
            }
        } else {
            Write-Warning "  Skipping removal of original test folder because it is not empty: $($testFolder.FullName)"
        }
    }
}

Write-Host "`n--- All merge operations complete. ---" -ForegroundColor Green
