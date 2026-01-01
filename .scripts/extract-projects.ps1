$inputFile = "D:\Drive\Jira\ZIS-258\CompareTwoFiles\txt\1.txt"

$projects = Get-Content $inputFile | ForEach-Object {
    if ($_ -match '(.+\.csproj)\s*:\s*error NU1202') {
        $Matches[1]
    }
} | Sort-Object -Unique

Write-Host "Found $($projects.Count) unique projects with errors:"
$projects | ForEach-Object { Write-Host "  $_" }

# Return the projects for further processing
$projects
