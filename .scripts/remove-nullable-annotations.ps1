# Get all C# files in SunamoCollections project
$files = Get-ChildItem -Path "SunamoCollections/SunamoCollections" -Filter "*.cs" -Recurse

$count = 0
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content

    # Remove nullable annotations from parameters and return types
    # Match patterns like "string?" or "int?" but not ternary operators
    $content = $content -replace '(\w+)\?\s+([\w<>]+)\s*([,)])', '$1 $2$3'  # Type? paramName,
    $content = $content -replace '(\w+)\?\s+([\w<>]+)\s*$', '$1 $2'           # Type? paramName at end
    $content = $content -replace '(\w+)\?\s+(\w+)\s*=', '$1 $2 ='           # Type? varName =
    $content = $content -replace ':\s*(\w+)\?([,\)\s])', ': $1$2'            # : Type?,
    $content = $content -replace '>\s*(\w+)\?([,\)\s])', '> $1$2'            # > Type?,

    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        $count++
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "`nTotal files updated: $count"
