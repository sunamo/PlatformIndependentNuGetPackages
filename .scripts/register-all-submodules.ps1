# Register all nested git repositories as proper git submodules
# This will create/update .gitmodules file

$ErrorActionPreference = "Stop"
$parentRepo = Get-Location

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Registruji vsechny nested repos jako git submodules" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Ziskej vsechny slozky ktere jsou git repozitare
$repos = Get-ChildItem -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName ".git")
} | Select-Object -ExpandProperty Name | Sort-Object

Write-Host "Nalezeno $($repos.Count) git repozitaru`n" -ForegroundColor Yellow

# Nejprve odstranit stare gitlink entries
Write-Host "Odstranuji stare gitlink entries..." -ForegroundColor Yellow
foreach ($repo in $repos) {
    git rm --cached $repo 2>$null
}

# Vytvorit prazdny .gitmodules soubor
$gitmodulesPath = ".gitmodules"
if (Test-Path $gitmodulesPath) {
    Remove-Item $gitmodulesPath -Force
}

Write-Host "`nPridavam repozitare jako submodules..." -ForegroundColor Yellow

$successCount = 0
$failedRepos = @()

foreach ($repo in $repos) {
    Write-Host "  Pridavam: $repo" -ForegroundColor Gray

    # Ziskej remote URL z nested repo
    Push-Location $repo
    $remoteUrl = git config --get remote.origin.url
    Pop-Location

    if ($remoteUrl) {
        # Pridat jako submodule
        git submodule add -f $remoteUrl $repo 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            $successCount++
            Write-Host "    -> OK ($remoteUrl)" -ForegroundColor Green
        } else {
            $failedRepos += $repo
            Write-Host "    -> CHYBA!" -ForegroundColor Red
        }
    } else {
        Write-Host "    -> CHYBA: Nema remote URL!" -ForegroundColor Red
        $failedRepos += $repo
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SOUHRN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Uspesne zaregistrovano: $successCount" -ForegroundColor Green
Write-Host "Celkem repozitaru: $($repos.Count)" -ForegroundColor Yellow

if ($failedRepos.Count -gt 0) {
    Write-Host "`nRepozitare s chybou:" -ForegroundColor Red
    $failedRepos | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "DALSI KROKY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. Zkontroluj .gitmodules soubor" -ForegroundColor Yellow
Write-Host "2. git add .gitmodules" -ForegroundColor Yellow
Write-Host "3. git commit -m 'feat: register all repos as submodules'" -ForegroundColor Yellow
Write-Host "4. git push" -ForegroundColor Yellow
Write-Host "`nPo pushnutí budou odkazy na GitHub fungovat!`n" -ForegroundColor Green
