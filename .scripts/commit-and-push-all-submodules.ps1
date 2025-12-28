# Commit and push all submodules and parent repo
# Usage: .\.scripts\commit-and-push-all-submodules.ps1 "commit message"

param(
    [Parameter(Mandatory=$true)]
    [string]$commitMessage
)

$ErrorActionPreference = "Continue"
$parentRepo = Get-Location

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "KROK 1: Commituju zmeny v kazdem submodulu" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Ziskej vsechny slozky ktere jsou git repozitare (nested repos)
$submodules = Get-ChildItem -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName ".git")
} | Select-Object -ExpandProperty Name

$committedCount = 0
$skippedCount = 0
$failedSubmodules = @()

foreach ($submodule in $submodules) {
    Write-Host "Zpracovavam: $submodule" -ForegroundColor Yellow

    Push-Location $submodule

    # Zkontroluj jestli ma zmeny
    $status = git status --porcelain

    if ($status) {
        Write-Host "  -> Ma zmeny, commituju..." -ForegroundColor Green

        # Pridej vsechny zmeny
        git add -A

        # Commit
        git commit -m "$commitMessage`n`nGenerated with [Claude Code](https://claude.com/claude-code)`n`nCo-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

        if ($LASTEXITCODE -eq 0) {
            $committedCount++
            Write-Host "  -> Commit uspesny" -ForegroundColor Green
        } else {
            Write-Host "  -> CHYBA pri commitu!" -ForegroundColor Red
            $failedSubmodules += $submodule
        }
    } else {
        Write-Host "  -> Zadne zmeny, preskakuji" -ForegroundColor Gray
        $skippedCount++
    }

    Pop-Location
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "KROK 2: Pushuji vsechny submoduly na remote" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$pushedCount = 0
$pushFailedSubmodules = @()

foreach ($submodule in $submodules) {
    Write-Host "Pushuji: $submodule" -ForegroundColor Yellow

    Push-Location $submodule

    # Zkontroluj jestli ma commity k pushnuti
    $ahead = git rev-list --count '@{u}..HEAD' 2>$null

    if ($ahead -and $ahead -gt 0) {
        Write-Host "  -> Ma $ahead commit(u) k pushnuti..." -ForegroundColor Green

        git push

        if ($LASTEXITCODE -eq 0) {
            $pushedCount++
            Write-Host "  -> Push uspesny" -ForegroundColor Green
        } else {
            Write-Host "  -> CHYBA pri push!" -ForegroundColor Red
            $pushFailedSubmodules += $submodule
        }
    } else {
        Write-Host "  -> Zadne commity k pushnuti" -ForegroundColor Gray
    }

    Pop-Location
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "KROK 3: Aktualizuji submodule reference v parent repo" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Pridej vsechny submoduly (pridava se aktualizovany SHA)
Write-Host "Pridavam aktualizovane submodule..." -ForegroundColor Yellow
git add .

# Commit parent repo
Write-Host "Commituju parent repo..." -ForegroundColor Yellow
git commit -m "$commitMessage`n`nGenerated with [Claude Code](https://claude.com/claude-code)`n`nCo-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Parent repo commit uspesny" -ForegroundColor Green

    # Push parent repo
    Write-Host "`nPushuji parent repo..." -ForegroundColor Yellow
    git push

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Parent repo push uspesny" -ForegroundColor Green
    } else {
        Write-Host "CHYBA pri push parent repo!" -ForegroundColor Red
    }
} else {
    Write-Host "CHYBA pri commitu parent repo!" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SOUHRN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Submoduly commitnute: $committedCount" -ForegroundColor Green
Write-Host "Submoduly preskoceny (bez zmen): $skippedCount" -ForegroundColor Gray
Write-Host "Submoduly pushnute: $pushedCount" -ForegroundColor Green

if ($failedSubmodules.Count -gt 0) {
    Write-Host "`nSubmoduly s chybou pri commitu:" -ForegroundColor Red
    $failedSubmodules | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

if ($pushFailedSubmodules.Count -gt 0) {
    Write-Host "`nSubmoduly s chybou pri push:" -ForegroundColor Red
    $pushFailedSubmodules | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}

Write-Host "`nHOTOVO!`n" -ForegroundColor Green
