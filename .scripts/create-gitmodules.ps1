# Create .gitmodules file manually for all nested repos

$ErrorActionPreference = "Stop"

Write-Host "`nVytvářím .gitmodules soubor...`n" -ForegroundColor Cyan

# Ziskej vsechny git repozitare
$repos = Get-ChildItem -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName ".git")
} | Select-Object -ExpandProperty Name | Sort-Object

$gitmodulesContent = ""
$successCount = 0
$failedRepos = @()

foreach ($repo in $repos) {
    Write-Host "Zpracovavam: $repo" -ForegroundColor Gray

    # Ziskej remote URL
    Push-Location $repo
    $remoteUrl = git config --get remote.origin.url
    Pop-Location

    if ($remoteUrl) {
        # Pridej do .gitmodules
        $gitmodulesContent += "[submodule `"$repo`"]`n"
        $gitmodulesContent += "`tpath = $repo`n"
        $gitmodulesContent += "`turl = $remoteUrl`n"
        $successCount++
        Write-Host "  -> OK ($remoteUrl)" -ForegroundColor Green
    } else {
        Write-Host "  -> CHYBA: Nema remote URL!" -ForegroundColor Red
        $failedRepos += $repo
    }
}

# Uloz .gitmodules
$gitmodulesPath = ".gitmodules"
$gitmodulesContent | Out-File -FilePath $gitmodulesPath -Encoding utf8 -NoNewline

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SOUHRN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Uspesne zpracovano: $successCount" -ForegroundColor Green
Write-Host "Celkem repozitaru: $($repos.Count)" -ForegroundColor Yellow
Write-Host ".gitmodules soubor vytvoren: $gitmodulesPath" -ForegroundColor Green

if ($failedRepos.Count -gt 0) {
    Write-Host "`nRepozitare bez remote URL:" -ForegroundColor Red
    $failedRepos | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

Write-Host "`n"
