$projects = @(
    'SunamoRegex',
    'SunamoRoslyn',
    'SunamoReflection',
    'SunamoNumbers',
    'SunamoCollections',
    'SunamoPlatformUwpInterop',
    'SunamoLang',
    'SunamoLogMessage',
    'SunamoEnums',
    'SunamoDelegates',
    'SunamoSolutionsIndexer',
    'SunamoDotNetZip',
    'SunamoTestValues',
    'SunamoTransactionsStatements',
    'SunamoSepaNet',
    'SunamoStringData'
)

foreach ($projectName in $projects) {
    $csproj = Get-ChildItem -Path $projectName -Filter "$projectName.csproj" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($csproj) {
        Write-Host "$projectName : $($csproj.FullName)"
    } else {
        Write-Host "$projectName : NOT FOUND"
    }
}
