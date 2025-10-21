# EN: Verify that all 38 files no longer have short variable names
# CZ: Ověřit že všech 38 souborů již nemá krátké názvy proměnných

$baseDir = "E:\vs\Projects\PlatformIndependentNuGetPackages"

$files = @(
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

$filesWithIssues = @()
$pattern = '\b(var (sb|l|ls|t|d|v|n|m|p|r|c|s|e|a|b|x|y|z) =|StringBuilder sb\b|List<[^>]+> l\b|string s\b|char c\b)'

Write-Host "`n=== Verifying all 38 files ===" -ForegroundColor Cyan

foreach ($file in $files) {
    $fullPath = Join-Path $baseDir $file
    $content = Get-Content $fullPath -Raw -Encoding UTF8

    if ($content -match $pattern) {
        Write-Host "✗ $file - STILL HAS SHORT VARS" -ForegroundColor Red
        $filesWithIssues += $file
    } else {
        Write-Host "✓ $file - Clean" -ForegroundColor Green
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan

if ($filesWithIssues.Count -eq 0) {
    Write-Host "SUCCESS: All 38 files are clean!" -ForegroundColor Green
} else {
    Write-Host "ISSUES FOUND in $($filesWithIssues.Count) files:" -ForegroundColor Red
    $filesWithIssues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
