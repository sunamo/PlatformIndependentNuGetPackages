# EN: Parse NuGet API key from ApiKeyConsts.cs to avoid hardcoding secrets
# CZ: Parsovat NuGet API klíč z ApiKeyConsts.cs aby se předešlo hardcoded secretům
$apiKeyConstFile = "E:\vs\Projects\Credentials\ApiKeys\ApiKeyConsts.cs"

if (-not (Test-Path $apiKeyConstFile)) {
    Write-Host "❌ CHYBA: Soubor s API klíči nenalezen: $apiKeyConstFile" -ForegroundColor Red
    exit 1
}

# EN: Read and parse nugetUploadPackages constant from C# file
# CZ: Přečíst a parsovat nugetUploadPackages konstantu z C# souboru
$apiKeyContent = Get-Content $apiKeyConstFile -Raw
if ($apiKeyContent -match 'nugetUploadPackages\s*=\s*"([^"]+)"') {
    $nugetApiKey = $matches[1]
    Write-Host "✅ NuGet API klíč načten z ApiKeyConsts.cs" -ForegroundColor Green
} else {
    Write-Host "❌ CHYBA: Nepodařilo se najít nugetUploadPackages v ApiKeyConsts.cs" -ForegroundColor Red
    exit 1
}

$skipPackages = @(
    'SunamoFtp','SunamoIni','SunamoMarkdown','SunamoCsv','SunamoFluentFtp',
    'SunamoDebugIO','SunamoMail','SunamoPS','SunamoClearScript','SunamoDebugging',
    'SunamoPInvoke','SunamoYouTube','SunamoCrypt','SunamoCl','SunamoPackageJson',
    'SunamoWinStd','SunamoXml','SunamoVcf','SunamoValues','SunamoUri',
    'SunamoUnderscore','SunamoTwoWayDictionary','SunamoThread','SunamoThisApp',
    'SunamoTextOutputGenerator','SunamoStringTrim','SunamoStringSubstring',
    'SunamoStringSplit','SunamoStringReplace','SunamoStringJoin','SunamoStringGetLines'
)

& "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\republish-parallel.ps1" -NuGetApiKey $nugetApiKey -ThrottleLimit 8 -SkipPackages $skipPackages
