# Parallel republish of NuGet packages
# EN: Publishes multiple packages in parallel for faster processing
# CZ: Publikuje více balíčků paralelně pro rychlejší zpracování

param(
    [Parameter(Mandatory=$true)]
    [string]$NuGetApiKey,

    [Parameter(Mandatory=$false)]
    [int]$ThrottleLimit = 8,  # Number of parallel jobs

    [Parameter(Mandatory=$false)]
    [string[]]$SkipPackages = @()  # Packages to skip (already published)
)

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$solutionPath = Join-Path $rootPath "PlatformIndependentNuGetPackages.sln"

Write-Host "Starting parallel republishing with $ThrottleLimit concurrent jobs..." -ForegroundColor Cyan
Write-Host ""

# Get list of all projects
$solutionContent = Get-Content $solutionPath
$projectLines = $solutionContent | Where-Object { $_ -match 'Project\(' }

$projectsToPublish = @()

foreach ($line in $projectLines) {
    if ($line -match '"([^"]+\.csproj)"') {
        $relativePath = $Matches[1]
        $projectPath = Join-Path (Split-Path $solutionPath -Parent) $relativePath

        if (Test-Path $projectPath) {
            $projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectPath)

            # Skip if in skip list
            if ($SkipPackages -contains $projectName) {
                Write-Host "Skipping $projectName (already published)" -ForegroundColor Gray
                continue
            }

            $projectsToPublish += @{
                Name = $projectName
                Path = $projectPath
            }
        }
    }
}

Write-Host "Found $($projectsToPublish.Count) packages to publish" -ForegroundColor Cyan
Write-Host ""

# Publish packages in parallel
$results = $projectsToPublish | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
    $project = $_
    $apiKey = $using:NuGetApiKey
    $projectPath = $project.Path
    $projectName = $project.Name

    # Function to update version
    function Update-Version {
        param([string]$Path)

        $content = Get-Content $Path -Raw
        [xml]$csproj = $content

        $currentVersion = $csproj.Project.PropertyGroup.Version | Where-Object { $_ } | Select-Object -First 1

        if (-not $currentVersion) {
            return $null
        }

        $today = Get-Date
        $year = $today.ToString("yy")
        $month = $today.Month
        $day = $today.Day
        $datePrefix = "$year.$month.$day"

        # Use a lock file to ensure sequence numbers are unique
        $lockFile = "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\.version-lock"
        $maxRetries = 100

        for ($i = 0; $i -lt $maxRetries; $i++) {
            try {
                # Try to create lock file
                $lock = [System.IO.File]::Open($lockFile, 'CreateNew', 'Write', 'None')

                try {
                    # Read current max sequence for today
                    $sequenceFile = "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\.sequence-$datePrefix"
                    $sequence = 1

                    if (Test-Path $sequenceFile) {
                        $sequence = ([int](Get-Content $sequenceFile)) + 1
                    }

                    $newVersion = "$datePrefix.$sequence"

                    # Save new sequence
                    $sequence | Out-File $sequenceFile -Encoding ASCII -NoNewline

                    # Update csproj
                    $content = $content -replace "<Version>$([regex]::Escape($currentVersion))</Version>", "<Version>$newVersion</Version>"
                    $content | Out-File $Path -Encoding UTF8 -NoNewline

                    return @{
                        Old = $currentVersion
                        New = $newVersion
                    }
                }
                finally {
                    $lock.Close()
                    Remove-Item $lockFile -ErrorAction SilentlyContinue
                }
            }
            catch {
                Start-Sleep -Milliseconds (50 + (Get-Random -Maximum 50))
            }
        }

        return $null
    }

    try {
        # Update version
        $versionInfo = Update-Version -Path $projectPath

        if (-not $versionInfo) {
            return @{
                Name = $projectName
                Status = "Failed"
                Message = "Could not update version"
            }
        }

        # Clean
        $projectDir = Split-Path $projectPath -Parent
        $binPath = Join-Path $projectDir "bin"
        $objPath = Join-Path $projectDir "obj"

        if (Test-Path $binPath) {
            Remove-Item $binPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $objPath) {
            Remove-Item $objPath -Recurse -Force -ErrorAction SilentlyContinue
        }

        # Build
        $buildOutput = dotnet pack $projectPath -c Release --output $binPath 2>&1

        if ($LASTEXITCODE -ne 0) {
            return @{
                Name = $projectName
                Status = "Failed"
                Message = "Build failed"
                Version = $versionInfo.New
            }
        }

        # Find .nupkg
        $nupkgFiles = Get-ChildItem -Path $binPath -Filter "*.nupkg" -Recurse | Where-Object { $_.Name -notlike "*.symbols.nupkg" }

        if ($nupkgFiles.Count -eq 0) {
            return @{
                Name = $projectName
                Status = "Failed"
                Message = "No .nupkg file found"
                Version = $versionInfo.New
            }
        }

        $nupkgFile = $nupkgFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1

        # Publish
        $pushOutput = dotnet nuget push $nupkgFile.FullName --api-key $apiKey --source https://api.nuget.org/v3/index.json --skip-duplicate 2>&1

        if ($LASTEXITCODE -ne 0) {
            # Check if it's just a duplicate
            if ($pushOutput -like "*already exists*" -or $pushOutput -like "*409*") {
                return @{
                    Name = $projectName
                    Status = "Skipped"
                    Message = "Already exists (duplicate)"
                    Version = $versionInfo.New
                }
            }

            return @{
                Name = $projectName
                Status = "Failed"
                Message = "Push failed: $pushOutput"
                Version = $versionInfo.New
            }
        }

        return @{
            Name = $projectName
            Status = "Success"
            Version = $versionInfo.New
            OldVersion = $versionInfo.Old
        }
    }
    catch {
        return @{
            Name = $projectName
            Status = "Failed"
            Message = $_.Exception.Message
        }
    }
}

# Display results
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "RESULTS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$success = 0
$failed = 0
$skipped = 0

foreach ($result in $results) {
    switch ($result.Status) {
        "Success" {
            Write-Host "✓ $($result.Name) - $($result.OldVersion) → $($result.Version)" -ForegroundColor Green
            $success++
        }
        "Skipped" {
            Write-Host "⊙ $($result.Name) - $($result.Message)" -ForegroundColor Cyan
            $skipped++
        }
        "Failed" {
            Write-Host "✗ $($result.Name) - $($result.Message)" -ForegroundColor Red
            $failed++
        }
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Successful: $success" -ForegroundColor Green
Write-Host "Skipped: $skipped" -ForegroundColor Cyan
Write-Host "Failed: $failed" -ForegroundColor Red
Write-Host "Total: $($success + $skipped + $failed)" -ForegroundColor White
