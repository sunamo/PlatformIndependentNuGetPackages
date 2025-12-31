$testFile = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoArgs\SunamoArgs\DumpAsStringHeaderArgs.cs"

Write-Host "Testing: $testFile" -ForegroundColor Cyan
$content = Get-Content $testFile -Raw

Write-Host "`n=== Original ===" -ForegroundColor Yellow
Write-Host $content

$withoutComments = $content -replace '//.*?(\r?\n|$)', ' ' -replace '/\*.*?\*/', ' ' -replace '#region.*?(\r?\n|$)', ' ' -replace '#endregion.*?(\r?\n|$)', ' ' -replace '\s+', ' ' -replace '^\s+|\s+$', ''

Write-Host "`n=== After removing comments ===" -ForegroundColor Yellow
Write-Host $withoutComments

$classContent = $withoutComments -replace 'using[^;]+;', '' -replace 'namespace[^;{]+;', '' -replace 'namespace[^{]+\{', '' -replace '\}$', ''

Write-Host "`n=== After removing namespace ===" -ForegroundColor Yellow
Write-Host $classContent

$hasClass = $classContent -match 'class'
$hasMembers = $classContent -match '(\{\s*(get|set)\s*;|\breturn\s+|\bnew\s+[\w<>]+\(|=[\w"(]|\w+\s+\w+\s*[=;(]|override\s+|virtual\s+|async\s+\w+\s*\()'

Write-Host "`n=== Detection ===" -ForegroundColor Yellow
Write-Host "Has class: $hasClass"
Write-Host "Has members: $hasMembers"

if ($hasClass -and -not $hasMembers) {
    Write-Host "`nRESULT: EMPTY CLASS (WRONG!)" -ForegroundColor Red
} else {
    Write-Host "`nRESULT: NOT EMPTY (CORRECT!)" -ForegroundColor Green
}
