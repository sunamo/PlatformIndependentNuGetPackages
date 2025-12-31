# Upgrade all .csproj files from net8.0 to net9.0

$projectFiles = Get-ChildItem -Path . -Filter "*.csproj" -Recurse
$updatedCount = 0

foreach ($file in $projectFiles) {
    $content = Get-Content $file.FullName -Raw

    if ($content -match 'net8\.0') {
        $newContent = $content -replace 'net8\.0', 'net9.0'
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "Updated: $($file.FullName)"
        $updatedCount++
    }
}

Write-Host "`nTotal projects updated: $updatedCount"
