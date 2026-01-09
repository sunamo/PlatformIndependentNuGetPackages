#!/usr/bin/env pwsh
# Script to check and remove empty C# classes

param(
    [switch]$Force = $false,
    [switch]$DryRun = $true,
    [switch]$OpenInVS = $false
)

$rootPath = Split-Path -Parent $PSScriptRoot

Write-Host "Step 1: Finding empty classes..." -ForegroundColor Cyan
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

Write-Host "Found $($emptyClasses.Count) empty class(es)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Step 2: Loading all .cs files for usage checking..." -ForegroundColor Cyan

# Load all .cs files and their content once (optimization)
$allFiles = @{}
Get-ChildItem -Path $rootPath -Filter "*.cs" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if (-not [string]::IsNullOrEmpty($content)) {
        $allFiles[$_.FullName] = $content
    }
}

Write-Host "Loaded $($allFiles.Count) files" -ForegroundColor Gray
Write-Host ""
Write-Host "Step 3: Checking which classes are used elsewhere..." -ForegroundColor Cyan
Write-Host ""

$usedClasses = @()
$unusedClasses = @()

foreach ($class in $emptyClasses) {
    $className = $class.Class

    # Search for usage of this class in all loaded files
    # Look for: new ClassName(), ClassName variable, : ClassName, <ClassName>, etc.
    $searchPattern = "\b$className\b"

    $found = $false
    foreach ($filePath in $allFiles.Keys) {
        # Skip the file where the class is defined
        if ($filePath -eq $class.FullPath) {
            continue
        }

        if ($allFiles[$filePath] -match $searchPattern) {
            $found = $true
            break
        }
    }

    if ($found) {
        $usedClasses += $class
    } else {
        $unusedClasses += $class
    }
}

Write-Host "Used empty classes (will NOT be removed): $($usedClasses.Count)" -ForegroundColor Yellow
if ($usedClasses.Count -gt 0) {
    $usedClasses | ForEach-Object {
        Write-Host "  $($_.File)" -ForegroundColor DarkYellow
        Write-Host "    Class: $($_.Class)" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "Unused empty classes (will be removed): $($unusedClasses.Count)" -ForegroundColor Green
if ($unusedClasses.Count -gt 0) {
    $unusedClasses | ForEach-Object {
        Write-Host "  $($_.File)" -ForegroundColor White
        Write-Host "    Class: $($_.Class)" -ForegroundColor Gray
    }
    Write-Host ""
}

if ($unusedClasses.Count -eq 0) {
    Write-Host "All empty classes are used somewhere. Nothing to remove." -ForegroundColor Green
    exit 0
}

Write-Host "Step 4: Removing unused empty classes..." -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN: Would remove these $($unusedClasses.Count) files (use -DryRun:`$false to actually remove):" -ForegroundColor Magenta
    $unusedClasses | ForEach-Object {
        Write-Host "  Would remove: $($_.File)" -ForegroundColor DarkGray
    }
    Write-Host ""

    if ($OpenInVS) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "UPOZORNĚNÍ: NEJDŘÍVE ZAVŘETE VŠECHNY TABY V VS26!" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Stiskněte ENTER pro otevření souborů ve Visual Studio 2026..." -ForegroundColor Yellow
        Read-Host

        Write-Host "Opening $($unusedClasses.Count) files in Visual Studio 2026..." -ForegroundColor Cyan

        # Find Visual Studio 2026
        $vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
        if (-not (Test-Path $vsPath)) {
            $vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe"
        }
        if (-not (Test-Path $vsPath)) {
            $vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
        }

        if (Test-Path $vsPath) {
            foreach ($class in $unusedClasses) {
                Write-Host "  Opening: $($class.File)" -ForegroundColor Gray
                Start-Process $vsPath -ArgumentList "`"$($class.FullPath)`""
                Start-Sleep -Milliseconds 500
            }
            Write-Host ""
            Write-Host "Done! Opened $($unusedClasses.Count) file(s) in Visual Studio." -ForegroundColor Green
        } else {
            Write-Host "ERROR: Visual Studio 2022/2026 not found at expected location!" -ForegroundColor Red
            Write-Host "Please install Visual Studio or update the path in the script." -ForegroundColor Yellow
        }
    }
} else {
    if ($Force) {
        Write-Host "Removing $($unusedClasses.Count) unused empty class files..." -ForegroundColor Red
        $unusedClasses | ForEach-Object {
            Write-Host "  Removing: $($_.File)" -ForegroundColor DarkRed
            Remove-Item -Path $_.FullPath -Force
        }
        Write-Host ""
        Write-Host "Done! Removed $($unusedClasses.Count) file(s)." -ForegroundColor Green
    } else {
        Write-Host "ERROR: Use -Force to confirm removal" -ForegroundColor Red
        Write-Host "Example: .\remove-empty-classes.ps1 -DryRun:`$false -Force" -ForegroundColor Yellow
        exit 1
    }
}
