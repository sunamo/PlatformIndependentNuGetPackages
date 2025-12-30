$scriptPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\find-and-open-empty-cs-files.ps1"
$lines = Get-Content $scriptPath

# Fix lines 52-55 (indices 51-54)
$lines[51] = "            -replace '//.*?(\r?\n|$)', ' ' ``"
$lines[52] = "            -replace '/\*.*?\*/', ' ' ``"
$lines[53] = "            -replace '#region.*?(\r?\n|$)', ' ' ``"
$lines[54] = "            -replace '#endregion.*?(\r?\n|$)', ' ' ``"

$lines | Set-Content $scriptPath

Write-Host "Fixed lines 52-55!" -ForegroundColor Green
