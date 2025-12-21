# Get TargetFrameworks for all projects in solution

$solutionPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\PlatformIndependentNuGetPackages.sln"

if (-not (Test-Path $solutionPath)) {
    Write-Error "Solution file not found: $solutionPath"
    exit 1
}

Write-Host "Reading solution file: $solutionPath" -ForegroundColor Cyan
Write-Host ""

# Read solution file and extract project paths
$solutionContent = Get-Content $solutionPath
$projectLines = $solutionContent | Where-Object { $_ -match 'Project\(' }

$results = @()

foreach ($line in $projectLines) {
    # Extract project path from line like: Project("{...}") = "ProjectName", "Path\To\Project.csproj", "{...}"
    if ($line -match '"([^"]+\.csproj)"') {
        $relativePath = $Matches[1]
        $projectPath = Join-Path (Split-Path $solutionPath -Parent) $relativePath

        if (Test-Path $projectPath) {
            # Read csproj file
            [xml]$csproj = Get-Content $projectPath

            # Try to find TargetFramework or TargetFrameworks
            $targetFramework = $csproj.Project.PropertyGroup.TargetFramework | Where-Object { $_ } | Select-Object -First 1
            $targetFrameworks = $csproj.Project.PropertyGroup.TargetFrameworks | Where-Object { $_ } | Select-Object -First 1

            $frameworks = if ($targetFrameworks) { $targetFrameworks } elseif ($targetFramework) { $targetFramework } else { "NOT FOUND" }

            $projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectPath)

            $results += [PSCustomObject]@{
                Project = $projectName
                TargetFrameworks = $frameworks
                Path = $relativePath
            }
        }
    }
}

# Sort by project name and display
$results | Sort-Object Project | Format-Table -AutoSize

Write-Host ""
Write-Host "Total projects: $($results.Count)" -ForegroundColor Green
