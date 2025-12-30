$file = "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\find-and-open-empty-cs-files.ps1"
$content = Get-Content $file -Raw

# Fix the broken section
$old = @'
        `$withoutComments = `$content ``
            -replace '//.*?(\r?\n|$)', '' ``
            -replace '/\*.*?\*/', '' ``
            -replace '#region.*?(\r?\n|$)', '' ``
            -replace '#endregion.*?(\r?\n|$)', '' ``
            -replace '\s+', ' ' ``
            -replace '^\s+|\s+
'@

$new = @'
        `$withoutComments = `$content ``
            -replace '//.*?(\r?\n|$)', ' ' ``
            -replace '/\*.*?\*/', ' ' ``
            -replace '#region.*?(\r?\n|$)', ' ' ``
            -replace '#endregion.*?(\r?\n|$)', ' ' ``
            -replace '\s+', ' ' ``
            -replace '^\s+|\s+$', ''
'@

$content = $content -replace [regex]::Escape($old), $new

Set-Content -Path $file -Value $content -NoNewline

Write-Host "Fixed broken script!" -ForegroundColor Green
