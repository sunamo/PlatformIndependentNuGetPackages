# EN: Unified script - generates and updates submodules-grouped.md with progress + quality data
# CZ: Sloučený skript - generuje a aktualizuje submodules-grouped.md s progress + quality daty

param(
    [Parameter(Mandatory=$false)]
    [string]$GroupNumber = "0",
    [switch]$SkipBuild,
    [switch]$SkipProgress,
    [switch]$CleanBinObj
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptDir
$groupedFile = Join-Path $scriptDir "submodules-grouped.md"
$gitmodulesPath = Join-Path $rootPath ".gitmodules"

# Parse GroupNumber - supports single number (4) or range (1-13)
$groupNumbers = @()
if ($GroupNumber -match "^(\d+)-(\d+)$") {
    $rangeStart = [int]$matches[1]
    $rangeEnd = [int]$matches[2]
    if ($rangeStart -gt $rangeEnd) { Write-Host "Invalid range: start ($rangeStart) > end ($rangeEnd)" -ForegroundColor Red; exit 1 }
    $groupNumbers = $rangeStart..$rangeEnd
} else {
    $groupNumbers = @([int]$GroupNumber)
}

$processAll = ($groupNumbers.Count -eq 1 -and $groupNumbers[0] -eq 0)

# ============================================
# FUNCTIONS
# ============================================

function Get-ProjectStats {
    param($projectName)
    $projectPath = Join-Path $rootPath $projectName
    if (-not (Test-Path $projectPath)) { return $null }

    $csFiles = @(Get-ChildItem -Path $projectPath -Filter '*.cs' -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
        $_.FullName -notmatch [regex]::Escape("\obj\") -and
        $_.FullName -notmatch [regex]::Escape("\bin\") -and
        $_.Name -ne "GlobalUsings.cs"
    })
    if ($csFiles.Count -eq 0) { return $null }

    $filesWithComment = 0
    foreach ($file in $csFiles) {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        if ([string]::IsNullOrWhiteSpace($content)) { continue }
        if ($content -match '//\s*variables\s+names:\s*ok') { $filesWithComment++ }
    }

    $percentage = [math]::Round(($filesWithComment / $csFiles.Count) * 100, 2)
    return @{ TotalFiles = $csFiles.Count; FilesWithComment = $filesWithComment; Percentage = $percentage }
}

function Test-ProjectNeedsBuild {
    param([string]$CsprojPath)
    $projectDir = Split-Path -Parent $CsprojPath
    $binDebugPath = Join-Path $projectDir "bin\Debug"
    if (-not (Test-Path $binDebugPath)) { return $true }

    $outputFiles = Get-ChildItem -Path $binDebugPath -Recurse -File | Where-Object { $_.Extension -eq ".dll" -or $_.Extension -eq ".exe" }
    if ($outputFiles.Count -eq 0) { return $true }

    $newestOutput = ($outputFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime
    $sourceFiles = @()
    $sourceFiles += Get-ChildItem -Path $projectDir -Filter "*.cs" -Recurse -File
    $sourceFiles += Get-Item $CsprojPath
    foreach ($sourceFile in $sourceFiles) {
        if ($sourceFile.LastWriteTime -gt $newestOutput) { return $true }
    }
    return $false
}

function Get-QualityResult {
    param([string]$SubmoduleName, [switch]$SkipBuild)
    $submodulePath = Join-Path $rootPath $SubmoduleName

    $result = [PSCustomObject]@{
        Submodule = $SubmoduleName; NoWarnStatus = "OK"; NoWarnFiles = @()
        BuildStatus = "OK"; BuildErrors = @(); ProjectsChecked = 0
    }

    $csprojFiles = Get-ChildItem -Path $submodulePath -Filter "*.csproj" -Recurse -File -ErrorAction SilentlyContinue
    $result.ProjectsChecked = $csprojFiles.Count

    if ($csprojFiles.Count -eq 0) {
        $result.NoWarnStatus = "NO_PROJECTS"; $result.BuildStatus = "NO_PROJECTS"; return $result
    }

    foreach ($csproj in $csprojFiles) {
        $content = Get-Content $csproj.FullName -Raw
        if ($content -match '<NoWarn>.*?\S.*?</NoWarn>') {
            $result.NoWarnStatus = "HAS_NOWARN"
            $relativePath = $csproj.FullName.Replace($rootPath + "\", "")
            $result.NoWarnFiles += $relativePath
            Write-Host "  ! NoWarn found in: $($csproj.Name)" -ForegroundColor Red
        }
    }
    if ($result.NoWarnStatus -eq "OK") { Write-Host "  ok All .csproj files without NoWarn" -ForegroundColor Green }

    if (-not $SkipBuild) {
        Write-Host "  Checking projects..." -ForegroundColor Gray
        foreach ($csproj in $csprojFiles) {
            $projectName = [System.IO.Path]::GetFileNameWithoutExtension($csproj.Name)
            $needsBuild = Test-ProjectNeedsBuild -CsprojPath $csproj.FullName
            if (-not $needsBuild) { Write-Host "  - $projectName - Up to date, skipping build" -ForegroundColor Cyan; continue }

            Write-Host "  ~ $projectName - Building..." -ForegroundColor Gray
            $buildOutput = dotnet build $csproj.FullName -c Debug --nologo 2>&1 | Out-String

            if ($buildOutput -match "(\d+) Error\(s\)" -and $Matches[1] -ne "0") {
                $result.BuildStatus = "HAS_ERRORS"; $result.BuildErrors += "$projectName - Errors: $($Matches[1])"
                Write-Host "  x $projectName - Build FAILED with errors" -ForegroundColor Red
            } elseif ($buildOutput -match "(\d+) Warning\(s\)" -and $Matches[1] -ne "0") {
                $result.BuildStatus = "HAS_WARNINGS"; $result.BuildErrors += "$projectName - Warnings: $($Matches[1])"
                Write-Host "  ! $projectName - Build succeeded with warnings" -ForegroundColor Yellow
            } else {
                Write-Host "  ok $projectName - Build succeeded" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "  - Build check skipped (-SkipBuild)" -ForegroundColor Cyan
        $result.BuildStatus = "SKIPPED"
    }

    return $result
}

function Get-QualityIndicator {
    param([PSCustomObject]$Result)
    if ($Result.NoWarnStatus -eq "OK" -and ($Result.BuildStatus -eq "OK" -or $Result.BuildStatus -eq "SKIPPED")) { return "[ok]" }
    elseif ($Result.BuildStatus -eq "HAS_ERRORS") { return "[x BUILD ERRORS]" }
    elseif ($Result.NoWarnStatus -eq "HAS_NOWARN") { return "[! NoWarn]" }
    elseif ($Result.BuildStatus -eq "HAS_WARNINGS") { return "[! Warnings]" }
    elseif ($Result.NoWarnStatus -eq "NO_PROJECTS") { return "[N/A]" }
    return "[?]"
}

# ============================================
# READ .gitmodules - source of truth
# ============================================

if (-not (Test-Path $gitmodulesPath)) {
    Write-Host ".gitmodules not found: $gitmodulesPath" -ForegroundColor Red; exit 1
}

$gitmodulesContent = Get-Content $gitmodulesPath
$allSubmodules = $gitmodulesContent | Where-Object { $_ -match '^\s*path\s*=\s*(.+)$' } | ForEach-Object { $matches[1].Trim() }

# Group by 10
$groups = [ordered]@{}
for ($i = 0; $i -lt $allSubmodules.Count; $i += 10) {
    $groupNum = [math]::Floor($i / 10) + 1
    $end = [Math]::Min($i + 10, $allSubmodules.Count)
    $groups[$groupNum] = @($allSubmodules[$i..($end - 1)])
}

$totalGroupCount = $groups.Count

# ============================================
# PARSE EXISTING FILE for previous stats
# ============================================

$previousStats = @{}
$previousQuality = @{}
$previousChecked = @{}

if (Test-Path $groupedFile) {
    $currentGroup = $null
    foreach ($line in (Get-Content $groupedFile)) {
        if ($line -match '^## Group (\d+)$') {
            $currentGroup = [int]$Matches[1]
        }
        elseif ($line -match '^\*\*Last checked:\*\*\s*(.+)$' -and $null -ne $currentGroup) {
            $previousChecked[$currentGroup] = $Matches[1].Trim()
        }
        elseif ($line -match '^- ([^\s(]+)\s+\((\d+(?:\.\d+)?)%\s*-\s*(\d+)/(\d+)\)\s*(\[.+\])?' -and $null -ne $currentGroup) {
            $projectName = $Matches[1].Trim()
            $previousStats[$projectName] = @{
                Percentage = [double]$Matches[2]
                FilesWithComment = [int]$Matches[3]
                TotalFiles = [int]$Matches[4]
            }
            if ($Matches[5]) { $previousQuality[$projectName] = $Matches[5].Trim() }
        }
    }
}

# ============================================
# DETERMINE WHICH GROUPS TO PROCESS
# ============================================

if ($processAll) {
    $groupsToProcess = @($groups.Keys)
} else {
    foreach ($groupNum in $groupNumbers) {
        if (-not $groups.ContainsKey($groupNum)) {
            Write-Host "Group $groupNum not found (total groups: $totalGroupCount)" -ForegroundColor Red; exit 1
        }
    }
    $groupsToProcess = $groupNumbers
}

# ============================================
# PROCESS GROUPS
# ============================================

$newProgressResults = @{}
$newQualityResults = @{}
$regressions = @()
$repoIndex = 0

# Collect all submodules to process
$submodulesToProcess = @()
foreach ($groupNum in $groupsToProcess) { $submodulesToProcess += $groups[$groupNum] }
$submodulesToProcess = $submodulesToProcess | Select-Object -Unique

# Filter missing
$existingNames = @()
$missingNames = @()
foreach ($name in $submodulesToProcess) {
    $submodulePath = Join-Path $rootPath $name
    if (Test-Path $submodulePath) { $existingNames += $name } else { $missingNames += $name }
}

if ($missingNames.Count -gt 0) {
    Write-Host "Skipping $($missingNames.Count) missing submodules:" -ForegroundColor Yellow
    foreach ($missing in $missingNames) { Write-Host "  - $missing" -ForegroundColor Yellow }
    Write-Host ""
}

# Clean bin/obj if requested
if ($CleanBinObj) {
    Write-Host "Cleaning bin/obj folders via fastestDeleteFolder..." -ForegroundColor Yellow
    foreach ($name in $existingNames) {
        $submodulePath = Join-Path $rootPath $name
        $foldersToDelete = Get-ChildItem -Path $submodulePath -Directory -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -eq "bin" -or $_.Name -eq "obj" }
        foreach ($folder in $foldersToDelete) {
            Write-Host "  Deleting: $($folder.FullName)" -ForegroundColor Gray
            fastestDeleteFolder $folder.FullName
        }
    }
    Write-Host "Clean complete." -ForegroundColor Green
    Write-Host ""
}

$groupLabel = if ($processAll) { "ALL" } else { $GroupNumber }
Write-Host "Processing group(s) $groupLabel with $($existingNames.Count) submodules" -ForegroundColor Cyan
Write-Host ""

foreach ($name in $existingNames) {
    $repoIndex++
    Write-Host "[$repoIndex/$($existingNames.Count)] $name" -ForegroundColor Yellow

    # Progress
    if (-not $SkipProgress) {
        $stats = Get-ProjectStats -projectName $name
        $newProgressResults[$name] = $stats
        if ($null -ne $stats) {
            Write-Host "  Progress: $($stats.Percentage)% ($($stats.FilesWithComment)/$($stats.TotalFiles))" -ForegroundColor Cyan

            # Regression detection
            if ($previousStats.ContainsKey($name)) {
                $prev = $previousStats[$name]
                $lostFiles = $prev.FilesWithComment - $stats.FilesWithComment
                if ($lostFiles -gt 0) {
                    $regressions += @{
                        Name = $name; PrevFiles = $prev.FilesWithComment; PrevTotal = $prev.TotalFiles; PrevPct = $prev.Percentage
                        NowFiles = $stats.FilesWithComment; NowTotal = $stats.TotalFiles; NowPct = $stats.Percentage; LostFiles = $lostFiles
                    }
                    Write-Host "  REGRESE! $($prev.FilesWithComment) -> $($stats.FilesWithComment) (ztrata $lostFiles)" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "  Progress: N/A (no .cs files)" -ForegroundColor Gray
        }
    }

    # Quality
    $qualityResult = Get-QualityResult -SubmoduleName $name -SkipBuild:$SkipBuild
    $newQualityResults[$name] = $qualityResult
    Write-Host ""
}

# ============================================
# REGRESSION SUMMARY
# ============================================

if ($regressions.Count -gt 0) {
    $totalLost = ($regressions | Measure-Object -Property LostFiles -Sum).Sum
    Write-Host ""
    Write-Host "!!! REGRESE DETEKOVÁNA !!!" -ForegroundColor Red
    Write-Host "Celkem ztraceno: $totalLost soubor(u) v $($regressions.Count) submodul(ech)" -ForegroundColor Red
    foreach ($reg in $regressions) {
        Write-Host "  $($reg.Name): $($reg.PrevFiles) -> $($reg.NowFiles) (ztrata $($reg.LostFiles))" -ForegroundColor Red
    }
    Write-Host ""
}

# ============================================
# WRITE submodules-grouped.md (COMPLETE REWRITE)
# ============================================

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$markdown = @()
$markdown += "# Submodules Grouped by 10"
$markdown += ""
$markdown += "Total submodules: $($allSubmodules.Count)"
$markdown += ""

$totalFiles = 0
$totalWithComment = 0

foreach ($groupNum in $groups.Keys) {
    $markdown += "## Group $groupNum"
    $markdown += ""

    $isProcessed = $groupsToProcess -contains $groupNum

    if ($isProcessed) {
        $markdown += "**Last checked:** $timestamp"
    } elseif ($previousChecked.ContainsKey($groupNum)) {
        $markdown += "**Last checked:** $($previousChecked[$groupNum])"
    }
    $markdown += ""

    foreach ($name in $groups[$groupNum]) {
        $progressLine = ""
        $qualityLine = ""

        if ($isProcessed) {
            # Use fresh data
            if ($missingNames -contains $name) {
                $progressLine = "(MISSING)"
            } elseif (-not $SkipProgress -and $newProgressResults.ContainsKey($name)) {
                $stats = $newProgressResults[$name]
                if ($null -ne $stats) {
                    $progressLine = "($($stats.Percentage)% - $($stats.FilesWithComment)/$($stats.TotalFiles))"
                    $totalFiles += $stats.TotalFiles
                    $totalWithComment += $stats.FilesWithComment
                } else {
                    $progressLine = "(N/A)"
                }
            } elseif ($SkipProgress -and $previousStats.ContainsKey($name)) {
                $prev = $previousStats[$name]
                $progressLine = "($($prev.Percentage)% - $($prev.FilesWithComment)/$($prev.TotalFiles))"
                $totalFiles += $prev.TotalFiles
                $totalWithComment += $prev.FilesWithComment
            } else {
                $progressLine = "(N/A)"
            }

            if ($newQualityResults.ContainsKey($name)) {
                $qualityLine = Get-QualityIndicator -Result $newQualityResults[$name]
            }
        } else {
            # Preserve existing data for non-processed groups
            if ($previousStats.ContainsKey($name)) {
                $prev = $previousStats[$name]
                $progressLine = "($($prev.Percentage)% - $($prev.FilesWithComment)/$($prev.TotalFiles))"
                $totalFiles += $prev.TotalFiles
                $totalWithComment += $prev.FilesWithComment
            } else {
                $progressLine = ""
            }
            if ($previousQuality.ContainsKey($name)) {
                $qualityLine = $previousQuality[$name]
            }
        }

        $line = "- $name"
        if ($progressLine) { $line += " $progressLine" }
        if ($qualityLine) { $line += " $qualityLine" }
        $markdown += $line
    }
    $markdown += ""
}

# Overall Progress
$overallPercentage = if ($totalFiles -gt 0) { [math]::Round(($totalWithComment / $totalFiles) * 100, 2) } else { 0 }

$markdown += "---"
$markdown += ""
$markdown += "## Overall Progress"
$markdown += ""
$markdown += "- **Total submodules:** $($allSubmodules.Count)"
$markdown += "- **Total .cs files:** $totalFiles"
$markdown += "- **Files with comment:** $totalWithComment"
$markdown += "- **Overall percentage:** $overallPercentage%"
$markdown += ""
$markdown += "Last updated: $timestamp"

$markdown | Out-File -FilePath $groupedFile -Encoding utf8BOM

# Export quality results to JSON
$jsonPath = Join-Path $scriptDir "submodules-quality-report.json"
$newQualityResults.Values | ConvertTo-Json -Depth 10 | Out-File $jsonPath -Encoding UTF8

# ============================================
# SUMMARY
# ============================================

$allQuality = @($newQualityResults.Values)
$perfectCount = @($allQuality | Where-Object { $_.NoWarnStatus -eq "OK" -and ($_.BuildStatus -eq "OK" -or $_.BuildStatus -eq "SKIPPED") }).Count
$noWarnCount = @($allQuality | Where-Object { $_.NoWarnStatus -eq "HAS_NOWARN" }).Count
$errorCount = @($allQuality | Where-Object { $_.BuildStatus -eq "HAS_ERRORS" }).Count
$warningCount = @($allQuality | Where-Object { $_.BuildStatus -eq "HAS_WARNINGS" }).Count

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY - Group(s) $groupLabel" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Perfect: $perfectCount" -ForegroundColor Green
Write-Host "NoWarn issues: $noWarnCount" -ForegroundColor $(if ($noWarnCount -gt 0) { "Red" } else { "Green" })
Write-Host "Build errors: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
Write-Host "Build warnings: $warningCount" -ForegroundColor $(if ($warningCount -gt 0) { "Yellow" } else { "Green" })
Write-Host "Overall progress: $overallPercentage% ($totalWithComment/$totalFiles)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Updated submodules-grouped.md" -ForegroundColor Green
Write-Host "Quality report: $jsonPath" -ForegroundColor Cyan
