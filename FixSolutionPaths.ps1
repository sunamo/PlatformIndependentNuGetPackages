<#
.SYNOPSIS
Fixes incorrect project paths within Visual Studio Solution (.sln) files.

.DESCRIPTION
This script scans for all .sln files in the specified directory. For each solution, it reads the content and finds all project references. It then normalizes the path for each project reference to be a simple, direct path relative to the solution file (e.g., "MyProject.csproj" instead of "MyProject\MyProject.csproj" or "..\..\MyProject.csproj").

This ensures that all projects are correctly located by Visual Studio, especially after file restructuring. The script automatically creates a backup of each modified .sln file.

.PARAMETER MainDirectory
The absolute path to the main directory containing the project folders with .sln files.
Default: "E:\vs3\PlatformIndependentNuGetPackages"

.PARAMETER WhatIf
A switch parameter that, if present, causes the script to report the changes it would have made without actually performing them.

.EXAMPLE
# Perform a dry run to see which solution files would be modified.
.\FixSolutionPaths.ps1 -WhatIf

.EXAMPLE
# Execute the script to fix the project paths in all solution files.
.\FixSolutionPaths.ps1
#>
param(
    [string]$MainDirectory = "E:\vs3\PlatformIndependentNuGetPackages",
    [switch]$WhatIf
)

# --- 1. Find all solution files recursively ---
Write-Host "Scanning for .sln files in '$MainDirectory'..." -ForegroundColor Yellow
try {
    $solutionFiles = Get-ChildItem -Path $MainDirectory -Filter "*.sln" -Recurse -File -ErrorAction Stop
} catch {
    Write-Error "Critical error finding .sln files: $($_.Exception.Message)"
    return
}

if ($solutionFiles.Count -eq 0) {
    Write-Host "No .sln files found in the specified directory."
    return
}

Write-Host "Found $($solutionFiles.Count) solution files to process." -ForegroundColor Green
if ($WhatIf) {
    Write-Host "--- SIMULATION MODE (WhatIf) ENABLED ---" -ForegroundColor Magenta
}

# --- 2. Process each solution file ---
foreach ($slnFile in $solutionFiles) {
    Write-Host "`n--- Processing: $($slnFile.FullName) ---" -ForegroundColor Cyan
    
    try {
        $originalContent = Get-Content -Path $slnFile.FullName -Raw
        $modifiedContent = $originalContent
        $wasModified = $false

        # Regex to find project lines and capture the full project path
        # Pattern captures: 1=pre-path, 2=the-path, 3=post-path
        $pattern = '(Project\("{[A-Z0-9\-]+}"\) = "[^"]+", ")([^"]+)(")'
        
        # Use a match evaluator to process each find
        $evaluator = {
            param($match)
            
            $prePath = $match.Groups[1].Value
            $projectPath = $match.Groups[2].Value
            $postPath = $match.Groups[3].Value
            
            # Normalize the path by taking only the filename
            $normalizedPath = Split-Path -Path $projectPath -Leaf
            
            # If the path changed, mark for modification
            if ($projectPath -ne $normalizedPath) {
                Write-Host "  - Fixing path for '$normalizedPath'" -ForegroundColor Yellow
                Write-Host "    Old: $projectPath"
                Write-Host "    New: $normalizedPath"
                $script:wasModified = $true
                return "$prePath$normalizedPath$postPath"
            } else {
                # Return the original match if no change is needed
                return $match.Value
            }
        }

        # Reset the flag for each file
        $script:wasModified = $false
        $modifiedContent = [regex]::Replace($originalContent, $pattern, $evaluator)

        if ($script:wasModified) {
            Write-Host "  Solution file requires updates." -ForegroundColor Green
            if ($WhatIf) {
                Write-Host "    WHATIF: Would save changes to $($slnFile.Name)"
            } else {
                # Create a backup
                $backupPath = "$($slnFile.FullName).backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                Write-Host "    Creating backup: $backupPath"
                Copy-Item -Path $slnFile.FullName -Destination $backupPath -Force
                
                # Save the modified content
                Set-Content -Path $slnFile.FullName -Value $modifiedContent -Encoding UTF8
                Write-Host "    SUCCESS: Solution file updated and backup created." -ForegroundColor Green
            }
        } else {
            Write-Host "  Solution file is already correct. No changes needed." -ForegroundColor Gray
        }

    } catch {
        Write-Error "  An error occurred while processing $($slnFile.Name): $($_.Exception.Message)"
    }
}

Write-Host "`n--- All operations complete. ---" -ForegroundColor Green
