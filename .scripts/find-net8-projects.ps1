$projects = Get-ChildItem -Recurse -Filter '*.csproj' -Path 'E:\vs\Projects\PlatformIndependentNuGetPackages' |
    Where-Object { $_.FullName -match '(Runner|\.Tests)\\' } |
    ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        if ($content -match '<TargetFrameworks?>[^<]*net8\.0') {
            [PSCustomObject]@{
                Project = $_.FullName
                TargetFramework = if ($content -match '<TargetFrameworks?>([^<]+)</TargetFrameworks?>') { $Matches[1] } else { 'NOT FOUND' }
            }
        }
    }

if ($projects.Count -eq 0) {
    Write-Host "No Runner or Tests projects with net8.0 found!" -ForegroundColor Green
} else {
    Write-Host "Found $($projects.Count) projects with net8.0:" -ForegroundColor Yellow
    $projects | Format-Table -AutoSize
}
