# Check all submodules for uncommitted changes and report their status
# This script helps identify which submodules have uncommitted changes
# so they only show up in 'git status' when they truly have changes

$ErrorActionPreference = "Stop"
$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

Write-Host "Checking all submodules for uncommitted changes..." -ForegroundColor Cyan
Write-Host ""

# Get all submodule paths from .gitmodules
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    if ($_ -match 'submodule\.(.+)\.path\s+(.+)') {
        $matches[2]
    }
}

$dirtySubmodules = @()

foreach ($submodule in $submodules) {
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        continue
    }

    # Check if submodule has uncommitted changes
    Push-Location $submodulePath
    try {
        $status = git status --porcelain

        if ($status) {
            $dirtySubmodules += [PSCustomObject]@{
                Name = $submodule
                Files = $status.Count
                Changes = $status
            }

            Write-Host "  $submodule" -ForegroundColor Yellow
            $status | ForEach-Object {
                Write-Host "    $_" -ForegroundColor Gray
            }
            Write-Host ""
        }
    }
    finally {
        Pop-Location
    }
}

Write-Host "Results:" -ForegroundColor Cyan
Write-Host "  Total submodules: $($submodules.Count)" -ForegroundColor White
Write-Host "  Dirty submodules: $($dirtySubmodules.Count)" -ForegroundColor $(if ($dirtySubmodules.Count -eq 0) { "Green" } else { "Yellow" })

if ($dirtySubmodules.Count -gt 0) {
    Write-Host "`nTo fix net10.0 removal issues, run:" -ForegroundColor Cyan
    Write-Host "  pwsh -File .scripts\restore-net10-in-submodules.ps1" -ForegroundColor White
}
