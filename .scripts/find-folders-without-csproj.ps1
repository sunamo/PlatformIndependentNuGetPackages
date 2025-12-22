$sunamoFolders = Get-ChildItem -Directory -Filter 'Sunamo*' | Where-Object { $_.Name -notlike '.*' }

Write-Host "Checking $($sunamoFolders.Count) Sunamo* folders...`n"

$foldersWithoutCsproj = @()

foreach ($folder in $sunamoFolders) {
    $directCsproj = Get-ChildItem -Path $folder.FullName -Filter '*.csproj' -File -ErrorAction SilentlyContinue

    if (-not $directCsproj) {
        $foldersWithoutCsproj += $folder.Name
        Write-Host "❌ $($folder.Name) - NO direct .csproj"
    } else {
        Write-Host "✅ $($folder.Name) - has direct .csproj: $($directCsproj.Name)"
    }
}

Write-Host "`n=========================================="
Write-Host "Folders WITHOUT direct .csproj: $($foldersWithoutCsproj.Count)"
Write-Host "==========================================`n"

if ($foldersWithoutCsproj.Count -gt 0) {
    $foldersWithoutCsproj | ForEach-Object { Write-Host "  - $_" }
}
