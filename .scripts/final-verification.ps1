Write-Host "`n=== SunamoCollections Verification ===" -ForegroundColor Cyan
$collections = dotnet build SunamoCollections/RunnerCollections/RunnerCollections.csproj 2>&1 | Select-String -Pattern 'Warning\(s\)' | Select-Object -Last 1
Write-Host $collections

Write-Host "`n=== SunamoCollectionsGeneric Verification ===" -ForegroundColor Cyan
$collectionsGeneric = dotnet build SunamoCollectionsGeneric/RunnerCollectionsGeneric/RunnerCollectionsGeneric.csproj 2>&1 | Select-String -Pattern 'Warning\(s\)' | Select-Object -Last 1
Write-Host $collectionsGeneric

Write-Host "`n=== Summary ===" -ForegroundColor Green
if ($collections -match "0 Warning" -and $collectionsGeneric -match "0 Warning") {
    Write-Host "SUCCESS: Both projects have 0 warnings!" -ForegroundColor Green
} else {
    Write-Host "FAILED: Some warnings remain" -ForegroundColor Red
}
