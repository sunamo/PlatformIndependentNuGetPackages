# EN: Parse build output and show which projects have errors
# CZ: Parsovat build výstup a zobrazit které projekty mají chyby

# EN: IMPORTANT: Always use PlatformIndependentNuGetPackages.Runners.sln, never Tests.sln or others
# CZ: DŮLEŽITÉ: Vždy používat PlatformIndependentNuGetPackages.Runners.sln, nikdy ne Tests.sln nebo jiné

param(
    [string]$SolutionPath = "PlatformIndependentNuGetPackages.Runners.sln",
    [string]$Configuration = "Debug"
)

Write-Host "Building solution and analyzing errors..." -ForegroundColor Cyan
Write-Host ""

# EN: Build and capture full output
# CZ: Build a zachytit celý výstup
$buildOutput = dotnet build -c $Configuration $SolutionPath 2>&1 | Out-String

# EN: Extract projects with errors
# CZ: Extrahovat projekty s chybami
$errorLines = $buildOutput -split "`n" | Where-Object { $_ -match "error (CS|NU)\d+:" }

# EN: Group errors by project
# CZ: Seskupit chyby podle projektu
$projectErrors = @{}

foreach ($line in $errorLines) {
    # EN: Extract project path from error line
    # CZ: Extrahovat cestu k projektu z řádku s chybou
    if ($line -match "\\(Sunamo[^\\]+)\\([^\\]+)\\") {
        $submodule = $matches[1]
        $project = $matches[2]
        $key = "$submodule\$project"

        if (-not $projectErrors.ContainsKey($key)) {
            $projectErrors[$key] = @()
        }

        $projectErrors[$key] += $line.Trim()
    }
}

# EN: Display summary
# CZ: Zobrazit souhrn
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "BUILD ERRORS SUMMARY" -ForegroundColor Yellow
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host ""

if ($projectErrors.Count -eq 0) {
    Write-Host "No errors found! Build succeeded." -ForegroundColor Green
} else {
    Write-Host "Found errors in $($projectErrors.Count) project(s):" -ForegroundColor Red
    Write-Host ""

    # EN: Sort by error count (descending)
    # CZ: Seřadit podle počtu chyb (sestupně)
    $sorted = $projectErrors.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending

    foreach ($entry in $sorted) {
        $errorCount = $entry.Value.Count
        Write-Host "  $($entry.Key)" -ForegroundColor Yellow -NoNewline
        Write-Host " - $errorCount error(s)" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "=" * 100 -ForegroundColor Cyan
    Write-Host "DETAILED ERRORS" -ForegroundColor Yellow
    Write-Host "=" * 100 -ForegroundColor Cyan
    Write-Host ""

    foreach ($entry in $sorted) {
        Write-Host "[$($entry.Key)] - $($entry.Value.Count) error(s)" -ForegroundColor Cyan
        Write-Host ("-" * 80) -ForegroundColor Gray

        # EN: Show first 10 errors per project
        # CZ: Zobrazit prvních 10 chyb na projekt
        $entry.Value | Select-Object -First 10 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Red
        }

        if ($entry.Value.Count -gt 10) {
            Write-Host "  ... and $($entry.Value.Count - 10) more error(s)" -ForegroundColor DarkGray
        }

        Write-Host ""
    }
}

# EN: Extract build summary
# CZ: Extrahovat souhrn buildu
if ($buildOutput -match "(\d+) Error\(s\)") {
    $totalErrors = $matches[1]
    Write-Host "Total errors: $totalErrors" -ForegroundColor Red
}

if ($buildOutput -match "(\d+) Warning\(s\)") {
    $totalWarnings = $matches[1]
    Write-Host "Total warnings: $totalWarnings" -ForegroundColor Yellow
}
