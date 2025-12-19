param(
    [string]$Path = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollections\SunamoCollections"
)

$files = Get-ChildItem -Path $Path -Filter '*.cs' -Recurse | Where-Object {
    $_.FullName -notmatch '\\obj\\' -and
    $_.FullName -notmatch '\\bin\\' -and
    $_.Name -ne 'GlobalUsings.cs'
}

$filesWithoutMarker = @()

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -notlike '*variables names: ok*') {
        $filesWithoutMarker += $file
    }
}

Write-Host "Files without '// variables names: ok' marker:" -ForegroundColor Yellow
Write-Host "Total: $($filesWithoutMarker.Count)" -ForegroundColor Cyan
Write-Host ""

$filesWithoutMarker | ForEach-Object {
    Write-Host $_.FullName
}
