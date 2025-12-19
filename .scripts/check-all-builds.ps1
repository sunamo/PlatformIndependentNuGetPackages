# EN: Check which .csproj files can be built and which cannot (parallel version)
# CZ: Zkontrolovat které .csproj soubory lze zbuildovat a které ne (paralelní verze)

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

# EN: Get all submodule paths
# CZ: Získat všechny cesty submodulů
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -replace 'submodule\..*\.path ', ''
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in this repository." -ForegroundColor Yellow
    exit
}

# EN: Collect all csproj files first
# CZ: Nejprve sesbírat všechny csproj soubory
$allCsprojFiles = @()

foreach ($submodule in $submodules) {
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        continue
    }

    $csprojFiles = Get-ChildItem -Path $submodulePath -Filter "*.csproj" -Recurse
    foreach ($csproj in $csprojFiles) {
        $allCsprojFiles += $csproj.FullName
    }
}

$totalProjects = $allCsprojFiles.Count

Write-Host "Building $totalProjects projects in parallel..." -ForegroundColor Yellow

# EN: Run builds in parallel
# CZ: Spustit buildy paralelně
$results = $allCsprojFiles | ForEach-Object -Parallel {
    $csprojPath = $_
    $rootPath = $using:rootPath
    $relativePath = $csprojPath.Substring($rootPath.Length + 1)

    $buildOutput = dotnet build -c Debug $csprojPath 2>&1 | Out-String
    $success = $LASTEXITCODE -eq 0

    $errorCount = 0
    $errorLines = @()
    if (-not $success) {
        $errorMatches = [regex]::Matches($buildOutput, "error CS\d+:[^\r\n]+")
        $errorCount = $errorMatches.Count
        $errorLines = $errorMatches | ForEach-Object { $_.Value.Trim() } | Select-Object -Unique
    }

    [PSCustomObject]@{
        Path = $relativePath
        Success = $success
        ErrorCount = $errorCount
        Errors = $errorLines
    }
} -ThrottleLimit 8

# EN: Separate results
# CZ: Rozdělit výsledky
$buildableProjects = @($results | Where-Object { $_.Success } | ForEach-Object { $_.Path })
$unbuildableProjects = @($results | Where-Object { -not $_.Success })

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

# EN: Save unbuildable projects with their errors
# CZ: Uložit nezbuilděné projekty s jejich chybami
$unbuildableContent = @()
$unbuildableProjects | Sort-Object -Property ErrorCount -Descending | ForEach-Object {
    $unbuildableContent += "=" * 80
    $unbuildableContent += "$($_.Path) ($($_.ErrorCount) errors)"
    $unbuildableContent += "=" * 80
    foreach ($err in $_.Errors) {
        $unbuildableContent += "  $err"
    }
    $unbuildableContent += ""
}
$unbuildableContent | Out-File -FilePath $unbuildableListPath -Encoding UTF8

Write-Host ""
Write-Host "Results saved to:" -ForegroundColor White
Write-Host "  Buildable: $buildableListPath" -ForegroundColor Green
Write-Host "  Unbuildable: $unbuildableListPath" -ForegroundColor Red
Write-Host ""
