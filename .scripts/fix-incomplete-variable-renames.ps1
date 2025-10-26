# EN: Fix incomplete variable renames in for loops and method bodies
# CZ: Oprava neúplných přejmenování proměnných ve for cyklech a těl metod

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "Fixing incomplete variable renames..." -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

$totalFixed = 0
$totalErrors = 0
$filesProcessed = 0

# EN: Get all submodule paths
# CZ: Získat všechny cesty submodulů
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -replace 'submodule\..*\.path ', ''
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in this repository." -ForegroundColor Yellow
    exit
}

function Fix-IncompleteRenames {
    param([string]$filePath)

    try {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        if (-not $content) {
            return $false
        }

        $originalContent = $content

        Write-Host "    Processing: $([System.IO.Path]::GetFileName($filePath))" -ForegroundColor Gray

        # EN: FIX 1: Fix for loops where declaration uses 'index' but increment/condition uses 'i'
        # CZ: OPRAVA 1: Opravit for cykly kde deklarace používá 'index' ale inkrement/podmínka používá 'i'

        # Pattern: for (int index = X; i >= 0; i--) -> for (int index = X; index >= 0; index--)
        $content = $content -replace 'for\s*\(\s*int\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*i--\s*\)', 'for (int index =$1; index $2$3; index--)'

        # Pattern: for (int index = X; i >= 0; i++) -> for (int index = X; index >= 0; index++)
        $content = $content -replace 'for\s*\(\s*int\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*i\+\+\s*\)', 'for (int index =$1; index $2$3; index++)'

        # Pattern: for (int index = X; i > 0; i--) -> for (int index = X; index > 0; index--)
        $content = $content -replace 'for\s*\(\s*int\s+index\s*=([^;]+);\s*i\s*(>|>=)([^;]+);\s*i--\s*\)', 'for (int index =$1; index $2$3; index--)'

        # Pattern: for (var index = X; i < Y; i++) -> for (var index = X; index < Y; index++)
        $content = $content -replace 'for\s*\(\s*var\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*i\+\+\s*\)', 'for (var index =$1; index $2$3; index++)'

        # Pattern: for (var index = X; i >= 0; i--) -> for (var index = X; index >= 0; index--)
        $content = $content -replace 'for\s*\(\s*var\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*i--\s*\)', 'for (var index =$1; index $2$3; index--)'

        # EN: FIX 2: Fix ++i/--i in increment position
        # CZ: OPRAVA 2: Opravit ++i/--i v pozici inkrementu

        # Pattern: for (int index = X; index >= 0; ++i) -> for (int index = X; index >= 0; ++index)
        $content = $content -replace 'for\s*\(\s*int\s+index\s*=([^;]+);\s*index\s*(>=|>|<=|<|==|!=)([^;]+);\s*\+\+i\s*\)', 'for (int index =$1; index $2$3; ++index)'

        # Pattern: for (int index = X; index >= 0; --i) -> for (int index = X; index >= 0; --index)
        $content = $content -replace 'for\s*\(\s*int\s+index\s*=([^;]+);\s*index\s*(>=|>|<=|<|==|!=)([^;]+);\s*--i\s*\)', 'for (int index =$1; index $2$3; --index)'

        # EN: FIX 3: Similar fixes for other common variable names
        # CZ: OPRAVA 3: Podobné opravy pro další běžné názvy proměnných

        # columnIndex patterns
        $content = $content -replace 'for\s*\(\s*int\s+columnIndex\s*=([^;]+);\s*j\s*(>=|>|<=|<|==|!=)([^;]+);\s*j--\s*\)', 'for (int columnIndex =$1; columnIndex $2$3; columnIndex--)'
        $content = $content -replace 'for\s*\(\s*int\s+columnIndex\s*=([^;]+);\s*j\s*(>=|>|<=|<|==|!=)([^;]+);\s*j\+\+\s*\)', 'for (int columnIndex =$1; columnIndex $2$3; columnIndex++)'
        $content = $content -replace 'for\s*\(\s*var\s+columnIndex\s*=([^;]+);\s*j\s*(>=|>|<=|<|==|!=)([^;]+);\s*j\+\+\s*\)', 'for (var columnIndex =$1; columnIndex $2$3; columnIndex++)'
        $content = $content -replace 'for\s*\(\s*var\s+columnIndex\s*=([^;]+);\s*j\s*(>=|>|<=|<|==|!=)([^;]+);\s*j--\s*\)', 'for (var columnIndex =$1; columnIndex $2$3; columnIndex--)'

        # thirdIndex patterns
        $content = $content -replace 'for\s*\(\s*int\s+thirdIndex\s*=([^;]+);\s*k\s*(>=|>|<=|<|==|!=)([^;]+);\s*k--\s*\)', 'for (int thirdIndex =$1; thirdIndex $2$3; thirdIndex--)'
        $content = $content -replace 'for\s*\(\s*int\s+thirdIndex\s*=([^;]+);\s*k\s*(>=|>|<=|<|==|!=)([^;]+);\s*k\+\+\s*\)', 'for (int thirdIndex =$1; thirdIndex $2$3; thirdIndex++)'
        $content = $content -replace 'for\s*\(\s*var\s+thirdIndex\s*=([^;]+);\s*k\s*(>=|>|<=|<|==|!=)([^;]+);\s*k\+\+\s*\)', 'for (var thirdIndex =$1; thirdIndex $2$3; thirdIndex++)'
        $content = $content -replace 'for\s*\(\s*var\s+thirdIndex\s*=([^;]+);\s*k\s*(>=|>|<=|<|==|!=)([^;]+);\s*k--\s*\)', 'for (var thirdIndex =$1; thirdIndex $2$3; thirdIndex--)'

        if ($content -ne $originalContent) {
            Write-Host "      ✓ Changes detected, saving..." -ForegroundColor Green
            Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
            return $true
        } else {
            Write-Host "      - No changes needed" -ForegroundColor Gray
        }

        return $false
    }
    catch {
        Write-Host "      Error: $_" -ForegroundColor Red
        Write-Host "      File: $filePath" -ForegroundColor Red
        return $null
    }
}

