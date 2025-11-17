# EN: Add all Runner projects to PlatformIndependentNuGetPackages.Runners.sln
# CZ: Pridat vsechny Runner projekty do PlatformIndependentNuGetPackages.Runners.sln
$solutionPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\PlatformIndependentNuGetPackages.Runners.sln"
$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

Write-Host "Adding Runner projects to solution..." -ForegroundColor Cyan

$runnerProjects = Get-ChildItem -Path $rootPath -Filter "Runner*.csproj" -Recurse
$count = 0

foreach ($project in $runnerProjects) {
    Write-Host "Adding: $($project.FullName)" -ForegroundColor Yellow
    dotnet sln $solutionPath add $project.FullName
    $count++
}

Write-Host "`nTotal Runner projects added: $count" -ForegroundColor Green