param(
    [int]$GroupNumber = 0
)

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
    elseif ($line -match '^- ([^\s(]+)' -and $null -ne $currentGroup) {
        # Extract project name without statistics (everything before space or parenthesis)
        $projectName = $Matches[1].Trim()
        $groups[$currentGroup] += $projectName
    }
}

# Function to analyze a project
function Get-ProjectStats {
    param($projectName)

    $projectPath = Join-Path $PSScriptRoot ".." $projectName

    if (-not (Test-Path $projectPath)) {
        return $null
    }

    # EN: Get all .cs files excluding obj/, bin/ and GlobalUsings.cs (same logic as open-files-without-var-ok.ps1)
    # CZ: Získej všechny .cs soubory kromě obj/, bin/ a GlobalUsings.cs (stejná logika jako open-files-without-var-ok.ps1)
    $csFiles = @(Get-ChildItem -Path $projectPath -Filter '*.cs' -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
        $_.FullName -notmatch [regex]::Escape("\obj\") -and
        $_.FullName -notmatch [regex]::Escape("\bin\") -and
        $_.Name -ne "GlobalUsings.cs"
    })

    if ($csFiles.Count -eq 0) {
        return $null
    }

    $filesWithComment = 0

    foreach ($file in $csFiles) {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue

        # EN: Skip null/empty files (they don't have the comment)
        # CZ: Přeskoč null/prázdné soubory (nemají komentář)
        if ([string]::IsNullOrWhiteSpace($content)) {
            continue
        }

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

if ($GroupNumber -gt 0) {
    $output += "# Variable Renaming Progress Report - Group $GroupNumber"
} else {
    $output += "# Variable Renaming Progress Report"
}
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

# Determine which groups to process
$groupsToProcess = if ($GroupNumber -gt 0) {
    if ($groups.ContainsKey($GroupNumber)) {
        @($GroupNumber)
    } else {
        Write-Host "Group $GroupNumber not found in submodules-grouped.md" -ForegroundColor Red
        exit 1
    }
} else {
    $groups.Keys | Sort-Object
}

# Process each group
foreach ($groupNum in $groupsToProcess) {
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

        # EN: Create progress bar (20 chars wide, 5% per char)
        # CZ: Vytvoř progress bar (20 znaků široký, 5% na znak)
        $barLength = [math]::Floor($stats.Percentage / 5)
        $progressBar = ""
        if ($barLength -gt 0) {
            $progressBar = "█" * $barLength
        }
        $emptyBar = "░" * (20 - $barLength)
        $fullBar = "$progressBar$emptyBar"

        # EN: Add percentage text inside/after the bar for better visibility
        # CZ: Přidej procenta do/za bar pro lepší viditelnost
        $percentText = "$($stats.Percentage)%".PadLeft(7)

        # Color indicator
        $indicator = if ($stats.Percentage -eq 100) { "🟢" }
                     elseif ($stats.Percentage -ge 75) { "🔵" }
                     elseif ($stats.Percentage -ge 50) { "🟡" }
                     elseif ($stats.Percentage -ge 25) { "🟠" }
                     elseif ($stats.Percentage -gt 0) { "🔴" }
                     else { "⚫" }

        # EN: Format table row with aligned columns
        # CZ: Formátuj řádek tabulky se zarovnanými sloupci
        $output += "| $projectName | $indicator $fullBar | $($stats.FilesWithComment)/$($stats.TotalFiles) | $percentText |"
    }

    $output += ""
}

# Summary
$output += "## Summary"
$output += ""
$overallPercentage = if ($totalFiles -gt 0) {
    [math]::Round(($totalWithComment / $totalFiles) * 100, 2)
} else {
    0
}

$output += "| Metric | Value |"
$output += "|--------|-------|"
$output += "| Total projects analyzed | $totalProjects |"
$output += "| Total .cs files | $totalFiles |"
$output += "| Files with comment | $totalWithComment |"
$output += "| Overall percentage | $overallPercentage% |"
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

# EN: Write to file with UTF8 BOM for emoji support
# CZ: Zapiš do souboru s UTF8 BOM pro podporu emoji
$output | Out-File -FilePath $outputFile -Encoding utf8BOM

# EN: Write to console with colors for better readability
# CZ: Zapiš do konzole s barvami pro lepší čitelnost
Write-Host ""
# EN: Temporarily set console output encoding to UTF8
# CZ: Dočasně nastav console output encoding na UTF8
$previousEncoding = [Console]::OutputEncoding
try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    foreach ($line in $output) {
        # EN: Add colors based on content
        # CZ: Přidej barvy podle obsahu
        if ($line -match '^#') {
            # EN: Headers in cyan
            # CZ: Hlavičky v cyan
            Write-Host $line -ForegroundColor Cyan
        }
        elseif ($line -match '100%') {
            # EN: 100% complete in green
            # CZ: 100% hotové v zelené
            Write-Host $line -ForegroundColor Green
        }
        elseif ($line -match '\| [^|]+ \| 🟢') {
            # EN: Green emoji rows in green
            # CZ: Řádky se zeleným emoji v zelené
            Write-Host $line -ForegroundColor Green
        }
        elseif ($line -match '\| [^|]+ \| 🔵') {
            # EN: Blue emoji rows in cyan
            # CZ: Řádky s modrým emoji v cyan
            Write-Host $line -ForegroundColor Cyan
        }
        elseif ($line -match '\| [^|]+ \| 🟡') {
            # EN: Yellow emoji rows in yellow
            # CZ: Řádky se žlutým emoji ve žluté
            Write-Host $line -ForegroundColor Yellow
        }
        elseif ($line -match '\| [^|]+ \| 🟠') {
            # EN: Orange emoji rows in DarkYellow
            # CZ: Řádky s oranžovým emoji v DarkYellow
            Write-Host $line -ForegroundColor DarkYellow
        }
        elseif ($line -match '\| [^|]+ \| 🔴') {
            # EN: Red emoji rows in red
            # CZ: Řádky s červeným emoji v červené
            Write-Host $line -ForegroundColor Red
        }
        elseif ($line -match '\| [^|]+ \| ⚫') {
            # EN: Black emoji rows in gray
            # CZ: Řádky s černým emoji v šedé
            Write-Host $line -ForegroundColor Gray
        }
        elseif ($line -match '^\|[-|]+\|$') {
            # EN: Table separators in dark gray
            # CZ: Oddělovače tabulky v tmavě šedé
            Write-Host $line -ForegroundColor DarkGray
        }
        else {
            # EN: Default white
            # CZ: Výchozí bílá
            Write-Host $line
        }
    }
} finally {
    [Console]::OutputEncoding = $previousEncoding
}
Write-Host ""

if ($GroupNumber -gt 0) {
    Write-Host "Report generated for Group $GroupNumber only: $outputFile" -ForegroundColor Green
} else {
    Write-Host "Report generated for all groups: $outputFile" -ForegroundColor Green
}
