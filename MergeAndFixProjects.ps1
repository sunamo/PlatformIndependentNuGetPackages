<#
.SYNOPSIS
Merges test projects with main projects, flattens the structure, and fixes solution files.

.DESCRIPTION
This script is the next generation for merging project structures. It performs a multi-step process for each project:
1.  Identifies common project folders between a main directory and a tests directory.
2.  Moves all content from the test project folder into the corresponding main project folder.
3.  "Flattens" the structure by moving all content from sub-folders (like the project-name folder, .Tests folder, .Runner folder) into the main project folder.
4.  Deletes the now-empty sub-folders.
5.  Intelligently updates the .sln file, replacing complex relative paths with simple, direct filenames, ensuring all projects are correctly referenced.
6.  Searches for any misplaced, nested .git directories and moves them to the correct root level of the project folder.
7.  Includes a -WhatIf switch for a safe-run simulation.

.PARAMETER MainDirectory
The absolute path to the main directory containing the primary projects.
Default: "E:\vs3\PlatformIndependentNuGetPackages"

.PARAMETER TestDirectory
The absolute path to the directory containing the test projects.
Default: "E:\vs3\_ut2\PlatformIndependentNuGetPackages.Tests"

.PARAMETER WhatIf
A switch parameter that, if present, causes the script to report the actions it would have taken without actually performing them.

.EXAMPLE
# Perform a dry run to see what changes will be made without applying them.
.\MergeAndFixProjects.ps1 -WhatIf

.EXAMPLE
# Execute the script to perform the merge and fix operations.
.\MergeAndFixProjects.ps1
#>

param(
    [string]$MainDirectory = "E:\vs3\PlatformIndependentNuGetPackages",
    [string]$TestDirectory = "E:\vs3\_ut2\PlatformIndependentNuGetPackages.Tests",
    [switch]$WhatIf
)

