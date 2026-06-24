<#
.SYNOPSIS
Merges the remaining test project directories into their corresponding main project directories using a more flexible matching logic.

.DESCRIPTION
This script is designed to clean up the remaining test folders that were not merged by the previous script. It uses a smarter matching algorithm to handle inconsistencies in naming conventions.

The script works as follows:
1.  It gets a list of all remaining directories in the test projects folder.
2.  It gets a list of all potential main project directories.
3.  For each remaining test folder, it tries to find the best matching main folder by:
    a.  Doing a direct name match (e.g., 'SunamoArgs.Tests' -> 'SunamoArgs').
    b.  Trying a case-insensitive match.
    c.  Looking for a main folder that *ends with* the test folder's base name (e.g., 'Roslyn.Tests' -> 'SunamoRoslyn').
4.  Once a match is found, it moves the contents, adds the test project to the solution, and removes the old test directory, similar to the previous script.

.PARAMETER MainProjectsDir
The path to the directory containing the main projects.
Default: "E:\vs3\PlatformIndependentNuGetPackages"

.PARAMETER TestProjectsDir
The path to the directory containing the test projects.
Default: "E:\vs3\_ut2\PlatformIndependentNuGetPackages.Tests"

.PARAMETER WhatIf
A switch parameter for a dry run to see what actions would be taken.
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

# --- 1. Get Remaining Test Folders and All Main Project Folders ---
$remainingTestFolders = Get-ChildItem -Path $TestProjectsDir -Directory
$allMainFolders = Get-ChildItem -Path $MainProjectsDir -Directory

Write-Host "Found $($remainingTestFolders.Count) remaining test project folders to process."
if ($WhatIf) {
    Write-Host "--- SIMULATION MODE (WhatIf) ENABLED ---" -ForegroundColor Magenta
}

# --- 2. Process Each Remaining Test Folder ---
foreach ($testFolder in $remainingTestFolders) {
    Write-Host "`n--- Attempting to match: $($testFolder.Name) ---" -ForegroundColor Cyan
    
    $testBaseName = $testFolder.Name.Replace(".Tests", "").Replace(".Tests2", "").Replace(".Sql", "")
    $foundMatch = $null

    # --- 3. Find Matching Main Folder ---
    # Exact match (e.g., SunamoArgs -> SunamoArgs)
    $foundMatch = $allMainFolders | Where-Object { $_.Name -eq $testBaseName } | Select-Object -First 1
    
    # EndsWith match for cases like 'Roslyn' -> 'SunamoRoslyn'
    if ($null -eq $foundMatch) {
        $foundMatch = $allMainFolders | Where-Object { $_.Name.EndsWith($testBaseName, [System.StringComparison]::OrdinalIgnoreCase) } | Select-Object -First 1
    }

    if ($null -eq $foundMatch) {
        Write-Warning "  No matching destination folder found for '$($testFolder.Name)'. Skipping."
        continue
    }

    $destPath = $foundMatch.FullName
    Write-Host "  Found match: '$($testFolder.Name)' -> '$($foundMatch.Name)'"

    # --- 4. Move Contents ---
    $itemsToMove = Get-ChildItem -Path $testFolder.FullName -Force -Recurse
    if ($itemsToMove.Count -gt 0) {
        if ($WhatIf) {
            Write-Host "    WHATIF: Would move contents of '$($testFolder.FullName)' to '$destPath'."
        } else {
            try {
                Move-Item -Path ($testFolder.FullName + '\*') -Destination $destPath -Force -ErrorAction Stop
                Write-Host "    SUCCESS: Moved contents to '$destPath'." -ForegroundColor Green
            } catch {
                Write-Error "    FAILURE: Could not move contents from '$($testFolder.FullName)'. Error: $($_.Exception.Message)"
                continue
            }
        }
    }

    # --- 5. Update Solution File ---
    $slnFile = Get-ChildItem -Path $destPath -Filter "*.sln" -File | Select-Object -First 1
    $testProjectFile = Get-ChildItem -Path $destPath -Filter "*$($testBaseName).Tests.csproj" -File -Recurse | Select-Object -First 1
    if ($null -eq $testProjectFile) {
         $testProjectFile = Get-ChildItem -Path $destPath -Filter "*$($testBaseName).Tests2.csproj" -File -Recurse | Select-Object -First 1
    }

    if ($slnFile -and $testProjectFile) {
        Write-Host "  Updating solution: $($slnFile.Name)"
        if ($WhatIf) {
            Write-Host "    WHATIF: Would run 'dotnet sln `"$($slnFile.FullName)`" add `"$($testProjectFile.FullName)`"'"
        } else {
            try {
                dotnet sln "$($slnFile.FullName)" add "$($testProjectFile.FullName)" | Out-Null
                Write-Host "    SUCCESS: Ensured test project '$($testProjectFile.Name)' is in the solution." -ForegroundColor Green
            } catch {
                Write-Error "    An exception occurred while updating the solution: $($_.Exception.Message)"
            }
        }
    }

    # --- 6. Remove Original Test Folder ---
    if ($WhatIf) {
        Write-Host "    WHATIF: Would remove the original empty folder '$($testFolder.FullName)'."
    } else {
        if ((Get-ChildItem -Path $testFolder.FullName -Force).Count -eq 0) {
            Remove-Item -Path $testFolder.FullName -Recurse -Force
            Write-Host "  SUCCESS: Removed original test folder." -ForegroundColor Green
        } else {
            Write-Warning "  Skipping removal of original test folder because it is not empty: $($testFolder.FullName)"
        }
    }
}

Write-Host "`n--- All cleanup operations complete. ---" -ForegroundColor Green
