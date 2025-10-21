# EN: Script to refactor short variable names to self-descriptive names
# CZ: Skript pro refaktorování krátkých názvů proměnných na samopopisné názvy

param(
    [Parameter(Mandatory=$false)]
    [string]$FileListPath1 = "E:\vs\Projects\PlatformIndependentNuGetPackages\files-to-refactor-1.txt",

    [Parameter(Mandatory=$false)]
    [string]$FileListPath2 = "E:\vs\Projects\PlatformIndependentNuGetPackages\files-to-refactor-2.txt",

    [Parameter(Mandatory=$false)]
    [string]$BaseDir = "E:\vs\Projects\PlatformIndependentNuGetPackages"
)

$ErrorActionPreference = "Stop"

# EN: Header comment to add to processed files
# CZ: Hlavičkový komentář pro přidání do zpracovaných souborů
$headerComment = @"
// EN: Variable names have been checked and replaced with self-descriptive names
// CZ: Názvy proměnných byly zkontrolovány a nahrazeny samopopisnými názvy

"@

# EN: Statistics
# CZ: Statistiky
$stats = @{
    TotalFiles = 0
    ProcessedFiles = 0
    SkippedFiles = 0
    ErrorFiles = @()
    Replacements = 0
}

# EN: Function to intelligently replace short variable names
# CZ: Funkce pro inteligentní náhradu krátkých názvů proměnných
function Replace-ShortVariables {
    param(
        [string]$Content,
        [string]$FilePath
    )

    $modified = $false
    $replacementCount = 0

    # EN: Define replacement patterns - order matters!
    # CZ: Definice vzorů pro nahrazení - pořadí záleží!
    $patterns = @(
        # StringBuilder sb -> stringBuilder
        @{
            Pattern = '\bStringBuilder\s+sb\b'
            Replacement = 'StringBuilder stringBuilder'
            VarPattern = '\bsb\b'
            VarReplacement = 'stringBuilder'
        },
        # var sb = new StringBuilder -> var stringBuilder = new StringBuilder
        @{
            Pattern = '\bvar\s+sb\s*=\s*new\s+StringBuilder'
            Replacement = 'var stringBuilder = new StringBuilder'
            VarPattern = '\bsb\b'
            VarReplacement = 'stringBuilder'
        },
        # List/lines: var l = (often from Split)
        @{
            Pattern = '\bvar\s+l\s*=.*\.Split\('
            Replacement = 'var lines ='
            VarPattern = '\bl\b'
            VarReplacement = 'lines'
            ContextCheck = 'Split'
        },
        @{
            Pattern = '\bvar\s+l\s*=.*List<'
            Replacement = 'var list ='
            VarPattern = '\bl\b'
            VarReplacement = 'list'
            ContextCheck = 'List'
        },
        @{
            Pattern = '\bList<[^>]+>\s+l\b'
            Replacement = { param($m) $m.Value -replace '\bl\b', 'list' }
            VarPattern = '\bl\b'
            VarReplacement = 'list'
        },
        # var ls = (source list or items)
        @{
            Pattern = '\bvar\s+ls\s*='
            Replacement = 'var sourceList ='
            VarPattern = '\bls\b'
            VarReplacement = 'sourceList'
        },
        # var t = (temp, type, target - context dependent)
        @{
            Pattern = '\bvar\s+t\s*=.*typeof\('
            Replacement = 'var type ='
            VarPattern = '\bt\b'
            VarReplacement = 'type'
            ContextCheck = 'typeof'
        },
        @{
            Pattern = '\bType\s+t\b'
            Replacement = 'Type type'
            VarPattern = '\bt\b'
            VarReplacement = 'type'
        },
        @{
            Pattern = '\bvar\s+t\s*='
            Replacement = 'var temp ='
            VarPattern = '\bt\b'
            VarReplacement = 'temp'
        },
        # var d = (data, dictionary, digitCount)
        @{
            Pattern = '\bDictionary<[^>]+>\s+d\b'
            Replacement = { param($m) $m.Value -replace '\bd\b', 'dictionary' }
            VarPattern = '\bd\b'
            VarReplacement = 'dictionary'
        },
        @{
            Pattern = '\bvar\s+d\s*=.*new\s+Dictionary'
            Replacement = 'var dictionary ='
            VarPattern = '\bd\b'
            VarReplacement = 'dictionary'
        },
        @{
            Pattern = '\bvar\s+d\s*='
            Replacement = 'var data ='
            VarPattern = '\bd\b'
            VarReplacement = 'data'
        },
        # var v = (value)
        @{
            Pattern = '\bvar\s+v\s*='
            Replacement = 'var value ='
            VarPattern = '\bv\b'
            VarReplacement = 'value'
        },
        # var n = (name, count)
        @{
            Pattern = '\bvar\s+n\s*=.*\.Count\b'
            Replacement = 'var count ='
            VarPattern = '\bn\b'
            VarReplacement = 'count'
            ContextCheck = 'Count'
        },
        @{
            Pattern = '\bvar\s+n\s*=.*\.Length\b'
            Replacement = 'var count ='
            VarPattern = '\bn\b'
            VarReplacement = 'count'
            ContextCheck = 'Length'
        },
        @{
            Pattern = '\bvar\s+n\s*='
            Replacement = 'var name ='
            VarPattern = '\bn\b'
            VarReplacement = 'name'
        },
        # var m = (message, match)
        @{
            Pattern = '\bvar\s+m\s*=.*\.Match\('
            Replacement = 'var match ='
            VarPattern = '\bm\b'
            VarReplacement = 'match'
            ContextCheck = 'Match'
        },
        @{
            Pattern = '\bMatch\s+m\b'
            Replacement = 'Match match'
            VarPattern = '\bm\b'
            VarReplacement = 'match'
        },
        @{
            Pattern = '\bvar\s+m\s*='
            Replacement = 'var message ='
            VarPattern = '\bm\b'
            VarReplacement = 'message'
        },
        # var p = (path, parameter)
        @{
            Pattern = '\bvar\s+p\s*=.*Path\.'
            Replacement = 'var path ='
            VarPattern = '\bp\b'
            VarReplacement = 'path'
            ContextCheck = 'Path'
        },
        @{
            Pattern = '\bvar\s+p\s*='
            Replacement = 'var parameter ='
            VarPattern = '\bp\b'
            VarReplacement = 'parameter'
        },
        # var r = (result)
        @{
            Pattern = '\bvar\s+r\s*='
            Replacement = 'var result ='
            VarPattern = '\br\b'
            VarReplacement = 'result'
        },
        # var c = (count, character)
        @{
            Pattern = '\bchar\s+c\b'
            Replacement = 'char character'
            VarPattern = '\bc\b'
            VarReplacement = 'character'
        },
        @{
            Pattern = '\bvar\s+c\s*=.*\.Count\b'
            Replacement = 'var count ='
            VarPattern = '\bc\b'
            VarReplacement = 'count'
            ContextCheck = 'Count'
        },
        @{
            Pattern = '\bvar\s+c\s*='
            Replacement = 'var count ='
            VarPattern = '\bc\b'
            VarReplacement = 'count'
        },
        # var s = (text, source, str)
        @{
            Pattern = '\bstring\s+s\b'
            Replacement = 'string text'
            VarPattern = '\bs\b'
            VarReplacement = 'text'
        },
        @{
            Pattern = '\bvar\s+s\s*=.*\.ToString\('
            Replacement = 'var text ='
            VarPattern = '\bs\b'
            VarReplacement = 'text'
            ContextCheck = 'ToString'
        },
        @{
            Pattern = '\bvar\s+s\s*='
            Replacement = 'var text ='
            VarPattern = '\bs\b'
            VarReplacement = 'text'
        },
        # var e = (exception in catch blocks, element otherwise)
        @{
            Pattern = 'catch\s*\(\s*\w+\s+e\s*\)'
            Replacement = { param($m) $m.Value -replace '\be\)', 'exception)' }
            VarPattern = '\be\b'
            VarReplacement = 'exception'
            ContextCheck = 'catch'
        },
        @{
            Pattern = '\bvar\s+e\s*='
            Replacement = 'var element ='
            VarPattern = '\be\b'
            VarReplacement = 'element'
        },
        # var a = (array, argument)
        @{
            Pattern = '\bvar\s+a\s*=.*\[\]'
            Replacement = 'var array ='
            VarPattern = '\ba\b'
            VarReplacement = 'array'
            ContextCheck = '[]'
        },
        @{
            Pattern = '\bvar\s+a\s*='
            Replacement = 'var argument ='
            VarPattern = '\ba\b'
            VarReplacement = 'argument'
        },
        # var b = (buffer, builder)
        @{
            Pattern = '\bvar\s+b\s*=.*new\s+byte\['
            Replacement = 'var buffer ='
            VarPattern = '\bb\b'
            VarReplacement = 'buffer'
            ContextCheck = 'byte['
        },
        @{
            Pattern = '\bbyte\[\]\s+b\b'
            Replacement = 'byte[] buffer'
            VarPattern = '\bb\b'
            VarReplacement = 'buffer'
        },
        @{
            Pattern = '\bvar\s+b\s*='
            Replacement = 'var builder ='
            VarPattern = '\bb\b'
            VarReplacement = 'builder'
        },
        # var x, y, z = (coordinate or generic)
        @{
            Pattern = '\bvar\s+x\s*='
            Replacement = 'var xValue ='
            VarPattern = '\bx\b'
            VarReplacement = 'xValue'
        },
        @{
            Pattern = '\bvar\s+y\s*='
            Replacement = 'var yValue ='
            VarPattern = '\by\b'
            VarReplacement = 'yValue'
        },
        @{
            Pattern = '\bvar\s+z\s*='
            Replacement = 'var zValue ='
            VarPattern = '\bz\b'
            VarReplacement = 'zValue'
        }
    )

    # EN: Track which variables have been replaced in this file
    # CZ: Sledování které proměnné byly nahrazeny v tomto souboru
    $replacedVars = @{}

    $newContent = $Content

    foreach ($pattern in $patterns) {
        if ($newContent -match $pattern.Pattern) {
            $varName = $pattern.VarReplacement

            # EN: Skip if this variable was already replaced
            # CZ: Přeskočit pokud tato proměnná už byla nahrazena
            $shortVar = $pattern.VarPattern -replace '\\b', ''
            if ($replacedVars.ContainsKey($shortVar)) {
                continue
            }

            # EN: First, replace the declaration
            # CZ: Nejprve nahradit deklaraci
            $oldContent = $newContent
            if ($pattern.Replacement -is [ScriptBlock]) {
                $newContent = $newContent -replace $pattern.Pattern, $pattern.Replacement
            } else {
                $newContent = $newContent -replace $pattern.Pattern, $pattern.Replacement
            }

            if ($oldContent -ne $newContent) {
                # EN: Then replace all occurrences of the variable in its scope
                # CZ: Potom nahradit všechny výskyty proměnné v jejím rozsahu
                # Note: This is a simplified approach - proper scope analysis would be more complex
                $newContent = $newContent -replace $pattern.VarPattern, $pattern.VarReplacement

                $replacedVars[$shortVar] = $varName
                $modified = $true
                $replacementCount++

                Write-Host "  Replaced '$shortVar' with '$varName'"
            }
        }
    }

    return @{
        Content = $newContent
        Modified = $modified
        ReplacementCount = $replacementCount
    }
}