function Invoke-MergeAndFix {
    param(
        [string]$mainDir,
        [string]$testDir,
        [switch]$simulate
    )

    # --- 1. Find Common Directories ---
    try {
        $mainFolders = Get-ChildItem -Path $mainDir -Directory -ErrorAction Stop
        $testFolders = Get-ChildItem -Path $testDir -Directory -ErrorAction Stop
    } catch {
        Write-Error "Critical error reading source directories: $($_.Exception.Message)"
        return
    }

    $commonFolderPairs = @()
    foreach ($mainFolder in $mainFolders) {
        $matchingTestFolder = $testFolders | Where-Object { $_.Name -eq $mainFolder.Name }
        if ($null -ne $matchingTestFolder) {
            $commonFolderPairs += @{ Main = $mainFolder; Test = $matchingTestFolder }
        }
    }

    if ($commonFolderPairs.Count -eq 0) {
        Write-Host "No common folders found to process."
        return
    }

    Write-Host "Found $($commonFolderPairs.Count) common folders to process:" -ForegroundColor Yellow
    $commonFolderPairs | ForEach-Object { Write-Host "  - $($_.Main.Name)" }
    Write-Host ""

    if ($simulate) {
        Write-Host "--- SIMULATION MODE (WhatIf) ENABLED ---" -ForegroundColor Magenta
        Write-Host "No actual changes will be made." -ForegroundColor Magenta
    } else {
        $confirmation = Read-Host "Proceed with merging $($commonFolderPairs.Count) folders? (y/n)"
        if ($confirmation -ne 'y') {
            Write-Host "Operation cancelled by user."
            return
        }
    }

    # --- 2. Process Each Common Folder ---
    foreach ($pair in $commonFolderPairs) {
        $mainPath = $pair.Main.FullName
        $testPath = $pair.Test.FullName
        $folderName = $pair.Main.Name

        Write-Host "`n--- Processing: $folderName ---" -ForegroundColor Cyan

        # --- 2a. Move Content from Test Directory ---
        Write-Host "  Step 1: Moving content from test directory..."
        $testItems = Get-ChildItem -Path $testPath -Force
        if ($testItems) {
            foreach ($item in $testItems) {
                $destination = Join-Path $mainPath $item.Name
                Write-Host "    - Moving $($item.Name)"
                if (!$simulate) {
                    try { Move-Item -Path $item.FullName -Destination $destination -Force -ErrorAction Stop }
                    catch { Write-Error "    Failed to move $($item.FullName): $($_.Exception.Message)" }
                }
            }
        } else {
            Write-Host "    Test directory is empty. Nothing to move."
        }

        # --- 2b. Flatten Project Structure ---
        Write-Host "  Step 2: Flattening directory structure..."
        $subFoldersToFlatten = Get-ChildItem -Path $mainPath -Directory -Force
        foreach ($subFolder in $subFoldersToFlatten) {
            Write-Host "    - Flattening content from $($subFolder.Name)"
            $contentToMove = Get-ChildItem -Path $subFolder.FullName -Force
            if ($contentToMove) {
                foreach ($item in $contentToMove) {
                    $destination = Join-Path $mainPath $item.Name
                     if (!$simulate) {
                        try { Move-Item -Path $item.FullName -Destination $destination -Force -ErrorAction Stop }
                        catch { Write-Error "    Failed to flatten $($item.FullName): $($_.Exception.Message)" }
                    }
                }
                if (!$simulate) {
                    # Remove the now-empty directory
                    try { Remove-Item -Path $subFolder.FullName -Force -ErrorAction Stop }
                    catch { Write-Warning "    Could not remove empty folder $($subFolder.FullName). It might not be empty."}
                }
            }
        }

        # --- 2c. Update Solution File ---
        Write-Host "  Step 3: Updating .sln file..."
        $slnFile = Get-ChildItem -Path $mainPath -Filter "*.sln" -File | Select-Object -First 1
        if ($slnFile) {
            if($simulate){
                Write-Host "    WHATIF: Would update $($slnFile.FullName)"
            } else {
                try {
                    $content = Get-Content $slnFile.FullName -Raw
                    $originalContent = $content
                    # This regex finds any path-like structure before a .csproj file in a project definition
                    # and replaces it with just the project file name.
                    $pattern = '(?<=, ")(?:[^\"]*\\|..\\)([^\"]+\.csproj)(?=")'
                    $content = $content -replace $pattern, '$1'

                    if ($content -ne $originalContent) {
                        Write-Host "    Solution file updated. Creating backup and saving." -ForegroundColor Green
                        $backupPath = "$($slnFile.FullName).backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                        Copy-Item -Path $slnFile.FullName -Destination $backupPath -Force
                        Set-Content -Path $slnFile.FullName -Value $content -Encoding UTF8
                    } else {
                        Write-Host "    Solution file appears to be up-to-date." -ForegroundColor Gray
                    }
                } catch {
                    Write-Error "    Failed to update $($slnFile.FullName): $($_.Exception.Message)"
                }
            }
        } else {
            Write-Warning "    No .sln file found in $mainPath."
        }

        # --- 2d. Move .git Directory ---
        Write-Host "  Step 4: Relocating .git directory..."
        $nestedGit = Get-ChildItem -Path $mainPath -Directory -Filter ".git" -Recurse -Force | Where-Object { $_.Parent.FullName -ne $mainPath }
        if ($nestedGit) {
            $targetGitPath = Join-Path $mainPath ".git"
            Write-Host "    Found nested .git at $($nestedGit.FullName)"
            if (!$simulate) {
                try {
                    Move-Item -Path $nestedGit.FullName -Destination $targetGitPath -Force -ErrorAction Stop
                    Write-Host "    Successfully moved .git to $targetGitPath" -ForegroundColor Green
                } catch {
                    Write-Error "    Failed to move .git directory: $($_.Exception.Message)"
                }
            }
        } else {
            Write-Host "    No nested .git directory found." -ForegroundColor Gray
        }
    }

    Write-Host "`n--- All operations complete. ---" -ForegroundColor Green
}

Invoke-MergeAndFix -mainDir $MainDirectory -testDir $TestDirectory -simulate:$WhatIf