# NuGet projects list from user
$nugetProjects = @(
    'SunamoAI', 'SunamoArgs', 'SunamoAsync', 'SunamoAttributes', 'SunamoAzureDevOpsApi',
    'SunamoBazosCrawler', 'SunamoBts', 'SunamoChar', 'SunamoCl', 'SunamoClearScript',
    'SunamoClipboard', 'SunamoCollectionOnDrive', 'SunamoCollections', 'SunamoCollectionsChangeContent',
    'SunamoCollectionsGeneric', 'SunamoCollectionsIndexesWithNull', 'SunamoCollectionsNonGeneric',
    'SunamoCollectionsTo', 'SunamoCollectionsValuesTableGrid', 'SunamoCollectionWithoutDuplicates',
    'SunamoColors', 'SunamoCompare', 'SunamoConverters', 'SunamoCrypt', 'SunamoCsproj',
    'SunamoCssGenerator', 'SunamoCsv', 'SunamoData', 'SunamoDateTime', 'SunamoDebugCollection',
    'SunamoDebugging', 'SunamoDebugIO', 'SunamoDelegates', 'SunamoDependencyInjection',
    'SunamoDevCode', 'SunamoDictionary', 'SunamoDotnetCmdBuilder', 'SunamoDotNetZip',
    'SunamoEditorConfig', 'SunamoEmbeddedResources', 'SunamoEmoticons', 'SunamoEnums',
    'SunamoEnumsHelper', 'SunamoExceptions', 'SunamoExtensions', 'SunamoFileExtensions',
    'SunamoFileIO', 'SunamoFilesIndex', 'SunamoFileSystem', 'SunamoFluentFtp', 'SunamoFtp',
    'SunamoGetFiles', 'SunamoGetFolders', 'SunamoGitConfig', 'SunamoGoogleMyMaps',
    'SunamoGoogleSheets', 'SunamoGpx', 'SunamoHtml', 'SunamoHttp', 'SunamoIni',
    'SunamoInterfaces', 'SunamoJson', 'SunamoLang', 'SunamoLaTeX', 'SunamoLogging',
    'SunamoLogMessage', 'SunamoMail', 'SunamoMarkdown', 'SunamoMathpix', 'SunamoMime',
    'SunamoMsgReader', 'SunamoMsSqlServer', 'SunamoNuGetProtocol', 'SunamoNumbers',
    'SunamoOctokit', 'SunamoPackageJson', 'SunamoParsing', 'SunamoPaths',
    'SunamoPercentCalculator', 'SunamoPInvoke', 'SunamoPlatformUwpInterop', 'SunamoPS',
    'SunamoRandom', 'SunamoReflection', 'SunamoRegex', 'SunamoResult', 'SunamoRobotsTxt',
    'SunamoRoslyn', 'SunamoRss', 'SunamoRuleset', 'SunamoSecurity', 'SunamoSelenium',
    'SunamoSerializer', 'SunamoShared', 'SunamoSolutionsIndexer', 'SunamoStopwatch',
    'SunamoString', 'SunamoStringData', 'SunamoStringFormat', 'SunamoStringGetLines',
    'SunamoStringGetString', 'SunamoStringJoin', 'SunamoStringJoinPairs', 'SunamoStringParts',
    'SunamoStringReplace', 'SunamoStringSplit', 'SunamoStringSubstring', 'SunamoStringTrim',
    'SunamoTest', 'SunamoText', 'SunamoTextIndexing', 'SunamoTextOutputGenerator',
    'SunamoThisApp', 'SunamoThread', 'SunamoThreading', 'SunamoTidy', 'SunamoToUnixLineEnding',
    'SunamoTwoWayDictionary', 'SunamoTypes', 'SunamoUnderscore', 'SunamoUri',
    'SunamoUriWebServices', 'SunamoValues', 'SunamoVcf', 'SunamoWikipedia', 'SunamoWinStd',
    'SunamoWpf', 'SunamoXlfKeys', 'SunamoXliffParser', 'SunamoXml', 'SunamoYaml', 'SunamoYouTube'
)

# Get local projects
$localProjects = Get-ChildItem -Directory -Filter 'Sunamo*' | Where-Object { $_.Name -notlike '.*' } | Select-Object -ExpandProperty Name

Write-Host "NuGet projects: $($nugetProjects.Count)"
Write-Host "Local projects: $($localProjects.Count)`n"

# Find projects in local but NOT in NuGet
$localOnly = $localProjects | Where-Object { $_ -notin $nugetProjects }

# Find projects in NuGet but NOT in local
$nugetOnly = $nugetProjects | Where-Object { $_ -notin $localProjects }

Write-Host "=========================================="
Write-Host "Projects in LOCAL but NOT on NuGet: $($localOnly.Count)"
Write-Host "==========================================`n"
if ($localOnly.Count -gt 0) {
    $localOnly | Sort-Object | ForEach-Object { Write-Host "  - $_" }
}

Write-Host "`n=========================================="
Write-Host "Projects on NuGet but NOT in LOCAL: $($nugetOnly.Count)"
Write-Host "==========================================`n"
if ($nugetOnly.Count -gt 0) {
    $nugetOnly | Sort-Object | ForEach-Object { Write-Host "  - $_" }
}
