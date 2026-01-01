# Set all Runner* and *.Tests projects to net10.0;net9.0;net8.0

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$targetFrameworks = "net10.0;net9.0;net8.0"

# Find all Runner* and *.Tests .csproj files
$projects = Get-ChildItem -Recurse -Filter '*.csproj' -Path $rootPath |
    Where-Object { $_.FullName -match '(Runner[^\\]*|\.Tests)\\[^\\]+\.csproj$' }

Write-Host "Found $($projects.Count) Runner and Tests projects" -ForegroundColor Cyan
Write-Host ""

$updated = 0
$skipped = 0
$errors = 0

foreach ($project in $projects) {
    $relativePath = $project.FullName.Replace($rootPath + '\', '')
    Write-Host "Processing: $relativePath"

    try {
        $content = Get-Content $project.FullName -Raw

        # Check current TargetFramework(s)
        $currentTF = $null
        if ($content -match '<TargetFrameworks>([^<]+)</TargetFrameworks>') {
            $currentTF = $Matches[1]
        } elseif ($content -match '<TargetFramework>([^<]+)</TargetFramework>') {
            $currentTF = $Matches[1]
        }

        if (-not $currentTF) {
            Write-Host "  WARNING: No TargetFramework found!" -ForegroundColor Yellow
            $errors++
            continue
        }

        # Check if already correct
        if ($currentTF -eq $targetFrameworks) {
            Write-Host "  Already correct: $currentTF" -ForegroundColor Green
            $skipped++
            continue
        }

        # Replace TargetFramework or TargetFrameworks with new value
        if ($content -match '<TargetFrameworks>') {
            $newContent = $content -replace '<TargetFrameworks>[^<]+</TargetFrameworks>', "<TargetFrameworks>$targetFrameworks</TargetFrameworks>"
        } else {
            # Change from singular to plural
            $newContent = $content -replace '<TargetFramework>[^<]+</TargetFramework>', "<TargetFrameworks>$targetFrameworks</TargetFrameworks>"
        }

        # Save file
        Set-Content $project.FullName -Value $newContent -NoNewline

        Write-Host "  Updated: $currentTF -> $targetFrameworks" -ForegroundColor Cyan
        $updated++
    }
    catch {
        Write-Host "  ERROR: $_" -ForegroundColor Red
        $errors++
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Updated: $updated" -ForegroundColor Cyan
Write-Host "Already correct: $skipped" -ForegroundColor Green
Write-Host "Errors: $errors" -ForegroundColor Red
Write-Host "Total: $($projects.Count)"
