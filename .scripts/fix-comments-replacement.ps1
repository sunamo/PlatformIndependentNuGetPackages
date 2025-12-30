$scriptPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\find-and-open-empty-cs-files.ps1"

$content = Get-Content $scriptPath -Raw

# Fix comment replacements to use space instead of empty string
$content = $content -replace "-replace '//\.\*\?\\(\r\?\\n\|\$\)', ''", "-replace '//.*?(\r?\n|$)', ' '"
$content = $content -replace "-replace '/\\\*\.\*\?\\\*/', ''", "-replace '/\*.*?\*/', ' '"
$content = $content -replace "-replace '#region\.\*\?\\(\r\?\\n\|\$\)', ''", "-replace '#region.*?(\r?\n|$)', ' '"
$content = $content -replace "-replace '#endregion\.\*\?\\(\r\?\\n\|\$\)', ''", "-replace '#endregion.*?(\r?\n|$)', ' '"

Set-Content -Path $scriptPath -Value $content -NoNewline

Write-Host "Fixed comment replacements!" -ForegroundColor Green
