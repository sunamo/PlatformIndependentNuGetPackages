# Revert all changes in all subdirectories (which are git repos)

$dirs = Get-ChildItem -Directory | Where-Object { Test-Path "$($_.FullName)/.git" }

foreach ($dir in $dirs) {
    Write-Host "Reverting changes in $($dir.Name)..."
    Push-Location $dir.FullName
    git checkout -- . 2>&1 | Out-Null
    Pop-Location
}

Write-Host "Done reverting all directories."
