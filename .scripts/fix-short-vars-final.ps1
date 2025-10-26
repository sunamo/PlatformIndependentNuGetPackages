# EN: Final precise script to fix ALL problematic short variable names
# CZ: Finální přesný skript pro opravu VŠECH problematických krátkých názvů proměnných

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "Fixing problematic short variable names (Final Version)..." -ForegroundColor Cyan
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
        $lines = Get-Content $filePath -Encoding UTF8
        if (-not $lines) {
            return $false
        }

        $changed = $false
        $inForLoop = $false
        $forLoopVarName = ""

        for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
            $line = $lines[$lineIndex]
            $originalLine = $line

            # EN: Detect for loop with index variable declared
            # CZ: Detekovat for cyklus s deklarovanou index proměnnou
            if ($line -match 'for\s*\(\s*var\s+(\w+)\s*=') {
                $forLoopVarName = $matches[1]
                $inForLoop = $true
            }

            # EN: If in for loop with 'index' declared but 'i' used
            # CZ: Pokud jsme v for cyklu kde je deklarován 'index' ale používá se 'i'
            if ($inForLoop -and $forLoopVarName -eq "index") {
                # Fix: i < something -> index < something
                $line = $line -replace '\bi\s*<\s*', 'index < '
                $line = $line -replace '\bi\s*>\s*', 'index > '
                $line = $line -replace '\bi\s*<=\s*', 'index <= '
                $line = $line -replace '\bi\s*>=\s*', 'index >= '
                # Fix typo: > = -> >=
                $line = $line -replace '>\s*=\s*', '>= '
                $line = $line -replace '<\s*=\s*', '<= '

                $line = $line -replace '\bi\+\+', 'index++'
                $line = $line -replace '\bi--', 'index--'
                $line = $line -replace '\+\+i\b', '++index'
                $line = $line -replace '--i\b', '--index'

                # Fix array/list access: something[i] -> something[index]
                $line = $line -replace '\[i\]', '[index]'

                # Fix method calls with i: RemoveAt(i) -> RemoveAt(index)
                $line = $line -replace '\(i\)', '(index)'
                $line = $line -replace '\(i,', '(index,'
                $line = $line -replace ',\s*i\)', ', index)'
                $line = $line -replace ',\s*i,', ', index,'

                # Fix: args[++i] -> args[++index]
                $line = $line -replace '\[\+\+i\]', '[++index]'
                $line = $line -replace '\[--i\]', '[--index]'
                $line = $line -replace '\[i\+\+\]', '[index++]'
                $line = $line -replace '\[i--\]', '[index--]'
            }

            # EN: End of for loop scope (simple heuristic)
            # CZ: Konec rozsahu for cyklu (jednoduchá heuristika)
            if ($inForLoop -and $line -match '^\s*}') {
                $inForLoop = $false
                $forLoopVarName = ""
            }

            # EN: Fix method parameter: (object n) -> (object value)
            # CZ: Opravit parametr metody: (object n) -> (object value)
            if ($line -match '\(object n\)') {
                $line = $line -replace '\(object n\)', '(object value)'
                # Also fix usages in the same/next lines if on single line method
                $line = $line -replace '\sn == null', ' value == null'
                $line = $line -replace '\sn !=', ' value !='
                $line = $line -replace '\+ n\b', '+ value'
                $line = $line -replace 'return n;', 'return value;'
            }

            # EN: Fix: (bool n) parameter -> (bool negate)
            # CZ: Opravit: (bool n) parametr -> (bool negate)
            if ($line -match ',\s*bool n\)') {
                $line = $line -replace ',\s*bool n\)', ', bool negate)'
            }
            if ($line -match 'if \(n\)') {
                $line = $line -replace 'if \(n\)', 'if (negate)'
            }

            # EN: Fix undefined 'b' in return statements
            # CZ: Opravit nedefinované 'b' v return příkazech
            if ($line -match 'return !b;' -or $line -match 'return b;') {
                $line = $line -replace 'return !b;', 'return !flag;'
                $line = $line -replace 'return b;', 'return flag;'
            }

            # EN: Fix undefined 'c' (character) in dynamic casts
            # CZ: Opravit nedefinované 'c' (znak) v dynamických castech
            if ($line -match '\(dynamic\)c\.First\(\)' -or $line -match '\(dynamic\)c;') {
                $line = $line -replace '\(dynamic\)c\.First\(\)', '(dynamic)character.First()'
                $line = $line -replace '\(dynamic\)c;', '(dynamic)character;'
            }

            # EN: Fix typo: type.Value should be t.Value
            # CZ: Opravit překlep: type.Value mělo být t.Value
            if ($line -match 'type\.Value' -and $line -match 'GetValueOfNullable') {
                $line = $line -replace 'type\.Value', 't.Value'
            }

            # EN: Fix out parameter: out byte b -> out byte byteValue
            # CZ: Opravit out parametr: out byte b -> out byte byteValue
            if ($line -match 'out byte b\)') {
                $line = $line -replace 'out byte b\)', 'out byte byteValue)'
            }
            if ($line -match 'byte\.TryParse\([^,]+, out b\)') {
                $line = $line -replace ', out b\)', ', out byteValue)'
            }

            # EN: Standard variable replacements
            # CZ: Standardní nahrazení proměnných

            # StringBuilder sb -> stringBuilder
            $line = $line -replace '\bvar sb = new StringBuilder\(', 'var stringBuilder = new StringBuilder('
            $line = $line -replace '\bStringBuilder sb([,;\)\s])', 'StringBuilder stringBuilder$1'
            $line = $line -replace '(\s)sb\.', '$1stringBuilder.'
            $line = $line -replace 'return sb;', 'return stringBuilder;'

            # List<> l -> list
            $line = $line -replace '\bvar l = new List<', 'var list = new List<'
            $line = $line -replace 'List<([^>]+)> l([,;\)\s])', 'List<$1> list$2'
            $line = $line -replace '(\s)l\.', '$1list.'
            $line = $line -replace '\bl\[', 'list['
            $line = $line -replace 'return l;', 'return list;'

            if ($line -ne $originalLine) {
                $lines[$lineIndex] = $line
                $changed = $true
            }
        }

        if ($changed) {
            Set-Content -Path $filePath -Value $lines -Encoding UTF8
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

        Write-Host "`nProcessing: $submodule" -ForegroundColor Green

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
            Write-Host "  Submodule summary: $submoduleFixed fixed, $submoduleSkipped skipped" -ForegroundColor Cyan
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
