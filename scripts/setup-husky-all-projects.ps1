# Setup Husky.NET for all projects in the repository
# CZ: Nastavení Husky.NET pro všechny projekty v repozitáři

param(
    [string]$RepositoryRoot = (Get-Location)
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Husky.NET Setup for All Projects" -ForegroundColor Cyan
Write-Host "CZ: Nastavení Husky.NET pro všechny projekty" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get all solution files
# CZ: Získat všechny solution soubory
$solutionFiles = Get-ChildItem -Path $RepositoryRoot -Filter "*.sln" -Recurse |
    Where-Object { $_.Name -ne 'temp_solution.sln' -and $_.DirectoryName -notmatch '\\obj\\' -and $_.DirectoryName -notmatch '\\bin\\' }

Write-Host "Found $($solutionFiles.Count) solution files" -ForegroundColor Yellow
Write-Host "CZ: Nalezeno $($solutionFiles.Count) solution souborů" -ForegroundColor Yellow
Write-Host ""

$totalSolutions = $solutionFiles.Count
$currentSolution = 0
$successCount = 0
$failCount = 0
$skippedCount = 0

foreach ($sln in $solutionFiles) {
    $currentSolution++
    $slnDir = $sln.DirectoryName
    $slnName = $sln.Name

    Write-Host "[$currentSolution/$totalSolutions] Processing: $slnName" -ForegroundColor Cyan
    Write-Host "CZ: [$currentSolution/$totalSolutions] Zpracovávám: $slnName" -ForegroundColor Cyan
    Write-Host "  Directory: $slnDir" -ForegroundColor Gray

    # Check if Husky.NET is already installed
    # CZ: Zkontrolovat zda už je Husky.NET nainstalován
    $huskyAlreadyInstalled = $false
    $csprojFiles = Get-ChildItem -Path $slnDir -Filter "*.csproj" -Recurse |
        Where-Object { $_.DirectoryName -notmatch '\\obj\\' -and $_.DirectoryName -notmatch '\\bin\\' }

    foreach ($csproj in $csprojFiles) {
        $content = Get-Content -Path $csproj.FullName -Raw
        if ($content -match 'Husky\.Net') {
            $huskyAlreadyInstalled = $true
            break
        }
    }

    if ($huskyAlreadyInstalled) {
        Write-Host "  ⊙ Husky.NET already installed, skipping..." -ForegroundColor Yellow
        Write-Host "  CZ: ⊙ Husky.NET již nainstalován, přeskakuji..." -ForegroundColor Yellow
        $skippedCount++
        Write-Host ""
        continue
    }

    # Change to solution directory
    # CZ: Změnit na složku řešení
    Push-Location $slnDir

    try {
        # Install Husky.NET via dotnet tool
        # CZ: Nainstalovat Husky.NET přes dotnet tool
        Write-Host "  → Installing Husky.NET..." -ForegroundColor White
        Write-Host "  CZ: → Instaluji Husky.NET..." -ForegroundColor White

        $installOutput = dotnet tool install Husky --no-cache 2>&1
        if ($LASTEXITCODE -ne 0) {
            # Try as update if already exists globally
            # CZ: Zkusit jako update pokud již existuje globálně
            $installOutput = dotnet tool update Husky 2>&1
        }

        # Initialize Husky
        # CZ: Inicializovat Husky
        Write-Host "  → Initializing Husky..." -ForegroundColor White
        Write-Host "  CZ: → Inicializuji Husky..." -ForegroundColor White

        $initOutput = dotnet husky install 2>&1

        # Create symbolic link or copy to centralized config
        # CZ: Vytvořit symbolický odkaz nebo zkopírovat na centralizovanou konfiguraci
        $localHuskyDir = Join-Path $slnDir ".husky"
        $centralHuskyDir = Join-Path $RepositoryRoot ".husky"

        if (Test-Path $localHuskyDir) {
            Remove-Item -Path $localHuskyDir -Recurse -Force
        }

        # Create task-runner.json pointing to central scripts
        # CZ: Vytvořit task-runner.json odkazující na centrální skripty
        New-Item -ItemType Directory -Path $localHuskyDir -Force | Out-Null

        $relativePathToCentral = [System.IO.Path]::GetRelativePath($localHuskyDir, $centralHuskyDir)
        $relativePathToCentral = $relativePathToCentral -replace '\\', '/'

        $taskRunnerContent = @"
{
  "tasks": [
    {
      "name": "check-czech-characters",
      "group": "pre-commit",
      "command": "pwsh",
      "args": [
        "-NoProfile",
        "-File",
        "$relativePathToCentral/scripts/check-czech-characters.ps1",
        "$slnDir"
      ],
      "pathMode": "absolute"
    }
  ]
}
"@

        Set-Content -Path (Join-Path $localHuskyDir "task-runner.json") -Value $taskRunnerContent -Encoding UTF8

        # Add pre-commit hook
        # CZ: Přidat pre-commit hook
        Write-Host "  → Adding pre-commit hook..." -ForegroundColor White
        Write-Host "  CZ: → Přidávám pre-commit hook..." -ForegroundColor White

        $addOutput = dotnet husky add pre-commit -c "dotnet husky run" 2>&1

        Write-Host "  ✓ Successfully configured Husky.NET" -ForegroundColor Green
        Write-Host "  CZ: ✓ Úspěšně nakonfigurován Husky.NET" -ForegroundColor Green
        $successCount++

    } catch {
        Write-Host "  ✗ Failed to configure Husky.NET: $_" -ForegroundColor Red
        Write-Host "  CZ: ✗ Selhalo nastavení Husky.NET: $_" -ForegroundColor Red
        $failCount++
    } finally {
        Pop-Location
    }

    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary / CZ: Souhrn" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total solutions: $totalSolutions" -ForegroundColor White
Write-Host "CZ: Celkem řešení: $totalSolutions" -ForegroundColor White
Write-Host "Successfully configured: $successCount" -ForegroundColor Green
Write-Host "CZ: Úspěšně nakonfigurováno: $successCount" -ForegroundColor Green
Write-Host "Skipped (already installed): $skippedCount" -ForegroundColor Yellow
Write-Host "CZ: Přeskočeno (již nainstalováno): $skippedCount" -ForegroundColor Yellow
Write-Host "Failed: $failCount" -ForegroundColor Red
Write-Host "CZ: Selhalo: $failCount" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($failCount -gt 0) {
    Write-Host "Some projects failed to configure. Please check the errors above." -ForegroundColor Red
    Write-Host "CZ: Některé projekty selhaly při konfiguraci. Zkontrolujte prosím chyby výše." -ForegroundColor Red
    exit 1
}

Write-Host "✓ All projects configured successfully!" -ForegroundColor Green
Write-Host "CZ: ✓ Všechny projekty úspěšně nakonfigurovány!" -ForegroundColor Green
exit 0
