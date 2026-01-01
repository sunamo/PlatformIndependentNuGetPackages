# Fix TargetFrameworks to ensure net10.0 is present and versions are properly ordered
# EN: Ensures all projects have net10.0 and frameworks are ordered as net10.0;net9.0;net8.0
# CZ: Zajišťuje že všechny projekty mají net10.0 a frameworky jsou seřazeny jako net10.0;net9.0;net8.0

param(
    [Parameter(Mandatory=$false)]
    [string[]]$ProjectNames = @()
)

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

# If no project names specified, use the list from the issue
if ($ProjectNames.Count -eq 0) {
    $ProjectNames = @(
        # net9.0;net8.0 projects
        "SunamoRuleset", "SunamoSecurity", "SunamoSelenium", "SunamoSerializer",
        "SunamoShared", "SunamoStopwatch", "SunamoString", "SunamoStringFormat",
        "SunamoStringGetLines", "SunamoToUnixLineEnding", "SunamoTwoWayDictionary",
        "SunamoTypes", "SunamoUnderscore", "SunamoUri", "SunamoUriWebServices",
        "SunamoValues", "SunamoVcf", "SunamoWikipedia", "SunamoWinStd",
        "SunamoXlfKeys", "SunamoXliffParser", "SunamoXml", "SunamoYaml", "SunamoYouTube",

        # net9.0;net9.0;net9.0 projects (duplicates)
        "SunamoAI", "SunamoArgs", "SunamoAsync", "SunamoAttributes",
        "SunamoAzureDevOpsApi", "SunamoBazosCrawler", "SunamoBts", "SunamoChar",
        "SunamoCl", "SunamoClearScript", "SunamoClipboard", "SunamoCollectionOnDrive",
        "SunamoCollectionsChangeContent", "SunamoCollectionsIndexesWithNull",
        "SunamoCollectionsNonGeneric", "SunamoCollectionsTo",
        "SunamoCollectionsValuesTableGrid", "SunamoCollectionWithoutDuplicates",
        "SunamoColors", "SunamoCompare", "SunamoCssGenerator", "SunamoData",
        "SunamoDebugCollection", "SunamoDebugIO"
    )
}

Write-Host "Fixing TargetFrameworks for $($ProjectNames.Count) projects..." -ForegroundColor Cyan
Write-Host ""

$updated = 0
$skipped = 0
$errors = 0

foreach ($projectName in $ProjectNames) {
    $csprojPath = Join-Path $rootPath "$projectName\$projectName\$projectName.csproj"

    if (-not (Test-Path $csprojPath)) {
        Write-Host "⚠ $projectName - .csproj not found at: $csprojPath" -ForegroundColor Yellow
        $errors++
        continue
    }

    # Read csproj as XML
    [xml]$csproj = Get-Content $csprojPath

    # Find TargetFramework or TargetFrameworks
    $propertyGroup = $csproj.Project.PropertyGroup | Where-Object { $_.TargetFramework -or $_.TargetFrameworks } | Select-Object -First 1

    if (-not $propertyGroup) {
        Write-Host "⚠ $projectName - No TargetFramework(s) found" -ForegroundColor Yellow
        $errors++
        continue
    }

    # Get current frameworks
    $currentFrameworks = if ($propertyGroup.TargetFrameworks) {
        $propertyGroup.TargetFrameworks
    } elseif ($propertyGroup.TargetFramework) {
        $propertyGroup.TargetFramework
    } else {
        $null
    }

    if (-not $currentFrameworks) {
        Write-Host "⚠ $projectName - Empty TargetFramework(s)" -ForegroundColor Yellow
        $errors++
        continue
    }

    # Parse frameworks
    $frameworks = $currentFrameworks -split ';' | Where-Object { $_ } | ForEach-Object { $_.Trim() } | Select-Object -Unique

    # Build new framework list: net10.0;net9.0;net8.0 (in this order, only if they exist or should be added)
    $newFrameworks = @()

    # Always add net10.0 first
    if ($frameworks -notcontains "net10.0") {
        $newFrameworks += "net10.0"
    } else {
        $newFrameworks += "net10.0"
    }

    # Add net9.0 if present
    if ($frameworks -contains "net9.0") {
        $newFrameworks += "net9.0"
    }

    # Add net8.0 if present or if it's a standard target
    if ($frameworks -contains "net8.0") {
        $newFrameworks += "net8.0"
    } else {
        # Add net8.0 for most projects (unless they have a specific reason not to)
        $newFrameworks += "net8.0"
    }

    # Add any other frameworks (like net7.0) at the end
    $otherFrameworks = $frameworks | Where-Object { $_ -notin @("net10.0", "net9.0", "net8.0") }
    if ($otherFrameworks) {
        $newFrameworks += $otherFrameworks
    }

    $newFrameworksString = $newFrameworks -join ';'

    # Check if update is needed
    if ($currentFrameworks -eq $newFrameworksString) {
        Write-Host "⊙ $projectName - Already correct: $currentFrameworks" -ForegroundColor Cyan
        $skipped++
        continue
    }

    # Read file as text to preserve formatting
    $content = Get-Content $csprojPath -Raw

    # Replace TargetFramework or TargetFrameworks
    if ($content -match '<TargetFrameworks>') {
        $content = $content -replace '<TargetFrameworks>[^<]+</TargetFrameworks>', "<TargetFrameworks>$newFrameworksString</TargetFrameworks>"
    } elseif ($content -match '<TargetFramework>') {
        # Change from singular to plural
        $content = $content -replace '<TargetFramework>[^<]+</TargetFramework>', "<TargetFrameworks>$newFrameworksString</TargetFrameworks>"
    }

    # Save file
    $content | Out-File $csprojPath -Encoding UTF8 -NoNewline

    Write-Host "✓ $projectName" -ForegroundColor Green
    Write-Host "  Old: $currentFrameworks" -ForegroundColor Gray
    Write-Host "  New: $newFrameworksString" -ForegroundColor White
    $updated++
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Updated: $updated" -ForegroundColor Green
Write-Host "Skipped (already correct): $skipped" -ForegroundColor Cyan
Write-Host "Errors: $errors" -ForegroundColor Red
