<#
.SYNOPSIS
Adds the corresponding 'Runner' project to each Visual Studio Solution (.sln) file in a specified directory.

.DESCRIPTION
This script iterates through all subdirectories of a given starting directory, looking for solution files (.sln).
For each solution found, it searches for a corresponding project file with a '.Runner.csproj' suffix in the same directory.
If a matching runner project is found, it is added to the solution using the 'dotnet sln add' command.

The script is designed to correctly associate runner projects with their solutions, which is a common requirement
for projects that have separate executable runners for testing or execution purposes.

.NOTES
Version: 2.0
Author: GitHub Copilot
Creation Date: 2024-07-30
#>

param(
    [string]$startDirectory = "E:\vs3\PlatformIndependentNuGetPackages"
)

# Get all solution files in the specified directory and its subdirectories
$solutionFiles = Get-ChildItem -Path $startDirectory -Filter *.sln -Recurse

if ($solutionFiles.Count -eq 0) {
    Write-Warning "No solution files (.sln) found in '$startDirectory'."
    return
}

Write-Host "Found $($solutionFiles.Count) solution files. Starting to process..."

foreach ($slnFile in $solutionFiles) {
    $slnPath = $slnFile.FullName
    $slnDir = $slnFile.DirectoryName
    $slnName = $slnFile.BaseName

    # Define the expected name for the runner project's csproj file
    $runnerProjectName = "$($slnName).Runner.csproj"
    $runnerProjectPath = Join-Path -Path $slnDir -ChildPath $runnerProjectName

    # Check if the runner project file exists
    if (Test-Path -Path $runnerProjectPath) {
        Write-Host "Processing solution: '$slnPath'"
        Write-Host "  - Found corresponding runner project: '$runnerProjectPath'"

        try {
            # Add the runner project to the solution
            dotnet sln "$slnPath" add "$runnerProjectPath"
            Write-Host "  - Successfully added '$runnerProjectName' to '$($slnFile.Name)'."
        }
        catch {
            Write-Error "Failed to add project '$runnerProjectPath' to solution '$slnPath'. Error: $_"
        }
    }
    else {
        # This is expected for some solutions, so we use Write-Verbose instead of Write-Warning
        Write-Verbose "No corresponding runner project found for '$slnPath'."
    }
}

Write-Host "Script finished."
