<#
.SYNOPSIS
Corrects the paths of main project files within Visual Studio Solution (.sln) files.

.DESCRIPTION
This script specifically targets and fixes the paths for main projects (e.g., "SunamoBts") within .sln files, leaving the paths for other projects (like ".Tests" and "Runner" projects) untouched.

It iterates through all .sln files, identifies project entries where the project name does NOT end in ".Tests" and does NOT start with "Runner", and sets their path to be a direct relative path (e.g., "SunamoBts.csproj") instead of a path into a subdirectory.

This provides a targeted fix for situations where main project paths were incorrectly modified. A backup of each modified .sln file is created before changes are applied.

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

# --- 1. Find all solution files ---
try {
    $solutionFiles = Get-ChildItem -Path $MainDirectory -Filter "*.sln" -Recurse -File -ErrorAction Stop
} catch {
    Write-Error "Critical error reading source directory '$MainDirectory': $($_.Exception.Message)"
    return
}

Write-Host "Found $($solutionFiles.Count) solution files to process." -ForegroundColor Yellow

if ($WhatIf) {
    Write-Host "--- SIMULATION MODE (WhatIf) ENABLED ---" -ForegroundColor Magenta
}

# --- 2. Process each solution file ---
foreach ($slnFile in $solutionFiles) {
    $slnPath = $slnFile.FullName
    Write-Host "`n--- Processing: $($slnFile.Name) in $($slnFile.Directory.Name) ---" -ForegroundColor Cyan

    try {
        $originalContent = Get-Content -Path $slnPath -Raw

        # Create a backup before making any changes
        $backupPath = "$slnPath.backup_mainpathfix_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        if (-not $WhatIf) {
            Copy-Item -Path $slnPath -Destination $backupPath -Force
            Write-Host "  - Backup created at '$backupPath'"
        } else {
            Write-Host "  - WHATIF: Would create backup at '$backupPath'"
        }

        # Regex to capture the project name and its path.
        # Captures: 1=preamble, 2=project name, 3=project path, 4=postamble
        $projectLinePattern = '(?m)^(Project\(\"{[A-Z0-9\-]+}\"\) = \"([^"]+)\",\s*\")[^"]+(\.csproj\")'
        
        $modifiedContent = [System.Text.RegularExpressions.Regex]::Replace($originalContent, $projectLinePattern, {
            param($match)
            
            $preamble = $match.Groups[1].Value
            $projectName = $match.Groups[2].Value
            $oldPath = $match.Groups[3].Value
            $postamble = $match.Groups[4].Value

            # --- This is the key logic ---
            # Only modify the path if it's a MAIN project.
            # We identify main projects as those that DON'T end in .Tests and DON'T start with Runner.
            if (-not $projectName.EndsWith(".Tests") -and -not $projectName.StartsWith("Runner")) {
                
                # The correct path for a main project is just its name and extension.
                $newPath = "$projectName.csproj"
                
                Write-Host "  - Fixing path for MAIN project '$projectName'"
                Write-Host "    - New path: '$newPath'" -ForegroundColor Green
                
                # Reconstruct the line with the new path
                return "$preamble$newPath$postamble"
            }
            else {
                # If it's not a main project, return the original matched line unchanged.
                return $match.Value
            }
        })

        if ($originalContent -ne $modifiedContent) {
            if (-not $WhatIf) {
                Set-Content -Path $slnPath -Value $modifiedContent -Encoding UTF8
                Write-Host "  - Successfully updated main project paths in '$($slnFile.Name)'." -ForegroundColor Green
            } else {
                Write-Host "  - WHATIF: Would save changes to '$($slnFile.Name)'."
            }
        } else {
            Write-Host "  - No main project path changes were necessary for '$($slnFile.Name)'."
        }

    } catch {
        Write-Error "An error occurred while processing '$slnPath': $_"
    }
}

Write-Host "`n--- All operations complete. ---" -ForegroundColor Green
