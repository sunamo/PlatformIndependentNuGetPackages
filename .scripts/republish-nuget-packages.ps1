# Republish NuGet packages with correct target frameworks (net10.0;net9.0;net8.0)
# EN: Checks published NuGet packages and republishes those without net10.0;net9.0;net8.0
# CZ: Kontroluje publikované NuGet balíčky a znovu publikuje ty bez net10.0;net9.0;net8.0

param(
    [Parameter(Mandatory=$false)]
    [string[]]$ProjectNames = @(),

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,  # Only check, don't publish

    [Parameter(Mandatory=$false)]
    [string]$NuGetApiKey = $env:NUGET_API_KEY,  # API key from environment variable

    [Parameter(Mandatory=$false)]
    [switch]$Force  # Force republish even if already correct
)

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$solutionPath = Join-Path $rootPath "PlatformIndependentNuGetPackages.sln"

if (-not $NuGetApiKey -and -not $DryRun) {
    Write-Error "NuGet API key not found. Set NUGET_API_KEY environment variable or use -NuGetApiKey parameter"
    Write-Host "For dry run (check only), use -DryRun switch" -ForegroundColor Yellow
    exit 1
}

Write-Host "Checking NuGet packages for Sunamo..." -ForegroundColor Cyan
Write-Host ""

# Function to get package info from NuGet.org
function Get-NuGetPackageInfo {
    param([string]$PackageName)

    try {
        # Use NuGet V3 API
        $searchUrl = "https://api-v2v3search-0.nuget.org/query?q=packageid:$PackageName&prerelease=false"
        $response = Invoke-RestMethod -Uri $searchUrl -Method Get -ErrorAction Stop

        if ($response.data.Count -eq 0) {
            return $null
        }

        # Get exact match
        $package = $response.data | Where-Object { $_.id -eq $PackageName } | Select-Object -First 1

        if (-not $package) {
            return $null
        }

        return @{
            Id = $package.id
            Version = $package.version
            TotalDownloads = $package.totalDownloads
        }
    }
    catch {
        Write-Warning "Failed to get info for ${PackageName}: $_"
        return $null
    }
}

# Function to get target frameworks from .nuspec
function Get-PackageTargetFrameworks {
    param(
        [string]$PackageName,
        [string]$Version
    )

    try {
        # Download .nuspec file
        $nuspecUrl = "https://api.nuget.org/v3-flatcontainer/$($PackageName.ToLower())/$Version/$($PackageName.ToLower()).nuspec"
        $nuspecContent = Invoke-RestMethod -Uri $nuspecUrl -Method Get -ErrorAction Stop

        # Parse XML
        [xml]$nuspec = $nuspecContent

        # Get target frameworks from dependencies
        $frameworks = @()

        # Check if there's a dependencies section
        $dependencies = $nuspec.package.metadata.dependencies

        if ($dependencies) {
            if ($dependencies.group) {
                # Multiple target frameworks
                foreach ($group in $dependencies.group) {
                    $targetFramework = $group.targetFramework
                    if ($targetFramework) {
                        $frameworks += $targetFramework
                    }
                }
            }
            elseif ($dependencies.dependency) {
                # Single target framework (usually .NET Standard or legacy)
                $frameworks += "legacy"
            }
        }

        # If no dependencies, try to get from files section (this requires downloading the .nupkg)
        if ($frameworks.Count -eq 0) {
            # Try alternative: download nupkg and check lib folder structure
            $nupkgUrl = "https://api.nuget.org/v3-flatcontainer/$($PackageName.ToLower())/$Version/$($PackageName.ToLower()).$Version.nupkg"

            $tempFile = [System.IO.Path]::GetTempFileName() + ".nupkg"
            Invoke-WebRequest -Uri $nupkgUrl -OutFile $tempFile -ErrorAction Stop

            # Extract and check lib folder
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $zip = [System.IO.Compression.ZipFile]::OpenRead($tempFile)

            try {
                $libEntries = $zip.Entries | Where-Object { $_.FullName -like "lib/*" -and $_.FullName -match "lib/([^/]+)/" }

                foreach ($entry in $libEntries) {
                    if ($entry.FullName -match "lib/([^/]+)/") {
                        $fw = $Matches[1]
                        if ($frameworks -notcontains $fw) {
                            $frameworks += $fw
                        }
                    }
                }
            }
            finally {
                $zip.Dispose()
                Remove-Item $tempFile -ErrorAction SilentlyContinue
            }
        }

        return $frameworks | Sort-Object -Unique
    }
    catch {
        Write-Warning "Failed to get target frameworks for ${PackageName} ${Version}: $_"
        return @()
    }
}

