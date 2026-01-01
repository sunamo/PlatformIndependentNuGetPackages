# List local branches for root and all submodules, grouped by branch combinations
# EN: Shows which repositories have which local branches, grouped by branch pattern
# CZ: Zobrazuje které repozitáře mají které lokální větve, seskupené podle vzoru větví

param(
    [switch]$IncludeRoot = $true
)

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

Write-Host "Analyzing branches in root and submodules..." -ForegroundColor Cyan
Write-Host ""

# Function to get local branches for a repository
function Get-LocalBranches {
    param([string]$Path)

    Push-Location $Path
    try {
        $branches = git branch --format='%(refname:short)' | Sort-Object
        return $branches -join ';'
    }
    finally {
        Pop-Location
    }
}

# Collect branch info
$branchInfo = @{}

# Add root if requested
if ($IncludeRoot) {
    $rootBranches = Get-LocalBranches -Path $rootPath
    $branchInfo["[ROOT]"] = $rootBranches
}

# Get all subdirectories that could be submodules
$subdirs = Get-ChildItem -Path $rootPath -Directory | Where-Object {
    $_.Name -notmatch '^(\.|_)' -and (Test-Path (Join-Path $_.FullName ".git"))
}

foreach ($dir in $subdirs) {
    $branches = Get-LocalBranches -Path $dir.FullName
    $branchInfo[$dir.Name] = $branches
}

# Group by branch combinations
$grouped = $branchInfo.GetEnumerator() | Group-Object -Property Value | Sort-Object Name

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "BRANCHES GROUPED BY COMBINATION" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

foreach ($group in $grouped) {
    $branchList = $group.Name -replace ';', ', '
    $count = $group.Group.Count

    Write-Host "Branches: $branchList" -ForegroundColor Yellow
    Write-Host "Count: $count" -ForegroundColor Gray
    Write-Host ""

    foreach ($item in ($group.Group | Sort-Object Name)) {
        Write-Host "  $($item.Name)" -ForegroundColor White
    }

    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total repositories: $($branchInfo.Count)" -ForegroundColor Green
Write-Host "Unique branch combinations: $($grouped.Count)" -ForegroundColor Green
