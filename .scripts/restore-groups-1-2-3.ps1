# Projects from Groups 1, 2, 3
$projects = @(
    # Group 1
    "SunamoAI",
    "SunamoArgs",
    "SunamoAsync",
    "SunamoAttributes",
    "SunamoAzureDevOpsApi",
    "SunamoBazosCrawler",
    "SunamoBts",
    "SunamoChar",
    "SunamoCl",
    "SunamoClearScript",

    # Group 2
    "SunamoClipboanrd",
    "SunamoCollectionOnDrive",
    "SunamoCollections",
    "SunamoCollectionsChangeContent",
    "SunamoCollectionsGeneric",
    "SunamoCollectionsIndexesWithNull",
    "SunamoCollectidonsNonGeneric",
    "SunamoCollectionsTo",
    "SunamoCollectionsValuesTableGrid",
    "SunamoCollectionWithoutDuplicates",

    # Group 3
    "SunamoColors",
    "SunamoCompare",
    "SunamoConverters",
    "SunamoCrypt",
    "SunamoCsproj",
    "SunamoCssGenerator",
    "SunamoCsv",
    "SunamoData",
    "SunamoDateTime",
    "SunamoDebugCollection"
)

Write-Host "Starting restore for 30 projects (Groups 1, 2, 3)..." -ForegroundColor Cyan
Write-Host "Cutoff date: 2025-12-27" -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date

# Call the restore script with all projects
& "$PSScriptRoot\restore-variables-ok-simple.ps1" -Projects $projects

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host ""
Write-Host "Total time: $($duration.TotalSeconds) seconds" -ForegroundColor Cyan
