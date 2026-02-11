# EN: Unified submodule check script - combines progress report and quality check
# CZ: Sloučený skript pro kontrolu submodulů - kombinuje progress report a kvalitativní kontrolu

param(
    [Parameter(Mandatory=$false)]
    [string]$GroupNumber = "0",
    [switch]$SkipBuild,      # EN: Skip build check (faster) | CZ: Přeskoč build kontrolu (rychlejší)
    [switch]$SkipProgress    # EN: Skip progress scan | CZ: Přeskoč progress skenování
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptDir
$groupedFile = Join-Path $scriptDir "submodules-grouped.md"

# Parse GroupNumber - supports single number (4) or range (1-3)
$groupNumbers = @()
if ($GroupNumber -match "^(\d+)-(\d+)$") {
    $rangeStart = [int]$matches[1]
    $rangeEnd = [int]$matches[2]
    if ($rangeStart -gt $rangeEnd) { Write-Host "Invalid range: start ($rangeStart) is greater than end ($rangeEnd)" -ForegroundColor Red; exit 1 }
    $groupNumbers = $rangeStart..$rangeEnd
} else {
    $groupNumbers = @([int]$GroupNumber)
}

# ============================================
# FUNCTIONS / FUNKCE
# ============================================

# EN: Count .cs files with "// variables names: ok" comment
# CZ: Spočítej .cs soubory s komentářem "// variables names: ok"
function Get-ProjectStats {
    param($projectName)

    $projectPath = Join-Path $rootPath $projectName

    if (-not (Test-Path $projectPath)) {
        return $null
    }

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

# EN: Check if project needs rebuild
# CZ: Zkontroluj jestli projekt potřebuje rebuild
function Test-ProjectNeedsBuild {
    param(
        [string]$CsprojPath
    )

    $projectDir = Split-Path -Parent $CsprojPath
    $binDebugPath = Join-Path $projectDir "bin\Debug"

    if (-not (Test-Path $binDebugPath)) {
        return $true
    }

    $outputFiles = Get-ChildItem -Path $binDebugPath -Recurse -File | Where-Object {
        $_.Extension -eq ".dll" -or $_.Extension -eq ".exe"
    }

    if ($outputFiles.Count -eq 0) {
        return $true
    }

    $newestOutput = ($outputFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime

    $sourceFiles = @()
    $sourceFiles += Get-ChildItem -Path $projectDir -Filter "*.cs" -Recurse -File
    $sourceFiles += Get-Item $CsprojPath

    foreach ($sourceFile in $sourceFiles) {
        if ($sourceFile.LastWriteTime -gt $newestOutput) {
            return $true
        }
    }

    return $false
}

# EN: Check a single submodule for NoWarn and build issues
# CZ: Zkontroluj jeden submodul pro NoWarn a build problémy
function Get-QualityResult {
    param(
        [string]$SubmoduleName,
        [switch]$SkipBuild
    )

    $submodulePath = Join-Path $rootPath $SubmoduleName

    $result = [PSCustomObject]@{
        Submodule = $SubmoduleName
        NoWarnStatus = "OK"
        NoWarnFiles = @()
        BuildStatus = "OK"
        BuildErrors = @()
        ProjectsChecked = 0
    }

    $csprojFiles = Get-ChildItem -Path $submodulePath -Filter "*.csproj" -Recurse -File -ErrorAction SilentlyContinue
    $result.ProjectsChecked = $csprojFiles.Count

    if ($csprojFiles.Count -eq 0) {
        $result.NoWarnStatus = "NO_PROJECTS"
        $result.BuildStatus = "NO_PROJECTS"
        return $result
    }

    # EN: Check for NoWarn in .csproj files
    # CZ: Zkontroluj NoWarn v .csproj souborech
    foreach ($csproj in $csprojFiles) {
        $content = Get-Content $csproj.FullName -Raw
        if ($content -match '<NoWarn>.*?\S.*?</NoWarn>') {
            $result.NoWarnStatus = "HAS_NOWARN"
            $relativePath = $csproj.FullName.Replace($rootPath + "\", "")
            $result.NoWarnFiles += $relativePath
            Write-Host "  ⚠ NoWarn found in: $($csproj.Name)" -ForegroundColor Red
        }
    }

    if ($result.NoWarnStatus -eq "OK") {
        Write-Host "  ✓ All .csproj files without NoWarn" -ForegroundColor Green
    }

    # EN: Build check
    # CZ: Build kontrola
    if (-not $SkipBuild) {
        Write-Host "  Checking projects..." -ForegroundColor Gray

        foreach ($csproj in $csprojFiles) {
            $projectName = [System.IO.Path]::GetFileNameWithoutExtension($csproj.Name)

            $needsBuild = Test-ProjectNeedsBuild -CsprojPath $csproj.FullName

            if (-not $needsBuild) {
                Write-Host "  ⊙ $projectName - Up to date, skipping build" -ForegroundColor Cyan
                continue
            }

            Write-Host "  ⟳ $projectName - Building..." -ForegroundColor Gray
            $buildOutput = dotnet build $csproj.FullName -c Debug --nologo 2>&1 | Out-String

            if ($buildOutput -match "(\d+) Error\(s\)" -and $Matches[1] -ne "0") {
                $result.BuildStatus = "HAS_ERRORS"
                $result.BuildErrors += "$projectName - Errors: $($Matches[1])"
                Write-Host "  ✗ $projectName - Build FAILED with errors" -ForegroundColor Red
            }
            elseif ($buildOutput -match "(\d+) Warning\(s\)" -and $Matches[1] -ne "0") {
                $result.BuildStatus = "HAS_WARNINGS"
                $result.BuildErrors += "$projectName - Warnings: $($Matches[1])"
                Write-Host "  ⚠ $projectName - Build succeeded with warnings" -ForegroundColor Yellow
            }
            else {
                Write-Host "  ✓ $projectName - Build succeeded" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "  ⊙ Build check skipped (-SkipBuild)" -ForegroundColor Cyan
        $result.BuildStatus = "SKIPPED"
    }

    return $result
}

# EN: Get quality indicator string for a result
# CZ: Získej kvalitativní indikátor pro výsledek
function Get-QualityIndicator {
    param([PSCustomObject]$Result)

    if ($Result.NoWarnStatus -eq "OK" -and ($Result.BuildStatus -eq "OK" -or $Result.BuildStatus -eq "SKIPPED")) {
        return "✓"
    } elseif ($Result.BuildStatus -eq "HAS_ERRORS") {
        return "✗ BUILD ERRORS"
    } elseif ($Result.NoWarnStatus -eq "HAS_NOWARN") {
        return "⚠ NoWarn"
    } elseif ($Result.BuildStatus -eq "HAS_WARNINGS") {
        return "⚠ Warnings"
    } elseif ($Result.NoWarnStatus -eq "NO_PROJECTS") {
        return "N/A"
    }
    return "?"
}

# ============================================
# PARSE GROUPS FROM submodules-grouped.md
# ============================================

if (-not (Test-Path $groupedFile)) {
    Write-Host "Grouped submodules file not found: $groupedFile" -ForegroundColor Red
    Write-Host "Run .scripts\group-submodules.ps1 first" -ForegroundColor Yellow
    exit 1
}

$groups = @{}
$previousStats = @{}
$currentGroup = $null

foreach ($line in (Get-Content $groupedFile)) {
    if ($line -match '^## Group (\d+)$') {
        $currentGroup = [int]$Matches[1]
        $groups[$currentGroup] = @()
    }
    elseif ($line -match '^- ([^\s(]+)\s+\((\d+(?:\.\d+)?)%\s*-\s*(\d+)/(\d+)\)' -and $null -ne $currentGroup) {
        # EN: Parse project name AND previous progress stats
        # CZ: Parsuj název projektu A předchozí progress statistiky
        $projectName = $Matches[1].Trim()
        $groups[$currentGroup] += $projectName
        $previousStats[$projectName] = @{
            Percentage = [double]$Matches[2]
            FilesWithComment = [int]$Matches[3]
            TotalFiles = [int]$Matches[4]
        }
    }
    elseif ($line -match '^- ([^\s(]+)' -and $null -ne $currentGroup) {
        $projectName = $Matches[1].Trim()
        $groups[$currentGroup] += $projectName
    }
}

# ============================================
# MODE: SPECIFIC GROUP (-GroupNumber N)
# ============================================

if (-not ($groupNumbers.Count -eq 1 -and $groupNumbers[0] -eq 0)) {
    foreach ($groupNum in $groupNumbers) {
        if (-not $groups.ContainsKey($groupNum)) {
            Write-Host "Group $groupNum not found in submodules-grouped.md" -ForegroundColor Red
            exit 1
        }
    }

    # EN: Collect submodules from all specified groups (keep per-group mapping for file update)
    # CZ: Sesbírej submoduly ze všech specifikovaných skupin (zachovej mapování pro update souboru)
    $allSubmoduleNames = @()
    foreach ($groupNum in $groupNumbers) {
        $allSubmoduleNames += $groups[$groupNum]
    }
    $allSubmoduleNames = $allSubmoduleNames | Select-Object -Unique

    # EN: Filter out missing submodules
    # CZ: Odfiltruj chybějící submoduly
    $existingNames = @()
    $missingNames = @()

    foreach ($name in $allSubmoduleNames) {
        $submodulePath = Join-Path $rootPath $name
        if (Test-Path $submodulePath) {
            $existingNames += $name
        } else {
            $missingNames += $name
        }
    }

    if ($missingNames.Count -gt 0) {
        Write-Host "Skipping $($missingNames.Count) missing submodules:" -ForegroundColor Yellow
        foreach ($missing in $missingNames) {
            Write-Host "  - $missing" -ForegroundColor Yellow
        }
        Write-Host ""
    }

    if ($existingNames.Count -eq 0) {
        Write-Host "No existing submodules found in group(s) $GroupNumber" -ForegroundColor Red
        exit 1
    }

    Write-Host "Checking group(s) $GroupNumber with $($existingNames.Count) submodules" -ForegroundColor Cyan
    Write-Host ""

    # EN: Build submodule-to-group mapping and global order counter
    # CZ: Vybuduj mapování submodul→skupina a globální pořadové počítadlo
    $submoduleToGroup = @{}
    foreach ($groupNum in $groupNumbers) {
        if ($groups.ContainsKey($groupNum)) {
            foreach ($name in $groups[$groupNum]) {
                if (-not $submoduleToGroup.ContainsKey($name)) { $submoduleToGroup[$name] = $groupNum }
            }
        }
    }

    # EN: Collect results for each submodule
    # CZ: Sesbírej výsledky pro každý submodul
    $progressResults = @{}
    $qualityResults = @{}
    $regressions = @()
    $repoIndex = 0

    foreach ($name in $existingNames) {
        $repoIndex++
        $groupLabel = if ($submoduleToGroup.ContainsKey($name)) { "Group $($submoduleToGroup[$name])" } else { "?" }
        Write-Host "Processing [$repoIndex/$($existingNames.Count)] ($groupLabel): $name" -ForegroundColor Yellow

        # EN: Progress check
        # CZ: Progress kontrola
        if (-not $SkipProgress) {
            $stats = Get-ProjectStats -projectName $name
            $progressResults[$name] = $stats
            if ($null -ne $stats) {
                Write-Host "  Progress: $($stats.Percentage)% ($($stats.FilesWithComment)/$($stats.TotalFiles))" -ForegroundColor Cyan

                # EN: REGRESSION DETECTION - compare with previous stats from submodules-grouped.md
                # CZ: DETEKCE REGRESE - porovnej s předchozími statistikami ze submodules-grouped.md
                if ($previousStats.ContainsKey($name)) {
                    $prev = $previousStats[$name]
                    $lostFiles = $prev.FilesWithComment - $stats.FilesWithComment

                    if ($lostFiles -gt 0) {
                        $regressions += @{
                            Name = $name
                            PrevFiles = $prev.FilesWithComment
                            PrevTotal = $prev.TotalFiles
                            PrevPct = $prev.Percentage
                            NowFiles = $stats.FilesWithComment
                            NowTotal = $stats.TotalFiles
                            NowPct = $stats.Percentage
                            LostFiles = $lostFiles
                        }

                        Write-Host ""
                        Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Red
                        Write-Host "  ║  REGRESE! Ztráta '// variables names: ok' komentářů!    ║" -ForegroundColor Red
                        Write-Host "  ╠══════════════════════════════════════════════════════════╣" -ForegroundColor Red
                        Write-Host "  ║  Předtím: $($prev.FilesWithComment)/$($prev.TotalFiles) ($($prev.Percentage)%)" -ForegroundColor Red
                        Write-Host "  ║  Nyní:    $($stats.FilesWithComment)/$($stats.TotalFiles) ($($stats.Percentage)%)" -ForegroundColor Red
                        Write-Host "  ║  ZTRACENO: $lostFiles soubor(ů) přišlo o OK komentář!" -ForegroundColor Red
                        Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Red
                        Write-Host ""
                    }
                }
            } else {
                Write-Host "  Progress: N/A (no .cs files)" -ForegroundColor Gray
            }
        }

        # EN: Quality check
        # CZ: Kvalitativní kontrola
        $qualityResult = Get-QualityResult -SubmoduleName $name -SkipBuild:$SkipBuild
        $qualityResults[$name] = $qualityResult

        Write-Host ""
    }

    # EN: REGRESSION SUMMARY - loud alert at the end so it's impossible to miss
    # CZ: SOUHRN REGRESÍ - hlasité upozornění na konci aby to nešlo přehlédnout
    if ($regressions.Count -gt 0) {
        $totalLost = ($regressions | Measure-Object -Property LostFiles -Sum).Sum

        Write-Host ""
        Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║                    !!! REGRESE DETEKOVÁNA !!!                    ║" -ForegroundColor Red
        Write-Host "║         Něco smazalo '// variables names: ok' komentáře!         ║" -ForegroundColor Red
        Write-Host "╠══════════════════════════════════════════════════════════════════╣" -ForegroundColor Red
        Write-Host "║  Celkem ztraceno: $totalLost soubor(ů) v $($regressions.Count) submodul(ech)" -ForegroundColor Red
        Write-Host "╠══════════════════════════════════════════════════════════════════╣" -ForegroundColor Red
        foreach ($reg in $regressions) {
            Write-Host "║  $($reg.Name): $($reg.PrevFiles) -> $($reg.NowFiles) (ztráta $($reg.LostFiles))" -ForegroundColor Red
        }
        Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
        Write-Host "DOPORUČENÍ: Zkontroluj git diff pro dotčené submoduly!" -ForegroundColor Yellow
        Write-Host ""
    }

    # ============================================
    # UPDATE submodules-grouped.md
    # ============================================

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $content = Get-Content $groupedFile
    $newContent = @()
    $skipUntilNextGroup = $false

    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]

        if ($line -match '^## Group (\d+)$') {
            $currentGroupNum = [int]$Matches[1]

            if ($groupNumbers -contains $currentGroupNum) {
                $newContent += $line
                $newContent += ""
                $newContent += "**Last checked:** $timestamp"
                $newContent += ""

                # EN: Write submodule lines with both progress and quality
                # CZ: Zapiš řádky submodulů s progress i kvalitou
                foreach ($name in $groups[$currentGroupNum]) {
                    $progressLine = ""
                    $qualityLine = ""

                    # EN: Progress part
                    # CZ: Progress část
                    if (-not $SkipProgress -and $progressResults.ContainsKey($name)) {
                        $stats = $progressResults[$name]
                        if ($null -ne $stats) {
                            $progressLine = "($($stats.Percentage)% - $($stats.FilesWithComment)/$($stats.TotalFiles))"
                        } else {
                            $progressLine = "(N/A)"
                        }
                    } elseif ($missingNames -contains $name) {
                        $progressLine = "(MISSING)"
                    } else {
                        # EN: Preserve existing progress from file if we skipped progress scan
                        # CZ: Zachovaj existující progress ze souboru pokud jsme přeskočili progress sken
                        $existingLine = $content | Where-Object { $_ -match "^- $([regex]::Escape($name)) \(" }
                        if ($existingLine -and $existingLine -match '\(([^)]+)\)') {
                            $progressLine = "($($Matches[1]))"
                        } else {
                            $progressLine = "(N/A)"
                        }
                    }

                    # EN: Quality part
                    # CZ: Kvalitativní část
                    if ($qualityResults.ContainsKey($name)) {
                        $qualityIndicator = Get-QualityIndicator -Result $qualityResults[$name]
                        $qualityLine = "[$qualityIndicator]"
                    }

                    if ($qualityLine -ne "") {
                        $newContent += "- $name $progressLine $qualityLine"
                    } else {
                        $newContent += "- $name $progressLine"
                    }
                }

                $newContent += ""
                $skipUntilNextGroup = $true
                continue
            } else {
                $skipUntilNextGroup = $false
            }
        }

        if ($skipUntilNextGroup) {
            if ($line -match '^## Group \d+$' -or $line -match '^---$') {
                $skipUntilNextGroup = $false
                $newContent += ""
                $newContent += $line
            }
            continue
        }

        $newContent += $line
    }

    $newContent | Out-File -FilePath $groupedFile -Encoding utf8BOM

    # EN: Export quality results to JSON
    # CZ: Exportuj kvalitativní výsledky do JSON
    $jsonPath = Join-Path $scriptDir "submodules-quality-report.json"
    $qualityResults.Values | ConvertTo-Json -Depth 10 | Out-File $jsonPath -Encoding UTF8

    # ============================================
    # SUMMARY
    # ============================================

    $allQuality = @($qualityResults.Values)
    $perfectCount = @($allQuality | Where-Object { $_.NoWarnStatus -eq "OK" -and ($_.BuildStatus -eq "OK" -or $_.BuildStatus -eq "SKIPPED") }).Count
    $noWarnCount = @($allQuality | Where-Object { $_.NoWarnStatus -eq "HAS_NOWARN" }).Count
    $errorCount = @($allQuality | Where-Object { $_.BuildStatus -eq "HAS_ERRORS" }).Count
    $warningCount = @($allQuality | Where-Object { $_.BuildStatus -eq "HAS_WARNINGS" }).Count

    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "SUMMARY - Group(s) $GroupNumber" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Perfect: $perfectCount" -ForegroundColor Green
    Write-Host "NoWarn issues: $noWarnCount" -ForegroundColor $(if ($noWarnCount -gt 0) { "Red" } else { "Green" })
    Write-Host "Build errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
    Write-Host "Build warnings: $warningCount" -ForegroundColor $(if ($warningCount -gt 0) { "Yellow" } else { "Green" })
    Write-Host ""
    Write-Host "Updated Group(s) $GroupNumber in submodules-grouped.md" -ForegroundColor Green
    Write-Host "Quality report: $jsonPath" -ForegroundColor Cyan
    exit 0
}

# ============================================
# MODE: FULL REPORT (no GroupNumber)
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "TIP: You can use -GroupNumber parameter to check specific group(s)" -ForegroundColor Yellow
Write-Host "Example: .\.scripts\check-group.ps1 -GroupNumber 4" -ForegroundColor Yellow
Write-Host "Example: .\.scripts\check-group.ps1 -GroupNumber 1-3" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$outputFile = Join-Path $scriptDir "variable-renaming-progress.md"
$output = @()

$output += "# Variable Renaming Progress Report"
$output += ""
$output += "Progress of adding ``// variables names: ok`` comments to files."
$output += ""
$output += "Generated: $timestamp"
$output += ""

$totalProjects = 0
$totalFiles = 0
$totalWithComment = 0
$projectsAt100 = 0
$projectsAt0 = 0

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

        $barLength = [math]::Floor($stats.Percentage / 5)
        $progressBar = ""
        if ($barLength -gt 0) {
            $progressBar = "█" * $barLength
        }
        $emptyBar = "░" * (20 - $barLength)
        $fullBar = "$progressBar$emptyBar"

        $percentText = "$($stats.Percentage)%".PadLeft(7)

        $indicator = if ($stats.Percentage -eq 100) { "🟢" }
                     elseif ($stats.Percentage -ge 75) { "🔵" }
                     elseif ($stats.Percentage -ge 50) { "🟡" }
                     elseif ($stats.Percentage -ge 25) { "🟠" }
                     elseif ($stats.Percentage -gt 0) { "🔴" }
                     else { "⚫" }

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

$output | Out-File -FilePath $outputFile -Encoding utf8BOM

# EN: Console output with colors
# CZ: Konzolový výstup s barvami
Write-Host ""
$previousEncoding = [Console]::OutputEncoding
try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    foreach ($line in $output) {
        if ($line -match '^#') {
            Write-Host $line -ForegroundColor Cyan
        }
        elseif ($line -match '100%') {
            Write-Host $line -ForegroundColor Green
        }
        elseif ($line -match '\| [^|]+ \| 🟢') {
            Write-Host $line -ForegroundColor Green
        }
        elseif ($line -match '\| [^|]+ \| 🔵') {
            Write-Host $line -ForegroundColor Cyan
        }
        elseif ($line -match '\| [^|]+ \| 🟡') {
            Write-Host $line -ForegroundColor Yellow
        }
        elseif ($line -match '\| [^|]+ \| 🟠') {
            Write-Host $line -ForegroundColor DarkYellow
        }
        elseif ($line -match '\| [^|]+ \| 🔴') {
            Write-Host $line -ForegroundColor Red
        }
        elseif ($line -match '\| [^|]+ \| ⚫') {
            Write-Host $line -ForegroundColor Gray
        }
        elseif ($line -match '^\|[-|]+\|$') {
            Write-Host $line -ForegroundColor DarkGray
        }
        else {
            Write-Host $line
        }
    }
} finally {
    [Console]::OutputEncoding = $previousEncoding
}
Write-Host ""
Write-Host "Report generated: $outputFile" -ForegroundColor Green
