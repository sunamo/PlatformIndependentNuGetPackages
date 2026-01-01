$inputFile = "D:\Drive\Jira\ZIS-258\CompareTwoFiles\txt\1.txt"
$outputFile = "D:\Drive\Jira\ZIS-258\CompareTwoFiles\txt\1_errors.txt"

$errors = Get-Content $inputFile | Where-Object {
    $_ -match ': error NU' -and
    $_ -notmatch 'warning.*See also error'
}

$errors | Set-Content $outputFile -Encoding UTF8

Write-Host "Filtered to $($errors.Count) error lines"
Write-Host "Output saved to: $outputFile"

# Now replace the original file
Copy-Item $outputFile $inputFile -Force
Write-Host "Original file replaced with errors only"
