# Fix remaining line 1142-1144
$filePath = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoString\SunamoString\SH.cs"
$lines = Get-Content -Path $filePath
$fixCount = 0

# Line 1142 (index 1141)
if ($lines[1141] -match 'foreach \(var item in input\)') {
    $lines[1141] = $lines[1141] -replace 'foreach \(var item in input\)', 'foreach (var character in input)'
    Write-Host "Fixed line 1142"
    $fixCount++
}

# Line 1143 (index 1142)
if ($lines[1142] -match 'if \(isWhiteSpace\.Invoke\(item\)\)') {
    $lines[1142] = $lines[1142] -replace 'if \(isWhiteSpace\.Invoke\(item\)\)', 'if (isWhiteSpace.Invoke(character))'
    Write-Host "Fixed line 1143"
    $fixCount++
}

# Line 1144 (index 1143)
if ($lines[1143] -match 'stringBuilder\.Append\(item\);') {
    $lines[1143] = $lines[1143] -replace 'stringBuilder\.Append\(item\);', 'stringBuilder.Append(character);'
    Write-Host "Fixed line 1144"
    $fixCount++
}

$lines | Set-Content -Path $filePath
Write-Host "Applied $fixCount additional fixes"
Write-Host "Done!"
