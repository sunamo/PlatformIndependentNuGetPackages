<#
.SYNOPSIS
Restores .sln files from the backups created by the previous script.

.DESCRIPTION
This script finds all backup files (*.sln.backup_*) in the specified directory and restores them to their original .sln filenames, effectively undoing the changes made by the previous script.

.PARAMETER MainDirectory
The absolute path to the main directory to scan for backups.
Default: "E:\vs3\PlatformIndependentNuGetPackages"

.PARAMETER WhatIf
A switch parameter that, if present, causes the script to report which files would be restored without actually performing the action.

.EXAMPLE
# See which solution files would be restored.
.\RestoreSolutionsFromBackup.ps1 -WhatIf

.EXAMPLE
# Restore all solution files from the most recent backups.
.\RestoreSolutionsFromBackup.ps1
#>
param(
    [string]$MainDirectory = "E:\vs3\PlatformIndependentNuGetPackages",
    [switch]$WhatIf
)

# --- 1. Find all backup files ---
Write-Host "Scanning for .sln.backup_* files in '$MainDirectory'..." -ForegroundColor Yellow
try {
    $backupFiles = Get-ChildItem -Path $MainDirectory -Filter "*.sln.backup_*" -Recurse -File -ErrorAction Stop
} catch {
    Write-Error "Critical error finding backup files: $($_.Exception.Message)"
    return
}

if ($backupFiles.Count -eq 0) {
    Write-Host "No backup files found to restore."
    return
}

Write-Host "Found $($backupFiles.Count) backup files to potentially restore." -ForegroundColor Green
if ($WhatIf) {
    Write-Host "--- SIMULATION MODE (WhatIf) ENABLED ---" -ForegroundColor Magenta
} else {
    $confirmation = Read-Host "Proceed with restoring $($backupFiles.Count) .sln files from their backups? (y/n)"
    if ($confirmation -ne 'y') {
        Write-Host "Operation cancelled by user."
        return
    }
}

# --- 2. Process each backup file ---
foreach ($backupFile in $backupFiles) {
    # Construct the original filename by removing the .backup_* suffix
    $originalPath = $backupFile.FullName -replace '\.backup_.*$', ''
    
    Write-Host "`n--- Restoring: $($originalPath) ---" -ForegroundColor Cyan
    Write-Host "  From backup: $($backupFile.Name)"

    if ($WhatIf) {
        Write-Host "    WHATIF: Would copy '$($backupFile.FullName)' to '$originalPath'"
    } else {
        try {
            Copy-Item -Path $backupFile.FullName -Destination $originalPath -Force -ErrorAction Stop
            Write-Host "    SUCCESS: Restored '$originalPath' successfully." -ForegroundColor Green
        } catch {
            Write-Error "    FAILURE: Could not restore '$originalPath'. Error: $($_.Exception.Message)"
        }
    }
}

Write-Host "`n--- Restoration complete. ---" -ForegroundColor Green
