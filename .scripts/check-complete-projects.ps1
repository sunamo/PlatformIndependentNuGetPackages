# EN: Check which projects have all files marked with "// variables names: ok"
# CZ: Zkontroluj které projekty mají všechny soubory označené "// variables names: ok"

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

# Find all project directories (directories with .csproj files)
$projectDirs = Get-ChildItem -Path $rootPath -Filter "*.csproj" -Recurse -File |
    Where-Object { $_.FullName -notmatch '\\obj\\|\\bin\\' } |
    ForEach-Object { $_.Directory.FullName } |
    Sort-Object -Unique

$completeProjects = @()
$incompleteProjects = @()

foreach ($projectDir in $projectDirs) {
    # Get all .cs files in the project (excluding obj/bin)
    $allCsFiles = Get-ChildItem -Path $projectDir -Filter "*.cs" -Recurse -File |
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
    $percentage = [math]::Round(($markedCount / $totalCount) * 100, 1)

    $projectName = Split-Path $projectDir -Leaf

    if ($markedCount -eq $totalCount) {
        $completeProjects += [PSCustomObject]@{
            Project = $projectName
            Total = $totalCount
            Marked = $markedCount
            Percentage = 100
        }
        Write-Host "✅ $projectName - $markedCount/$totalCount (100%)" -ForegroundColor Green
    }
    elseif ($percentage -ge 50) {
        $incompleteProjects += [PSCustomObject]@{
            Project = $projectName
            Total = $totalCount
            Marked = $markedCount
            Percentage = $percentage
        }
        Write-Host "🟡 $projectName - $markedCount/$totalCount ($percentage%)" -ForegroundColor Yellow
    }
}

Write-Host "`n📊 SUMMARY:" -ForegroundColor Cyan
Write-Host "Complete projects: $($completeProjects.Count)" -ForegroundColor Green
Write-Host "`nComplete projects list:" -ForegroundColor Green
$completeProjects | ForEach-Object { Write-Host "  - $($_.Project)" -ForegroundColor Green }

if ($incompleteProjects.Count -gt 0) {
    Write-Host "`nProjects >50% complete:" -ForegroundColor Yellow
    $incompleteProjects | Sort-Object -Property Percentage -Descending | ForEach-Object {
        Write-Host "  - $($_.Project): $($_.Percentage)%" -ForegroundColor Yellow
    }
}