foreach ($submodule in $submodules) {
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        continue
    }

    Push-Location $submodulePath

    try {
        # EN: Find commit with refactoring message
        # CZ: Najít commit s refactoringovou zprávou
        $commitHash = git log --all --oneline --grep="feat: Replace variables names with self-describe names" --format="%H" | Select-Object -First 1

        if (-not $commitHash) {
            Pop-Location
            continue
        }

        Write-Host "`nProcessing submodule: $submodule" -ForegroundColor Cyan

        # EN: Get files changed in that commit
        # CZ: Získat soubory změněné v tom commitu
        $changedFiles = git show --name-only --pretty=format:"" $commitHash | Where-Object { $_ -like "*.cs" }

        $submoduleFixed = 0

        foreach ($file in $changedFiles) {
            $fullPath = Join-Path $submodulePath $file

            if (-not (Test-Path $fullPath)) {
                continue
            }

            $filesProcessed++
            $result = Fix-IncompleteRenames -filePath $fullPath

            if ($result -eq $true) {
                $submoduleFixed++
                $totalFixed++
            }
            elseif ($result -eq $null) {
                $totalErrors++
            }
        }

        if ($submoduleFixed -gt 0) {
            Write-Host "  ${submodule}: $submoduleFixed files fixed" -ForegroundColor Green
        }

    } catch {
        Write-Host "  Error processing submodule: $_" -ForegroundColor Red
        $totalErrors++
    } finally {
        Pop-Location
    }
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 80) -ForegroundColor Gray
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Files processed: $filesProcessed" -ForegroundColor White
Write-Host "  Files fixed: $totalFixed" -ForegroundColor Green
Write-Host "  Errors: $totalErrors" -ForegroundColor Red
