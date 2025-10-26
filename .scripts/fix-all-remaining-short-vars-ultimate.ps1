# EN: Ultimate fix script for ALL remaining short variable issues
# CZ: Ultimátní fix skript pro VŠECHNY zbývající problémy s krátkými proměnnými

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "Fixing ALL remaining short variable issues (Ultimate Version)..." -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

$totalFixed = 0
$totalSkipped = 0
$totalErrors = 0

# EN: Get all submodule paths
# CZ: Získat všechny cesty submodulů
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -replace 'submodule\..*\.path ', ''
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in this repository." -ForegroundColor Yellow
    exit
}

function Fix-ShortVarsInFile {
    param([string]$filePath)

    try {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        if (-not $content) {
            return $false
        }

        $originalContent = $content

        # EN: FIX 1: Replace `i` with `index` in expressions within for loops
        # CZ: OPRAVA 1: Nahradit `i` za `index` ve výrazech uvnitř for cyklů

        # Pattern: hexEncoded.Substring(i * 2, 2) -> hexEncoded.Substring(index * 2, 2)
        $content = $content -replace '\.Substring\(i\s*\*', '.Substring(index *'
        $content = $content -replace '\(i\s*\*\s*2', '(index * 2'

        # Pattern: args[++i] -> args[++index] (when index is declared)
        # This is tricky - need to check if in for loop with index
        $content = $content -replace 'args\[(\+\+)i\]', 'args[$1index]'
        $content = $content -replace 'p\[(\+\+)i\]', 'p[$1index]'
        $content = $content -replace 'setsNameValue\[(\+\+)i\]', 'setsNameValue[$1index]'
        $content = $content -replace 'p_2\[(\+\+)i\]', 'p_2[$1index]'

        # Pattern: for (var index = 0; index < X; ++index) where ++i appears in body
        $content = $content -replace '(\bfor\s*\(\s*var\s+index\s*=[^;]+;[^;]+;\s*\+\+)i\b', '$1index'

        # EN: FIX 2: Fix ++index usage in array access within same line
        # CZ: OPRAVA 2: Opravit použití ++index v přístupu k poli na stejném řádku

        # This requires line-by-line processing for context awareness
        $lines = $content -split "`r?`n"
        $inForLoopWithIndex = $false
        $modifiedLines = @()

        for ($lineNum = 0; $lineNum -lt $lines.Count; $lineNum++) {
            $line = $lines[$lineNum]

            # Detect for loop with index
            if ($line -match 'for\s*\(\s*var\s+index\s*=') {
                $inForLoopWithIndex = $true
            }

            # In for loop context, fix remaining i usage
            if ($inForLoopWithIndex) {
                # Fix: something[i] where should be something[index]
                # But be careful with ++i patterns
                if ($line -match '\[i\]' -and $line -notmatch '\[(\+\+|--|index)') {
                    $line = $line -replace '\[i\]', '[index]'
                }

                # Fix: (i) -> (index)
                if ($line -match '\(i\)' -and $line -notmatch 'for|if|while') {
                    $line = $line -replace '\(i\)', '(index)'
                }

                # Fix: i * something -> index * something
                if ($line -match '\bi\s*\*') {
                    $line = $line -replace '\bi\s*\*', 'index *'
                }

                # Fix: i / something -> index / something
                if ($line -match '\bi\s*/') {
                    $line = $line -replace '\bi\s*/', 'index /'
                }

                # Fix: i + something -> index + something (but not ++i)
                if ($line -match '\bi\s*\+[^+]') {
                    $line = $line -replace '\bi\s*\+([^+])', 'index +$1'
                }

                # Fix: i - something -> index - something (but not --i)
                if ($line -match '\bi\s*-[^-]') {
                    $line = $line -replace '\bi\s*-([^-])', 'index -$1'
                }

                # Fix: i < something -> index < something
                if ($line -match '\bi\s*<') {
                    $line = $line -replace '\bi\s*<', 'index <'
                }

                # Fix: i > something -> index > something
                if ($line -match '\bi\s*>') {
                    $line = $line -replace '\bi\s*>', 'index >'
                }

                # Fix: i++ -> index++
                if ($line -match '\bi\+\+') {
                    $line = $line -replace '\bi\+\+', 'index++'
                }

                # Fix: ++i -> ++index
                if ($line -match '\+\+i\b') {
                    $line = $line -replace '\+\+i\b', '++index'
                }

                # Fix: i-- -> index--
                if ($line -match '\bi--') {
                    $line = $line -replace '\bi--', 'index--'
                }

                # Fix: --i -> --index
                if ($line -match '--i\b') {
                    $line = $line -replace '--i\b', '--index'
                }
            }

            # Simple heuristic: end of method or major block
            if ($line -match '^\s*}\s*$' -and $inForLoopWithIndex) {
                $inForLoopWithIndex = $false
            }

            $modifiedLines += $line
        }

        $content = $modifiedLines -join "`r`n"

        if ($content -ne $originalContent) {
            Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
            return $true
        }

        return $false
    }
    catch {
        Write-Host "      Error: $_" -ForegroundColor Red
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

        # EN: Get files changed in that commit
        # CZ: Získat soubory změněné v tom commitu
        $changedFiles = git show --name-only --pretty=format:"" $commitHash | Where-Object { $_ -like "*.cs" }

        $submoduleFixed = 0
        $submoduleSkipped = 0

        foreach ($file in $changedFiles) {
            $fullPath = Join-Path $submodulePath $file

            if (-not (Test-Path $fullPath)) {
                continue
            }

            $result = Fix-ShortVarsInFile -filePath $fullPath

            if ($result -eq $true) {
                Write-Host "  ✓ Fixed: $file" -ForegroundColor Green
                $submoduleFixed++
                $totalFixed++
            }
            elseif ($result -eq $false) {
                $submoduleSkipped++
                $totalSkipped++
            }
            else {
                $totalErrors++
            }
        }

        if ($submoduleFixed -gt 0) {
            Write-Host "`n${submodule}: $submoduleFixed fixed, $submoduleSkipped skipped" -ForegroundColor Cyan
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
Write-Host "  Files fixed: $totalFixed" -ForegroundColor Green
Write-Host "  Files skipped (no changes): $totalSkipped" -ForegroundColor Yellow
Write-Host "  Errors: $totalErrors" -ForegroundColor Red
