# Comment out broken global usings in GlobalUsings.cs files

$brokenUsings = @(
    'SunamoExtensions.Helpers',
    'SunamoExtensions._System',
    'SunamoGetFolders._sunamo.SunamoFileSystem',
    'SunamoGetFolders._sunamo.SunamoGetFiles',
    'SunamoParsing._sunamo.SunamoNumbers',
    'SunamoXml._sunamo.SunamoCollectionsGeneric',
    'SunamoWikipedia._sunamo.SunamoDictionary',
    'SunamoWikipedia._sunamo.SunamoString',
    'SunamoWikipedia._sunamo.SunamoStringSplit',
    'SunamoWinStd._sunamo.SunamoDictionary',
    'SunamoWinStd._sunamo.SunamoStringParts',
    'SunamoWinStd._sunamo.SunamoStringTrim',
    'SunamoValues._sunamo.SunamoCollections'
)

$filesUpdated = 0

Get-ChildItem -Path . -Filter "GlobalUsings.cs" -Recurse | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw
    $originalContent = $content

    foreach ($broken in $brokenUsings) {
        $pattern = "global using $broken;"
        $replacement = "// global using $broken;"
        $content = $content -replace [regex]::Escape($pattern), $replacement
    }

    if ($content -ne $originalContent) {
        Set-Content -Path $file -Value $content -NoNewline
        Write-Host "Updated: $file"
        $filesUpdated++
    }
}

Write-Host "`nTotal files updated: $filesUpdated"
