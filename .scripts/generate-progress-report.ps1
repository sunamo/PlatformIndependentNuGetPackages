# Read groups from submodules-grouped.md
$groupsFile = Join-Path $PSScriptRoot "submodules-grouped.md"
$groupsContent = Get-Content $groupsFile -Raw

# Parse groups
$groups = @{}
$currentGroup = $null

foreach ($line in (Get-Content $groupsFile)) {
    if ($line -match '^## Group (\d+)$') {
        $currentGroup = [int]$Matches[1]
        $groups[$currentGroup] = @()
    }
    elseif ($line -match '^- (.+)$' -and $null -ne $currentGroup) {
        $groups[$currentGroup] += $Matches[1]
    }
}

# Function to analyze a project
function Get-ProjectStats {
    param($projectName)

    $projectPath = Join-Path $PSScriptRoot ".." $projectName

    if (-not (Test-Path $projectPath)) {
        return $null
    }

    $csFiles = Get-ChildItem -Path $projectPath -Filter '*.cs' -Recurse -File -ErrorAction SilentlyContinue

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

# Generate report
$outputFile = Join-Path $PSScriptRoot "variable-renaming-progress.md"
$output = @()

$output += "# Variable Renaming Progress Report"
$output += ""
$output += "Progress of adding `// variables names: ok` comments to files."
$output += ""
$output += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$output += ""

$totalProjects = 0
$totalFiles = 0
$totalWithComment = 0
$projectsAt100 = 0
$projectsAt0 = 0

# Process each group
foreach ($groupNum in ($groups.Keys | Sort-Object)) {
    $output += "## Group $groupNum"
    $output += ""
    $output += "| Project | Progress | Files | Percentage |"
    $output += "|---------|----------|-------|------------|"

    foreach ($projectName in $groups[$groupNum]) {
        $stats = Get-ProjectStats -projectName $projectName

        if ($null -eq $stats) {
            $output += "| $projectName | N/A | N/A | N/A |"
            continue
        }

        $totalProjects++
        $totalFiles += $stats.TotalFiles
        $totalWithComment += $stats.FilesWithComment

        if ($stats.Percentage -eq 100) { $projectsAt100++ }
        if ($stats.Percentage -eq 0) { $projectsAt0++ }

        # Create progress bar
        $barLength = [math]::Floor($stats.Percentage / 5)
        $progressBar = ""
        if ($barLength -gt 0) {
            $progressBar = "█" * $barLength
        }
        $emptyBar = "░" * (20 - $barLength)
        $fullBar = "$progressBar$emptyBar"

        # Color indicator
        $indicator = if ($stats.Percentage -eq 100) { "🟢" }
                     elseif ($stats.Percentage -ge 75) { "🔵" }
                     elseif ($stats.Percentage -ge 50) { "🟡" }
                     elseif ($stats.Percentage -ge 25) { "🟠" }
                     elseif ($stats.Percentage -gt 0) { "🔴" }
                     else { "⚫" }

        $output += "| $projectName | $indicator $fullBar | $($stats.FilesWithComment)/$($stats.TotalFiles) | $($stats.Percentage)% |"
    }

    $output += ""
}

# Summary
$output += "## Summary"
$output += ""
$output += "| Metric | Value |"
$output += "|--------|-------|"
$output += "| Total projects analyzed | $totalProjects |"
$output += "| Total .cs files | $totalFiles |"
$output += "| Files with comment | $totalWithComment |"
$output += "| Overall percentage | $([math]::Round(($totalWithComment / $totalFiles) * 100, 2))% |"
$output += "| Projects at 100% | $projectsAt100 |"
$output += "| Projects at 0% | $projectsAt0 |"
$output += "| Projects in progress | $($totalProjects - $projectsAt100 - $projectsAt0) |"
$output += ""
$output += "## Legend"
$output += ""
$output += "- 🟢 100% complete"
$output += "- 🔵 75-99% complete"
$output += "- 🟡 50-74% complete"
$output += "- 🟠 25-49% complete"
$output += "- 🔴 1-24% complete"
$output += "- ⚫ 0% complete"

# Write to file
$output | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "Report generated: $outputFile"
