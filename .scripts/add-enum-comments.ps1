# EN: Add "// variables names: ok" comment to files containing only enums
# CZ: Přidá komentář "// variables names: ok" do souborů obsahujících pouze enumy

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$comment = "// variables names: ok"

# Find all .cs files
$csFiles = Get-ChildItem -Path $rootPath -Filter "*.cs" -Recurse -File

$enumOnlyFiles = @()

foreach ($file in $csFiles) {
    $content = Get-Content -Path $file.FullName -Raw

    # Skip if already has the comment
    if ($content -match "// variables names: ok") {
        continue
    }

    # Check if file contains only enum (and namespace, using, comments)
    # Remove comments, usings, namespace, whitespace
    $codeOnly = $content -replace '//[^\r\n]*', '' # Remove line comments
    $codeOnly = $codeOnly -replace '/\*[\s\S]*?\*/', '' # Remove block comments
    $codeOnly = $codeOnly -replace 'using\s+[^;]+;', '' # Remove usings
    $codeOnly = $codeOnly -replace 'namespace\s+[^;{]+[;{]', '' # Remove namespace
    $codeOnly = $codeOnly -replace '\s+', ' ' # Normalize whitespace
    $codeOnly = $codeOnly.Trim()

    # Check if only contains enum definitions
    if ($codeOnly -match '^\s*(\[.*?\]\s*)*(public|internal|private|protected)?\s*enum\s+' -and
        $codeOnly -notmatch '\b(class|interface|struct|record)\b' -and
        $codeOnly -notmatch '\bvoid\b|\breturn\b|\bif\b|\bfor\b|\bwhile\b') {

        $enumOnlyFiles += $file

        # Add comment at the beginning
        $newContent = $comment + "`r`n" + $content
        Set-Content -Path $file.FullName -Value $newContent -NoNewline

        Write-Host "✓ Added comment to: $($file.FullName)" -ForegroundColor Green
    }
}

Write-Host "`n✅ Processed $($enumOnlyFiles.Count) enum-only files" -ForegroundColor Cyan