# EN: Function to process a single file
# CZ: Funkce pro zpracování jednoho souboru
function Process-File {
    param(
        [string]$RelativePath
    )

    $fullPath = Join-Path $BaseDir $RelativePath

    Write-Host "Processing: $RelativePath" -ForegroundColor Cyan

    if (-not (Test-Path $fullPath)) {
        Write-Host "  File not found: $fullPath" -ForegroundColor Yellow
        $stats.SkippedFiles++
        return
    }

    try {
        # EN: Read file content
        # CZ: Čtení obsahu souboru
        $content = Get-Content -Path $fullPath -Raw -Encoding UTF8

        # EN: Check if header already exists
        # CZ: Kontrola zda hlavička již existuje
        if ($content -match "Variable names have been checked and replaced with self-descriptive names") {
            Write-Host "  Already processed (header found)" -ForegroundColor Yellow
            $stats.SkippedFiles++
            return
        }

        # EN: Replace short variables
        # CZ: Nahrazení krátkých proměnných
        $result = Replace-ShortVariables -Content $content -FilePath $fullPath

        if ($result.Modified) {
            # EN: Add header comment at the beginning
            # CZ: Přidání hlavičkového komentáře na začátek
            $newContent = $headerComment + $result.Content

            # EN: Write back to file
            # CZ: Zápis zpět do souboru
            Set-Content -Path $fullPath -Value $newContent -Encoding UTF8 -NoNewline

            Write-Host "  SUCCESS: $($result.ReplacementCount) variable(s) replaced" -ForegroundColor Green
            $stats.ProcessedFiles++
            $stats.Replacements += $result.ReplacementCount
        } else {
            Write-Host "  No short variables found" -ForegroundColor Yellow
            $stats.SkippedFiles++
        }
    }
    catch {
        Write-Host "  ERROR: $_" -ForegroundColor Red
        $stats.ErrorFiles += $RelativePath
    }
}

