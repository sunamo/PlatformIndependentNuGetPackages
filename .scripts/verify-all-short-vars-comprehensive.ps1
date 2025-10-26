# EN: Comprehensive verification script to find ALL remaining short variable issues
# CZ: Komplexní verifikační skript pro nalezení VŠECH zbývajících problémů s krátkými proměnnými

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "Comprehensive verification of short variables across all submodules..." -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

$totalIssues = 0
$issuesByFile = @{}

# EN: Get all submodule paths
# CZ: Získat všechny cesty submodulů
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -replace 'submodule\..*\.path ', ''
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in this repository." -ForegroundColor Yellow
    exit
}

function Check-FileForIssues {
    param([string]$filePath)

    $issues = @()

    try {
        $lines = Get-Content $filePath -Encoding UTF8
        if (-not $lines) {
            return $issues
        }

        $inForLoopWithIndex = $false
        $forLoopDepth = 0
        $braceDepth = 0
        $startBraceDepth = 0

        for ($lineNum = 0; $lineNum -lt $lines.Count; $lineNum++) {
            $line = $lines[$lineNum]
            $lineNumber = $lineNum + 1

            # EN: Track for loop with 'index' variable
            # CZ: Sledovat for cyklus s proměnnou 'index'
            if ($line -match 'for\s*\(\s*var\s+index\s*=') {
                $inForLoopWithIndex = $true
                $startBraceDepth = $braceDepth
            }

            # EN: Track brace depth
            # CZ: Sledovat hloubku složených závorek
            $openBraces = ([regex]::Matches($line, '\{')).Count
            $closeBraces = ([regex]::Matches($line, '\}')).Count
            $braceDepth += $openBraces - $closeBraces

            # EN: Check for problematic 'i' usage when 'index' is declared
            # CZ: Kontrolovat problematické použití 'i' když je deklarován 'index'
            if ($inForLoopWithIndex) {
                # Check for: i < , i > , i <= , i >= , i++, i--, [i], (i), etc.
                if ($line -match '\bi\s*[<>]=?\s*|\bi\+\+|\bi--|\+\+i|--i|\[i\]|\(i\)|\(i,|,\s*i\)|,\s*i,') {
                    # Exclude comments
                    if ($line -notmatch '^\s*//.*\bi') {
                        $issues += @{
                            LineNumber = $lineNumber
                            Line = $line.Trim()
                            Issue = "Usage of 'i' when 'index' is declared in for loop"
                        }
                    }
                }

                # Check for typo: > = instead of >=
                if ($line -match '>\s*=\s*[^=]|<\s*=\s*[^=]') {
                    $issues += @{
                        LineNumber = $lineNumber
                        Line = $line.Trim()
                        Issue = "Typo: spaced comparison operator (> = or < =)"
                    }
                }
            }

            # EN: Check for undefined short variables (not in comments)
            # CZ: Kontrolovat nedefinované krátké proměnné (ne v komentářích)
            if ($line -notmatch '^\s*//' -and $line -notmatch '^\s*\*') {
                # Check for: (object n), (bool n), etc.
                if ($line -match '\(object n\)|\(bool n\)|,\s*bool n\)') {
                    $issues += @{
                        LineNumber = $lineNumber
                        Line = $line.Trim()
                        Issue = "Short parameter name 'n'"
                    }
                }

                # Check for: return !b; or return b; (when b is undefined)
                if ($line -match 'return !b;|return b;' -and $line -notmatch 'bool b\s*=') {
                    # Need to check if 'b' is a parameter or local variable
                    # This is a heuristic check
                    $issues += @{
                        LineNumber = $lineNumber
                        Line = $line.Trim()
                        Issue = "Possible undefined variable 'b' in return statement"
                    }
                }

                # Check for: (dynamic)c.First() where c is undefined
                if ($line -match '\(dynamic\)c\.First\(\)|\(dynamic\)c;') {
                    $issues += @{
                        LineNumber = $lineNumber
                        Line = $line.Trim()
                        Issue = "Undefined variable 'c' in dynamic cast"
                    }
                }

                # Check for: type.Value when should be t.Value
                if ($line -match 'type\.Value' -and $line -notmatch 'GetValueOfNullable') {
                    # This might be OK in some contexts, just flag it
                }

                # Check for: out byte b without definition
                if ($line -match 'out byte b\)') {
                    $issues += @{
                        LineNumber = $lineNumber
                        Line = $line.Trim()
                        Issue = "Short out parameter name 'b'"
                    }
                }
            }

            # EN: End of for loop scope
            # CZ: Konec rozsahu for cyklu
            if ($inForLoopWithIndex -and $braceDepth -le $startBraceDepth) {
                $inForLoopWithIndex = $false
            }
        }

    } catch {
        Write-Host "      Error checking file: $_" -ForegroundColor Red
    }

    return $issues
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

        $submoduleIssues = 0

        foreach ($file in $changedFiles) {
            $fullPath = Join-Path $submodulePath $file

            if (-not (Test-Path $fullPath)) {
                continue
            }

            $issues = Check-FileForIssues -filePath $fullPath

            if ($issues.Count -gt 0) {
                if (-not $issuesByFile.ContainsKey($submodule)) {
                    $issuesByFile[$submodule] = @{}
                }
                $issuesByFile[$submodule][$file] = $issues
                $submoduleIssues += $issues.Count
                $totalIssues += $issues.Count
            }
        }

        if ($submoduleIssues -gt 0) {
            Write-Host "`n${submodule}: Found $submoduleIssues issue(s)" -ForegroundColor Yellow
        }

    } catch {
        Write-Host "  Error processing submodule: $_" -ForegroundColor Red
    } finally {
        Pop-Location
    }
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 80) -ForegroundColor Gray
Write-Host "Verification Summary:" -ForegroundColor Cyan
Write-Host "  Total issues found: $totalIssues" -ForegroundColor $(if ($totalIssues -eq 0) { "Green" } else { "Red" })

if ($totalIssues -gt 0) {
    Write-Host "`nDetailed Issues:" -ForegroundColor Yellow
    Write-Host ("=" * 80) -ForegroundColor Gray

    foreach ($submodule in $issuesByFile.Keys | Sort-Object) {
        Write-Host "`n[$submodule]" -ForegroundColor Cyan

        foreach ($file in $issuesByFile[$submodule].Keys | Sort-Object) {
            Write-Host "  File: $file" -ForegroundColor White

            foreach ($issue in $issuesByFile[$submodule][$file]) {
                Write-Host "    Line $($issue.LineNumber): $($issue.Issue)" -ForegroundColor Yellow
                Write-Host "      $($issue.Line)" -ForegroundColor DarkGray
            }
        }
    }

    # EN: Save issues to file for reference
    # CZ: Uložit problémy do souboru pro referenci
    $outputFile = Join-Path $rootPath ".scripts\short-vars-issues.txt"
    $output = "Short Variable Issues - $(Get-Date)`n"
    $output += "=" * 80 + "`n`n"

    foreach ($submodule in $issuesByFile.Keys | Sort-Object) {
        $output += "[$submodule]`n"
        foreach ($file in $issuesByFile[$submodule].Keys | Sort-Object) {
            $output += "  $file`n"
            foreach ($issue in $issuesByFile[$submodule][$file]) {
                $output += "    Line $($issue.LineNumber): $($issue.Issue)`n"
                $output += "      $($issue.Line)`n"
            }
        }
        $output += "`n"
    }

    Set-Content -Path $outputFile -Value $output -Encoding UTF8
    Write-Host "`nIssues saved to: $outputFile" -ForegroundColor Cyan
}
