# Check submodules for NoWarn in csproj and build warnings/errors
# EN: Checks if all .csproj files in submodules are without NoWarn element and build without warnings/errors
# CZ: Kontroluje zda všechny .csproj soubory v submodulech jsou bez NoWarn elementu a buildují bez warningů/chyb

param(
    [Parameter(Mandatory=$false)]
    [int]$GroupNumber = 0
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptDir
$groupedFile = Join-Path $scriptDir "submodules-grouped.md"

# Function to check if project needs rebuild
function Test-ProjectNeedsBuild {
    param(
        [string]$CsprojPath
    )

    $projectDir = Split-Path -Parent $CsprojPath
    $projectName = [System.IO.Path]::GetFileNameWithoutExtension($CsprojPath)

    # Find output assembly (DLL or EXE) in bin/Debug
    $binDebugPath = Join-Path $projectDir "bin\Debug"

    if (-not (Test-Path $binDebugPath)) {
        # No build output exists, need to build
        return $true
    }

    # Find all potential output files
    $outputFiles = Get-ChildItem -Path $binDebugPath -Recurse -File | Where-Object {
        $_.Extension -eq ".dll" -or $_.Extension -eq ".exe"
    }

    if ($outputFiles.Count -eq 0) {
        # No output files found, need to build
        return $true
    }

    # Get the newest output file timestamp
    $newestOutput = ($outputFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime

    # Get all source files (.cs and .csproj)
    $sourceFiles = @()
    $sourceFiles += Get-ChildItem -Path $projectDir -Filter "*.cs" -Recurse -File
    $sourceFiles += Get-Item $CsprojPath

    # Check if any source file is newer than output
    foreach ($sourceFile in $sourceFiles) {
        if ($sourceFile.LastWriteTime -gt $newestOutput) {
            # Source file is newer, need to rebuild
            return $true
        }
    }

    # All source files are older than output, no need to rebuild
    return $false
}

# Determine which submodules to check
if ($GroupNumber -eq 0) {
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "TIP: You can use -GroupNumber parameter to check only specific group" -ForegroundColor Yellow
    Write-Host "Example: .\.scripts\check-submodules-quality.ps1 -GroupNumber 4" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    # Get all submodules
    $submoduleDirs = Get-ChildItem -Path $rootPath -Directory | Where-Object {
        $_.Name -notmatch "^\." -and
        (Test-Path (Join-Path $_.FullName ".git"))
    }
    $submoduleNames = $submoduleDirs | Select-Object -ExpandProperty Name
} else {
    # Load submodules from specified group
    if (-not (Test-Path $groupedFile)) {
        Write-Host "Grouped submodules file not found: $groupedFile" -ForegroundColor Red
        Write-Host "Run .scripts\group-submodules.ps1 first" -ForegroundColor Yellow
        exit 1
    }

    # Read submodules from the specified group
    $content = Get-Content $groupedFile
    $inGroup = $false
    $submoduleNames = @()

    foreach ($line in $content) {
        if ($line -match "^## Group $GroupNumber$") {
            $inGroup = $true
            continue
        }
        if ($inGroup -and $line -match "^## Group \d+$") {
            break
        }
        if ($inGroup -and $line -match "^- ([^\s(]+)") {
            $submoduleNames += $matches[1].Trim()
        }
    }

    if ($submoduleNames.Count -eq 0) {
        Write-Host "No submodules found in group $GroupNumber" -ForegroundColor Red
        exit 1
    }

    Write-Host "Checking group $GroupNumber with $($submoduleNames.Count) submodules" -ForegroundColor Cyan
    Write-Host ""

    # Filter out missing submodules
    $existingNames = @()
    $missingNames = @()

    foreach ($name in $submoduleNames) {
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

    $submoduleNames = $existingNames

    if ($submoduleNames.Count -eq 0) {
        Write-Host "No existing submodules found in group $GroupNumber" -ForegroundColor Red
        exit 1
    }
}

# Convert names to directory objects
$submodules = $submoduleNames | ForEach-Object {
    Get-Item (Join-Path $rootPath $_)
}

Write-Host "Checking $($submodules.Count) submodules..." -ForegroundColor Cyan
Write-Host ""

$results = @()

foreach ($submodule in $submodules) {
    Write-Host "Processing: $($submodule.Name)" -ForegroundColor Yellow

    $result = [PSCustomObject]@{
        Submodule = $submodule.Name
        NoWarnStatus = "OK"
        NoWarnFiles = @()
        BuildStatus = "OK"
        BuildErrors = @()
        ProjectsChecked = 0
    }

    # Find all .csproj files in submodule
    $csprojFiles = Get-ChildItem -Path $submodule.FullName -Filter "*.csproj" -Recurse -File
    $result.ProjectsChecked = $csprojFiles.Count

    if ($csprojFiles.Count -eq 0) {
        Write-Host "  No .csproj files found" -ForegroundColor Gray
        $result.NoWarnStatus = "NO_PROJECTS"
        $result.BuildStatus = "NO_PROJECTS"
        $results += $result
        continue
    }

    # Check for NoWarn in .csproj files (ignore empty <NoWarn></NoWarn>)
    foreach ($csproj in $csprojFiles) {
        $content = Get-Content $csproj.FullName -Raw

        # Match <NoWarn> only if it has non-whitespace content before </NoWarn>
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

    # Build all projects in Debug configuration
    Write-Host "  Checking projects..." -ForegroundColor Gray

    foreach ($csproj in $csprojFiles) {
        $projectName = [System.IO.Path]::GetFileNameWithoutExtension($csproj.Name)

        # Check if project needs rebuild
        $needsBuild = Test-ProjectNeedsBuild -CsprojPath $csproj.FullName

        if (-not $needsBuild) {
            Write-Host "  ⊙ $projectName - Up to date, skipping build" -ForegroundColor Cyan
            continue
        }

        # Build project
        Write-Host "  ⟳ $projectName - Building..." -ForegroundColor Gray
        $buildOutput = dotnet build $csproj.FullName -c Debug --nologo 2>&1 | Out-String

        # Check for errors
        if ($buildOutput -match "(\d+) Error\(s\)" -and $Matches[1] -ne "0") {
            $result.BuildStatus = "HAS_ERRORS"
            $result.BuildErrors += "$projectName - Errors: $($Matches[1])"
            Write-Host "  ✗ $projectName - Build FAILED with errors" -ForegroundColor Red
        }
        # Check for warnings
        elseif ($buildOutput -match "(\d+) Warning\(s\)" -and $Matches[1] -ne "0") {
            $result.BuildStatus = "HAS_WARNINGS"
            $result.BuildErrors += "$projectName - Warnings: $($Matches[1])"
            Write-Host "  ⚠ $projectName - Build succeeded with warnings" -ForegroundColor Yellow
        }
        else {
            Write-Host "  ✓ $projectName - Build succeeded" -ForegroundColor Green
        }
    }

    $results += $result
    Write-Host ""
}

# Summary
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$perfectSubmodules = $results | Where-Object { $_.NoWarnStatus -eq "OK" -and $_.BuildStatus -eq "OK" }
$noWarnIssues = $results | Where-Object { $_.NoWarnStatus -eq "HAS_NOWARN" }
$buildErrors = $results | Where-Object { $_.BuildStatus -eq "HAS_ERRORS" }
$buildWarnings = $results | Where-Object { $_.BuildStatus -eq "HAS_WARNINGS" }
$noProjects = $results | Where-Object { $_.NoWarnStatus -eq "NO_PROJECTS" }

Write-Host "Total submodules: $($results.Count)" -ForegroundColor White
Write-Host "Perfect (no NoWarn, no build issues): $($perfectSubmodules.Count)" -ForegroundColor Green
Write-Host "With NoWarn in .csproj: $($noWarnIssues.Count)" -ForegroundColor Red
Write-Host "With build errors: $($buildErrors.Count)" -ForegroundColor Red
Write-Host "With build warnings: $($buildWarnings.Count)" -ForegroundColor Yellow
Write-Host "Without projects: $($noProjects.Count)" -ForegroundColor Gray
Write-Host ""

if ($perfectSubmodules.Count -gt 0) {
    Write-Host "=== Perfect Submodules ($($perfectSubmodules.Count)) ===" -ForegroundColor Green
    foreach ($sub in $perfectSubmodules) {
        Write-Host "  ✓ $($sub.Submodule) ($($sub.ProjectsChecked) projects)" -ForegroundColor Green
    }
    Write-Host ""
}

if ($noWarnIssues.Count -gt 0) {
    Write-Host "=== Submodules with NoWarn ($($noWarnIssues.Count)) ===" -ForegroundColor Red
    foreach ($sub in $noWarnIssues) {
        Write-Host "  ✗ $($sub.Submodule)" -ForegroundColor Red
        foreach ($file in $sub.NoWarnFiles) {
            Write-Host "    - $file" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

if ($buildErrors.Count -gt 0) {
    Write-Host "=== Submodules with Build Errors ($($buildErrors.Count)) ===" -ForegroundColor Red
    foreach ($sub in $buildErrors) {
        Write-Host "  ✗ $($sub.Submodule)" -ForegroundColor Red
        foreach ($error in $sub.BuildErrors) {
            Write-Host "    - $error" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

if ($buildWarnings.Count -gt 0) {
    Write-Host "=== Submodules with Build Warnings ($($buildWarnings.Count)) ===" -ForegroundColor Yellow
    foreach ($sub in $buildWarnings) {
        Write-Host "  ⚠ $($sub.Submodule)" -ForegroundColor Yellow
        foreach ($warning in $sub.BuildErrors) {
            Write-Host "    - $warning" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# Export results to JSON
$jsonPath = Join-Path $rootPath ".scripts\submodules-quality-report.json"
$results | ConvertTo-Json -Depth 10 | Out-File $jsonPath -Encoding UTF8
Write-Host "Results exported to: $jsonPath" -ForegroundColor Cyan

# If -GroupNumber is specified, update submodules-grouped.md with quality check timestamp and results
if ($GroupNumber -gt 0) {
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    # Build quality summary for the group
    $qualitySummary = "Perfect: $($perfectSubmodules.Count), NoWarn issues: $($noWarnIssues.Count), Build errors: $($buildErrors.Count), Build warnings: $($buildWarnings.Count)"

    $content = Get-Content $groupedFile
    $newContent = @()
    $skipUntilNextSection = $false

    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]

        # Detect group header
        if ($line -match '^## Group (\d+)$') {
            $currentGroupNum = [int]$Matches[1]

            if ($currentGroupNum -eq $GroupNumber) {
                $newContent += $line

                # Check next lines for existing timestamps
                $j = $i + 1
                $progressReportLine = ""

                while ($j -lt $content.Count -and $content[$j] -notmatch '^- ') {
                    if ($content[$j] -match '^\*\*Progress report:\*\*') {
                        $progressReportLine = $content[$j]
                    }
                    if ($content[$j] -match '^## Group \d+$') {
                        break
                    }
                    $j++
                }

                # Add timestamp and quality summary lines
                $newContent += ""
                if ($progressReportLine -ne "") {
                    $newContent += $progressReportLine
                }
                $newContent += "**Quality check:** Last updated $timestamp - $qualitySummary"
                $newContent += ""

                # Add detailed quality info for each submodule
                foreach ($result in $results) {
                    $submoduleName = $result.Submodule

                    # Find existing line with this submodule
                    $existingLine = $content | Where-Object { $_ -match "^- $submoduleName \(" }

                    if ($existingLine) {
                        # Keep existing progress stats, add quality indicator
                        $qualityIndicator = ""
                        if ($result.NoWarnStatus -eq "OK" -and $result.BuildStatus -eq "OK") {
                            $qualityIndicator = "✓"
                        } elseif ($result.BuildStatus -eq "HAS_ERRORS") {
                            $qualityIndicator = "✗ BUILD ERRORS"
                        } elseif ($result.NoWarnStatus -eq "HAS_NOWARN") {
                            $qualityIndicator = "⚠ NoWarn"
                        } elseif ($result.BuildStatus -eq "HAS_WARNINGS") {
                            $qualityIndicator = "⚠ Warnings"
                        } elseif ($result.NoWarnStatus -eq "NO_PROJECTS") {
                            $qualityIndicator = "N/A"
                        }

                        # Modify existing line to include quality indicator
                        if ($existingLine -match '^(- \S+) (\([^)]+\))(.*)$') {
                            $projectName = $Matches[1]
                            $stats = $Matches[2]
                            $newContent += "$projectName $stats [$qualityIndicator]"
                        } else {
                            $newContent += $existingLine
                        }
                    }
                }

                # Add blank line after project list
                $newContent += ""

                # Skip old content until next section
                $skipUntilNextSection = $true
                continue
            } else {
                $skipUntilNextSection = $false
            }
        }

        # Skip old timestamp/header lines in target group
        if ($skipUntilNextSection) {
            if ($line -match '^## Group \d+$' -or $line -match '^---$') {
                $skipUntilNextSection = $false
                # Add blank line before next section
                $newContent += ""
                $newContent += $line
            }
            continue
        }

        $newContent += $line
    }

    # Write updated content
    $newContent | Out-File -FilePath $groupedFile -Encoding utf8BOM

    Write-Host ""
    Write-Host "Updated Group $GroupNumber quality check in submodules-grouped.md" -ForegroundColor Green
    Write-Host "Timestamp: $timestamp" -ForegroundColor Cyan
    Write-Host "Summary: $qualitySummary" -ForegroundColor Cyan
}
