# Get list of files that still need refactoring
$baseDir = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$filesListPath = Join-Path $baseDir "files-with-short-variables.txt"
$outputPath = Join-Path $baseDir "files-needing-refactoring.txt"

$filesWithoutHeader = @()

Get-Content $filesListPath | ForEach-Object {
    $relativePath = $_.Trim()
    if ($relativePath) {
        $fullPath = Join-Path $baseDir $relativePath

        if (Test-Path $fullPath) {
            $firstLine = Get-Content $fullPath -TotalCount 1 -ErrorAction SilentlyContinue
            if ($firstLine -notmatch "Variable names have been checked") {
                $filesWithoutHeader += $relativePath
            }
        }
    }
}

$filesWithoutHeader | Out-File $outputPath -Encoding utf8
Write-Host "Saved $($filesWithoutHeader.Count) files to $outputPath"
