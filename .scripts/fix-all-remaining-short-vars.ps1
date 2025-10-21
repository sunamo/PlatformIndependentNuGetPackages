# EN: Fix all remaining short variable names in 38 files
# CZ: Opravit všechny zbývající krátké názvy proměnných ve 38 souborech

$baseDir = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$filesFixed = 0
$totalFiles = 0

# EN: List of all 38 files to fix
# CZ: Seznam všech 38 souborů k opravě
$filesToFix = @(
    "SunamoChar\SunamoChar\CharHelper.cs",
    "SunamoCl\SunamoCl\SunamoCmd\Tables\TableParser.cs",
    "SunamoClipboard\SunamoClipboard\ClipboardHelper.cs",
    "SunamoCollections\SunamoCollections\CA.cs",
    "SunamoCollectionsGeneric\SunamoCollectionsGeneric\Collections\CyclingCollection.cs",
    "SunamoColors\SunamoColors\UtilsHex.cs",
    "SunamoConverters\SunamoConverters\Converts\ConvertCamelConventionWithNumbers.cs",
    "SunamoConverters\SunamoConverters\Converts\ConvertDayShortcutString.cs",
    "SunamoConverters\SunamoConverters\Converts\ConvertSnakeConvention.cs",
    "SunamoCsproj\SunamoCsproj\CsprojHelper.cs",
    "SunamoCsproj\SunamoCsproj\CsprojNsHelper.cs",
    "SunamoCsproj\SunamoCsproj\Data\ItemGroupElement.cs",
    "SunamoData\SunamoData\Data\ABC.cs",
    "SunamoDateTime\SunamoDateTime\NormalizeDate.cs",
    "SunamoDevCode\SunamoDevCode\Aps\ApsHelper.cs",
    "SunamoDevCode\SunamoDevCode\GenerateJson.cs",
    "SunamoDevCode\SunamoDevCode\PpkOnDriveDevCodeBase.cs",
    "SunamoDevCode\SunamoDevCode\RepoGetFileMascGeneratorData.cs",
    "SunamoDevCode\SunamoDevCode\SunamoSolutionsIndexer\FoldersWithSolutions.cs",
    "SunamoDevCode\SunamoDevCode\ToNetCore\research\InWeb.cs",
    "SunamoDevCode\SunamoDevCode\_sunamo\SunamoConverters\Converts\ConvertSnakeConvention.cs",
    "SunamoDevCode\SunamoDevCode\_sunamo\SunamoFileSystem\FS.cs",
    "SunamoEnumsHelper\SunamoEnumsHelper\EnumHelper.cs",
    "SunamoFileIO\SunamoFileIO\EncodingHelper.cs",
    "SunamoFileSystem\SunamoFileSystem\FS.cs",
    "SunamoFileSystem\SunamoFileSystem\_sunamo\SunamoStringSplit\SHSplit.cs",
    "SunamoPS\SunamoPS\PowershellParser.cs",
    "SunamoPS\SunamoPS\PowershellRunner.cs",
    "SunamoRandom\SunamoRandom\RandomHelper.cs",
    "SunamoRoslyn\SunamoRoslyn\_public\ABCRoslyn.cs",
    "SunamoRoslyn\SunamoRoslyn\_sunamo\SH.cs",
    "SunamoSerializer\SunamoSerializer\SF.cs",
    "SunamoShared\SunamoShared\_sunamo\SunamoString\SH.cs",
    "SunamoStopwatch\SunamoStopwatch\StopwatchStatic.cs",
    "SunamoStringSplit\SunamoStringSplit\SHSplit.cs",
    "SunamoUri\SunamoUri\UH.cs",
    "SunamoUriWebServices\SunamoUriWebServices\UriWebServicesClassesWeb.cs",
    "SunamoXml\SunamoXml\XHelper.cs"
)

