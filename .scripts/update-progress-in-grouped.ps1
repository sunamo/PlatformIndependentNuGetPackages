# Function to analyze a project (excluding bin/obj folders)
function Get-ProjectStats {
    param($projectName)

    $projectPath = Join-Path $PSScriptRoot ".." $projectName

    if (-not (Test-Path $projectPath)) {
        return $null
    }

    $csFiles = Get-ChildItem -Path $projectPath -Filter '*.cs' -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\bin\\' -and $_.FullName -notmatch '\\obj\\' }

    if ($csFiles.Count -eq 0) {
        return $null
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

    return @{
        TotalFiles = $csFiles.Count
        FilesWithComment = $filesWithComment
        Percentage = $percentage
    }
}

# Read and update submodules-grouped.md
$groupsFile = Join-Path $PSScriptRoot "submodules-grouped.md"
$lines = Get-Content $groupsFile

$updatedLines = @()
$totalProjects = 0
$totalFiles = 0
$totalWithComment = 0

foreach ($line in $lines) {
    if ($line -match '^- (.+?)(\s*\(.*\))?$') {
        $projectName = $Matches[1].Trim()
        $stats = Get-ProjectStats -projectName $projectName

        if ($null -eq $stats) {
            $updatedLines += "- $projectName (N/A)"
        } else {
            $totalProjects++
            $totalFiles += $stats.TotalFiles
            $totalWithComment += $stats.FilesWithComment
            $updatedLines += "- $projectName ($($stats.Percentage)% - $($stats.FilesWithComment)/$($stats.TotalFiles))"
        }
    } else {
        $updatedLines += $line
    }
}

# Add summary at the end
$overallPercentage = if ($totalFiles -gt 0) { [math]::Round(($totalWithComment / $totalFiles) * 100, 2) } else { 0 }

$updatedLines += ""
$updatedLines += "---"
$updatedLines += ""
$updatedLines += "## Overall Progress"
$updatedLines += ""
$updatedLines += "- **Total projects:** $totalProjects"
$updatedLines += "- **Total .cs files:** $totalFiles (excluding bin/obj)"
$updatedLines += "- **Files with comment:** $totalWithComment"
$updatedLines += "- **Overall percentage:** $overallPercentage%"
$updatedLines += ""
$updatedLines += "Last updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Write back to file
$updatedLines | Out-File -FilePath $groupsFile -Encoding UTF8

Write-Host "Updated: $groupsFile"
Write-Host "Total projects: $totalProjects"
Write-Host "Total files: $totalFiles"
Write-Host "Files with comment: $totalWithComment"
Write-Host "Overall percentage: $overallPercentage%"
