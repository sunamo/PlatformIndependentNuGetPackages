# EN: Removes consecutive blocks of commented-out code (3+ lines) from C# files
# CZ: Odstraní souvislé bloky zakomentovaného kódu (3+ řádků) z C# souborů

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,  # EN: Path to file or directory | CZ: Cesta k souboru nebo složce
    [switch]$WhatIf,  # EN: Only show what would be removed, without actually removing | CZ: Pouze ukázat co by se smazalo, bez skutečného mazání
    [int]$MinBlockSize = 3  # EN: Minimum number of consecutive commented lines to be considered a block | CZ: Minimální počet souvislých zakomentovaných řádků pro blok
)

function Remove-CommentedCodeBlocks {
    param(
        [string]$FilePath,
        [switch]$WhatIf,
        [int]$MinBlockSize
    )

    # EN: Read file content
    # CZ: Přečti obsah souboru
    $lines = Get-Content -Path $FilePath -Encoding UTF8
    if (-not $lines) {
        Write-Host "  Empty file, skipping: $FilePath" -ForegroundColor Gray
        return
    }

    $newLines = @()
    $currentCommentBlock = @()
    $currentBlockStartLine = -1
    $blocksRemoved = 0
    $linesRemoved = 0

    # EN: Skip header (first 2 lines with variable names check comment)
    # CZ: Přeskoč hlavičku (první 2 řádky s komentářem o kontrole proměnných)
    $isHeaderLine = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineNumber = $i + 1

        # EN: Detect header lines (first 2 lines)
        # CZ: Detekuj řádky hlavičky (první 2 řádky)
        if ($i -lt 2 -and ($line -match '^//\s*(EN:|CZ:).*[Vv]ariable')) {
            $isHeaderLine = $true
        } else {
            $isHeaderLine = $false
        }

        # EN: Check if this is a commented line (but not XML doc comment /// and not header)
        # CZ: Zkontroluj jestli je to zakomentovaný řádek (ale ne XML doc komentář /// a ne hlavička)
        $isCommented = $false
        if (-not $isHeaderLine) {
            # EN: Line starts with // but not /// (trim leading whitespace first)
            # CZ: Řádek začíná // ale ne /// (nejdřív odstraň úvodní mezery)
            $trimmedLine = $line.TrimStart()
            if ($trimmedLine -match '^//[^/]') {
                $isCommented = $true
            }
        }

        if ($isCommented) {
            # EN: Add to current comment block
            # CZ: Přidej do aktuálního bloku komentářů
            if ($currentCommentBlock.Count -eq 0) {
                $currentBlockStartLine = $lineNumber
            }
            $currentCommentBlock += $line
        } else {
            # EN: End of comment block - check if we should remove it
            # CZ: Konec bloku komentářů - zkontroluj jestli ho máme smazat
            if ($currentCommentBlock.Count -ge $MinBlockSize) {
                # EN: This is a block worth removing
                # CZ: Toto je blok který stojí za odstranění

                # EN: Check if it's not a "whole method commented + dummy return/throw" case
                # CZ: Zkontroluj jestli to není případ "celá metoda zakomentovaná + dummy return/throw"
                $shouldKeep = $false

                # EN: Look ahead to see if there's only 1 functional line before closing brace
                # CZ: Podívej se dopředu jestli je jen 1 funkční řádek před uzavírací závorkou
                $functionalLinesAhead = 0
                $closingBraceFound = $false
                for ($j = $i; $j -lt [Math]::Min($i + 10, $lines.Count); $j++) {
                    $aheadLine = $lines[$j].Trim()
                    if ($aheadLine -eq '}') {
                        $closingBraceFound = $true
                        break
                    }
                    # EN: Skip empty lines and comment lines
                    # CZ: Přeskoč prázdné řádky a řádky s komentáři
                    if ($aheadLine -ne '' -and -not $aheadLine.StartsWith('//')) {
                        $functionalLinesAhead++
                    }
                }

                # EN: If there's exactly 1 functional line (throw/return) before closing brace, keep the block
                # CZ: Pokud je přesně 1 funkční řádek (throw/return) před uzavírací závorkou, ponechej blok
                if ($closingBraceFound -and $functionalLinesAhead -eq 1 -and $currentCommentBlock.Count -gt 10) {
                    $functionalLine = ''
                    for ($j = $i; $j -lt $lines.Count; $j++) {
                        $testLine = $lines[$j].Trim()
                        if ($testLine -ne '' -and -not $testLine.StartsWith('//')) {
                            $functionalLine = $testLine
                            break
                        }
                    }

                    # EN: Check if it's a throw or return statement
                    # CZ: Zkontroluj jestli je to throw nebo return příkaz
                    if ($functionalLine -match '^\s*(throw|return)\s') {
                        $shouldKeep = $true
                        Write-Host "    Keeping commented method block (line $currentBlockStartLine, $($currentCommentBlock.Count) lines) - followed by dummy throw/return" -ForegroundColor Cyan
                    }
                }

                if (-not $shouldKeep) {
                    # EN: Remove this block
                    # CZ: Odstraň tento blok
                    $blocksRemoved++
                    $linesRemoved += $currentCommentBlock.Count

                    if ($WhatIf) {
                        Write-Host "    Would remove block at lines $currentBlockStartLine-$($currentBlockStartLine + $currentCommentBlock.Count - 1) ($($currentCommentBlock.Count) lines):" -ForegroundColor Yellow
                        $currentCommentBlock | Select-Object -First 3 | ForEach-Object {
                            Write-Host "      $_" -ForegroundColor Gray
                        }
                        if ($currentCommentBlock.Count -gt 3) {
                            Write-Host "      ... ($($currentCommentBlock.Count - 3) more lines)" -ForegroundColor Gray
                        }
                    }
                } else {
                    # EN: Keep this block
                    # CZ: Ponechej tento blok
                    $newLines += $currentCommentBlock
                }
            } else {
                # EN: Block too small, keep it
                # CZ: Blok moc malý, ponechej ho
                $newLines += $currentCommentBlock
            }

            # EN: Reset block
            # CZ: Resetuj blok
            $currentCommentBlock = @()
            $currentBlockStartLine = -1

            # EN: Add current non-comment line
            # CZ: Přidej aktuální ne-komentářový řádek
            $newLines += $line
        }
    }

    # EN: Handle last block if file ends with comments
    # CZ: Zpracuj poslední blok pokud soubor končí komentáři
    if ($currentCommentBlock.Count -ge $MinBlockSize) {
        $blocksRemoved++
        $linesRemoved += $currentCommentBlock.Count

        if ($WhatIf) {
            Write-Host "    Would remove block at end of file (lines $currentBlockStartLine-$($lines.Count)) ($($currentCommentBlock.Count) lines)" -ForegroundColor Yellow
        }
    } else {
        $newLines += $currentCommentBlock
    }

    # EN: Report and save if changes were made
    # CZ: Nahlásit a uložit pokud byly provedeny změny
    if ($blocksRemoved -gt 0) {
        Write-Host "  File: $FilePath" -ForegroundColor Green
        Write-Host "    Blocks removed: $blocksRemoved" -ForegroundColor Yellow
        Write-Host "    Lines removed: $linesRemoved" -ForegroundColor Yellow

        if (-not $WhatIf) {
            # EN: Save modified file
            # CZ: Ulož upravený soubor
            $newLines | Set-Content -Path $FilePath -Encoding UTF8
            Write-Host "    File saved!" -ForegroundColor Green
        }

        return $true
    }

    return $false
}

