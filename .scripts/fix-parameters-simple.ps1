# Simple line-by-line parameter fixing script
param(
    [string]$ProjectPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollections"
)

Write-Host "=== Fixing Parameter Casing (Line-by-Line Approach) ===" -ForegroundColor Cyan

$csFiles = Get-ChildItem -Path $ProjectPath -Filter "*.cs" -Recurse
$totalReplacements = 0
$filesModified = 0

foreach ($file in $csFiles) {
    $lines = Get-Content $file.FullName
    $modified = $false
    $fileReplacements = 0

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $originalLine = $lines[$i]
        $newLine = $originalLine

        # Replace List<T> List with List<T> list
        $newLine = $newLine -replace '\(List<([^>]+)>\s+List\b', '(List<$1> list'
        $newLine = $newLine -replace ',(\s*)List<([^>]+)>\s+List\b', ',$1List<$2> list'

        # Replace IList<T> List with IList<T> list
        $newLine = $newLine -replace '\(IList<([^>]+)>\s+List\b', '(IList<$1> list'
        $newLine = $newLine -replace ',(\s*)IList<([^>]+)>\s+List\b', ',$1IList<$2> list'

        if ($newLine -cne $originalLine) {  # Case-sensitive comparison!
            $lines[$i] = $newLine
            $modified = $true
            $fileReplacements++
        }
    }

    if ($modified) {
        # Write back with UTF-8 encoding
        [System.IO.File]::WriteAllLines($file.FullName, $lines, [System.Text.UTF8Encoding]::new($false))
        $filesModified++
        $totalReplacements += $fileReplacements

        $relativePath = $file.FullName.Replace("$ProjectPath\", "")
        Write-Host "  ✓ $relativePath - $fileReplacements line(s) changed" -ForegroundColor Green
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Files modified: $filesModified" -ForegroundColor Yellow
Write-Host "Total lines changed: $totalReplacements" -ForegroundColor Yellow
Write-Host "`nParameter casing fix complete!" -ForegroundColor Green
