<#
.SYNOPSIS
Fixes the project paths within Visual Studio Solution (.sln) files.

.DESCRIPTION
This script iterates through all .sln files in a specified directory. For each solution, it reads the content and finds all project entries. It then corrects the path for each project to be a simple, relative path based on the project's name.

For example, a line like:
Project("{...}") = "MyProject", "some\long\path\MyProject.csproj", "{...}"
will be corrected to:
Project("{...}") = "MyProject", "MyProject\MyProject.csproj", "{...}"

This is useful for cleaning up solution files after project restructuring. A backup of each modified .sln file is created before changes are applied.

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
    Write-Host "`n--- Processing: $($slnFile.Name) ---" -ForegroundColor Cyan

    try {
        $slnContent = Get-Content -Path $slnPath -Raw

        # Create a backup before making any changes
        $backupPath = "$slnPath.backup_pathfix_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        if (-not $WhatIf) {
            Copy-Item -Path $slnPath -Destination $backupPath -Force
            Write-Host "  - Backup created at '$backupPath'"
        } else {
            Write-Host "  - WHATIF: Would create backup at '$backupPath'"
        }

        # Regex to capture the project name and its incorrect path
        # Captures: 1=preamble, 2=project name, 3=project path, 4=postamble
        $projectLinePattern = '(?m)^(Project\(\"{[A-Z0-9\-]+}\"\) = \"([^"]+)\",\s*\")[^"]+(\.csproj\")'
        
        $modifiedContent = [System.Text.RegularExpressions.Regex]::Replace($slnContent, $projectLinePattern, {
            param($match)
            
            $preamble = $match.Groups[1].Value
            $projectName = $match.Groups[2].Value
            $postamble = $match.Groups[3].Value

            # Construct the new, correct relative path
            $newPath = "$projectName\\$projectName.csproj"
            
            # Handle .Tests projects
            if ($projectName.EndsWith(".Tests")) {
                $newPath = "$projectName\\$projectName.csproj"
            }
            # Handle Runner projects
            elseif ($projectName.StartsWith("Runner")) {
                 $newPath = "$projectName\\$projectName.csproj"
            }

            Write-Host "  - Fixing path for project '$projectName'"
            Write-Host "    - Old path was likely incorrect."
            Write-Host "    - New path: '$newPath'" -ForegroundColor Green
            
            # Reconstruct the line
            return "$preamble$newPath$postamble"
        })

        if ($slnContent -ne $modifiedContent) {
            if (-not $WhatIf) {
                Set-Content -Path $slnPath -Value $modifiedContent -Encoding UTF8
                Write-Host "  - Successfully updated project paths in '$($slnFile.Name)'." -ForegroundColor Green
            } else {
                Write-Host "  - WHATIF: Would save changes to '$($slnFile.Name)'."
            }
        } else {
            Write-Host "  - No path changes were necessary for '$($slnFile.Name)'."
        }

    } catch {
        Write-Error "An error occurred while processing '$slnPath': $_"
    }
}

Write-Host "`n--- All operations complete. ---" -ForegroundColor Green
