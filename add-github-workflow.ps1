# Script to add GitHub workflow to all Sunamo* folders
param(
    [string]$TestMode = $null
)

$baseDir = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$templatePath = "$baseDir\SunamoAsync\.github\workflows\build-sunamoasync.yml"

# Read template
$template = Get-Content $templatePath -Raw

# Get all Sunamo directories
$sunamoDirs = Get-ChildItem -Path $baseDir -Directory -Filter "Sunamo*" | Where-Object { $_.Name -ne "SunamoAsync" }

# If test mode, only process first 5
if ($TestMode -eq "test") {
    $sunamoDirs = $sunamoDirs | Select-Object -First 5
    Write-Host "TEST MODE: Processing only first 5 directories" -ForegroundColor Yellow
}

$processedCount = 0
$errorCount = 0

foreach ($dir in $sunamoDirs) {
    $projectName = $dir.Name
    Write-Host "`nProcessing $projectName..." -ForegroundColor Cyan

    # Check if .csproj exists in subdirectory with same name
    $csprojPath = Join-Path $dir.FullName "$projectName\$projectName.csproj"
    $testCsprojPath = Join-Path $dir.FullName "$projectName.Tests\$projectName.Tests.csproj"

    if (-not (Test-Path $csprojPath)) {
        Write-Host "  Skipping: $csprojPath not found" -ForegroundColor Yellow
        continue
    }

    # Create .github/workflows directory
    $workflowDir = Join-Path $dir.FullName ".github\workflows"
    New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null

    # Replace project name in template
    $workflowContent = $template -replace "SunamoAsync", $projectName

    # Save workflow file
    $workflowPath = Join-Path $workflowDir "build-$($projectName.ToLower()).yml"
    $workflowContent | Set-Content -Path $workflowPath -Encoding UTF8

    Write-Host "  Created: $workflowPath" -ForegroundColor Green

    # Git commit and push
    try {
        Push-Location $dir.FullName

        git add .github/workflows/*
        git commit -m "feat: Added GitHub Actions workflow for automated build"
        git push

        Write-Host "  Pushed to GitHub" -ForegroundColor Green
        $processedCount++
    }
    catch {
        Write-Host "  Error during git operations: $_" -ForegroundColor Red
        $errorCount++
    }
    finally {
        Pop-Location
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Processed: $processedCount" -ForegroundColor Green
Write-Host "  Errors: $errorCount" -ForegroundColor $(if($errorCount -gt 0){"Red"}else{"Green"})
Write-Host "========================================" -ForegroundColor Cyan