$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$slnxPath = "$rootPath\PlatformIndependentNuGetPackages.Runners.slnx"

$content = Get-Content $slnxPath -Raw

$allCsprojs = Get-ChildItem -Path $rootPath -Filter "*.csproj" -Recurse |
    Where-Object { $_.FullName -notmatch [regex]::Escape("\obj\") } |
    ForEach-Object { $_.FullName.Substring($rootPath.Length + 1) }

$missing = $allCsprojs | Where-Object { -not $content.Contains($_) }

Write-Host "Total csproj on disk: $($allCsprojs.Count)" -ForegroundColor Cyan
Write-Host "Missing from slnx: $($missing.Count)" -ForegroundColor $(if ($missing.Count -gt 0) { "Yellow" } else { "Green" })

if ($missing.Count -eq 0) {
    Write-Host "Nothing to add." -ForegroundColor Green
    return
}

foreach ($relativePath in ($missing | Sort-Object)) {
    Write-Host "ADD: $relativePath" -ForegroundColor Yellow

    $parts = $relativePath.Split("\")
    $topLevelDir = $parts[0]
    $folderName = "/$topLevelDir/"
    $projectLine = "    <Project Path=`"$relativePath`" />"

    # Case-insensitive search for existing folder
    $folderMatch = [regex]::Match($content, "(?i)<Folder Name=""/$topLevelDir/"">")
    if ($folderMatch.Success) {
        $existingFolderTag = $folderMatch.Value
        $idx = $content.IndexOf($existingFolderTag)
        $closingIdx = $content.IndexOf("  </Folder>", $idx)
        $content = $content.Substring(0, $closingIdx) + $projectLine + "`n" + $content.Substring($closingIdx)
    } else {
        $newFolder = "  <Folder Name=`"$folderName`">`n$projectLine`n  </Folder>`n"
        $content = $content.Replace("</Solution>", $newFolder + "</Solution>")
    }
}

Set-Content $slnxPath $content -NoNewline -Encoding UTF8
Write-Host "`nSaved. Added $($missing.Count) projects." -ForegroundColor Green
