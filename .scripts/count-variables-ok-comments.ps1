$sunamoFolders = Get-ChildItem -Directory -Filter 'Sunamo*' | Where-Object { $_.Name -notlike '.*' }

Write-Host "Analyzing $($sunamoFolders.Count) Sunamo* projects...`n"

$results = @()

foreach ($folder in $sunamoFolders) {
    $csFiles = Get-ChildItem -Path $folder.FullName -Filter '*.cs' -Recurse -File -ErrorAction SilentlyContinue

    if ($csFiles.Count -eq 0) {
        continue
    }

    $filesWithComment = 0

    foreach ($file in $csFiles) {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -match '//\s*variables\s+names:\s*ok') {
            $filesWithComment++
        }
    }

    $percentage = if ($csFiles.Count -gt 0) {
        [math]::Round(($filesWithComment / $csFiles.Count) * 100, 2)
    } else {
        0
    }

    $results += [PSCustomObject]@{
        Project = $folder.Name
        TotalFiles = $csFiles.Count
        FilesWithComment = $filesWithComment
        Percentage = $percentage
    }
}

# Sort by percentage descending
$results = $results | Sort-Object -Property Percentage -Descending

Write-Host "=========================================="
Write-Host "Projects sorted by completion percentage"
Write-Host "==========================================`n"

foreach ($result in $results) {
    $bar = ""
    $barLength = [math]::Floor($result.Percentage / 2)
    if ($barLength -gt 0) {
        $bar = "█" * $barLength
    }

    $color = if ($result.Percentage -eq 100) { "Green" }
             elseif ($result.Percentage -ge 75) { "Cyan" }
             elseif ($result.Percentage -ge 50) { "Yellow" }
             elseif ($result.Percentage -ge 25) { "Magenta" }
             else { "Red" }

    Write-Host ("{0,-40} {1,6}% ({2,4}/{3,4}) " -f $result.Project, $result.Percentage, $result.FilesWithComment, $result.TotalFiles) -NoNewline
    Write-Host $bar -ForegroundColor $color
}

# Summary statistics
$totalFiles = ($results | Measure-Object -Property TotalFiles -Sum).Sum
$totalWithComment = ($results | Measure-Object -Property FilesWithComment -Sum).Sum
$overallPercentage = if ($totalFiles -gt 0) { [math]::Round(($totalWithComment / $totalFiles) * 100, 2) } else { 0 }

Write-Host "`n=========================================="
Write-Host "SUMMARY"
Write-Host "==========================================`n"
Write-Host "Total projects: $($results.Count)"
Write-Host "Total .cs files: $totalFiles"
Write-Host "Files with comment: $totalWithComment"
Write-Host "Overall percentage: $overallPercentage%"
Write-Host "`nProjects at 100%: $(($results | Where-Object { $_.Percentage -eq 100 }).Count)"
Write-Host "Projects at 0%: $(($results | Where-Object { $_.Percentage -eq 0 }).Count)"
