$output = dotnet build SunamoCollections/RunnerCollections/RunnerCollections.csproj --no-incremental 2>&1 | Select-String -Pattern 'warning CS[0-9]{4}'

$warningCounts = $output | ForEach-Object {
    if ($_ -match 'warning (CS[0-9]{4})') {
        $matches[1]
    }
} | Group-Object | Sort-Object Count -Descending

Write-Host "`nWarning Summary After Disabling XML Documentation:"
$warningCounts | Format-Table -AutoSize Count, Name

Write-Host "`nTotal warnings remaining: $($output.Count)"
