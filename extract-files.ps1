$json = Get-Content 'E:\vs\Projects\PlatformIndependentNuGetPackages\verification-results.json' | ConvertFrom-Json
$json.hasCommentButStillHasShortVars | Out-File 'E:\vs\Projects\PlatformIndependentNuGetPackages\files-to-refactor-1.txt' -Encoding utf8
$json.noCommentButHasShortVars | Out-File 'E:\vs\Projects\PlatformIndependentNuGetPackages\files-to-refactor-2.txt' -Encoding utf8
Write-Host "Extracted files to files-to-refactor-1.txt and files-to-refactor-2.txt"