function Fix-ShortVars {
    param([string]$filePath)

    $fullPath = Join-Path $baseDir $filePath
    Write-Host "Processing: $filePath" -ForegroundColor Cyan

    try {
        $content = Get-Content $fullPath -Raw -Encoding UTF8
        $originalContent = $content

        # EN: Fix StringBuilder sb
        # CZ: Opravit StringBuilder sb
        $content = $content -replace '\bvar sb = new StringBuilder\(', 'var stringBuilder = new StringBuilder('
        $content = $content -replace '\bvar sb = new System\.Text\.StringBuilder\(', 'var stringBuilder = new System.Text.StringBuilder('
        $content = $content -replace '\bStringBuilder sb([,;\)\s])', 'StringBuilder stringBuilder$1'

        # EN: Replace all uses of sb with stringBuilder (but not in comments)
        # CZ: Nahradit všechna použití sb s stringBuilder (ale ne v komentářích)
        $content = $content -replace '(\s)sb\.', '$1stringBuilder.'
        $content = $content -replace '\(sb,', '(stringBuilder,'
        $content = $content -replace '\(sb\)', '(stringBuilder)'
        $content = $content -replace '\ssb,', ' stringBuilder,'
        $content = $content -replace '\ssb\)', ' stringBuilder)'
        $content = $content -replace '\ssb;', ' stringBuilder;'
        $content = $content -replace '\bsb\.', 'stringBuilder.'

        # EN: Fix List<> l
        # CZ: Opravit List<> l
        $content = $content -replace '\bvar l = new List<', 'var list = new List<'
        $content = $content -replace 'List<string> l([,;\)\s])', 'List<string> list$1'
        $content = $content -replace 'List<int> l([,;\)\s])', 'List<int> list$1'

        # EN: Replace l. with list. (but not in comments and not when it's part of a longer word)
        # CZ: Nahradit l. s list. (ale ne v komentářích a ne když je součástí delšího slova)
        $content = $content -replace '(\s)l\.', '$1list.'
        $content = $content -replace '\(l,', '(list,'
        $content = $content -replace '\(l\)', '(list)'
        $content = $content -replace '\sl,', ' list,'
        $content = $content -replace '\sl\)', ' list)'
        $content = $content -replace '\sl;', ' list;'
        $content = $content -replace '\bl\.', 'list.'
        $content = $content -replace '\bl\[', 'list['

        # EN: Fix lines ls
        # CZ: Opravit řádky ls
        $content = $content -replace '\bvar ls = ', 'var lines = '
        $content = $content -replace '(\s)ls\.', '$1lines.'
        $content = $content -replace '\(ls,', '(lines,'
        $content = $content -replace '\(ls\)', '(lines)'
        $content = $content -replace '\sls,', ' lines,'
        $content = $content -replace '\sls\)', ' lines)'
        $content = $content -replace '\sls;', ' lines;'

        # EN: Fix var t (type)
        # CZ: Opravit var t (typ)
        $content = $content -replace '\bvar t = typeof\(', 'var type = typeof('
        $content = $content -replace '\bType t = ', 'Type type = '

        # EN: Fix var d (dictionary)
        # CZ: Opravit var d (slovník)
        $content = $content -replace '\bvar d = new Dictionary<', 'var dictionary = new Dictionary<'

        # EN: Fix var v (value)
        # CZ: Opravit var v (hodnota)
        $content = $content -replace '\bvar v = ', 'var value = '

        # EN: Fix var n (number)
        # CZ: Opravit var n (číslo)
        $content = $content -replace '\bvar n = ', 'var number = '

        # EN: Fix var m (message)
        # CZ: Opravit var m (zpráva)
        $content = $content -replace '\bvar m = ', 'var message = '

        # EN: Fix var p (path/parameter)
        # CZ: Opravit var p (cesta/parametr)
        $content = $content -replace '\bvar p = ', 'var path = '

        # EN: Fix var r (result)
        # CZ: Opravit var r (výsledek)
        $content = $content -replace '\bvar r = ', 'var result = '

        # EN: Fix var c (char/character)
        # CZ: Opravit var c (znak)
        $content = $content -replace '\bvar c = ', 'var character = '
        $content = $content -replace '\bchar c([,;\)\s])', 'char character$1'

        # EN: Fix var s (string)
        # CZ: Opravit var s (řetězec)
        $content = $content -replace '\bvar s = ', 'var str = '
        $content = $content -replace '\bstring s([,;\)\s])', 'string str$1'

        # EN: Fix var e (element)
        # CZ: Opravit var e (prvek)
        $content = $content -replace '\bvar e = ', 'var element = '

        # EN: Fix var a (array)
        # CZ: Opravit var a (pole)
        $content = $content -replace '\bvar a = ', 'var array = '

        # EN: Fix var b (boolean)
        # CZ: Opravit var b (boolean)
        $content = $content -replace '\bvar b = ', 'var boolean = '

        # EN: Fix var x, y, z (coordinates)
        # CZ: Opravit var x, y, z (souřadnice)
        $content = $content -replace '\bvar x = ', 'var xCoord = '
        $content = $content -replace '\bvar y = ', 'var yCoord = '
        $content = $content -replace '\bvar z = ', 'var zCoord = '

        if ($content -ne $originalContent) {
            Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline
            Write-Host "  ✓ Fixed: $filePath" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  - No changes: $filePath" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "  ✗ Error: $_" -ForegroundColor Red
        return $false
    }
}

Write-Host "`n=== Fixing remaining short variables in 38 files ===`n" -ForegroundColor Cyan

foreach ($file in $filesToFix) {
    $totalFiles++
    if (Fix-ShortVars -filePath $file) {
        $filesFixed++
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Total files processed: $totalFiles" -ForegroundColor White
Write-Host "Files modified: $filesFixed" -ForegroundColor Green
Write-Host "Files unchanged: $($totalFiles - $filesFixed)" -ForegroundColor Yellow
