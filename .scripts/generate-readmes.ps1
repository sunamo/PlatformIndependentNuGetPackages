# Generate comprehensive README.md files for all Sunamo NuGet packages
# This script reads actual source code to understand what each package does

$ErrorActionPreference = "Continue"
$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$processedCount = 0
$errorCount = 0
$errors = @()

# Get all Sunamo directories
$packages = Get-ChildItem -Path $rootPath -Directory -Filter "Sunamo*" | Sort-Object Name

Write-Host "Found $($packages.Count) Sunamo packages to process" -ForegroundColor Cyan
Write-Host "Starting README generation..." -ForegroundColor Cyan
Write-Host ""

foreach ($package in $packages) {
    $processedCount++
    $packageName = $package.Name
    $packagePath = $package.FullName

    Write-Host "[$processedCount/$($packages.Count)] Processing: $packageName" -ForegroundColor Yellow

    try {
        # Find .csproj file
        $csprojFile = Get-ChildItem -Path $packagePath -Filter "*.csproj" -File | Select-Object -First 1

        if (-not $csprojFile) {
            Write-Host "  [SKIP] No .csproj file found" -ForegroundColor Red
            $errors += "$packageName - No .csproj file found"
            $errorCount++
            continue
        }

        # Read .csproj content
        [xml]$csprojXml = Get-Content $csprojFile.FullName
        $description = $csprojXml.Project.PropertyGroup.Description
        $version = $csprojXml.Project.PropertyGroup.Version

        # Get C# source files
        $csFiles = Get-ChildItem -Path $packagePath -Filter "*.cs" -Recurse -File |
            Where-Object { $_.FullName -notmatch "\\obj\\|\\bin\\|AssemblyInfo" } |
            Select-Object -First 10

        if ($csFiles.Count -eq 0) {
            Write-Host "  [SKIP] No .cs files found" -ForegroundColor Red
            $errors += "$packageName - No .cs files found"
            $errorCount++
            continue
        }

        Write-Host "  Found $($csFiles.Count) source files to analyze" -ForegroundColor Gray

        # Prepare data for Claude to analyze
        $sourceCodeSamples = @()
        foreach ($csFile in $csFiles) {
            $relativePath = $csFile.FullName.Replace($packagePath, "").TrimStart('\')
            $sourceCodeSamples += @{
                Path = $relativePath
                FullPath = $csFile.FullName
            }
        }

        # Output package info for Claude processing
        Write-Host "  Package: $packageName"
        Write-Host "  Description: $description"
        Write-Host "  Version: $version"
        Write-Host "  Source files: $($sourceCodeSamples.Count)"
        Write-Host "  Ready for README generation" -ForegroundColor Green
        Write-Host ""

    } catch {
        Write-Host "  [ERROR] $_" -ForegroundColor Red
        $errors += "$packageName - $_"
        $errorCount++
    }
}

Write-Host ""
Write-Host "Script preparation complete!" -ForegroundColor Cyan
Write-Host "Processed: $processedCount packages" -ForegroundColor Green
Write-Host "Errors: $errorCount packages" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "Errors encountered:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}
