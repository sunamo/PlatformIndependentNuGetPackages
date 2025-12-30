$file = "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\find-and-open-empty-cs-files.ps1"
$content = Get-Content $file -Raw

# Replace the whitespace handling line
$old = "            -replace '\s+', ''"
$new = @"
            -replace '\s+', ' ' ``
            -replace '^\s+|\s+$', ''
"@

$content = $content -replace [regex]::Escape($old), $new

Set-Content -Path $file -Value $content -NoNewline

Write-Host "Fixed whitespace handling!" -ForegroundColor Green
