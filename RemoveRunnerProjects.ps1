#Requires -Version 5
<#
 .SYNOPSIS
 A script to remove runner projects from Visual Studio Solution (.sln) files.
 .DESCRIPTION
 This script scans a directory for .sln files and removes any project entries
 where the project name starts with "Runner". It's designed to clean up solutions
 where runner projects were added incorrectly, causing issues like duplicate
 project references. The script makes a backup of each modified .sln file
 before making changes.
 .NOTES
 Version: 1.0
 Author: GitHub Copilot
 Creation Date: 2024-07-30
#>

# Configuration
$startDirectory = "E:\vs3\PlatformIndependentNuGetPackages"
$backupSuffix = ".backup_runner_removed"

# Regular expression to find runner project entries in a .sln file.
# This pattern is designed to match the entire multi-line block for a project
# whose name starts with "Runner".
$runnerProjectPattern = '(?ms)Project\(\"{[A-Z0-9\-]+}\"\)\s*=\s*\"Runner[^"]+\".*?EndProject'

# Find all solution files recursively
$solutionFiles = Get-ChildItem -Path $startDirectory -Filter *.sln -Recurse

if ($solutionFiles.Count -eq 0) {
    Write-Output "No solution files found in the specified directory."
    exit
}

Write-Output "Found $($solutionFiles.Count) solution files. Processing..."

foreach ($slnFile in $solutionFiles) {
    try {
        $slnPath = $slnFile.FullName
        $slnContent = Get-Content -Path $slnPath -Raw

        # Check if the file contains a runner project before proceeding
        if ($slnContent -match $runnerProjectPattern) {
            Write-Host "Processing '$slnPath'..."

            # Create a backup before modifying
            $backupPath = $slnPath + $backupSuffix
            Copy-Item -Path $slnPath -Destination $backupPath -Force
            Write-Host "  - Backup created at '$backupPath'"

            # Remove all occurrences of the runner project pattern
            $modifiedContent = [System.Text.RegularExpressions.Regex]::Replace($slnContent, $runnerProjectPattern, "")

            # Clean up any resulting excess empty lines to make the file tidy.
            # This replaces three or more consecutive newlines with just two.
            $cleanedContent = [System.Text.RegularExpressions.Regex]::Replace($modifiedContent, "(\r?\n){3,}", "`r`n`r`n")

            # Save the modified content back to the original file
            Set-Content -Path $slnPath -Value $cleanedContent -Encoding UTF8
            Write-Host "  - Successfully removed runner project entries."
        }
    }
    catch {
        Write-Error "An error occurred while processing '$($slnFile.FullName)': $_"
    }
}

Write-Output "Script finished. All targeted solution files have been processed."
