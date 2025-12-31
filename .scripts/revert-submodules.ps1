# Revert all changes in submodules

$submodules = git submodule status | ForEach-Object { $_.Split(' ')[2] }

foreach ($submodule in $submodules) {
    if (Test-Path $submodule) {
        Write-Host "Reverting changes in $submodule..."
        Push-Location $submodule
        git checkout -- .
        Pop-Location
    }
}

Write-Host "Done reverting all submodules."
