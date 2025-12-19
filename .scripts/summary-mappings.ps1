# Generate summary of converted mappings

$outputFile = "E:\vs\Projects\PlatformIndependentNuGetPackages\.variable-rename-project\mappings\SunamoString-complete-mappings.json"

Write-Host "Reading: $outputFile" -ForegroundColor Cyan
$data = Get-Content $outputFile -Raw | ConvertFrom-Json

Write-Host "`nBreakdown by Scope and OperationType:" -ForegroundColor Yellow
$data | Group-Object Scope | ForEach-Object {
    Write-Host "`n$($_.Name):" -ForegroundColor Green
    $_.Group | Group-Object OperationType | ForEach-Object {
        Write-Host "  $($_.Name): $($_.Count)" -ForegroundColor White
    }
}

Write-Host "`nTotal mappings: $($data.Count)" -ForegroundColor Cyan
