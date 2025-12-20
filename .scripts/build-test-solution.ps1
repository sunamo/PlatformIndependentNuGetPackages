# Build PlatformIndependentNuGetPackages.Tests.sln to verify all projects are buildable
param(
    [switch]$Clean,
    [switch]$Restore
)

$solutionPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\PlatformIndependentNuGetPackages.Tests.sln"
$configuration = "Debug"

Write-Host "Building solution: $solutionPath" -ForegroundColor Cyan
Write-Host "Configuration: $configuration" -ForegroundColor Yellow

# Clean if requested
if ($Clean) {
    Write-Host "`nCleaning solution..." -ForegroundColor Yellow
    dotnet clean $solutionPath --configuration $configuration
}

# Restore if requested
if ($Restore) {
    Write-Host "`nRestoring packages..." -ForegroundColor Yellow
    dotnet restore $solutionPath
}

# Build the solution
Write-Host "`nBuilding solution..." -ForegroundColor Green
$buildResult = dotnet build $solutionPath --configuration $configuration --no-incremental 2>&1

# Check for errors
$errors = $buildResult | Where-Object { $_ -match "error" }
$warnings = $buildResult | Where-Object { $_ -match "warning" }

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nBuild FAILED!" -ForegroundColor Red
    Write-Host "Errors found:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    exit 1
} else {
    Write-Host "`nBuild SUCCEEDED!" -ForegroundColor Green

    if ($warnings.Count -gt 0) {
        Write-Host "`nWarnings: $($warnings.Count)" -ForegroundColor Yellow
    } else {
        Write-Host "No warnings" -ForegroundColor Green
    }

    Write-Host "`nAll projects in PlatformIndependentNuGetPackages.Tests.sln are buildable!" -ForegroundColor Green
}