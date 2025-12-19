$content = Get-Content 'E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollections\SunamoCollections\CA.cs' -Raw
$lines = $content -split "`r`n|`n"
$line = $lines | Where-Object { $_ -match 'OccurenceOfEveryLine' }
Write-Host "Line content:"
Write-Host "'$line'"
Write-Host "`n Checking if replacement works..."
$original = $line
$replaced = $line -replace '\(List<([^>]+)>\s+List\b', '(List<${1}> list'
Write-Host "Original: '$original'"
Write-Host "Replaced: '$replaced'"
Write-Host "Are they equal? $($original -eq $replaced)"

# Try simpler replacement
$replaced2 = $line -replace 'List<string> List', 'List<string> list'
Write-Host "`nSimpler replacement:"
Write-Host "Replaced2: '$replaced2'"
Write-Host "Are original and replaced2 equal? $($original -eq $replaced2)"
