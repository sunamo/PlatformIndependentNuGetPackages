# Fix short variable names in all .cs files
# Excludes files with "// variables names: ok" comment
# Excludes obj/ and bin/ folders

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

# Common short variable name patterns to fix
# Format: @{Pattern = regex pattern; Replacement = replacement}
$replacements = @(
    # vr (variable result) -> result
    @{Pattern = '\bvar vr\s*='; Replacement = 'var result ='}
    @{Pattern = '\bList<([^>]+)> vr\s*='; Replacement = 'List<$1> result ='}
    @{Pattern = '\bDictionary<([^,]+),\s*([^>]+)> vr\s*='; Replacement = 'Dictionary<$1, $2> result ='}
    @{Pattern = '\bvr\.'; Replacement = 'result.'}
    @{Pattern = '\breturn vr;'; Replacement = 'return result;'}
    @{Pattern = '\(vr,'; Replacement = '(result,'}
    @{Pattern = ',\s*vr\)'; Replacement = ', result)'}

    # xd (XmlDocument) -> xmlDocument
    @{Pattern = '\bvar xd\s*=\s*new XmlDocument'; Replacement = 'var xmlDocument = new XmlDocument'}
    @{Pattern = '\bXmlDocument xd\s*='; Replacement = 'XmlDocument xmlDocument ='}
    @{Pattern = '\bxd\.'; Replacement = 'xmlDocument.'}
    @{Pattern = '\(xd,'; Replacement = '(xmlDocument,'}
    @{Pattern = '\(xd\)'; Replacement = '(xmlDocument)'}
    @{Pattern = '\breturn xd;'; Replacement = 'return xmlDocument;'}

    # tf (text file / outer XML) -> outerXml or text
    @{Pattern = '\bvar tf\s*=\s*([^;]+\.OuterXml)'; Replacement = 'var outerXml = $1'}
    @{Pattern = '\bstring tf\s*='; Replacement = 'string text ='}
    @{Pattern = '\btf\s*!='; Replacement = 'text !='}
    @{Pattern = '\btf\s*=='; Replacement = 'text =='}

    # ts (toString) -> text or value
    @{Pattern = '\bvar ts\s*=\s*([^;]+\.ToString\(\))'; Replacement = 'var text = $1'}

    # sb (StringBuilder) -> stringBuilder (only if not already proper name)
    @{Pattern = '\bvar sb\s*=\s*new StringBuilder'; Replacement = 'var stringBuilder = new StringBuilder'}
    @{Pattern = '\bStringBuilder sb\s*='; Replacement = 'StringBuilder stringBuilder ='}
    @{Pattern = '\bsb\.'; Replacement = 'stringBuilder.'}
    @{Pattern = '\(sb\.'; Replacement = '(stringBuilder.'}
    @{Pattern = '\(sb\)'; Replacement = '(stringBuilder)'}
    @{Pattern = '\breturn sb;'; Replacement = 'return stringBuilder;'}

    # dx (index) -> foundIndex or index
    @{Pattern = '\bint dx\s*=\s*-1'; Replacement = 'int foundIndex = -1'}
    @{Pattern = '\bvar dx\s*=\s*-1'; Replacement = 'var foundIndex = -1'}
    @{Pattern = '\bint dx\s*=\s*([^;]+\.IndexOf)'; Replacement = 'int foundIndex = $1'}
    @{Pattern = '\bvar dx\s*=\s*([^;]+\.IndexOf)'; Replacement = 'var foundIndex = $1'}
    @{Pattern = '\bdx\s*=\s*([^;]+\.IndexOf)'; Replacement = 'foundIndex = $1'}
    @{Pattern = '\bdx\s*!=\s*-1'; Replacement = 'foundIndex != -1'}
    @{Pattern = '\bdx\s*==\s*-1'; Replacement = 'foundIndex == -1'}
    @{Pattern = '\(dx,'; Replacement = '(foundIndex,'}
    @{Pattern = ',\s*dx\)'; Replacement = ', foundIndex)'}
    @{Pattern = '\bref dx\b'; Replacement = 'ref foundIndex'}
    @{Pattern = '\.Remove\(dx,'; Replacement = '.Remove(foundIndex,'}
    @{Pattern = '\.Insert\(dx,'; Replacement = '.Insert(foundIndex,'}
    @{Pattern = '\.IndexOf\([^,]+,\s*dx\)'; Replacement = '.IndexOf($1, foundIndex)'}

    # dx2 (second index) -> closingTagIndex or secondIndex
    @{Pattern = '\bint dx2\s*=\s*-1'; Replacement = 'int secondIndex = -1'}
    @{Pattern = '\bvar dx2\s*=\s*-1'; Replacement = 'var secondIndex = -1'}
    @{Pattern = '\bint dx2\s*='; Replacement = 'int secondIndex ='}
    @{Pattern = '\bvar dx2\s*='; Replacement = 'var secondIndex ='}
    @{Pattern = '\bdx2\s*='; Replacement = 'secondIndex ='}
    @{Pattern = '\bdx2\)'; Replacement = 'secondIndex)'}
    @{Pattern = '\(dx2,'; Replacement = '(secondIndex,'}

    # ret (return value) -> result or returnValue
    @{Pattern = '\bvar ret\s*='; Replacement = 'var result ='}
    @{Pattern = '\bstring ret\s*='; Replacement = 'string result ='}
    @{Pattern = '\breturn ret;'; Replacement = 'return result;'}

    # fn (file name) -> fileName
    @{Pattern = '\bvar fn\s*='; Replacement = 'var fileName ='}
    @{Pattern = '\bstring fn\s*='; Replacement = 'string fileName ='}

    # fp (file path) -> filePath
    @{Pattern = '\bvar fp\s*='; Replacement = 'var filePath ='}
    @{Pattern = '\bstring fp\s*='; Replacement = 'string filePath ='}

    # nf (new file) -> newFilePath or backupPath
    @{Pattern = '\bvar nf\s*=\s*FS\.InsertBetweenFileNameAndExtension'; Replacement = 'var backupFilePath = FS.InsertBetweenFileNameAndExtension'}

    # lc (line comment) -> commentPrefix
    @{Pattern = '\bvar lc\s*=\s*"//'; Replacement = 'var commentPrefix = "//'}
    @{Pattern = '\.StartsWith\(lc\)'; Replacement = '.StartsWith(commentPrefix)'}
)

Write-Host "Finding .cs files without 'variables names: ok' comment..." -ForegroundColor Cyan

# Find all .cs files that don't have the "variables names: ok" comment
$files = Get-ChildItem -Path $rootPath -Filter "*.cs" -Recurse -File |
    Where-Object {
        $_.FullName -notmatch '\\obj\\' -and
        $_.FullName -notmatch '\\bin\\' -and
        -not (Select-String -Path $_.FullName -Pattern "variables names: ok" -Quiet)
    }

Write-Host "Found $($files.Count) files to process" -ForegroundColor Yellow

$filesModified = 0
$totalReplacements = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fileReplacements = 0

    foreach ($replacement in $replacements) {
        $matches = [regex]::Matches($content, $replacement.Pattern)
        if ($matches.Count -gt 0) {
            $content = $content -replace $replacement.Pattern, $replacement.Replacement
            $fileReplacements += $matches.Count
        }
    }

    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        $filesModified++
        $totalReplacements += $fileReplacements
        Write-Host "Modified: $($file.FullName) ($fileReplacements replacements)" -ForegroundColor Green
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "Files modified: $filesModified" -ForegroundColor Yellow
Write-Host "Total replacements: $totalReplacements" -ForegroundColor Yellow
Write-Host "Done!" -ForegroundColor Green
