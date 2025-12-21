# EN: Check which SOLUTIONS (SLN) are complete - groups of 3 projects (Main, Runner, Tests)
# CZ: Zkontroluj které SOLUTION (SLN) jsou kompletní - skupiny 3 projektů (Hlavní, Runner, Tests)

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

# Find all solution folders (folders containing subfolders with .csproj files)
$solutionFolders = Get-ChildItem -Path $rootPath -Directory |
    Where-Object {
        $_.Name -notmatch '^\.' -and
        $_.Name -ne 'packages' -and
        $_.Name -ne 'TestResults'
    }

$completeSolutions = @()
$incompleteSolutions = @()

foreach ($solutionFolder in $solutionFolders) {
    # Get all .cs files in all projects within this solution
    $allCsFiles = Get-ChildItem -Path $solutionFolder.FullName -Filter "*.cs" -Recurse -File |
        Where-Object { $_.FullName -notmatch '\\obj\\|\\bin\\' }

    if ($allCsFiles.Count -eq 0) {
        continue
    }

    # Count files with "// variables names: ok" comment
    $markedFiles = $allCsFiles | Where-Object {
        $content = Get-Content -Path $_.FullName -TotalCount 5 -ErrorAction SilentlyContinue
        $content -match '^\s*//\s*variables names:\s*ok'
    }

    $totalCount = $allCsFiles.Count
    $markedCount = $markedFiles.Count
    $percentage = if ($totalCount -gt 0) { [math]::Round(($markedCount / $totalCount) * 100, 1) } else { 0 }

    $solutionName = $solutionFolder.Name

    if ($markedCount -eq $totalCount -and $totalCount -gt 0) {
        $completeSolutions += [PSCustomObject]@{
            Solution = $solutionName
            Total = $totalCount
            Marked = $markedCount
            Percentage = 100
        }
        Write-Host "✅ $solutionName - $markedCount/$totalCount (100%)" -ForegroundColor Green
    }
    elseif ($percentage -ge 80) {
        $incompleteSolutions += [PSCustomObject]@{
            Solution = $solutionName
            Total = $totalCount
            Marked = $markedCount
            Percentage = $percentage
        }
        Write-Host "🟡 $solutionName - $markedCount/$totalCount ($percentage%)" -ForegroundColor Yellow
    }
    elseif ($percentage -ge 1) {
        Write-Host "🔴 $solutionName - $markedCount/$totalCount ($percentage%)" -ForegroundColor Red
    }
}

Write-Host "`n📊 SUMMARY:" -ForegroundColor Cyan
Write-Host "Complete solutions: $($completeSolutions.Count)" -ForegroundColor Green

if ($completeSolutions.Count -gt 0) {
    Write-Host "`n✅ Complete solutions:" -ForegroundColor Green
    $completeSolutions | ForEach-Object { Write-Host "  - $($_.Solution)" -ForegroundColor Green }
}

if ($incompleteSolutions.Count -gt 0) {
    Write-Host "`n🟡 Solutions >80% complete:" -ForegroundColor Yellow
    $incompleteSolutions | Sort-Object -Property Percentage -Descending | ForEach-Object {
        Write-Host "  - $($_.Solution): $($_.Percentage)% ($($_.Marked)/$($_.Total))" -ForegroundColor Yellow
    }
}
