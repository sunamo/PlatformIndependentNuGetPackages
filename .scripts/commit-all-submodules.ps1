# Commit and push all submodule changes
# EN: Commits version updates and framework changes in all submodules
# CZ: Commituje aktualizace verzí a změny frameworků ve všech submodulech

param(
    [Parameter(Mandatory=$false)]
    [string]$CommitMessage = "feat: update to version 26.1.1.X with net10.0;net9.0;net8.0"
)

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

Write-Host "Committing changes in all submodules..." -ForegroundColor Cyan
Write-Host ""

# Get list of modified submodules
$gitStatus = git status --porcelain
$modifiedSubmodules = $gitStatus | Where-Object { $_ -match '^\s*M\s+(\S+)\s+\(modified content' } | ForEach-Object {
    if ($_ -match '^\s*M\s+(\S+)\s+\(') {
        $Matches[1]
    }
}

$committed = 0
$skipped = 0
$failed = 0

foreach ($submodule in $modifiedSubmodules) {
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        Write-Host "⚠ $submodule - Path not found" -ForegroundColor Yellow
        $skipped++
        continue
    }

    Write-Host "Processing $submodule..." -ForegroundColor White

    Push-Location $submodulePath

    try {
        # Check if there are changes
        $status = git status --porcelain

        if (-not $status) {
            Write-Host "  ⊙ No changes to commit" -ForegroundColor Cyan
            $skipped++
            Pop-Location
            continue
        }

        # Add all changes
        git add -A

        # Commit
        git commit -m $CommitMessage

        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ✗ Commit failed" -ForegroundColor Red
            $failed++
            Pop-Location
            continue
        }

        # Push
        git push

        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ✗ Push failed" -ForegroundColor Red
            $failed++
            Pop-Location
            continue
        }

        Write-Host "  ✓ Committed and pushed" -ForegroundColor Green
        $committed++
    }
    catch {
        Write-Host "  ✗ Error: $_" -ForegroundColor Red
        $failed++
    }
    finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Committed: $committed" -ForegroundColor Green
Write-Host "Skipped: $skipped" -ForegroundColor Cyan
Write-Host "Failed: $failed" -ForegroundColor Red
Write-Host ""
Write-Host "Now update the main repository:" -ForegroundColor Yellow
Write-Host "  git add ." -ForegroundColor White
Write-Host "  git commit -m 'feat: update all packages to 26.1.1.X with net10.0;net9.0;net8.0'" -ForegroundColor White
Write-Host "  git push" -ForegroundColor White
