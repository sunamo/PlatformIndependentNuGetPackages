$file = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollections\SunamoCollections\CA.cs"
$content = Get-Content $file -Raw

Write-Host "=== Testing Regex Patterns ===" -ForegroundColor Cyan

# Test 1: Simple pattern match
if ($content -match 'List<string> List') {
    Write-Host "✓ Found 'List<string> List'" -ForegroundColor Green
} else {
    Write-Host "✗ Did not find 'List<string> List'" -ForegroundColor Red
}

# Test 2: Check for opening paren + List<
if ($content -match '\(List<') {
    Write-Host "✓ Found '(List<'" -ForegroundColor Green
} else {
    Write-Host "✗ Did not find '(List<'" -ForegroundColor Red
}

# Test 3: Try the replacement
$pattern = '\(List<([^>]+)>\s+List\b'
$matches = [regex]::Matches($content, $pattern)
Write-Host "Matches found: $($matches.Count)" -ForegroundColor Yellow

foreach ($match in $matches) {
    Write-Host "  Match: $($match.Value)" -ForegroundColor Cyan
}

# Test 4: Try replacement
$testContent = $content
$before = $testContent.Length
Write-Host "Before replacement length: $before"

$testContent = $testContent -replace '\(List<([^>]+)>\s+List\b', '(List<${1}> list'

$after = $testContent.Length
Write-Host "After replacement length: $after"

if ($testContent -ne $content) {
    Write-Host "✓ Replacement would change content" -ForegroundColor Green
    # Show first difference
    $lines = $testContent.Split("`n")
    $origLines = $content.Split("`n")
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -ne $origLines[$i]) {
            Write-Host "First changed line $i`:" -ForegroundColor Yellow
            Write-Host "  OLD: $($origLines[$i])" -ForegroundColor Red
            Write-Host "  NEW: $($lines[$i])" -ForegroundColor Green
            break
        }
    }
} else {
    Write-Host "✗ Replacement did not change content" -ForegroundColor Red
    Write-Host "Testing alternative replacement..." -ForegroundColor Yellow
    $testContent2 = $content -replace '\(List<string>\s+List\b', '(List<string> list'
    if ($testContent2 -ne $content) {
        Write-Host "✓ Direct pattern works!" -ForegroundColor Green
    }
}
