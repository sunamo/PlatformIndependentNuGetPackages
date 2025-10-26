# EN: Complete script to replace ALL short variable names with descriptive ones
# CZ: Kompletní skript pro nahrazení VŠECH krátkých názvů proměnných za popisné

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "Replacing ALL short variable names with descriptive ones..." -ForegroundColor Cyan
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

# EN: Mapping of short variable names to descriptive names based on common contexts
# CZ: Mapování krátkých názvů proměnných na popisné názvy podle běžných kontextů
$variableMappings = @{
    'i' = 'index'
    'j' = 'columnIndex'
    'k' = 'thirdIndex'
    'l' = 'list'
    'm' = 'match'
    'n' = 'number'
    'x' = 'xCoordinate'
    'y' = 'yCoordinate'
    'z' = 'zCoordinate'
}

function Fix-AllShortVarsInFile {
    param([string]$filePath)

    try {
        $lines = Get-Content $filePath -Encoding UTF8
        if (-not $lines) {
            return $false
        }

        $changed = $false
        $modifiedLines = @()

        # EN: Track for loops and their variable names
        # CZ: Sledovat for cykly a jejich názvy proměnných
        $forLoopVars = @{}  # Maps declared var name to context depth
        $braceDepth = 0
        $forLoopDepths = @()  # Stack of depths where for loops were declared

        for ($lineNum = 0; $lineNum -lt $lines.Count; $lineNum++) {
            $line = $lines[$lineNum]
            $originalLine = $line

            # EN: Track brace depth
            # CZ: Sledovat hloubku složených závorek
            $openBraces = ([regex]::Matches($line, '\{')).Count
            $closeBraces = ([regex]::Matches($line, '\}')).Count
            $prevBraceDepth = $braceDepth
            $braceDepth += $openBraces - $closeBraces

            # EN: Detect for loops with single-letter variable names
            # CZ: Detekovat for cykly s jednopísmenkovými názvy proměnných
            foreach ($shortVar in $variableMappings.Keys) {
                if ($line -match "for\s*\(\s*var\s+$shortVar\s*=") {
                    $forLoopVars[$shortVar] = $braceDepth
                    if ($forLoopDepths -notcontains $braceDepth) {
                        $forLoopDepths += $braceDepth
                    }
                }
            }

            # EN: Replace short variable names if we're in their for loop scope
            # CZ: Nahradit krátké názvy proměnných pokud jsme v jejich for cyklu
            foreach ($shortVar in $forLoopVars.Keys) {
                $contextDepth = $forLoopVars[$shortVar]

                # Only replace if we're still in the same or deeper scope
                if ($braceDepth -ge $contextDepth) {
                    $longVar = $variableMappings[$shortVar]

                    # EN: Replace in for loop declaration
                    # CZ: Nahradit v deklaraci for cyklu
                    $line = $line -replace "for\s*\(\s*var\s+$shortVar\s*=", "for (var $longVar ="

                    # EN: Replace comparisons
                    # CZ: Nahradit porovnání
                    $line = $line -replace "\b$shortVar\s*<", "$longVar <"
                    $line = $line -replace "\b$shortVar\s*>", "$longVar >"
                    $line = $line -replace "\b$shortVar\s*<=", "$longVar <="
                    $line = $line -replace "\b$shortVar\s*>=", "$longVar >="
                    $line = $line -replace "\b$shortVar\s*==", "$longVar =="
                    $line = $line -replace "\b$shortVar\s*!=", "$longVar !="

                    # EN: Replace increments/decrements
                    # CZ: Nahradit inkrementy/dekrementy
                    $line = $line -replace "\b$shortVar\+\+", "$longVar++"
                    $line = $line -replace "\b$shortVar--", "$longVar--"
                    $line = $line -replace "\+\+$shortVar\b", "++$longVar"
                    $line = $line -replace "--$shortVar\b", "--$longVar"

                    # EN: Replace array/collection access
                    # CZ: Nahradit přístup k poli/kolekci
                    $line = $line -replace "\[$shortVar\]", "[$longVar]"
                    $line = $line -replace "\[$shortVar\s*\*", "[$longVar *"
                    $line = $line -replace "\[$shortVar\s*/", "[$longVar /"
                    $line = $line -replace "\[$shortVar\s*\+", "[$longVar +"
                    $line = $line -replace "\[$shortVar\s*-", "[$longVar -"

                    # EN: Replace in expressions (array indexing in multi-dimensional)
                    # CZ: Nahradit ve výrazech (indexování pole ve vícerozměrných)
                    $line = $line -replace "\[\s*\w+\s*,\s*$shortVar\s*\]", "[`$1, $longVar]"
                    $line = $line -replace "value\[\s*\w+\s*,\s*$shortVar\s*\]", "value[`$1, $longVar]"

                    # EN: Replace in method calls
                    # CZ: Nahradit ve voláních metod
                    $line = $line -replace "\($shortVar\)", "($longVar)"
                    $line = $line -replace "\($shortVar,", "($longVar,"
                    $line = $line -replace ",\s*$shortVar\)", ", $longVar)"
                    $line = $line -replace ",\s*$shortVar,", ", $longVar,"

                    # EN: Replace in arithmetic operations
                    # CZ: Nahradit v aritmetických operacích
                    $line = $line -replace "\b$shortVar\s*\*", "$longVar *"
                    $line = $line -replace "\b$shortVar\s*/", "$longVar /"
                    $line = $line -replace "\b$shortVar\s*\+([^+])", "$longVar +`$1"
                    $line = $line -replace "\b$shortVar\s*-([^-])", "$longVar -`$1"
                    $line = $line -replace "\b$shortVar\s*%", "$longVar %"

                    # EN: Replace standalone usage
                    # CZ: Nahradit samostatné použití
                    $line = $line -replace "\b$shortVar\s*;", "$longVar;"
                    $line = $line -replace "\b$shortVar\s*\)", "$longVar)"
                }
            }

            # EN: Clean up for loop tracking when exiting scope
            # CZ: Vyčistit sledování for cyklu při opuštění rozsahu
            if ($braceDepth -lt $prevBraceDepth) {
                # Remove variables from deeper scopes
                $keysToRemove = @()
                foreach ($key in $forLoopVars.Keys) {
                    if ($forLoopVars[$key] -gt $braceDepth) {
                        $keysToRemove += $key
                    }
                }
                foreach ($key in $keysToRemove) {
                    $forLoopVars.Remove($key)
                }
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

            $result = Fix-AllShortVarsInFile -filePath $fullPath

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
