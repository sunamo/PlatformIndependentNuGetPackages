# Check build status of modified projects from git status
$ErrorActionPreference = "Continue"

# List of modified projects from git status
$modifiedProjects = @(
    "SunamoHtml",
    "SunamoPS",
    "SunamoPackageJson",
    "SunamoParsing",
    "SunamoPaths",
    "SunamoPercentCalculator",
    "SunamoPlatformUwpInterop",
    "SunamoRandom",
    "SunamoReflection",
    "SunamoRegex",
    "SunamoResult",
    "SunamoRobotsTxt",
    "SunamoRoslyn",
    "SunamoRss",
    "SunamoRuleset",
    "SunamoSecurity",
    "SunamoSelenium",
    "SunamoSerializer",
    "SunamoShared",
    "SunamoStopwatch",
    "SunamoString",
    "SunamoStringFormat",
    "SunamoStringGetLines",
    "SunamoStringGetString",
    "SunamoStringJoin",
    "SunamoStringJoinPairs",
    "SunamoStringParts",
    "SunamoStringReplace",
    "SunamoStringSplit",
    "SunamoStringSubstring",
    "SunamoStringTrim",
    "SunamoTest",
    "SunamoText",
    "SunamoTextIndexing",
    "SunamoTextOutputGenerator",
    "SunamoThisApp",
    "SunamoThread",
    "SunamoThreading",
    "SunamoTidy",
    "SunamoToUnixLineEnding",
    "SunamoTwoWayDictionary",
    "SunamoTypes",
    "SunamoUnderscore",
    "SunamoUri",
    "SunamoUriWebServices",
    "SunamoValues",
    "SunamoVcf",
    "SunamoWikipedia",
    "SunamoWinStd",
    "SunamoXlfKeys",
    "SunamoXliffParser",
    "SunamoXml",
    "SunamoYaml",
    "SunamoYouTube"
)

$failed = @()
$succeeded = @()

foreach ($projectName in $modifiedProjects) {
    $projectPath = Join-Path $PSScriptRoot "..\$projectName"

    if (Test-Path $projectPath) {
        $solutionFile = Get-ChildItem -Path $projectPath -Filter "*.sln" | Select-Object -First 1

        if ($solutionFile) {
            Write-Host "Building $projectName..." -ForegroundColor Cyan
            Push-Location $projectPath

            $output = dotnet build $solutionFile.Name 2>&1
            $buildResult = $LASTEXITCODE

            if ($buildResult -eq 0) {
                Write-Host "✓ $projectName" -ForegroundColor Green
                $succeeded += $projectName
            } else {
                Write-Host "✗ $projectName - FAILED" -ForegroundColor Red
                $errors = $output | Where-Object { $_ -match "error CS" } | Select-Object -First 3
                $failed += @{
                    Name = $projectName
                    Errors = $errors
                }
            }

            Pop-Location
        }
    }
}

Write-Host "`n=== BUILD SUMMARY ===" -ForegroundColor Yellow
Write-Host "Succeeded: $($succeeded.Count)" -ForegroundColor Green
Write-Host "Failed: $($failed.Count)" -ForegroundColor Red

if ($failed.Count -gt 0) {
    Write-Host "`n=== FAILED PROJECTS ===" -ForegroundColor Red
    foreach ($fail in $failed) {
        Write-Host "`n$($fail.Name):" -ForegroundColor Red
        $fail.Errors | ForEach-Object { Write-Host "  $_" }
    }
}
