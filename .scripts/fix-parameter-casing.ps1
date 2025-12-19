# Fix incorrectly renamed parameters (PascalCase → camelCase)
# This script reverts parameters that were incorrectly renamed by fix-non-private-fields-casing.ps1

param(
    [string]$ProjectPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollections"
)

Write-Host "=== Fixing Parameter Casing in $ProjectPath ===" -ForegroundColor Cyan

# Get all .cs files
$csFiles = Get-ChildItem -Path $ProjectPath -Filter "*.cs" -Recurse

$totalReplacements = 0
$filesModified = 0

foreach ($file in $csFiles) {
    $content = Get-Content $file.FullName -Raw
    if (-not $content) { continue }

    $originalContent = $content
    $fileReplacements = 0

    # Direct replacements for specific parameter patterns
    # These were incorrectly renamed from camelCase to PascalCase by previous script

    # List<T> List → List<T> list (after opening paren)
    if ($content -match '\(List<') {
        $before = $content
        $content = $content -replace '\(List<([^>]+)>\s+List\b', '(List<$1> list'
        if ($content -ne $before) { $fileReplacements++ }
    }

    # , List<T> List → , List<T> list (after comma)
    if ($content -match ',\s*List<') {
        $before = $content
        $content = $content -replace ',(\s*)List<([^>]+)>\s+List\b', ',$1List<$2> list'
        if ($content -ne $before) { $fileReplacements++ }
    }

    # IList<T> List → IList<T> list (after opening paren)
    if ($content -match '\(IList<') {
        $before = $content
        $content = $content -replace '\(IList<([^>]+)>\s+List\b', '(IList<$1> list'
        if ($content -ne $before) { $fileReplacements++ }
    }

    # , IList<T> List → , IList<T> list (after comma)
    if ($content -match ',\s*IList<') {
        $before = $content
        $content = $content -replace ',(\s*)IList<([^>]+)>\s+List\b', ',$1IList<$2> list'
        if ($content -ne $before) { $fileReplacements++ }
    }

    # Only save if content changed
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        $filesModified++
        $totalReplacements += $fileReplacements

        $relativePath = $file.FullName.Replace("$ProjectPath\", "")
        Write-Host "  ✓ $relativePath - $fileReplacements replacements" -ForegroundColor Green
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Files modified: $filesModified" -ForegroundColor Yellow
Write-Host "Total parameter renamings: $totalReplacements" -ForegroundColor Yellow
Write-Host "`nParameter casing fix complete!" -ForegroundColor Green
