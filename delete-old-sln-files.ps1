param(
    [string]$RootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
)

Write-Host "Deleting old .sln files from: $RootPath" -ForegroundColor Cyan

$slnFiles = Get-ChildItem -Path $RootPath -Filter "*.sln" -Recurse

$deletedCount = 0
$warningCount = 0

foreach ($slnFile in $slnFiles) {
    $slnxPath = $slnFile.FullName -replace '\.sln$', '.slnx'

    if (Test-Path $slnxPath) {
        Write-Host "Deleting: $($slnFile.FullName)" -ForegroundColor Yellow
        Remove-Item $slnFile.FullName -Force
        $deletedCount++
    } else {
        Write-Host "WARNING: No .slnx found for $($slnFile.FullName)" -ForegroundColor Red
        $warningCount++
    }
}

Write-Host "`nDeletion complete!" -ForegroundColor Green
Write-Host "  Deleted: $deletedCount files" -ForegroundColor Green
Write-Host "  Warnings: $warningCount files" -ForegroundColor Yellow