# Function to check if frameworks are standard
function Test-StandardFrameworks {
    param([string[]]$Frameworks)

    if ($Frameworks.Count -eq 0) {
        return $false
    }

    # Check for exact match: net10.0, net9.0, net8.0
    $hasNet10 = $Frameworks -contains "net10.0"
    $hasNet9 = $Frameworks -contains "net9.0"
    $hasNet8 = $Frameworks -contains "net8.0"

    # Check that ONLY these frameworks are present
    $onlyStandard = $true
    foreach ($fw in $Frameworks) {
        if ($fw -notin @("net10.0", "net9.0", "net8.0")) {
            $onlyStandard = $false
            break
        }
    }

    return ($hasNet10 -and $hasNet9 -and $hasNet8 -and $onlyStandard)
}

# Function to update package version to today's date
function Update-PackageVersion {
    param([string]$ProjectPath)

    # Read csproj
    $csprojContent = Get-Content $ProjectPath -Raw
    [xml]$csproj = $csprojContent

    # Get current version
    $currentVersion = $csproj.Project.PropertyGroup.Version | Where-Object { $_ } | Select-Object -First 1

    if (-not $currentVersion) {
        Write-Warning "  No version found in project"
        return $false
    }

    # Calculate new version based on today's date: year.month.day.sequence
    $today = Get-Date
    $year = $today.ToString("yy")
    $month = $today.Month
    $day = $today.Day
    $datePrefix = "$year.$month.$day"

    # Check if current version is from today
    if ($currentVersion -match "^$([regex]::Escape($datePrefix))\.(\d+)$") {
        # Same day - increment sequence
        $sequence = [int]$Matches[1] + 1
        $newVersion = "$datePrefix.$sequence"
    }
    else {
        # Different day - start with sequence 1
        $newVersion = "$datePrefix.1"
    }

    # Update version in file
    $csprojContent = $csprojContent -replace "<Version>$([regex]::Escape($currentVersion))</Version>", "<Version>$newVersion</Version>"

    # Save file
    $csprojContent | Out-File $ProjectPath -Encoding UTF8 -NoNewline

    Write-Host "  Version updated: $currentVersion → $newVersion" -ForegroundColor Cyan

    return $true
}

# Function to build and publish package
function Publish-NuGetPackage {
    param(
        [string]$ProjectPath,
        [string]$PackageName
    )

    Write-Host "  Building $PackageName..." -ForegroundColor White

    # Update version to today's date
    $versionUpdated = Update-PackageVersion -ProjectPath $ProjectPath

    if (-not $versionUpdated) {
        Write-Error "  Failed to update version for $PackageName"
        return $false
    }

    # Clean previous builds
    $projectDir = Split-Path $ProjectPath -Parent
    $binPath = Join-Path $projectDir "bin"
    $objPath = Join-Path $projectDir "obj"

    if (Test-Path $binPath) {
        Remove-Item $binPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path $objPath) {
        Remove-Item $objPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Build package
    $buildResult = dotnet pack $ProjectPath -c Release --output $binPath 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Error "  Build failed for $PackageName"
        Write-Host $buildResult -ForegroundColor Red
        return $false
    }

    # Find the .nupkg file
    $nupkgFiles = Get-ChildItem -Path $binPath -Filter "*.nupkg" -Recurse | Where-Object { $_.Name -notlike "*.symbols.nupkg" }

    if ($nupkgFiles.Count -eq 0) {
        Write-Error "  No .nupkg file found for $PackageName"
        return $false
    }

    $nupkgFile = $nupkgFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1

    Write-Host "  Package built: $($nupkgFile.Name)" -ForegroundColor Green

    if ($DryRun) {
        Write-Host "  [DRY RUN] Would publish: $($nupkgFile.FullName)" -ForegroundColor Yellow
        return $true
    }

    # Publish to NuGet.org
    Write-Host "  Publishing to NuGet.org..." -ForegroundColor White

    $pushResult = dotnet nuget push $nupkgFile.FullName --api-key $NuGetApiKey --source https://api.nuget.org/v3/index.json 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Error "  Publish failed for $PackageName"
        Write-Host $pushResult -ForegroundColor Red
        return $false
    }

    Write-Host "  Successfully published $PackageName" -ForegroundColor Green
    return $true
}

# Main logic
Write-Host "Step 1: Getting list of projects from solution..." -ForegroundColor Cyan

$solutionContent = Get-Content $solutionPath
$projectLines = $solutionContent | Where-Object { $_ -match 'Project\(' }

