# Verify published packages on nuget.org
$testPackages = @('SunamoFtp', 'SunamoCsv', 'SunamoPInvoke', 'SunamoCrypt', 'SunamoAI')

Write-Host "Verifying sample packages on nuget.org..." -ForegroundColor Cyan
Write-Host ""

foreach ($pkg in $testPackages) {
    $url = "https://api-v2v3search-0.nuget.org/query?q=packageid:$pkg&prerelease=false"
    $response = Invoke-RestMethod -Uri $url
    $package = $response.data | Where-Object { $_.id -eq $pkg } | Select-Object -First 1

    if ($package) {
        Write-Host "$($package.id) - v$($package.version)" -ForegroundColor Green

        # Check if version is 26.1.1.X
        if ($package.version -match '^26\.1\.1\.') {
            Write-Host "  ✓ Latest version is from today (26.1.1.X)" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ Version is NOT from today: $($package.version)" -ForegroundColor Yellow
        }
    }
}