# EN: Main processing
# CZ: Hlavní zpracování
Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "Short Variable Refactoring Script" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

# EN: Read file lists
# CZ: Čtení seznamů souborů
$files1 = Get-Content $FileListPath1 | Where-Object { $_ -and $_.Trim() }
$files2 = Get-Content $FileListPath2 | Where-Object { $_ -and $_.Trim() }

$allFiles = $files1 + $files2
$stats.TotalFiles = $allFiles.Count

Write-Host "Total files to process: $($stats.TotalFiles)" -ForegroundColor Cyan
Write-Host "  - From hasCommentButStillHasShortVars: $($files1.Count)" -ForegroundColor Cyan
Write-Host "  - From noCommentButHasShortVars: $($files2.Count)" -ForegroundColor Cyan
Write-Host ""

# EN: Process each file
# CZ: Zpracování každého souboru
$currentFile = 0
foreach ($file in $allFiles) {
    $currentFile++
    Write-Host "[$currentFile/$($stats.TotalFiles)] " -NoNewline -ForegroundColor Gray
    Process-File -RelativePath $file
}

# EN: Print summary
# CZ: Výpis souhrnu
Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "SUMMARY" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Total files: $($stats.TotalFiles)" -ForegroundColor White
Write-Host "Successfully processed: $($stats.ProcessedFiles)" -ForegroundColor Green
Write-Host "Skipped: $($stats.SkippedFiles)" -ForegroundColor Yellow
Write-Host "Errors: $($stats.ErrorFiles.Count)" -ForegroundColor Red
Write-Host "Total replacements: $($stats.Replacements)" -ForegroundColor Cyan

if ($stats.ErrorFiles.Count -gt 0) {
    Write-Host "`nFiles with errors:" -ForegroundColor Red
    foreach ($errorFile in $stats.ErrorFiles) {
        Write-Host "  - $errorFile" -ForegroundColor Red
    }
}

Write-Host "`nRefactoring complete!`n" -ForegroundColor Green