$results = @()
$toRepublish = @()

foreach ($line in $projectLines) {
    if ($line -match '"([^"]+\.csproj)"') {
        $relativePath = $Matches[1]
        $projectPath = Join-Path (Split-Path $solutionPath -Parent) $relativePath

        if (Test-Path $projectPath) {
            [xml]$csproj = Get-Content $projectPath
            $projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectPath)

            # Filter by project names if specified
            if ($ProjectNames.Count -gt 0 -and $projectName -notin $ProjectNames) {
                continue
            }

            # Get local target frameworks
            $targetFramework = $csproj.Project.PropertyGroup.TargetFramework | Where-Object { $_ } | Select-Object -First 1
            $targetFrameworks = $csproj.Project.PropertyGroup.TargetFrameworks | Where-Object { $_ } | Select-Object -First 1
            $localFrameworks = if ($targetFrameworks) { $targetFrameworks } elseif ($targetFramework) { $targetFramework } else { $null }

            if (-not $localFrameworks) {
                continue
            }

            Write-Host "Checking $projectName..." -ForegroundColor White

            # Get package info from NuGet.org
            $packageInfo = Get-NuGetPackageInfo -PackageName $projectName

            if (-not $packageInfo) {
                Write-Host "  Not found on NuGet.org (skipping)" -ForegroundColor Yellow
                continue
            }

            Write-Host "  Latest version: $($packageInfo.Version)" -ForegroundColor Gray
            Write-Host "  Downloads: $($packageInfo.TotalDownloads)" -ForegroundColor Gray

            # Get target frameworks from published package
            $publishedFrameworks = Get-PackageTargetFrameworks -PackageName $projectName -Version $packageInfo.Version

            Write-Host "  Published frameworks: $($publishedFrameworks -join '; ')" -ForegroundColor Gray
            Write-Host "  Local frameworks: $localFrameworks" -ForegroundColor Gray

            # Check if published package has standard frameworks
            $isStandard = Test-StandardFrameworks -Frameworks $publishedFrameworks

            if ($isStandard -and -not $Force) {
                Write-Host "  ✓ Already has standard frameworks" -ForegroundColor Green
            }
            else {
                if ($Force) {
                    Write-Host "  → FORCE: Will republish" -ForegroundColor Yellow
                }
                else {
                    Write-Host "  → Needs republishing" -ForegroundColor Yellow
                }

                $toRepublish += @{
                    ProjectName = $projectName
                    ProjectPath = $projectPath
                    LocalFrameworks = $localFrameworks
                    PublishedFrameworks = $publishedFrameworks -join '; '
                    Version = $packageInfo.Version
                }
            }

            Write-Host ""
        }
    }
}

# Summary
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total packages checked: $($results.Count + $toRepublish.Count)" -ForegroundColor White
Write-Host "Packages to republish: $($toRepublish.Count)" -ForegroundColor Yellow
Write-Host ""

if ($toRepublish.Count -eq 0) {
    Write-Host "All packages are up to date!" -ForegroundColor Green
    exit 0
}

# Show packages to republish
Write-Host "Packages that will be republished:" -ForegroundColor Yellow
foreach ($pkg in $toRepublish) {
    Write-Host "  - $($pkg.ProjectName)" -ForegroundColor White
    Write-Host "    Published: $($pkg.PublishedFrameworks)" -ForegroundColor Gray
    Write-Host "    Local: $($pkg.LocalFrameworks)" -ForegroundColor Gray
}
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] No packages will be published" -ForegroundColor Yellow
    exit 0
}

# Confirm before publishing (skip if running non-interactively)
if ([Environment]::UserInteractive -and -not $Force) {
    Write-Host "Do you want to proceed with publishing these packages? (Y/N)" -ForegroundColor Yellow
    $confirmation = Read-Host

    if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
        Write-Host "Cancelled by user" -ForegroundColor Red
        exit 0
    }
}
else {
    Write-Host "Auto-confirming (non-interactive mode or -Force specified)" -ForegroundColor Yellow
}

# Publish packages
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "PUBLISHING PACKAGES" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$published = 0
$failed = 0

foreach ($pkg in $toRepublish) {
    Write-Host "Publishing $($pkg.ProjectName)..." -ForegroundColor Cyan

    $success = Publish-NuGetPackage -ProjectPath $pkg.ProjectPath -PackageName $pkg.ProjectName

    if ($success) {
        $published++
    }
    else {
        $failed++
    }

    Write-Host ""
}

# Final summary
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "FINAL SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Successfully published: $published" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red