# EN: Main script logic
# CZ: Hlavní logika skriptu
Write-Host "Removing commented code blocks..." -ForegroundColor Cyan
Write-Host ""

$csFiles = @()

# EN: Determine if Path is file or directory
# CZ: Urči jestli je Path soubor nebo složka
if (Test-Path $Path -PathType Leaf) {
    # EN: Single file
    # CZ: Jednotlivý soubor
    if ($Path -like "*.cs") {
        $csFiles += Get-Item $Path
    } else {
        Write-Error "Path is not a .cs file: $Path"
        exit 1
    }
} elseif (Test-Path $Path -PathType Container) {
    # EN: Directory - find all .cs files
    # CZ: Složka - najdi všechny .cs soubory
    $csFiles = Get-ChildItem -Path $Path -Filter "*.cs" -Recurse -File | Where-Object {
        $_.FullName -notmatch [regex]::Escape("\obj\") -and
        $_.FullName -notmatch [regex]::Escape("\bin\") -and
        $_.Name -ne "GlobalUsings.cs"
    }
} else {
    Write-Error "Path not found: $Path"
    exit 1
}

Write-Host "Found $($csFiles.Count) .cs file(s)" -ForegroundColor Cyan
Write-Host "Minimum block size: $MinBlockSize lines" -ForegroundColor Cyan
if ($WhatIf) {
    Write-Host "Mode: WhatIf (no changes will be made)" -ForegroundColor Yellow
} else {
    Write-Host "Mode: Execute (files will be modified)" -ForegroundColor Red
}
Write-Host ""

$filesModified = 0
foreach ($file in $csFiles) {
    $modified = Remove-CommentedCodeBlocks -FilePath $file.FullName -WhatIf:$WhatIf -MinBlockSize $MinBlockSize
    if ($modified) {
        $filesModified++
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Green
Write-Host "  Total files processed: $($csFiles.Count)" -ForegroundColor Cyan
Write-Host "  Files with changes: $filesModified" -ForegroundColor Yellow

if ($WhatIf) {
    Write-Host ""
    Write-Host "Re-run without -WhatIf to apply changes." -ForegroundColor Yellow
}
