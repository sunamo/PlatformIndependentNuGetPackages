# Fix parameter usages inside method bodies after parameter renaming
# This script finds methods with parameter "list" and renames usages of "List" to "list" inside the method body
param(
    [string]$ProjectPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollections"
)

Write-Host "=== Fixing Parameter Usages in Method Bodies ===" -ForegroundColor Cyan

$csFiles = Get-ChildItem -Path $ProjectPath -Filter "*.cs" -Recurse | Where-Object { $_.Name -like "CA*.cs" }
$totalReplacements = 0
$filesModified = 0

foreach ($file in $csFiles) {
    $content = Get-Content $file.FullName -Raw
    if (-not $content) { continue }

    $originalContent = $content

    # Pattern: Find methods with parameter "list" and replace "List." or "List[" with "list." or "list["
    # But only in method bodies, not in type declarations

    # This is complex, so we'll use a simpler approach:
    # Replace "List." and "List[" with "list." and "list[" only when preceded by whitespace or operators
    # And NOT when preceded by "<" (which would be part of a type like "List<string>")

    $content = $content -replace '([^\<])List\.', '$1list.'
    $content = $content -replace '([^\<])List\[', '$1list['
    $content = $content -replace '\breturn List\b', 'return list'
    $content = $content -replace '= List\[', '= list['
    $content = $content -replace '= List\.', '= list.'

    # Only save if content changed
    if ($content -cne $originalContent) {
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.UTF8Encoding]::new($false))
        $filesModified++

        $relativePath = $file.FullName.Replace("$ProjectPath\", "")
        Write-Host "  ✓ $relativePath" -ForegroundColor Green
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Files modified: $filesModified" -ForegroundColor Yellow
Write-Host "`nParameter usage fix complete!" -ForegroundColor Green
