$basePath = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoString\SunamoString"
$header1 = "// EN: Variable names have been checked and replaced with self-descriptive names"
$header2 = "// CZ: Názvy proměnných byly zkontrolovány a nahrazeny samopopisnými názvy"

$filesWithoutHeader = @()
$allFiles = @()

Get-ChildItem -Path $basePath -Recurse -Filter "*.cs" | Where-Object {
    $_.FullName -notmatch [regex]::Escape("\obj\") -and
    $_.FullName -notmatch [regex]::Escape("\bin\") -and
    $_.Name -ne "GlobalUsings.cs"
} | ForEach-Object {
    $file = $_

    # Count total lines
    $content = Get-Content -Path $file.FullName -ErrorAction SilentlyContinue
    $totalLines = if ($content -is [array]) { $content.Count } else { 1 }

    # Check if file has the header
    $hasHeader = $false
    if ($totalLines -ge 2) {
        if ($content[0] -eq $header1 -and $content[1] -eq $header2) {
            $hasHeader = $true
        }
    }

    $allFiles += [PSCustomObject]@{
        Path = $file.FullName
        Lines = $totalLines
        HasHeader = $hasHeader
        Name = $file.Name
    }

    # Only include files with more than 10 lines and without header
    if ($totalLines -gt 10 -and -not $hasHeader) {
        $filesWithoutHeader += [PSCustomObject]@{
            Path = $file.FullName
            Lines = $totalLines
        }
    }
}

# Sort by lines descending (biggest files first)
$filesWithoutHeader = $filesWithoutHeader | Sort-Object -Property Lines -Descending

# Output results
Write-Host "SUMMARY: Files WITHOUT required header (> 10 lines, sorted by size - largest first):" -ForegroundColor Green
Write-Host ""

if ($filesWithoutHeader.Count -eq 0) {
    Write-Host "No files found without the required header." -ForegroundColor Green
} else {
    $filesWithoutHeader | Sort-Object -Property Lines -Descending | ForEach-Object {
        Write-Host "Lines: $($_.Lines)`t$($_.Path)"
    }
    Write-Host ""
    Write-Host "Total files: $($filesWithoutHeader.Count)" -ForegroundColor Cyan
}
