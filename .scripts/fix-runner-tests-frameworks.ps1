$inputFile = "D:\Drive\Jira\ZIS-258\CompareTwoFiles\txt\1.txt"

# Extract unique project paths and remove the build number prefix (e.g., "111>")
$projects = Get-Content $inputFile | ForEach-Object {
    if ($_ -match '>(.+\.csproj)\s*:\s*error NU1202') {
        $Matches[1]
    }
} | Sort-Object -Unique

Write-Host "Found $($projects.Count) unique projects with errors"
Write-Host ""

$updatedCount = 0
$alreadyNet9Count = 0
$errorCount = 0

foreach ($project in $projects) {
    Write-Host "Processing: $project"

    if (-not (Test-Path $project)) {
        Write-Host "  ERROR: Project file not found!" -ForegroundColor Red
        $errorCount++
        continue
    }

    $content = Get-Content $project -Raw

    # Check if already only net9.0
    if ($content -match '<TargetFramework>net9\.0</TargetFramework>' -or $content -match '<TargetFrameworks>net9\.0</TargetFrameworks>') {
        Write-Host "  Already targeting only net9.0" -ForegroundColor Yellow
        $alreadyNet9Count++
        continue
    }

    # Replace net9.0;net8.0 with just net9.0 (remove net8.0 from multi-targeting)
    if ($content -match '<TargetFrameworks>net9\.0;net8\.0</TargetFrameworks>') {
        $newContent = $content -replace '<TargetFrameworks>net9\.0;net8\.0</TargetFrameworks>', '<TargetFramework>net9.0</TargetFramework>'
        Set-Content $project -Value $newContent -NoNewline
        Write-Host "  Updated: removed net8.0 from multi-targeting (net9.0;net8.0 -> net9.0)" -ForegroundColor Green
        $updatedCount++
    }
    # Replace net8.0 with net9.0 (singular)
    elseif ($content -match '<TargetFramework>net8\.0</TargetFramework>') {
        $newContent = $content -replace '<TargetFramework>net8\.0</TargetFramework>', '<TargetFramework>net9.0</TargetFramework>'
        Set-Content $project -Value $newContent -NoNewline
        Write-Host "  Updated net8.0 -> net9.0" -ForegroundColor Green
        $updatedCount++
    }
    # Replace other multi-targeting patterns with net8.0
    elseif ($content -match '<TargetFrameworks>.*net8\.0.*</TargetFrameworks>') {
        $newContent = $content -replace '<TargetFrameworks>[^<]*net8\.0[^<]*</TargetFrameworks>', '<TargetFramework>net9.0</TargetFramework>'
        Set-Content $project -Value $newContent -NoNewline
        Write-Host "  Updated: removed net8.0 from multi-targeting (-> net9.0)" -ForegroundColor Green
        $updatedCount++
    }
    else {
        Write-Host "  WARNING: Could not find net8.0 TargetFramework pattern!" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Updated: $updatedCount" -ForegroundColor Green
Write-Host "  Already net9.0: $alreadyNet9Count" -ForegroundColor Yellow
Write-Host "  Errors: $errorCount" -ForegroundColor Red
Write-Host "  Total: $($projects.Count)"
