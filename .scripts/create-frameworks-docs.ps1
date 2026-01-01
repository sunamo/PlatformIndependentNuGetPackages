# Create FRAMEWORKS.md files for projects with non-standard target frameworks
# EN: Creates FRAMEWORKS.md template files for projects missing net8.0 or having additional frameworks
# CZ: Vytváří FRAMEWORKS.md template soubory pro projekty které nemají net8.0 nebo mají dodatečné frameworky

param(
    [Parameter(Mandatory=$false)]
    [string[]]$ProjectNames = @(),

    [Parameter(Mandatory=$false)]
    [switch]$Force  # Přepsat existující FRAMEWORKS.md soubory
)

$solutionPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\PlatformIndependentNuGetPackages.sln"
$templatePath = "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\FRAMEWORKS.md.template"

if (-not (Test-Path $solutionPath)) {
    Write-Error "Solution file not found: $solutionPath"
    exit 1
}

if (-not (Test-Path $templatePath)) {
    Write-Error "Template file not found: $templatePath"
    exit 1
}

$template = Get-Content $templatePath -Raw

Write-Host "Creating FRAMEWORKS.md files for projects with non-standard target frameworks..." -ForegroundColor Cyan
Write-Host ""

$created = 0
$skipped = 0
$errors = 0

# Read solution file and extract project paths
$solutionContent = Get-Content $solutionPath
$projectLines = $solutionContent | Where-Object { $_ -match 'Project\(' }

foreach ($line in $projectLines) {
    if ($line -match '"([^"]+\.csproj)"') {
        $relativePath = $Matches[1]
        $projectPath = Join-Path (Split-Path $solutionPath -Parent) $relativePath

        if (Test-Path $projectPath) {
            [xml]$csproj = Get-Content $projectPath
            $targetFramework = $csproj.Project.PropertyGroup.TargetFramework | Where-Object { $_ } | Select-Object -First 1
            $targetFrameworks = $csproj.Project.PropertyGroup.TargetFrameworks | Where-Object { $_ } | Select-Object -First 1
            $frameworks = if ($targetFrameworks) { $targetFrameworks } elseif ($targetFramework) { $targetFramework } else { $null }

            if (-not $frameworks) {
                continue
            }

            $projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectPath)
            $projectDir = Split-Path $projectPath -Parent
            $submoduleDir = Split-Path $projectDir -Parent

            # Filter by project names if specified
            if ($ProjectNames.Count -gt 0 -and $projectName -notin $ProjectNames) {
                continue
            }

            # Check if frameworks are standard (net10.0;net9.0;net8.0)
            $fws = $frameworks -split ';' | Where-Object { $_ } | ForEach-Object { $_.Trim() } | Select-Object -Unique

            # Check that ONLY net8/9/10 are present AND all three are present
            $hasNet10 = $fws -contains "net10.0"
            $hasNet9 = $fws -contains "net9.0"
            $hasNet8 = $fws -contains "net8.0"

            $isStandard = $true
            foreach ($fw in $fws) {
                if ($fw -notmatch '^net(8|9|10)\.0$') {
                    $isStandard = $false
                    break
                }
            }

            if ($isStandard -and $hasNet10 -and $hasNet9 -and $hasNet8) {
                # Standard frameworks - skip
                continue
            }

            # Project has non-standard frameworks
            $frameworksPath = Join-Path $submoduleDir "FRAMEWORKS.md"

            if ((Test-Path $frameworksPath) -and -not $Force) {
                Write-Host "⊙ $projectName - FRAMEWORKS.md already exists (use -Force to overwrite)" -ForegroundColor Cyan
                $skipped++
                continue
            }

            # Prepare template with current framework info
            $content = $template -replace 'Target frameworks: `net10\.0;net9\.0`', "Target frameworks: ``$frameworks``"

            # Add specific guidance based on what's missing/additional
            $missing = @()
            if (-not $hasNet10) { $missing += "net10.0" }
            if (-not $hasNet9) { $missing += "net9.0" }
            if (-not $hasNet8) { $missing += "net8.0" }

            $nonStandard = $fws | Where-Object { $_ -notmatch '^net(8|9|10)\.0$' }

            $guidance = ""
            if ($missing.Count -gt 0) {
                $guidance += "`n**Missing frameworks:** $($missing -join ', ')`n"
            }
            if ($nonStandard.Count -gt 0) {
                $guidance += "`n**Additional frameworks:** $($nonStandard -join ', ')`n"
            }

            if ($guidance) {
                $content = $content -replace '\[Doplň důvod zde - například:\]', "$guidance`n[Doplň důvod zde - například:]"
            }

            # Create file
            $content | Out-File $frameworksPath -Encoding UTF8 -NoNewline

            Write-Host "✓ $projectName" -ForegroundColor Green
            Write-Host "  Frameworks: $frameworks" -ForegroundColor Gray
            Write-Host "  Created: $frameworksPath" -ForegroundColor White
            $created++
        }
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Created: $created" -ForegroundColor Green
Write-Host "Skipped (already exists): $skipped" -ForegroundColor Cyan
Write-Host "Errors: $errors" -ForegroundColor Red
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit the FRAMEWORKS.md files to document why net8.0 is not supported" -ForegroundColor White
Write-Host "2. Document what would be needed to add net8.0 support" -ForegroundColor White
Write-Host "3. Run get-target-frameworks.ps1 to see the documented reasons" -ForegroundColor White
