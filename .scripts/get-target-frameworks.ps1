# Get TargetFrameworks for all projects and explain why non-standard frameworks are used
# EN: Lists all projects with their target frameworks and explains deviations from net8/9/10
# CZ: Vypíše všechny projekty s jejich target frameworky a vysvětlí odchylky od net8/9/10

$solutionPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\PlatformIndependentNuGetPackages.sln"

if (-not (Test-Path $solutionPath)) {
    Write-Error "Solution file not found: $solutionPath"
    exit 1
}

# Function to check if frameworks are standard (must have net10, net9, AND net8)
function Test-StandardFrameworks {
    param([string]$Frameworks)

    $fws = $Frameworks -split ';' | Where-Object { $_ } | ForEach-Object { $_.Trim() } | Select-Object -Unique

    # Check that ONLY net8/9/10 are present
    foreach ($fw in $fws) {
        if ($fw -notmatch '^net(8|9|10)\.0$') {
            return $false
        }
    }

    # Check that ALL three (net8, net9, net10) are present
    $hasNet10 = $fws -contains "net10.0"
    $hasNet9 = $fws -contains "net9.0"
    $hasNet8 = $fws -contains "net8.0"

    if (-not ($hasNet10 -and $hasNet9 -and $hasNet8)) {
        return $false
    }

    return $true
}

# Function to find reason for non-standard framework
function Get-FrameworkReason {
    param(
        [string]$ProjectPath,
        [string]$Frameworks
    )

    $projectDir = Split-Path $ProjectPath -Parent
    $projectName = [System.IO.Path]::GetFileNameWithoutExtension($ProjectPath)
    $submoduleDir = Split-Path $projectDir -Parent
    $reasons = @()

    # Check FRAMEWORKS.md in submodule root (highest priority)
    $frameworksPath = Join-Path $submoduleDir "FRAMEWORKS.md"
    if (Test-Path $frameworksPath) {
        $frameworksContent = Get-Content $frameworksPath -Raw

        # Extract any "Why" section (could be "Why net8.0 is not supported", "Why net7.0 is included", etc.)
        if ($frameworksContent -match '(?s)##\s*Why\s+[^\n]+\n+(.*?)(?=\n##|\z)') {
            $whySection = $Matches[1].Trim()
            # Remove HTML comments
            $whySection = $whySection -replace '(?s)<!--.*?-->', ''
            $whySection = $whySection.Trim()
            # Remove placeholder text (everything from [Doplň to end of that section including examples)
            $whySection = $whySection -replace '(?s)\[Doplň.*', ''
            $whySection = $whySection.Trim()
            # Remove "Missing frameworks:" and "Additional frameworks:" lines as we already show them
            $whySection = $whySection -replace '\*\*(Missing|Additional) frameworks:\*\*[^\n]*\n?', ''
            $whySection = $whySection.Trim()

            if ($whySection -and $whySection.Length -gt 10) {
                $reasons += $whySection
            }
        }

        # Extract any "Requirements" section (could be for net8.0 support, for removing net7.0, etc.)
        if ($frameworksContent -match '(?s)##\s*Requirements\s+[^\n]+\n+(.*?)(?=\n##|\z)') {
            $requirementsSection = $Matches[1].Trim()
            # Remove HTML comments
            $requirementsSection = $requirementsSection -replace '(?s)<!--.*?-->', ''
            $requirementsSection = $requirementsSection.Trim()
            # Remove placeholder text
            $requirementsSection = $requirementsSection -replace '(?s)\[Doplň.*', ''
            $requirementsSection = $requirementsSection.Trim()

            if ($requirementsSection -and $requirementsSection.Length -gt 10) {
                $reasons += "Requirements: $requirementsSection"
            }
        }
    }

    # Check README.md in submodule root (only if FRAMEWORKS.md not found)
    if ($reasons.Count -eq 0) {
        $readmePath = Join-Path $submoduleDir "README.md"
        if (Test-Path $readmePath) {
            $readmeContent = Get-Content $readmePath -Raw

            # Look for framework-related explanations (multiple patterns)
            $patterns = @(
                '(?i)##\s*Target\s*Framework[s]?\s*\n+(.*?)(?=\n##|\z)',
                '(?i)##\s*Framework[s]?\s*\n+(.*?)(?=\n##|\z)',
                '(?i)(why.*net\d.*?|reason.*framework.*?)[:\s]+(.*?)(?=\n\n|\z)',
                '(?i)(net\d\.0.*?support.*?|support.*?net\d\.0.*?)[:\s]+(.*?)(?=\n\n|\z)'
            )

            foreach ($pattern in $patterns) {
                if ($readmeContent -match $pattern) {
                    $explanation = $Matches[1].Trim()
                    if ($explanation -and $explanation.Length -lt 300 -and $explanation.Length -gt 10) {
                        $reasons += "README: $explanation"
                        break
                    }
                }
            }
        }
    }

    # Check .csproj for comments
    if (Test-Path $ProjectPath) {
        $csprojContent = Get-Content $ProjectPath -Raw

        # Look for XML comments near TargetFrameworks
        if ($csprojContent -match '<!--\s*([^-]*(?:framework|net\d|compatibility)[^-]*?)\s*-->\s*<TargetFrameworks') {
            $comment = $Matches[1].Trim()
            if ($comment) {
                $reasons += "CSPROJ Comment: $comment"
            }
        }

        # Check for old package references that might require older frameworks
        # Note: This is just a heuristic - packages with major version < 3 are considered potentially problematic
        $oldPackages = @()

        # Match PackageReference with version
        $packageMatches = [regex]::Matches($csprojContent, '<PackageReference Include="([^"]+)"\s+Version="([^"]+)"')
        foreach ($match in $packageMatches) {
            $packageName = $match.Groups[1].Value
            $version = $match.Groups[2].Value

            # Only flag really old packages (major version < 3) as potentially blocking
            # Most packages with v3+ support modern .NET frameworks
            if ($version -match '^([0-9]+)\.') {
                $majorVersion = [int]$Matches[1]
                if ($majorVersion -lt 3) {
                    $oldPackages += "$packageName ($version)"
                }
            }
        }

        if ($oldPackages.Count -gt 0) {
            $reasons += "Old packages (may not support newer frameworks): $($oldPackages -join ', ')"
        }
    }

    # Analyze frameworks
    $fws = $Frameworks -split ';' | Where-Object { $_ } | ForEach-Object { $_.Trim() } | Select-Object -Unique

    # Check for missing standard frameworks
    $hasNet10 = $fws -contains "net10.0"
    $hasNet9 = $fws -contains "net9.0"
    $hasNet8 = $fws -contains "net8.0"

    $missing = @()
    if (-not $hasNet10) { $missing += "net10.0" }
    if (-not $hasNet9) { $missing += "net9.0" }
    if (-not $hasNet8) { $missing += "net8.0" }

    # Build reason message
    $frameworkInfo = @()

    if ($missing.Count -gt 0) {
        $frameworkInfo += "Missing: $($missing -join ', ')"
    }

    # Check for non-standard frameworks (not net8/9/10)
    $nonStandard = $fws | Where-Object { $_ -notmatch '^net(8|9|10)\.0$' }

    if ($nonStandard.Count -gt 0) {
        $frameworkInfo += "Additional: $($nonStandard -join ', ')"
    }

    # Add framework info at the beginning if present
    if ($frameworkInfo.Count -gt 0) {
        $frameworkSummary = $frameworkInfo -join " | "
        if ($reasons.Count -eq 0) {
            # No documented reason found
            $reasons += "$frameworkSummary (no documented reason in README.md or .csproj)"
        } else {
            # Prepend framework info to documented reasons
            $reasons = @($frameworkSummary) + $reasons
        }
    }

    if ($reasons.Count -eq 0) {
        return "Unknown reason"
    }

    return $reasons -join " | "
}

