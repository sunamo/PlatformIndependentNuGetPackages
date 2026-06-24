<#
.SYNOPSIS
Restores all .sln files in a directory from the OLDEST available backup.

.DESCRIPTION
This script is designed to recover from a series of failed modifications. It scans a directory for solution files (.sln). For each solution, it finds all corresponding backup files (e.g., *.sln.backup_*, *.sln.backup_fix_*). It then identifies the backup with the oldest timestamp in its filename and restores the solution file from that specific backup. This ensures a rollback to the earliest known-good state.

.NOTES
Version: 1.0
Author: GitHub Copilot
Creation Date: 2025-07-30
#>
param(
    [string]$StartDirectory = "E:\vs3\PlatformIndependentNuGetPackages"
)

Write-Host "Starting restoration of .sln files from the oldest backups in '$StartDirectory'..."

# Find all solution files that have at least one backup
$solutionFiles = Get-ChildItem -Path $StartDirectory -Filter "*.sln" -Recurse -File

foreach ($slnFile in $solutionFiles) {
    $slnDir = $slnFile.DirectoryName
    $slnBaseName = $slnFile.BaseName # e.g., "SunamoArgs"
    
    # Find all backup files for the current solution
    $backupFiles = Get-ChildItem -Path $slnDir -Filter "$($slnBaseName).sln.backup_*" -File
    
    if ($null -eq $backupFiles -or $backupFiles.Count -eq 0) {
        Write-Host "No backups found for $($slnFile.Name), skipping." -ForegroundColor Gray
        continue
    }
    
    # Find the oldest backup by sorting by name (which contains the timestamp)
    $oldestBackup = $backupFiles | Sort-Object Name | Select-Object -First 1
    
    if ($null -ne $oldestBackup) {
        try {
            Write-Host "Restoring '$($slnFile.FullName)' from oldest backup '$($oldestBackup.Name)'..." -ForegroundColor Cyan
            Copy-Item -Path $oldestBackup.FullName -Destination $slnFile.FullName -Force
            Write-Host "  SUCCESS: Restored successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "  FAILURE: Could not restore '$($slnFile.FullName)' from '$($oldestBackup.FullName)'. Error: $_"
        }
    }
}

Write-Host "`n--- Restoration process complete. ---" -ForegroundColor Green
