# Get TargetFrameworks for all projects and explain why non-standard frameworks are used
# EN: Lists all projects with their target frameworks and explains deviations from net8/9/10
# CZ: Vypíše všechny projekty s jejich target frameworky a vysvětlí odchylky od net8/9/10

$solutionPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\PlatformIndependentNuGetPackages.sln"

if (-not (Test-Path $solutionPath)) {
    Write-Error "Solution file not found: $solutionPath"
    exit 1
}

# Function to check if frameworks contain only net8, net9, net10
function Test-StandardFrameworks {
    param([string]$Frameworks)

    $fws = $Frameworks -split ';' | Where-Object { $_ } | ForEach-Object { $_.Trim() }

    foreach ($fw in $fws) {
        if ($fw -notmatch '^net(8|9|10)\.0$') {
            return $false
        }
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

    # Check README.md in submodule root
    $readmePath = Join-Path $submoduleDir "README.md"
    if (Test-Path $readmePath) {
        $readmeContent = Get-Content $readmePath -Raw

        # Look for framework-related explanations
        if ($readmeContent -match '(?i)(target framework|framework|why.*net\d|reason.*framework)[:\s]+(.*?)(?=\n\n|\z)') {
            $explanation = $Matches[2].Trim()
            if ($explanation -and $explanation.Length -lt 200) {
                $reasons += "README: $explanation"
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
        $oldPackages = @()

        # Match PackageReference with version
        $packageMatches = [regex]::Matches($csprojContent, '<PackageReference Include="([^"]+)"\s+Version="([^"]+)"')
        foreach ($match in $packageMatches) {
            $packageName = $match.Groups[1].Value
            $version = $match.Groups[2].Value

            # Check if package version suggests older framework requirement
            # (e.g., packages with version < 6.0 might require net6.0 or older)
            if ($version -match '^([0-9]+)\.') {
                $majorVersion = [int]$Matches[1]
                if ($majorVersion -lt 6) {
                    $oldPackages += "$packageName ($version)"
                }
            }
        }

        if ($oldPackages.Count -gt 0) {
            $reasons += "Old packages: $($oldPackages -join ', ')"
        }
    }

    # Analyze frameworks to find non-standard ones
    $fws = $Frameworks -split ';' | Where-Object { $_ } | ForEach-Object { $_.Trim() }
    $nonStandard = $fws | Where-Object { $_ -notmatch '^net(8|9|10)\.0$' }

    if ($nonStandard.Count -gt 0) {
        $reasons += "Non-standard frameworks: $($nonStandard -join ', ')"
    }

    if ($reasons.Count -eq 0) {
        return "No reason found"
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
