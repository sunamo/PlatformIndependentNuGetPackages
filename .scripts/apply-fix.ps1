$scriptPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\find-and-open-empty-cs-files.ps1"
$fixedLine = Get-Content "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\line57.txt" -Raw

$lines = Get-Content $scriptPath
$lines[56] = $fixedLine.Trim()
$lines | Set-Content $scriptPath

Write-Host "Fixed!" -ForegroundColor Green