Write-Host "Reading solution file: $solutionPath" -ForegroundColor Cyan
Write-Host ""

# Read solution file and extract project paths
$solutionContent = Get-Content $solutionPath
$projectLines = $solutionContent | Where-Object { $_ -match 'Project\(' }

$results = @()

foreach ($line in $projectLines) {
    # Extract project path from line
    if ($line -match '"([^"]+\.csproj)"') {
        $relativePath = $Matches[1]
        $projectPath = Join-Path (Split-Path $solutionPath -Parent) $relativePath

        if (Test-Path $projectPath) {
            # Read csproj file
            [xml]$csproj = Get-Content $projectPath

            # Try to find TargetFramework or TargetFrameworks
            $targetFramework = $csproj.Project.PropertyGroup.TargetFramework | Where-Object { $_ } | Select-Object -First 1
            $targetFrameworks = $csproj.Project.PropertyGroup.TargetFrameworks | Where-Object { $_ } | Select-Object -First 1

            $frameworks = if ($targetFrameworks) { $targetFrameworks } elseif ($targetFramework) { $targetFramework } else { "NOT FOUND" }
            $projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectPath)

            # Check if frameworks are standard (only net8/9/10)
            $isStandard = Test-StandardFrameworks -Frameworks $frameworks

            # Get reason if non-standard
            $reason = ""
            if (-not $isStandard -and $frameworks -ne "NOT FOUND") {
                $reason = Get-FrameworkReason -ProjectPath $projectPath -Frameworks $frameworks
            }

            $results += [PSCustomObject]@{
                Project = $projectName
                TargetFrameworks = $frameworks
                IsStandard = $isStandard
                Reason = $reason
                Path = $relativePath
            }
        }
    }
}

# Group and display
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "STANDARD FRAMEWORKS (net8/9/10 only)" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$standardProjects = $results | Where-Object { $_.IsStandard -eq $true }
$grouped = $standardProjects | Group-Object TargetFrameworks | Sort-Object Name

foreach ($group in $grouped) {
    Write-Host "TargetFrameworks: $($group.Name)" -ForegroundColor Cyan
    Write-Host "Count: $($group.Count)" -ForegroundColor Green
    Write-Host ""
    $group.Group | Sort-Object Project | Select-Object Project | Format-Table -AutoSize
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "NON-STANDARD FRAMEWORKS (with reasons)" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$nonStandardProjects = $results | Where-Object { $_.IsStandard -eq $false }

if ($nonStandardProjects.Count -eq 0) {
    Write-Host "All projects use standard frameworks (net8/9/10)" -ForegroundColor Green
} else {
    foreach ($project in $nonStandardProjects | Sort-Object Project) {
        Write-Host "$($project.Project)" -ForegroundColor Yellow
        Write-Host "  Frameworks: $($project.TargetFrameworks)" -ForegroundColor White
        Write-Host "  Reason: $($project.Reason)" -ForegroundColor Gray
        Write-Host ""
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total projects: $($results.Count)" -ForegroundColor White
Write-Host "Standard frameworks: $($standardProjects.Count)" -ForegroundColor Green
Write-Host "Non-standard frameworks: $($nonStandardProjects.Count)" -ForegroundColor Yellow
