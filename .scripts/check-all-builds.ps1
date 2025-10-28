# EN: Check which .csproj files can be built and which cannot
# CZ: Zkontrolovat které .csproj soubory lze zbuildovat a které ne

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "CHECKING ALL CSPROJ BUILD STATUS" -ForegroundColor Yellow
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host ""

$buildableProjects = @()
$unbuildableProjects = @()
$totalProjects = 0

# EN: Get all submodule paths
# CZ: Získat všechny cesty submodulů
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -replace 'submodule\..*\.path ', ''
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in this repository." -ForegroundColor Yellow
    exit
}

Write-Host "Testing builds across all submodules..." -ForegroundColor White
Write-Host ""

foreach ($submodule in $submodules) {
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        continue
    }

    # EN: Find all .csproj files in this submodule
    # CZ: Najít všechny .csproj soubory v tomto submodulu
    $csprojFiles = Get-ChildItem -Path $submodulePath -Filter "*.csproj" -Recurse

    foreach ($csproj in $csprojFiles) {
        $totalProjects++
        $relativePath = $csproj.FullName.Substring($rootPath.Length + 1)

        Write-Host "Testing: $relativePath" -ForegroundColor Gray -NoNewline

        # EN: Try to build the project
        # CZ: Zkusit zbuildovat projekt
        $buildOutput = dotnet build $csproj.FullName 2>&1 | Out-String

        if ($LASTEXITCODE -eq 0) {
            Write-Host " - " -NoNewline
            Write-Host "OK" -ForegroundColor Green
            $buildableProjects += $relativePath
        } else {
            Write-Host " - " -NoNewline
            Write-Host "FAILED" -ForegroundColor Red

            # EN: Count errors
            # CZ: Spočítat chyby
            $errorCount = ($buildOutput | Select-String -Pattern "error CS\d+:").Matches.Count

            $unbuildableProjects += [PSCustomObject]@{
                Path = $relativePath
                ErrorCount = $errorCount
            }
        }
    }
}

Write-Host ""
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "RESULTS" -ForegroundColor Yellow
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host ""
Write-Host "Total projects: $totalProjects" -ForegroundColor White
Write-Host "Buildable: $($buildableProjects.Count)" -ForegroundColor Green
Write-Host "Unbuildable: $($unbuildableProjects.Count)" -ForegroundColor Red
Write-Host ""

# EN: Save results to files
# CZ: Uložit výsledky do souborů
$buildableListPath = Join-Path $rootPath ".scripts\buildable-projects.txt"
$unbuildableListPath = Join-Path $rootPath ".scripts\unbuildable-projects.txt"

Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "BUILDABLE PROJECTS ($($buildableProjects.Count))" -ForegroundColor Green
Write-Host "=" * 100 -ForegroundColor Cyan
$buildableProjects | Sort-Object | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
$buildableProjects | Sort-Object | Out-File -FilePath $buildableListPath -Encoding UTF8

Write-Host ""
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "UNBUILDABLE PROJECTS ($($unbuildableProjects.Count))" -ForegroundColor Red
Write-Host "=" * 100 -ForegroundColor Cyan
$unbuildableProjects | Sort-Object -Property ErrorCount -Descending | ForEach-Object {
    Write-Host "  $($_.Path) " -NoNewline -ForegroundColor Red
    Write-Host "($($_.ErrorCount) errors)" -ForegroundColor Yellow
}

$unbuildableProjects | Sort-Object -Property ErrorCount -Descending | ForEach-Object {
    "$($_.Path) ($($_.ErrorCount) errors)"
} | Out-File -FilePath $unbuildableListPath -Encoding UTF8

Write-Host ""
Write-Host "Results saved to:" -ForegroundColor White
Write-Host "  Buildable: $buildableListPath" -ForegroundColor Green
Write-Host "  Unbuildable: $unbuildableListPath" -ForegroundColor Red
Write-Host ""
