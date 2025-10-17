# Fix test projects by adding missing using directives to GlobalUsings.cs
# EN: Script to fix common test project build errors
# CZ: Skript pro opravu běžných build chyb v test projektech

$ErrorActionPreference = "Stop"

Write-Host "Starting test project fixes..." -ForegroundColor Green

# EN: Find all test projects
# CZ: Najdi všechny test projekty
$testProjects = Get-ChildItem -Path . -Recurse -Filter "*.Tests.csproj"

Write-Host "Found $($testProjects.Count) test projects" -ForegroundColor Cyan

foreach ($proj in $testProjects) {
    Write-Host "`nProcessing: $($proj.Name)" -ForegroundColor Yellow

    $projectDir = $proj.Directory.FullName
    $globalUsingsPath = Join-Path $projectDir "GlobalUsings.cs"

    # EN: Check if GlobalUsings.cs exists
    # CZ: Zkontroluj zda GlobalUsings.cs existuje
    if (Test-Path $globalUsingsPath) {
        $content = Get-Content $globalUsingsPath -Raw

        # EN: Add common using directives if missing
        # CZ: Přidej běžné using direktivy pokud chybí
        $modified = $false

        if ($content -notmatch "global using Xunit;") {
            Write-Host "  Adding: global using Xunit;" -ForegroundColor Gray
            $content += "`nglobal using Xunit;"
            $modified = $true
        }

        # EN: Extract project name to add namespace using
        # CZ: Extrahuj název projektu pro přidání namespace usingu
        $projectName = $proj.BaseName -replace '\.Tests$', ''
        $namespaceLine = "global using $projectName;"

        if ($content -notmatch [regex]::Escape($namespaceLine)) {
            Write-Host "  Adding: $namespaceLine" -ForegroundColor Gray
            $content += "`n$namespaceLine"
            $modified = $true
        }

        if ($modified) {
            Set-Content -Path $globalUsingsPath -Value $content -NoNewline
            Write-Host "  Updated GlobalUsings.cs" -ForegroundColor Green
        } else {
            Write-Host "  No changes needed" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  WARNING: GlobalUsings.cs not found" -ForegroundColor Red
    }
}

Write-Host "`nFinished processing test projects" -ForegroundColor Green
