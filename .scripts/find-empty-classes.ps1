#!/usr/bin/env pwsh
# Script to find and optionally remove empty C# classes

param(
    [switch]$Remove = $false,
    [switch]$DryRun = $true
)

$rootPath = Split-Path -Parent $PSScriptRoot

Write-Host "Searching for empty classes in: $rootPath" -ForegroundColor Cyan
Write-Host ""

$emptyClasses = @()

Get-ChildItem -Path $rootPath -Filter "*.cs" -Recurse | ForEach-Object {
    $filePath = $_.FullName
    $content = Get-Content $filePath -Raw

    # Skip files with null/empty content
    if ([string]::IsNullOrEmpty($content)) {
        return
    }

    # Skip files with "variables names: ok" comment
    if ($content -match "//\s*variables\s+names:\s*ok") {
        return
    }

    # Find all class declarations
    $classMatches = [regex]::Matches($content, '(?:public|internal|private|protected)?\s*(?:static|sealed|abstract)?\s*class\s+(\w+)(?:\s*:\s*[\w\s,<>]+)?\s*\{')

    foreach ($match in $classMatches) {
        $className = $match.Groups[1].Value
        $classStartIndex = $match.Index + $match.Length

        # Find the closing brace for this class
        $braceCount = 1
        $currentIndex = $classStartIndex
        $classEndIndex = -1

        while ($currentIndex -lt $content.Length -and $braceCount -gt 0) {
            $char = $content[$currentIndex]
            if ($char -eq '{') {
                $braceCount++
            } elseif ($char -eq '}') {
                $braceCount--
                if ($braceCount -eq 0) {
                    $classEndIndex = $currentIndex
                    break
                }
            }
            $currentIndex++
        }

        if ($classEndIndex -gt $classStartIndex) {
            # Extract class body
            $classBody = $content.Substring($classStartIndex, $classEndIndex - $classStartIndex)

            # Remove all comments (single-line, multi-line, XML doc comments) and whitespace
            $cleanBody = $classBody -replace '///.*', '' -replace '//.*', '' -replace '/\*[\s\S]*?\*/', '' -replace '\s', ''

            if ($cleanBody -eq '') {
                $emptyClasses += [PSCustomObject]@{
                    File = $filePath.Replace($rootPath, "").TrimStart('\')
                    Class = $className
                    FullPath = $filePath
                }
            }
        }
    }
}

if ($emptyClasses.Count -eq 0) {
    Write-Host "No empty classes found!" -ForegroundColor Green
    exit 0
}

Write-Host "Found $($emptyClasses.Count) empty class(es):" -ForegroundColor Yellow
Write-Host ""

$emptyClasses | ForEach-Object {
    Write-Host "  $($_.File)" -ForegroundColor White
    Write-Host "    Class: $($_.Class)" -ForegroundColor Gray
}

Write-Host ""

if ($Remove) {
    if ($DryRun) {
        Write-Host "DRY RUN: Would remove these files (use -DryRun:`$false to actually remove):" -ForegroundColor Magenta
        $emptyClasses | ForEach-Object {
            Write-Host "  Would remove: $($_.File)" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "Removing empty class files..." -ForegroundColor Red
        $emptyClasses | ForEach-Object {
            Write-Host "  Removing: $($_.File)" -ForegroundColor DarkRed
            Remove-Item -Path $_.FullPath -Force
        }
        Write-Host ""
        Write-Host "Done! Removed $($emptyClasses.Count) file(s)." -ForegroundColor Green
    }
} else {
    Write-Host "Tip: Use -Remove -DryRun:`$false to actually remove these files" -ForegroundColor Cyan
}
