# EN: Add ALL missing .csproj projects to PlatformIndependentNuGetPackages.Runners.sln
# CZ: Pridat VSECHNY chybejici .csproj projekty do PlatformIndependentNuGetPackages.Runners.sln
$solutionPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\PlatformIndependentNuGetPackages.Runners.sln"
$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

Write-Host "Finding all .csproj files..." -ForegroundColor Cyan
$allProjects = Get-ChildItem -Path $rootPath -Filter "*.csproj" -Recurse

Write-Host "Getting existing projects from solution..." -ForegroundColor Cyan
$existingProjects = dotnet sln $solutionPath list | Where-Object { $_ -match "\.csproj$" }

Write-Host "`nComparing and adding missing projects..." -ForegroundColor Cyan
$added = 0
$skipped = 0

foreach ($project in $allProjects) {
    $relativePath = $project.FullName.Replace("$rootPath\", "")

    if ($existingProjects -contains $relativePath) {
        Write-Host "SKIP (already exists): $relativePath" -ForegroundColor Gray
        $skipped++
    }
    else {
        Write-Host "ADD: $relativePath" -ForegroundColor Yellow
        dotnet sln $solutionPath add $project.FullName
        $added++
    }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Projects added: $added" -ForegroundColor Green
Write-Host "Projects skipped (already in solution): $skipped" -ForegroundColor Gray
Write-Host "Total projects in folder: $($allProjects.Count)" -ForegroundColor Cyan
