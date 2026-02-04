# Check if all Sunamo NuGet packages have TargetFrameworks net8-10
# EN: Verifies all Sunamo* projects have net8.0, net9.0, and net10.0 target frameworks
# CZ: Ověřuje že všechny Sunamo* projekty mají target frameworky net8.0, net9.0 a net10.0

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

Write-Host "Checking TargetFrameworks for all Sunamo NuGet packages..." -ForegroundColor Cyan
Write-Host "Expected: net10.0;net9.0;net8.0 (or any order with all three)" -ForegroundColor Gray
Write-Host ""

# Get all Sunamo* directories (submodules)
$sunamoFolders = Get-ChildItem -Path $rootPath -Directory | Where-Object { $_.Name -like "Sunamo*" }

$correctProjects = @()
$incorrectProjects = @()
$notFoundProjects = @()

foreach ($folder in $sunamoFolders) {
    $projectName = $folder.Name
    $csprojPath = Join-Path $folder.FullName "$projectName\$projectName.csproj"

    if (-not (Test-Path $csprojPath)) {
        $notFoundProjects += [PSCustomObject]@{
            Project = $projectName
            Reason = ".csproj not found at expected location"
        }
        continue
    }

    # Read csproj as XML
    try {
        [xml]$csproj = Get-Content $csprojPath

        # Find TargetFramework or TargetFrameworks
        $targetFramework = $csproj.Project.PropertyGroup.TargetFramework | Where-Object { $_ } | Select-Object -First 1
        $targetFrameworks = $csproj.Project.PropertyGroup.TargetFrameworks | Where-Object { $_ } | Select-Object -First 1

        $frameworks = if ($targetFrameworks) { $targetFrameworks } elseif ($targetFramework) { $targetFramework } else { $null }

        if (-not $frameworks) {
            $incorrectProjects += [PSCustomObject]@{
                Project = $projectName
                Current = "NOT FOUND"
                Issue = "No TargetFramework(s) element found"
            }
            continue
        }

        # Parse frameworks
        $fwList = $frameworks -split ';' | Where-Object { $_ } | ForEach-Object { $_.Trim() } | Select-Object -Unique

        # Check if contains all three: net8.0, net9.0, net10.0
        $hasNet8 = $fwList -contains "net8.0"
        $hasNet9 = $fwList -contains "net9.0"
        $hasNet10 = $fwList -contains "net10.0"

        $hasAllThree = $hasNet8 -and $hasNet9 -and $hasNet10
        $onlyStandard = ($fwList | Where-Object { $_ -notmatch '^net(8|9|10)\.0$' }).Count -eq 0

        if ($hasAllThree -and $onlyStandard) {
            $correctProjects += [PSCustomObject]@{
                Project = $projectName
                TargetFrameworks = $frameworks
            }
        } else {
            $missing = @()
            if (-not $hasNet8) { $missing += "net8.0" }
            if (-not $hasNet9) { $missing += "net9.0" }
            if (-not $hasNet10) { $missing += "net10.0" }

            $extra = $fwList | Where-Object { $_ -notmatch '^net(8|9|10)\.0$' }

            $issue = @()
            if ($missing.Count -gt 0) {
                $issue += "Missing: $($missing -join ', ')"
            }
            if ($extra.Count -gt 0) {
                $issue += "Extra: $($extra -join ', ')"
            }

            $incorrectProjects += [PSCustomObject]@{
                Project = $projectName
                Current = $frameworks
                Issue = $issue -join " | "
            }
        }
    }
    catch {
        $incorrectProjects += [PSCustomObject]@{
            Project = $projectName
            Current = "ERROR"
            Issue = "Failed to parse .csproj: $($_.Exception.Message)"
        }
    }
}

# Display results
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "RESULTS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if ($incorrectProjects.Count -eq 0 -and $notFoundProjects.Count -eq 0) {
    Write-Host "✓ All $($correctProjects.Count) Sunamo projects have correct TargetFrameworks (net8.0;net9.0;net10.0)" -ForegroundColor Green
} else {
    if ($incorrectProjects.Count -gt 0) {
        Write-Host "⚠ INCORRECT TARGETFRAMEWORKS ($($incorrectProjects.Count) projects):" -ForegroundColor Yellow
        Write-Host ""
        foreach ($project in $incorrectProjects | Sort-Object Project) {
            Write-Host "  $($project.Project)" -ForegroundColor Yellow
            Write-Host "    Current: $($project.Current)" -ForegroundColor Gray
            Write-Host "    Issue: $($project.Issue)" -ForegroundColor Red
            Write-Host ""
        }
    }

    if ($notFoundProjects.Count -gt 0) {
        Write-Host "⚠ .CSPROJ NOT FOUND ($($notFoundProjects.Count) projects):" -ForegroundColor Red
        Write-Host ""
        foreach ($project in $notFoundProjects | Sort-Object Project) {
            Write-Host "  $($project.Project)" -ForegroundColor Red
            Write-Host "    Reason: $($project.Reason)" -ForegroundColor Gray
            Write-Host ""
        }
    }

    if ($correctProjects.Count -gt 0) {
        Write-Host "✓ CORRECT TARGETFRAMEWORKS ($($correctProjects.Count) projects):" -ForegroundColor Green
        Write-Host ""
        $correctProjects | Sort-Object Project | Format-Table -AutoSize
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Sunamo projects: $($sunamoFolders.Count)" -ForegroundColor White
Write-Host "Correct: $($correctProjects.Count)" -ForegroundColor Green
Write-Host "Incorrect: $($incorrectProjects.Count)" -ForegroundColor Yellow
Write-Host ".csproj not found: $($notFoundProjects.Count)" -ForegroundColor Red
Write-Host ""

# Exit with error code if there are issues
if ($incorrectProjects.Count -gt 0 -or $notFoundProjects.Count -gt 0) {
    exit 1
}
