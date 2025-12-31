# Fix pushSolutionsData -> PushSolutionsData in ApsHelper files

$files = @(
    'SunamoDevCode\SunamoDevCode\Aps\ApsHelper.cs',
    'SunamoDevCode\SunamoDevCode\Aps\ApsHelper1.cs',
    'SunamoDevCode\SunamoDevCode\Aps\ApsHelper2.cs'
)

foreach ($file in $files) {
    $fullPath = Join-Path $PSScriptRoot "..\$file"
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw
        $newContent = $content -replace '\bpushSolutionsData\b', 'PushSolutionsData'

        if ($content -ne $newContent) {
            Set-Content -Path $fullPath -Value $newContent -NoNewline
            Write-Host "Fixed: $file"
        }
    }
}

Write-Host "Done"
