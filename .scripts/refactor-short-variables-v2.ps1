# EN: Script to refactor short variable names to self-descriptive names in C# files
# CZ: Skript pro refaktorování krátkých názvů proměnných na samopopisné názvy v C# souborech

param(
    [Parameter(Mandatory=$false)]
    [string]$BaseDir = "E:\vs\Projects\PlatformIndependentNuGetPackages",

    [Parameter(Mandatory=$false)]
    [int]$TestMode = 0  # If > 0, only process this many files for testing
)

$ErrorActionPreference = "Stop"

# EN: Header comment to add to processed files
# CZ: Hlavičkový komentář pro přidání do zpracovaných souborů
$headerComment = "// EN: Variable names have been checked and replaced with self-descriptive names`r`n// CZ: Názvy proměnných byly zkontrolovány a nahrazeny samopopisnými názvy`r`n`r`n"

# EN: Statistics
# CZ: Statistiky
$stats = @{
    TotalFiles = 0
    ProcessedFiles = 0
    SkippedFiles = 0
    AlreadyProcessed = 0
    ErrorFiles = @()
    TotalReplacements = 0
}

# EN: Read file lists
# CZ: Čtení seznamů souborů
$files1Path = Join-Path $BaseDir "files-to-refactor-1.txt"
$files2Path = Join-Path $BaseDir "files-to-refactor-2.txt"

if (-not (Test-Path $files1Path) -or -not (Test-Path $files2Path)) {
    Write-Host "ERROR: File lists not found!" -ForegroundColor Red
    Write-Host "Expected: $files1Path" -ForegroundColor Red
    Write-Host "Expected: $files2Path" -ForegroundColor Red
    exit 1
}

$files1 = Get-Content $files1Path | Where-Object { $_ -and $_.Trim() }
$files2 = Get-Content $files2Path | Where-Object { $_ -and $_.Trim() }
$allFiles = $files1 + $files2

if ($TestMode -gt 0) {
    Write-Host "TEST MODE: Processing only first $TestMode files" -ForegroundColor Yellow
    $allFiles = $allFiles | Select-Object -First $TestMode
}

$stats.TotalFiles = $allFiles.Count

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "Short Variable Refactoring Script v2" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta
Write-Host "Total files to process: $($stats.TotalFiles)" -ForegroundColor Cyan
Write-Host ""

# EN: Process each file
# CZ: Zpracování každého souboru
$currentFile = 0

