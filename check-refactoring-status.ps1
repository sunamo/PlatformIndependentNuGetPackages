# Check which files in the list already have the refactoring comment header
$baseDir = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$filesListPath = Join-Path $baseDir "files-with-short-variables.txt"

$filesWithHeader = 0
$filesWithoutHeader = @()
$totalFiles = 0

Get-Content $filesListPath | ForEach-Object {
    $relativePath = $_.Trim()
    if ($relativePath) {
        $totalFiles++
        $fullPath = Join-Path $baseDir $relativePath

        if (Test-Path $fullPath) {
            $firstLine = Get-Content $fullPath -TotalCount 1 -ErrorAction SilentlyContinue
            if ($firstLine -match "Variable names have been checked") {
                $filesWithHeader++
            } else {
                $filesWithoutHeader += $relativePath
            }
        }
    }
}

Write-Host "Total files: $totalFiles"
Write-Host "Files with header: $filesWithHeader"
Write-Host "Files without header: $($filesWithoutHeader.Count)"

if ($filesWithoutHeader.Count -gt 0) {
    Write-Host "`nFiles still needing refactoring:"
    $filesWithoutHeader | Select-Object -First 20 | ForEach-Object { Write-Host "  $_" }
    if ($filesWithoutHeader.Count -gt 20) {
        Write-Host "  ... and $($filesWithoutHeader.Count - 20) more"
    }
}
