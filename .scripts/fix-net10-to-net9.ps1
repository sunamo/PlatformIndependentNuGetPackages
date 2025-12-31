# Fix net10.0 to net9.0 (net10 doesn't exist yet)

$projectFiles = Get-ChildItem -Path . -Filter "*.csproj" -Recurse
$updatedCount = 0

foreach ($file in $projectFiles) {
    $content = Get-Content $file.FullName -Raw

    if ($content -match 'net10\.0') {
        $newContent = $content -replace 'net10\.0', 'net9.0'
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "Fixed: $($file.FullName)"
        $updatedCount++
    }
}

Write-Host "`nTotal projects fixed: $updatedCount"
