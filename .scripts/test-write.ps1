$file = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollections\SunamoCollections\CA.cs"
$lines = Get-Content $file

Write-Host "Original line 8: $($lines[7])"

# Try simple replacement
$testLine = $lines[7]

# Find what's between > and )
$gtPos = $testLine.IndexOf(">", $testLine.IndexOf("("))
$parenPos = $testLine.IndexOf(")")
$between = $testLine.Substring($gtPos, $parenPos - $gtPos + 1)
Write-Host "Between '>' and ')': '$between'"
$betweenBytes = [System.Text.Encoding]::UTF8.GetBytes($between)
Write-Host "All bytes between > and ): $($betweenBytes -join ', ')"

# Check each character
Write-Host "`nCharacter analysis:"
for ($i = 0; $i -lt $between.Length; $i++) {
    $ch = $between[$i]
    $byte = $betweenBytes[$i]
    Write-Host "  [$i] char='$ch' byte=$byte dec=$([int]$ch)"
}

$newLine = $testLine.Replace("List<string> List", "List<string> list")

Write-Host "After replacement: $newLine"

# Check lengths
Write-Host "Original length: $($testLine.Length)"
Write-Host "New length: $($newLine.Length)"

# Check bytes at parameter position in both strings
$origBytes = [System.Text.Encoding]::UTF8.GetBytes($testLine.Substring(63, 4))
$newBytes = [System.Text.Encoding]::UTF8.GetBytes($newLine.Substring(63, 4))
Write-Host "Original param bytes: $($origBytes -join ', ')"
Write-Host "New param bytes: $($newBytes -join ', ')"

# Check exact bytes at the position where "List" parameter should be
$paramStart = $testLine.IndexOf("List", $testLine.IndexOf("("))
Write-Host "Parameter 'List' starts at position: $paramStart"
if ($paramStart -ge 0) {
    $param = $testLine.Substring($paramStart, 4)
    Write-Host "Parameter substring: '$param'"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($param)
    Write-Host "Bytes: $($bytes -join ', ')"
}

Write-Host "Are they equal (case-insensitive -eq)? $($testLine -eq $newLine)"
Write-Host "Are they equal (case-sensitive -ceq)? $($testLine -ceq $newLine)"

if ($testLine -cne $newLine) {
    Write-Host "Replacement worked!" -ForegroundColor Green
    $lines[7] = $newLine

    # Try to write the file
    try {
        [System.IO.File]::WriteAllLines($file, $lines, [System.Text.UTF8Encoding]::new($false))
        Write-Host "File written successfully!" -ForegroundColor Green

        # Read back to verify
        $verifyLines = Get-Content $file
        Write-Host "Verified line 8: $($verifyLines[7])"
    } catch {
        Write-Host "Error writing file: $_" -ForegroundColor Red
    }
} else {
    Write-Host "No replacement happened" -ForegroundColor Red
}
