# Split variables-with-context.json into smaller chunks for AI analysis

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$inputFile = Join-Path $rootPath ".variable-rename-project\analysis\variables-with-context.json"
$outputDir = Join-Path $rootPath ".variable-rename-project\analysis\chunks"

# Create output directory
if (Test-Path $outputDir) {
    Remove-Item $outputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $outputDir | Out-Null

# Load JSON
Write-Host "Loading variables..." -ForegroundColor Cyan
$variables = Get-Content $inputFile -Raw | ConvertFrom-Json

Write-Host "Total variables: $($variables.Count)" -ForegroundColor Yellow

# Split into chunks of 30
$chunkSize = 30
$chunkIndex = 0
for ($i = 0; $i -lt $variables.Count; $i += $chunkSize) {
    $chunkIndex++
    $chunk = $variables[$i..[Math]::Min($i + $chunkSize - 1, $variables.Count - 1)]

    $chunkFile = Join-Path $outputDir "chunk-$($chunkIndex.ToString('000')).json"
    $chunk | ConvertTo-Json -Depth 10 | Out-File $chunkFile -Encoding UTF8

    Write-Host "Created chunk $chunkIndex : $($chunk.Count) variables" -ForegroundColor Green
}

Write-Host "`nTotal chunks created: $chunkIndex" -ForegroundColor Cyan
Write-Host "Output directory: $outputDir" -ForegroundColor Yellow