foreach ($relativePath in $allFiles) {
    $currentFile++
    $fullPath = Join-Path $BaseDir $relativePath

    Write-Host "[$currentFile/$($stats.TotalFiles)] $relativePath" -ForegroundColor Gray

    if (-not (Test-Path $fullPath)) {
        Write-Host "  SKIP: File not found" -ForegroundColor Yellow
        $stats.SkippedFiles++
        continue
    }

    try {
        # EN: Read file content
        # CZ: Čtení obsahu souboru
        $content = Get-Content -Path $fullPath -Raw -Encoding UTF8

        if (-not $content) {
            Write-Host "  SKIP: Empty file" -ForegroundColor Yellow
            $stats.SkippedFiles++
            continue
        }

        # EN: Check if already processed
        # CZ: Kontrola zda již bylo zpracováno
        if ($content -match "Variable names have been checked and replaced with self-descriptive names") {
            Write-Host "  SKIP: Already processed" -ForegroundColor Yellow
            $stats.AlreadyProcessed++
            continue
        }

        $originalContent = $content
        $replacementsMade = 0

        # EN: Define replacement rules with careful regex patterns
        # CZ: Definice pravidel nahrazení s pečlivými regex vzory

        # StringBuilder sb
        if ($content -match '\bStringBuilder\s+sb\b') {
            $content = $content -replace '\bStringBuilder\s+sb\b', 'StringBuilder stringBuilder'
            $content = $content -replace '\bsb\.', 'stringBuilder.'
            $content = $content -replace '\bsb\)', 'stringBuilder)'
            $content = $content -replace '\bsb,', 'stringBuilder,'
            $content = $content -replace '\bsb;', 'stringBuilder;'
            $content = $content -replace '\(sb\b', '(stringBuilder'
            $content = $content -replace '\ssb\b', ' stringBuilder'
            $replacementsMade++
            Write-Host "  - StringBuilder sb -> stringBuilder" -ForegroundColor Green
        }

        # var l = ... (lines or list, check context)
        if ($content -match '\bvar\s+l\s*=') {
            $newVarName = if ($content -match 'var\s+l\s*=.*\.Split\(') { 'lines' } else { 'list' }
            $content = $content -replace '\bvar\s+l\s*=', "var $newVarName ="
            $content = $content -replace '\bl\.', "$newVarName."
            $content = $content -replace '\bl\)', "$newVarName)"
            $content = $content -replace '\bl,', "$newVarName,"
            $content = $content -replace '\bl;', "$newVarName;"
            $content = $content -replace '\(l\b', "($newVarName"
            $content = $content -replace '\sl\b', " $newVarName"
            $replacementsMade++
            Write-Host "  - var l -> $newVarName" -ForegroundColor Green
        }

        # List<T> l
        if ($content -match '\bList<[^>]+>\s+l\b') {
            $content = $content -replace '\b(List<[^>]+>)\s+l\b', '$1 list'
            $content = $content -replace '\bl\.', 'list.'
            $content = $content -replace '\bl\)', 'list)'
            $content = $content -replace '\bl,', 'list,'
            $content = $content -replace '\bl;', 'list;'
            $content = $content -replace '\(l\b', '(list'
            $content = $content -replace '\sl\b', ' list'
            $replacementsMade++
            Write-Host "  - List<T> l -> list" -ForegroundColor Green
        }

        # var ls =
        if ($content -match '\bvar\s+ls\s*=') {
            $content = $content -replace '\bvar\s+ls\s*=', 'var sourceList ='
            $content = $content -replace '\bls\.', 'sourceList.'
            $content = $content -replace '\bls\)', 'sourceList)'
            $content = $content -replace '\bls,', 'sourceList,'
            $content = $content -replace '\bls;', 'sourceList;'
            $content = $content -replace '\(ls\b', '(sourceList'
            $content = $content -replace '\sls\b', ' sourceList'
            $replacementsMade++
            Write-Host "  - var ls -> sourceList" -ForegroundColor Green
        }

        # var t = (type or temp, check context)
        if ($content -match '\bvar\s+t\s*=') {
            $newVarName = if ($content -match 'var\s+t\s*=.*typeof\(') { 'type' } else { 'temp' }
            $content = $content -replace '\bvar\s+t\s*=', "var $newVarName ="
            $content = $content -replace '\bt\.', "$newVarName."
            $content = $content -replace '\bt\)', "$newVarName)"
            $content = $content -replace '\bt,', "$newVarName,"
            $content = $content -replace '\bt;', "$newVarName;"
            $content = $content -replace '\(t\b', "($newVarName"
            $content = $content -replace '\st\b', " $newVarName"
            $replacementsMade++
            Write-Host "  - var t -> $newVarName" -ForegroundColor Green
        }

        # Type t
        if ($content -match '\bType\s+t\b') {
            $content = $content -replace '\bType\s+t\b', 'Type type'
            $content = $content -replace '\bt\.', 'type.'
            $content = $content -replace '\bt\)', 'type)'
            $content = $content -replace '\bt,', 'type,'
            $content = $content -replace '\bt;', 'type;'
            $content = $content -replace '\(t\b', '(type'
            $content = $content -replace '\st\b', ' type'
            $replacementsMade++
            Write-Host "  - Type t -> type" -ForegroundColor Green
        }

        # var d = (dictionary or data, check context)
        if ($content -match '\bvar\s+d\s*=') {
            $newVarName = if ($content -match 'var\s+d\s*=.*Dictionary') { 'dictionary' } else { 'data' }
            $content = $content -replace '\bvar\s+d\s*=', "var $newVarName ="
            $content = $content -replace '\bd\.', "$newVarName."
            $content = $content -replace '\bd\)', "$newVarName)"
            $content = $content -replace '\bd,', "$newVarName,"
            $content = $content -replace '\bd;', "$newVarName;"
            $content = $content -replace '\bd\[', "$newVarName["
            $content = $content -replace '\(d\b', "($newVarName"
            $content = $content -replace '\sd\b', " $newVarName"
            $replacementsMade++
            Write-Host "  - var d -> $newVarName" -ForegroundColor Green
        }

        # Dictionary<K,V> d
        if ($content -match '\bDictionary<[^>]+>\s+d\b') {
            $content = $content -replace '\b(Dictionary<[^>]+>)\s+d\b', '$1 dictionary'
            $content = $content -replace '\bd\.', 'dictionary.'
            $content = $content -replace '\bd\)', 'dictionary)'
            $content = $content -replace '\bd,', 'dictionary,'
            $content = $content -replace '\bd;', 'dictionary;'
            $content = $content -replace '\bd\[', 'dictionary['
            $content = $content -replace '\(d\b', '(dictionary'
            $content = $content -replace '\sd\b', ' dictionary'
            $replacementsMade++
            Write-Host "  - Dictionary<K,V> d -> dictionary" -ForegroundColor Green
        }

        # var v =
        if ($content -match '\bvar\s+v\s*=') {
            $content = $content -replace '\bvar\s+v\s*=', 'var value ='
            $content = $content -replace '\bv\.', 'value.'
            $content = $content -replace '\bv\)', 'value)'
            $content = $content -replace '\bv,', 'value,'
            $content = $content -replace '\bv;', 'value;'
            $content = $content -replace '\(v\b', '(value'
            $content = $content -replace '\sv\b', ' value'
            $replacementsMade++
            Write-Host "  - var v -> value" -ForegroundColor Green
        }

        # var n = (name or count, check context)
        if ($content -match '\bvar\s+n\s*=') {
            $newVarName = if ($content -match 'var\s+n\s*=.*(\.Count|\.Length)') { 'count' } else { 'name' }
            $content = $content -replace '\bvar\s+n\s*=', "var $newVarName ="
            $content = $content -replace '\bn\.', "$newVarName."
            $content = $content -replace '\bn\)', "$newVarName)"
            $content = $content -replace '\bn,', "$newVarName,"
            $content = $content -replace '\bn;', "$newVarName;"
            $content = $content -replace '\(n\b', "($newVarName"
            $content = $content -replace '\sn\b', " $newVarName"
            $replacementsMade++
            Write-Host "  - var n -> $newVarName" -ForegroundColor Green
        }

        # var m = (match or message, check context)
        if ($content -match '\bvar\s+m\s*=') {
            $newVarName = if ($content -match 'var\s+m\s*=.*\.Match\(') { 'match' } else { 'message' }
            $content = $content -replace '\bvar\s+m\s*=', "var $newVarName ="
            $content = $content -replace '\bm\.', "$newVarName."
            $content = $content -replace '\bm\)', "$newVarName)"
            $content = $content -replace '\bm,', "$newVarName,"
            $content = $content -replace '\bm;', "$newVarName;"
            $content = $content -replace '\(m\b', "($newVarName"
            $content = $content -replace '\sm\b', " $newVarName"
            $replacementsMade++
            Write-Host "  - var m -> $newVarName" -ForegroundColor Green
        }

        # Match m
        if ($content -match '\bMatch\s+m\b') {
            $content = $content -replace '\bMatch\s+m\b', 'Match match'
            $content = $content -replace '\bm\.', 'match.'
            $content = $content -replace '\bm\)', 'match)'
            $content = $content -replace '\bm,', 'match,'
            $content = $content -replace '\bm;', 'match;'
            $content = $content -replace '\(m\b', '(match'
            $content = $content -replace '\sm\b', ' match'
            $replacementsMade++
            Write-Host "  - Match m -> match" -ForegroundColor Green
        }

        # var p = (path or parameter, check context)
        if ($content -match '\bvar\s+p\s*=') {
            $newVarName = if ($content -match 'var\s+p\s*=.*Path\.') { 'path' } else { 'parameter' }
            $content = $content -replace '\bvar\s+p\s*=', "var $newVarName ="
            $content = $content -replace '\bp\.', "$newVarName."
            $content = $content -replace '\bp\)', "$newVarName)"
            $content = $content -replace '\bp,', "$newVarName,"
            $content = $content -replace '\bp;', "$newVarName;"
            $content = $content -replace '\(p\b', "($newVarName"
            $content = $content -replace '\sp\b', " $newVarName"
            $replacementsMade++
            Write-Host "  - var p -> $newVarName" -ForegroundColor Green
        }

        # var r =
        if ($content -match '\bvar\s+r\s*=') {
            $content = $content -replace '\bvar\s+r\s*=', 'var result ='
            $content = $content -replace '\br\.', 'result.'
            $content = $content -replace '\br\)', 'result)'
            $content = $content -replace '\br,', 'result,'
            $content = $content -replace '\br;', 'result;'
            $content = $content -replace '\(r\b', '(result'
            $content = $content -replace '\sr\b', ' result'
            $replacementsMade++
            Write-Host "  - var r -> result" -ForegroundColor Green
        }

        # var c = (count or character, check context)
        if ($content -match '\bvar\s+c\s*=') {
            $newVarName = 'count'
            $content = $content -replace '\bvar\s+c\s*=', "var $newVarName ="
            $content = $content -replace '\bc\.', "$newVarName."
            $content = $content -replace '\bc\)', "$newVarName)"
            $content = $content -replace '\bc,', "$newVarName,"
            $content = $content -replace '\bc;', "$newVarName;"
            $content = $content -replace '\(c\b', "($newVarName"
            $content = $content -replace '\sc\b', " $newVarName"
            $replacementsMade++
            Write-Host "  - var c -> $newVarName" -ForegroundColor Green
        }

        # char c
        if ($content -match '\bchar\s+c\b') {
            $content = $content -replace '\bchar\s+c\b', 'char character'
            $content = $content -replace '\bc\)', 'character)'
            $content = $content -replace '\bc,', 'character,'
            $content = $content -replace '\bc;', 'character;'
            $content = $content -replace '\(c\b', '(character'
            $content = $content -replace '\sc\b', ' character'
            $replacementsMade++
            Write-Host "  - char c -> character" -ForegroundColor Green
        }

        # var s = (text)
        if ($content -match '\bvar\s+s\s*=') {
            $content = $content -replace '\bvar\s+s\s*=', 'var text ='
            $content = $content -replace '\bs\.', 'text.'
            $content = $content -replace '\bs\)', 'text)'
            $content = $content -replace '\bs,', 'text,'
            $content = $content -replace '\bs;', 'text;'
            $content = $content -replace '\bs\[', 'text['
            $content = $content -replace '\(s\b', '(text'
            $content = $content -replace '\ss\b', ' text'
            $replacementsMade++
            Write-Host "  - var s -> text" -ForegroundColor Green
        }

        # string s
        if ($content -match '\bstring\s+s\b') {
            $content = $content -replace '\bstring\s+s\b', 'string text'
            $content = $content -replace '\bs\.', 'text.'
            $content = $content -replace '\bs\)', 'text)'
            $content = $content -replace '\bs,', 'text,'
            $content = $content -replace '\bs;', 'text;'
            $content = $content -replace '\bs\[', 'text['
            $content = $content -replace '\(s\b', '(text'
            $content = $content -replace '\ss\b', ' text'
            $replacementsMade++
            Write-Host "  - string s -> text" -ForegroundColor Green
        }

        # catch (Exception e)
        if ($content -match 'catch\s*\([^)]*\se\s*\)') {
            $content = $content -replace 'catch\s*\(([^)]*)\se\s*\)', 'catch ($1 exception)'
            $content = $content -replace '\be\.', 'exception.'
            $content = $content -replace '\be\)', 'exception)'
            $content = $content -replace '\be,', 'exception,'
            $content = $content -replace '\be;', 'exception;'
            $content = $content -replace '\(e\b', '(exception'
            $content = $content -replace '\se\b', ' exception'
            $replacementsMade++
            Write-Host "  - catch e -> exception" -ForegroundColor Green
        }

        # var e =
        if ($content -match '\bvar\s+e\s*=') {
            $content = $content -replace '\bvar\s+e\s*=', 'var element ='
            $content = $content -replace '\be\.', 'element.'
            $content = $content -replace '\be\)', 'element)'
            $content = $content -replace '\be,', 'element,'
            $content = $content -replace '\be;', 'element;'
            $content = $content -replace '\(e\b', '(element'
            $content = $content -replace '\se\b', ' element'
            $replacementsMade++
            Write-Host "  - var e -> element" -ForegroundColor Green
        }

        # var a =
        if ($content -match '\bvar\s+a\s*=') {
            $newVarName = if ($content -match 'var\s+a\s*=.*\[\]') { 'array' } else { 'argument' }
            $content = $content -replace '\bvar\s+a\s*=', "var $newVarName ="
            $content = $content -replace '\ba\.', "$newVarName."
            $content = $content -replace '\ba\)', "$newVarName)"
            $content = $content -replace '\ba,', "$newVarName,"
            $content = $content -replace '\ba;', "$newVarName;"
            $content = $content -replace '\ba\[', "$newVarName["
            $content = $content -replace '\(a\b', "($newVarName"
            $content = $content -replace '\sa\b', " $newVarName"
            $replacementsMade++
            Write-Host "  - var a -> $newVarName" -ForegroundColor Green
        }

        # var b = (buffer or builder)
        if ($content -match '\bvar\s+b\s*=') {
            $newVarName = if ($content -match 'var\s+b\s*=.*byte\[') { 'buffer' } else { 'builder' }
            $content = $content -replace '\bvar\s+b\s*=', "var $newVarName ="
            $content = $content -replace '\bb\.', "$newVarName."
            $content = $content -replace '\bb\)', "$newVarName)"
            $content = $content -replace '\bb,', "$newVarName,"
            $content = $content -replace '\bb;', "$newVarName;"
            $content = $content -replace '\bb\[', "$newVarName["
            $content = $content -replace '\(b\b', "($newVarName"
            $content = $content -replace '\sb\b', " $newVarName"
            $replacementsMade++
            Write-Host "  - var b -> $newVarName" -ForegroundColor Green
        }

        # byte[] b
        if ($content -match '\bbyte\[\]\s+b\b') {
            $content = $content -replace '\bbyte\[\]\s+b\b', 'byte[] buffer'
            $content = $content -replace '\bb\.', 'buffer.'
            $content = $content -replace '\bb\)', 'buffer)'
            $content = $content -replace '\bb,', 'buffer,'
            $content = $content -replace '\bb;', 'buffer;'
            $content = $content -replace '\bb\[', 'buffer['
            $content = $content -replace '\(b\b', '(buffer'
            $content = $content -replace '\sb\b', ' buffer'
            $replacementsMade++
            Write-Host "  - byte[] b -> buffer" -ForegroundColor Green
        }

        # var x, y, z
        if ($content -match '\bvar\s+x\s*=') {
            $content = $content -replace '\bvar\s+x\s*=', 'var xValue ='
            $content = $content -replace '\bx\.', 'xValue.'
            $content = $content -replace '\bx\)', 'xValue)'
            $content = $content -replace '\bx,', 'xValue,'
            $content = $content -replace '\bx;', 'xValue;'
            $content = $content -replace '\(x\b', '(xValue'
            $content = $content -replace '\sx\b', ' xValue'
            $replacementsMade++
            Write-Host "  - var x -> xValue" -ForegroundColor Green
        }

        if ($content -match '\bvar\s+y\s*=') {
            $content = $content -replace '\bvar\s+y\s*=', 'var yValue ='
            $content = $content -replace '\by\.', 'yValue.'
            $content = $content -replace '\by\)', 'yValue)'
            $content = $content -replace '\by,', 'yValue,'
            $content = $content -replace '\by;', 'yValue;'
            $content = $content -replace '\(y\b', '(yValue'
            $content = $content -replace '\sy\b', ' yValue'
            $replacementsMade++
            Write-Host "  - var y -> yValue" -ForegroundColor Green
        }

        if ($content -match '\bvar\s+z\s*=') {
            $content = $content -replace '\bvar\s+z\s*=', 'var zValue ='
            $content = $content -replace '\bz\.', 'zValue.'
            $content = $content -replace '\bz\)', 'zValue)'
            $content = $content -replace '\bz,', 'zValue,'
            $content = $content -replace '\bz;', 'zValue;'
            $content = $content -replace '\(z\b', '(zValue'
            $content = $content -replace '\sz\b', ' zValue'
            $replacementsMade++
            Write-Host "  - var z -> zValue" -ForegroundColor Green
        }

        if ($replacementsMade -gt 0) {
            # EN: Add header comment
            # CZ: Přidání hlavičkového komentáře
            $content = $headerComment + $content

            # EN: Write back to file
            # CZ: Zápis zpět do souboru
            Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline

            Write-Host "  SUCCESS: $replacementsMade variable type(s) refactored" -ForegroundColor Green
            $stats.ProcessedFiles++
            $stats.TotalReplacements += $replacementsMade
        }
        else {
            Write-Host "  SKIP: No short variables found" -ForegroundColor Yellow
            $stats.SkippedFiles++
        }
    }
    catch {
        Write-Host "  ERROR: $_" -ForegroundColor Red
        $stats.ErrorFiles += $relativePath
    }
}

