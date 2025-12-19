param(
    [string]$Path = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollections\SunamoCollections"
)

$files = Get-ChildItem -Path $Path -Filter '*.cs' -Recurse | Where-Object {
    $_.FullName -notmatch '\\obj\\' -and
    $_.FullName -notmatch '\\bin\\' -and
    $_.Name -ne 'GlobalUsings.cs'
}

$added = 0

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue

    # Check if already has marker
    if ($content -like '*// variables names: ok*') {
        continue
    }

    # Check if has header
    if ($content -match '// EN: Variable names have been checked') {
        # Add marker at the beginning
        $newContent = "// variables names: ok`r`n" + $content
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "Added marker to: $($file.Name)" -ForegroundColor Green
        $added++
    }
}

Write-Host "`nTotal files updated: $added" -ForegroundColor Cyan
