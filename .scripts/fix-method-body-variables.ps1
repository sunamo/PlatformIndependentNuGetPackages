# EN: Fix variables in method bodies where for loop was partially renamed
# CZ: Oprava proměnných v těl metod kde for cyklus byl částečně přejmenován

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "FIXING VARIABLES IN METHOD BODIES" -ForegroundColor Yellow
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host ""

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

function Fix-MethodBodyVariables {
    param([string]$filePath)

    try {
        $lines = Get-Content $filePath -Encoding UTF8
        if (-not $lines) {
            return $false
        }

        $modifiedLines = @()
        $changed = $false
        $inForLoopScope = $false
        $forLoopVar = $null
        $shortVar = $null
        $braceDepth = 0
        $forLoopStartDepth = 0

        for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
            $line = $lines[$lineIndex]
            $originalLine = $line

            # EN: Track brace depth
            # CZ: Sledovat hloubku složených závorek
            $openBraces = ([regex]::Matches($line, '\{')).Count
            $closeBraces = ([regex]::Matches($line, '\}')).Count
            $previousDepth = $braceDepth
            $braceDepth += $openBraces - $closeBraces

            # EN: Detect for loop with renamed variable (e.g., for (int index = ...; i < ...; i++))
            # CZ: Detekovat for cyklus s přejmenovanou proměnnou
            if ($line -match 'for\s*\(\s*(?:int|var)\s+(index|columnIndex|thirdIndex)\s*=') {
                # Found a for loop with long variable name
                $forLoopVar = $matches[1]

                # Check if condition or increment uses short variable
                if ($line -match 'for\s*\([^;]+;\s*(i|j|k)\s*[<>=!]' -or $line -match '[<>=!;]\s*(i|j|k)(\+\+|--|\s*\))') {
                    # This for loop needs fixing, it's already partially renamed
                    $shortVar = $matches[1]
                } else {
                    # Check what short variable corresponds to this long variable
                    switch ($forLoopVar) {
                        'index' { $shortVar = 'i' }
                        'columnIndex' { $shortVar = 'j' }
                        'thirdIndex' { $shortVar = 'k' }
                    }
                }

                $inForLoopScope = $true
                $forLoopStartDepth = $braceDepth
            }

            # EN: If we're in a for loop scope, replace short variable with long variable
            # CZ: Pokud jsme v rozsahu for cyklu, nahradit krátkou proměnnou za dlouhou
            if ($inForLoopScope -and $forLoopVar -and $shortVar) {
                # Replace only if we're still in the scope (at same or deeper brace depth)
                if ($braceDepth -ge $forLoopStartDepth) {
                    # Replace various patterns where short variable is used

                    # Array/list indexing: something[i] -> something[index]
                    $line = $line -replace "\[$shortVar\]", "[$forLoopVar]"

                    # Arithmetic operations
                    $line = $line -replace "\b$shortVar\s*\+\+", "$forLoopVar++"
                    $line = $line -replace "\b$shortVar--", "$forLoopVar--"
                    $line = $line -replace "\+\+$shortVar\b", "++$forLoopVar"
                    $line = $line -replace "--$shortVar\b", "--$forLoopVar"

                    # Comparisons
                    $line = $line -replace "\b$shortVar\s*<", "$forLoopVar <"
                    $line = $line -replace "\b$shortVar\s*>", "$forLoopVar >"
                    $line = $line -replace "\b$shortVar\s*<=", "$forLoopVar <="
                    $line = $line -replace "\b$shortVar\s*>=", "$forLoopVar >="
                    $line = $line -replace "\b$shortVar\s*==", "$forLoopVar =="
                    $line = $line -replace "\b$shortVar\s*!=", "$forLoopVar !="

                    # In expressions
                    $line = $line -replace "\b$shortVar\s*\*", "$forLoopVar *"
                    $line = $line -replace "\b$shortVar\s*/", "$forLoopVar /"
                    $line = $line -replace "\b$shortVar\s*\+([^+])", "$forLoopVar +`$1"
                    $line = $line -replace "\b$shortVar\s*-([^-])", "$forLoopVar -`$1"
                    $line = $line -replace "\b$shortVar\s*%", "$forLoopVar %"

                    # Method calls and parameters
                    $line = $line -replace "\($shortVar\)", "($forLoopVar)"
                    $line = $line -replace "\($shortVar,", "($forLoopVar,"
                    $line = $line -replace ",\s*$shortVar\)", ", $forLoopVar)"
                    $line = $line -replace ",\s*$shortVar,", ", $forLoopVar,"

                    # Standalone usage
                    $line = $line -replace "\b$shortVar\s*;", "$forLoopVar;"
                    $line = $line -replace "return\s+$shortVar\b", "return $forLoopVar"
                }
            }

            # EN: Exit scope when brace depth returns to level before for loop
            # CZ: Opustit rozsah když hloubka závorek se vrátí na úroveň před for cyklem
            if ($inForLoopScope -and $braceDepth -lt $forLoopStartDepth) {
                $inForLoopScope = $false
                $forLoopVar = $null
                $shortVar = $null
                $forLoopStartDepth = 0
            }

            if ($line -ne $originalLine) {
                $changed = $true
            }

            $modifiedLines += $line
        }

        if ($changed) {
            Set-Content -Path $filePath -Value $modifiedLines -Encoding UTF8
            return $true
        }

        return $false
    }
    catch {
        Write-Host "      ERROR in $filePath : $_" -ForegroundColor Red
        return $null
    }
}

Write-Host "Processing submodules..." -ForegroundColor White
Write-Host ""

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

        Write-Host "[$submodule]" -ForegroundColor Cyan

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
            $result = Fix-MethodBodyVariables -filePath $fullPath

            if ($result -eq $true) {
                $submoduleFixed++
                $totalFixed++
                Write-Host "  ✓ $file" -ForegroundColor Green
            }
            elseif ($result -eq $null) {
                $totalErrors++
            }
        }

        if ($submoduleFixed -eq 0) {
            Write-Host "  - No changes" -ForegroundColor Gray
        }

    } catch {
        Write-Host "  ERROR processing submodule: $_" -ForegroundColor Red
        $totalErrors++
    } finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Yellow
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "Files processed: $filesProcessed" -ForegroundColor White
Write-Host "Files fixed: $totalFixed" -ForegroundColor Green
if ($totalErrors -gt 0) {
    Write-Host "Errors: $totalErrors" -ForegroundColor Red
} else {
    Write-Host "Errors: 0" -ForegroundColor Green
}
Write-Host ""