# EN: Print summary
# CZ: Výpis souhrnu
Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "REFACTORING SUMMARY" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Total files in list: $($stats.TotalFiles)" -ForegroundColor White
Write-Host "Successfully refactored: $($stats.ProcessedFiles)" -ForegroundColor Green
Write-Host "Already processed: $($stats.AlreadyProcessed)" -ForegroundColor Cyan
Write-Host "Skipped (no changes): $($stats.SkippedFiles)" -ForegroundColor Yellow
Write-Host "Errors: $($stats.ErrorFiles.Count)" -ForegroundColor Red
Write-Host "Total variable types refactored: $($stats.TotalReplacements)" -ForegroundColor Cyan

if ($stats.ErrorFiles.Count -gt 0) {
    Write-Host "`nFiles with errors:" -ForegroundColor Red
    foreach ($errorFile in $stats.ErrorFiles) {
        Write-Host "  - $errorFile" -ForegroundColor Red
    }
}

$totalProcessed = $stats.ProcessedFiles + $stats.AlreadyProcessed
Write-Host "`nTotal completed (new + already done): $totalProcessed / $($stats.TotalFiles)" -ForegroundColor Cyan

if ($totalProcessed -eq $stats.TotalFiles) {
    Write-Host "`nALL FILES COMPLETED!" -ForegroundColor Green
}

Write-Host ""
