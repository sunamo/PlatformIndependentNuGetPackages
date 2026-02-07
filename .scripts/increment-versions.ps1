# Increment package versions for republishing
# EN: Increments the last part of version number (e.g., 25.12.31.2 -> 25.12.31.3)
# CZ: Zvyšuje poslední část čísla verze (např. 25.12.31.2 -> 25.12.31.3)

param(
    [Parameter(Mandatory=$false)]
    [string[]]$ProjectNames = @(),

    [Parameter(Mandatory=$false)]
    [ValidateSet('PlatformIndependent', 'Windows', 'Both')]
    [string]$Target = 'Both'
)

$rootPaths = @()
if ($Target -eq 'PlatformIndependent' -or $Target -eq 'Both') {
    $rootPaths += "E:\vs\Projects\PlatformIndependentNuGetPackages"
}
if ($Target -eq 'Windows' -or $Target -eq 'Both') {
    $rootPaths += "E:\vs\Projects\WindowsNuGetPackages"
}

Write-Host "Incrementing package versions..." -ForegroundColor Cyan
Write-Host "Target: $Target" -ForegroundColor Cyan
Write-Host ""

$updated = 0
$skipped = 0

foreach ($rootPath in $rootPaths) {
    Write-Host "Processing: $rootPath" -ForegroundColor Magenta
    Write-Host ""

    # Find main .csproj files (where filename matches submodule name)
    $projectFiles = Get-ChildItem -Path $rootPath -Directory | ForEach-Object {
        $submoduleName = $_.Name
        # Look for the main csproj file (e.g., SunamoExceptions\SunamoExceptions\SunamoExceptions.csproj)
        $mainCsproj = Get-ChildItem -Path $_.FullName -Filter "$submoduleName.csproj" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($mainCsproj) {
            $mainCsproj
        }
    }

    foreach ($projectFile in $projectFiles) {
        $projectPath = $projectFile.FullName
        $projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectPath)

        # Filter by project names if specified
        if ($ProjectNames.Count -gt 0 -and $projectName -notin $ProjectNames) {
            continue
        }

        # Read csproj
        $csprojContent = Get-Content $projectPath -Raw
        [xml]$csproj = $csprojContent

        # Get current version
        $currentVersion = $csproj.Project.PropertyGroup.Version | Where-Object { $_ } | Select-Object -First 1

        if (-not $currentVersion) {
            Write-Host "⚠ $projectName - No version found" -ForegroundColor Yellow
            $skipped++
            continue
        }

        # Parse version
        if ($currentVersion -match '^(\d+\.\d+\.\d+)\.(\d+)$') {
            $versionPrefix = $Matches[1]
            $versionSuffix = [int]$Matches[2]
            $newVersion = "$versionPrefix.$($versionSuffix + 1)"
        }
        else {
            Write-Host "⚠ $projectName - Cannot parse version: $currentVersion" -ForegroundColor Yellow
            $skipped++
            continue
        }

        # Update version in file
        $csprojContent = $csprojContent -replace "<Version>$([regex]::Escape($currentVersion))</Version>", "<Version>$newVersion</Version>"

        # Save file
        $csprojContent | Out-File $projectPath -Encoding UTF8 -NoNewline

        Write-Host "✓ $projectName" -ForegroundColor Green
        Write-Host "  $currentVersion → $newVersion" -ForegroundColor White
        $updated++
    }

    Write-Host ""
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Updated: $updated" -ForegroundColor Green
Write-Host "Skipped: $skipped" -ForegroundColor Yellow
