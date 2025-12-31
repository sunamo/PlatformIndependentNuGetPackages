# Fix net10.0 → remove it from TargetFrameworks

$files = Get-ChildItem -Recurse -Filter "*.csproj" | Where-Object {
    $content = Get-Content $_.FullName -Raw
    $content -match "net10\.0"
}

foreach ($file in $files) {
    Write-Host "Fixing $($file.FullName)..."
    $content = Get-Content $file.FullName -Raw
    $content = $content -replace '<TargetFrameworks>net10\.0;net9\.0;net8\.0</TargetFrameworks>', '<TargetFrameworks>net9.0;net8.0</TargetFrameworks>'
    $content = $content -replace '<TargetFrameworks>net10\.0;net9\.0</TargetFrameworks>', '<TargetFrameworks>net9.0</TargetFrameworks>'
    $content = $content -replace '<TargetFrameworks>net10\.0</TargetFrameworks>', '<TargetFrameworks>net9.0</TargetFrameworks>'
    $content = $content -replace '<TargetFramework>net10\.0</TargetFramework>', '<TargetFramework>net9.0</TargetFramework>'
    Set-Content $file.FullName -Value $content -NoNewline
}

Write-Host "Done."
