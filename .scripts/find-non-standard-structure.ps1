$sunamoFolders = Get-ChildItem -Directory -Filter 'Sunamo*' | Where-Object { $_.Name -notlike '.*' }

Write-Host "Checking $($sunamoFolders.Count) Sunamo* folders for standard structure...`n"

$nonStandardFolders = @()

foreach ($folder in $sunamoFolders) {
    $folderName = $folder.Name
    $expectedCsprojPath = Join-Path $folder.FullName "$folderName\$folderName.csproj"

    if (Test-Path $expectedCsprojPath) {
        Write-Host "✅ $folderName - has standard structure"
    } else {
        Write-Host "❌ $folderName - MISSING standard structure"
        $nonStandardFolders += $folderName
    }
}

Write-Host "`n=========================================="
Write-Host "Folders WITHOUT standard structure: $($nonStandardFolders.Count)"
Write-Host "==========================================`n"

if ($nonStandardFolders.Count -gt 0) {
    $nonStandardFolders | ForEach-Object { Write-Host "  - $_" }
}
