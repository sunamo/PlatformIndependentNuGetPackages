# Test empty class detection on specific file

$testFile = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCssGenerator\SunamoCssGenerator\_sunamo\StringBuilderExtensions.cs"

Write-Host "Testing file: $testFile" -ForegroundColor Cyan
Write-Host ""

$content = Get-Content $testFile -Raw

Write-Host "Original content:" -ForegroundColor Yellow
Write-Host $content
Write-Host ""

# Remove all comments (including #region/#endregion) and whitespace
$withoutComments = $content `
    -replace '//.*?(\r?\n|$)', '' `
    -replace '/\*.*?\*/', '' `
    -replace '#region.*?(\r?\n|$)', '' `
    -replace '#endregion.*?(\r?\n|$)', '' `
    -replace '\s+', ''

Write-Host "After removing comments and whitespace:" -ForegroundColor Yellow
Write-Host $withoutComments
Write-Host ""

# Remove using directives and namespace declarations
# EN: Handle both file-scoped (namespace X;) and block-scoped (namespace X { }) namespaces
# CZ: Zpracuj jak file-scoped (namespace X;) tak block-scoped (namespace X { }) namespaces
$classContent = $withoutComments `
    -replace 'using[^;]+;', '' `
    -replace 'namespace[^;{]+;', '' `
    -replace 'namespace[^{]+\{', '' `
    -replace '\}$', ''

Write-Host "After removing using/namespace:" -ForegroundColor Yellow
Write-Host $classContent
Write-Host ""

# Check for empty class
$hasClassDeclaration = $classContent -match 'class'

# Test each pattern individually to see what matches
Write-Host "Testing individual patterns:" -ForegroundColor Yellow
$patterns = @(
    'void', 'int', 'string', 'bool', 'double', 'float', 'decimal', 'long', 'byte', 'char', 'object',
    'Task', 'List', 'Dictionary', 'async', 'override', 'virtual', 'const', 'get', 'set', 'return', 'new',
    '=\w', ';\w'
)
foreach ($pattern in $patterns) {
    if ($classContent -match $pattern) {
        Write-Host "  MATCH: $pattern" -ForegroundColor Red
    }
}
Write-Host ""

$hasMembers = $classContent -match '(\{(get|set);|\breturn\s+|\bnew\s+[\w<>]+\(|=[\w"(]|\w+\s+\w+\s*[=;(]|override\s+|virtual\s+|async\s+\w+\s*\()'

Write-Host "Has class declaration: $hasClassDeclaration" -ForegroundColor Cyan
Write-Host "Has members: $hasMembers" -ForegroundColor Cyan
Write-Host ""

if ($hasClassDeclaration -and -not $hasMembers) {
    Write-Host "RESULT: This is an EMPTY CLASS!" -ForegroundColor Green
} else {
    Write-Host "RESULT: This is NOT an empty class" -ForegroundColor Red
}
