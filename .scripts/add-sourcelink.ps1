#!/usr/bin/env pwsh
# Adds SourceLink configuration to all NuGet package .csproj files

$ErrorActionPreference = "Stop"

# Find all Sunamo* root directories
$rootDirs = Get-ChildItem -Path . -Directory -Filter "Sunamo*" | Where-Object { $_.Name -notlike "*Tests" -and $_.Name -notlike "Runner*" }

$updatedCount = 0
$skippedCount = 0
$errors = @()

foreach ($rootDir in $rootDirs) {
    # Check if there's a subdirectory with the same name (NuGet package structure)
    $projectDir = Join-Path $rootDir.FullName $rootDir.Name

    if (-not (Test-Path $projectDir)) {
        Write-Host "Skipping $($rootDir.Name): No matching subdirectory found" -ForegroundColor Yellow
        $skippedCount++
        continue
    }

    # Find .csproj file
    $csprojFile = Join-Path $projectDir "$($rootDir.Name).csproj"

    if (-not (Test-Path $csprojFile)) {
        Write-Host "Skipping $($rootDir.Name): No .csproj file found at $csprojFile" -ForegroundColor Yellow
        $skippedCount++
        continue
    }

    try {
        Write-Host "Processing $($rootDir.Name)..." -ForegroundColor Cyan

        # Load XML
        [xml]$csproj = Get-Content $csprojFile

        # Check if it's packable (skip if not)
        $isPackable = $csproj.Project.PropertyGroup.IsPackable
        if ($isPackable -eq "false") {
            Write-Host "  Skipping $($rootDir.Name): IsPackable=false" -ForegroundColor Yellow
            $skippedCount++
            continue
        }

        $modified = $false

        # 1. Add SourceLink PropertyGroup if not exists
        $hasDebugType = $false
        $hasPublishRepoUrl = $false
        $hasEmbedUntracked = $false
        $hasContinuousIntegration = $false

        foreach ($propGroup in $csproj.Project.PropertyGroup) {
            if ($propGroup.DebugType) { $hasDebugType = $true }
            if ($propGroup.PublishRepositoryUrl) { $hasPublishRepoUrl = $true }
            if ($propGroup.EmbedUntrackedSources) { $hasEmbedUntracked = $true }
            if ($propGroup.ContinuousIntegrationBuild) { $hasContinuousIntegration = $true }
        }

        if (-not ($hasDebugType -and $hasPublishRepoUrl -and $hasEmbedUntracked -and $hasContinuousIntegration)) {
            Write-Host "  Adding SourceLink PropertyGroup..." -ForegroundColor Green

            # Create new PropertyGroup
            $newPropGroup = $csproj.CreateElement("PropertyGroup")

            if (-not $hasDebugType) {
                $debugType = $csproj.CreateElement("DebugType")
                $debugType.InnerText = "embedded"
                $newPropGroup.AppendChild($debugType) | Out-Null
            }

            if (-not $hasPublishRepoUrl) {
                $publishRepoUrl = $csproj.CreateElement("PublishRepositoryUrl")
                $publishRepoUrl.InnerText = "true"
                $newPropGroup.AppendChild($publishRepoUrl) | Out-Null
            }

            if (-not $hasEmbedUntracked) {
                $embedUntracked = $csproj.CreateElement("EmbedUntrackedSources")
                $embedUntracked.InnerText = "true"
                $newPropGroup.AppendChild($embedUntracked) | Out-Null
            }

            if (-not $hasContinuousIntegration) {
                $continuousIntegration = $csproj.CreateElement("ContinuousIntegrationBuild")
                $continuousIntegration.InnerText = "true"
                $newPropGroup.AppendChild($continuousIntegration) | Out-Null
            }

            # Add PropertyGroup after the first PropertyGroup
            $firstPropGroup = $csproj.Project.PropertyGroup | Select-Object -First 1
            $csproj.Project.InsertAfter($newPropGroup, $firstPropGroup) | Out-Null

            $modified = $true
        } else {
            Write-Host "  SourceLink PropertyGroup already exists" -ForegroundColor Gray
        }

        # 2. Add Microsoft.SourceLink.GitHub PackageReference if not exists
        $hasSourceLink = $false

        foreach ($itemGroup in $csproj.Project.ItemGroup) {
            foreach ($packageRef in $itemGroup.PackageReference) {
                if ($packageRef.Include -eq "Microsoft.SourceLink.GitHub") {
                    $hasSourceLink = $true
                    break
                }
            }
            if ($hasSourceLink) { break }
        }

        if (-not $hasSourceLink) {
            Write-Host "  Adding Microsoft.SourceLink.GitHub PackageReference..." -ForegroundColor Green

            # Create new ItemGroup or use existing one
            $itemGroup = $csproj.Project.ItemGroup | Where-Object { $_.PackageReference } | Select-Object -First 1

            if (-not $itemGroup) {
                # Create new ItemGroup
                $itemGroup = $csproj.CreateElement("ItemGroup")
                $csproj.Project.AppendChild($itemGroup) | Out-Null
            }

            # Create PackageReference
            $packageRef = $csproj.CreateElement("PackageReference")
            $packageRef.SetAttribute("Include", "Microsoft.SourceLink.GitHub")
            $packageRef.SetAttribute("Version", "8.0.*")
            $packageRef.SetAttribute("PrivateAssets", "All")
            $itemGroup.AppendChild($packageRef) | Out-Null

            $modified = $true
        } else {
            Write-Host "  Microsoft.SourceLink.GitHub PackageReference already exists" -ForegroundColor Gray
        }

        # Save if modified
        if ($modified) {
            $csproj.Save($csprojFile)
            Write-Host "  Updated $($rootDir.Name)" -ForegroundColor Green
            $updatedCount++
        } else {
            Write-Host "  No changes needed for $($rootDir.Name)" -ForegroundColor Gray
            $skippedCount++
        }

    } catch {
        $errorMsg = "Error processing $($rootDir.Name): $_"
        Write-Host "  $errorMsg" -ForegroundColor Red
        $errors += $errorMsg
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Updated: $updatedCount" -ForegroundColor Green
Write-Host "  Skipped: $skippedCount" -ForegroundColor Yellow
if ($errors.Count -gt 0) {
    Write-Host "  Errors: $($errors.Count)" -ForegroundColor Red
    Write-Host "`nErrors:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}
Write-Host "========================================" -ForegroundColor Cyan
