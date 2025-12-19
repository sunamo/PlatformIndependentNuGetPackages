# EN: Find all C# files with more than specified line count
# CZ: Najde všechny C# soubory s více než zadaným počtem řádků

param(
    [int]$MinLines = 300,
    [string]$SolutionPath = "."
)

Write-Host "Searching for .cs files with more than $MinLines lines..." -ForegroundColor Cyan
Write-Host ""

$files = Get-ChildItem -Path $SolutionPath -Filter "*.cs" -Recurse -File | Where-Object {
    $_.FullName -notmatch '\\obj\\' -and
    $_.FullName -notmatch '\\bin\\' -and
    $_.FullName -notmatch '\\.git\\' -and
    $_.FullName -notmatch '\\node_modules\\'
}

$largeFiles = @()

foreach ($file in $files) {
    $lineCount = (Get-Content $file.FullName | Measure-Object -Line).Lines

    if ($lineCount -gt $MinLines) {
        $largeFiles += [PSCustomObject]@{
            File = $file.FullName.Replace($PWD.Path + '\', '')
            Lines = $lineCount
            Directory = $file.Directory.Name
        }
    }
}

$largeFiles = $largeFiles | Sort-Object -Property Lines -Descending

Write-Host "Found $($largeFiles.Count) files with more than $MinLines lines:" -ForegroundColor Green
Write-Host ""
Write-Host ("=" * 120)
Write-Host ("{0,-80} {1,10} {2,-25}" -f "File", "Lines", "Directory") -ForegroundColor Yellow
Write-Host ("=" * 120)

$totalLines = 0
foreach ($file in $largeFiles) {
    Write-Host ("{0,-80} {1,10} {2,-25}" -f $file.File, $file.Lines, $file.Directory)
    $totalLines += $file.Lines
}

Write-Host ("=" * 120)
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Total files to split: $($largeFiles.Count)" -ForegroundColor White
Write-Host "  Total lines in these files: $totalLines" -ForegroundColor White
Write-Host "  Average lines per file: $([math]::Round($totalLines / $largeFiles.Count, 0))" -ForegroundColor White
Write-Host ""

# Group by project/module
$byProject = $largeFiles | Group-Object -Property Directory | Sort-Object -Property Count -Descending

Write-Host "Files grouped by project/module:" -ForegroundColor Cyan
Write-Host ""
foreach ($group in $byProject) {
    Write-Host "  $($group.Name): $($group.Count) file(s)" -ForegroundColor White
    foreach ($file in $group.Group | Sort-Object -Property Lines -Descending) {
        Write-Host ("    - {0} ({1} lines)" -f ($file.File -split '\\')[-1], $file.Lines) -ForegroundColor Gray
    }
    Write-Host ""
}

return $largeFiles
