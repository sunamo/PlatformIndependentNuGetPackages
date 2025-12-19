# Verify converted mappings structure

$outputFile = "E:\vs\Projects\PlatformIndependentNuGetPackages\.variable-rename-project\mappings\SunamoString-complete-mappings.json"

Write-Host "Reading output file: $outputFile" -ForegroundColor Cyan
$data = Get-Content $outputFile -Raw | ConvertFrom-Json

Write-Host "`nSample Parameter mapping:" -ForegroundColor Yellow
$data | Where-Object { $_.Scope -eq "Parameter" } | Select-Object -First 1 | ConvertTo-Json -Depth 5 | Write-Host

Write-Host "`nSample Local Variable mapping:" -ForegroundColor Yellow
$data | Where-Object { $_.Scope -eq "Local" } | Select-Object -First 1 | ConvertTo-Json -Depth 5 | Write-Host

Write-Host "`nSample Field (ConvertToProperty) mapping:" -ForegroundColor Yellow
$data | Where-Object { $_.OperationType -eq "ConvertFieldToProperty" } | Select-Object -First 1 | ConvertTo-Json -Depth 5 | Write-Host

Write-Host "`nTotal mappings: $($data.Count)" -ForegroundColor Green
