# Restore net10.0 in all .csproj files across all submodules
# This script finds all .csproj files with uncommitted changes that removed net10.0
# and restores them to their original state

$ErrorActionPreference = "Stop"
$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

Write-Host "Checking all submodules for net10.0 removal..." -ForegroundColor Cyan

# Get all submodule paths from .gitmodules
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    if ($_ -match 'submodule\.(.+)\.path\s+(.+)') {
        $matches[2]
    }
}

$fixedCount = 0
$checkedCount = 0

foreach ($submodule in $submodules) {
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        Write-Host "  Skipping $submodule (path not found)" -ForegroundColor Yellow
        continue
    }

    $checkedCount++

    # Check if submodule has uncommitted changes
    Push-Location $submodulePath
    try {
        $status = git status --porcelain

        if ($status) {
            # Get list of modified .csproj files
            $modifiedCsproj = $status | Where-Object { $_ -match '\.csproj$' } | ForEach-Object {
                $_.Substring(3).Trim()
            }

            if ($modifiedCsproj) {
                foreach ($file in $modifiedCsproj) {
                    # Check if the file has net10.0 removal
                    $diff = git diff $file

                    if ($diff -match '-\s*<TargetFrameworks>net10\.0;') {
                        Write-Host "  Restoring net10.0 in $submodule/$file" -ForegroundColor Yellow
                        git restore $file
                        $fixedCount++
                    }
                }
            }
        }
    }
    finally {
        Pop-Location
    }
}

Write-Host "`nResults:" -ForegroundColor Cyan
Write-Host "  Checked submodules: $checkedCount" -ForegroundColor White
Write-Host "  Fixed .csproj files: $fixedCount" -ForegroundColor Green

if ($fixedCount -gt 0) {
    Write-Host "`nPlease run 'git status' to verify the changes." -ForegroundColor Cyan
}
