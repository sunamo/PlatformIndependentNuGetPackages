#!/usr/bin/env pwsh
# Script to remove C# files that contain only comments or no functional code

param(
    [switch]$Force = $false,
    [switch]$DryRun = $true
)

$rootPath = Split-Path -Parent $PSScriptRoot

Write-Host "Step 1: Finding files with only comments or no functional code..." -ForegroundColor Cyan
Write-Host ""

$emptyFiles = @()

# Get all submodules
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object { $_ -replace '^submodule\..*\.path ', '' }

foreach ($submodule in $submodules) {
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        Write-Host "Skipping non-existent submodule: $submodule" -ForegroundColor DarkGray
        continue
    }

    Write-Host "Checking submodule: $submodule" -ForegroundColor Gray

    Get-ChildItem -Path $submodulePath -Filter "*.cs" -Recurse | ForEach-Object {
        $filePath = $_.FullName
        $content = Get-Content $filePath -Raw

        # Skip files with null/empty content
        if ([string]::IsNullOrEmpty($content)) {
            $emptyFiles += [PSCustomObject]@{
                File = $filePath.Replace($rootPath, "").TrimStart('\')
                FullPath = $filePath
                Reason = "Empty file"
            }
            return
        }

        # Skip files with "variables names: ok" comment
        if ($content -match "//\s*variables\s+names:\s*ok") {
            return
        }

        # Remove all comments (single-line, multi-line, XML doc comments)
        $cleanContent = $content -replace '///.*', '' -replace '//.*', '' -replace '/\*[\s\S]*?\*/', ''

        # Remove using directives (metadata, not functional code)
        $cleanContent = $cleanContent -replace 'using\s+[\w\.]+\s*;', ''

        # Remove namespace declarations (keep only body)
        $cleanContent = $cleanContent -replace 'namespace\s+[\w\.]+\s*\{', ''

        # Remove whitespace
        $cleanContent = $cleanContent -replace '\s', ''

        # Check if only empty braces or completely empty
        if ($cleanContent -eq '' -or $cleanContent -eq '{}') {
            $emptyFiles += [PSCustomObject]@{
                File = $filePath.Replace($rootPath, "").TrimStart('\')
                FullPath = $filePath
                Reason = "Only comments/no functional code"
            }
        }
    }
}

if ($emptyFiles.Count -eq 0) {
    Write-Host "No files with only comments found!" -ForegroundColor Green
    exit 0
}

Write-Host "Found $($emptyFiles.Count) file(s) with only comments or no functional code" -ForegroundColor Yellow
Write-Host ""

Write-Host "Step 2: Loading all .cs files for usage checking..." -ForegroundColor Cyan

# Load all .cs files and their content once (optimization)
$allFiles = @{}
foreach ($submodule in $submodules) {
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        continue
    }

    Get-ChildItem -Path $submodulePath -Filter "*.cs" -Recurse | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        if (-not [string]::IsNullOrEmpty($content)) {
            $allFiles[$_.FullName] = $content
        }
    }
}

Write-Host "Loaded $($allFiles.Count) files" -ForegroundColor Gray
Write-Host ""
Write-Host "Step 3: Checking which files are used elsewhere..." -ForegroundColor Cyan
Write-Host ""

$usedFiles = @()
$unusedFiles = @()

foreach ($file in $emptyFiles) {
    # Extract potential class/interface/struct/enum names from the file
    $content = Get-Content $file.FullPath -Raw
    $typeNames = @()

    # Find all type declarations
    $typeMatches = [regex]::Matches($content, '(?:public|internal|private|protected)?\s*(?:static|sealed|abstract|partial)?\s*(?:class|interface|struct|enum)\s+(\w+)')
    foreach ($match in $typeMatches) {
        $typeNames += $match.Groups[1].Value
    }

    if ($typeNames.Count -eq 0) {
        # No types found, safe to remove
        $unusedFiles += $file
        continue
    }

    # Search for usage of any type from this file in all loaded files
    $found = $false
    foreach ($typeName in $typeNames) {
        $searchPattern = "\b$typeName\b"

        foreach ($filePath in $allFiles.Keys) {
            # Skip the file itself
            if ($filePath -eq $file.FullPath) {
                continue
            }

            if ($allFiles[$filePath] -match $searchPattern) {
                $found = $true
                break
            }
        }

        if ($found) {
            break
        }
    }

    if ($found) {
        $usedFiles += $file
    } else {
        $unusedFiles += $file
    }
}

Write-Host "Used files (will NOT be removed): $($usedFiles.Count)" -ForegroundColor Yellow
if ($usedFiles.Count -gt 0) {
    $usedFiles | ForEach-Object {
        Write-Host "  $($_.File)" -ForegroundColor DarkYellow
        Write-Host "    Reason: $($_.Reason)" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "Unused files (will be removed): $($unusedFiles.Count)" -ForegroundColor Green
if ($unusedFiles.Count -gt 0) {
    $unusedFiles | ForEach-Object {
        Write-Host "  $($_.File)" -ForegroundColor White
        Write-Host "    Reason: $($_.Reason)" -ForegroundColor Gray
    }
    Write-Host ""
}

if ($unusedFiles.Count -eq 0) {
    Write-Host "All files are used somewhere. Nothing to remove." -ForegroundColor Green
    exit 0
}

Write-Host "Step 4: Removing unused files..." -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN: Would remove these $($unusedFiles.Count) files (use -DryRun:`$false to actually remove):" -ForegroundColor Magenta
    $unusedFiles | ForEach-Object {
        Write-Host "  Would remove: $($_.File)" -ForegroundColor DarkGray
    }
    Write-Host ""
} else {
    if ($Force) {
        Write-Host "Removing $($unusedFiles.Count) unused files..." -ForegroundColor Red
        $unusedFiles | ForEach-Object {
            Write-Host "  Removing: $($_.File)" -ForegroundColor DarkRed
            Remove-Item -Path $_.FullPath -Force
        }
        Write-Host ""
        Write-Host "Done! Removed $($unusedFiles.Count) file(s)." -ForegroundColor Green
    } else {
        Write-Host "ERROR: Use -Force to confirm removal" -ForegroundColor Red
        Write-Host "Example: .\remove-comment-only-files.ps1 -DryRun:`$false -Force" -ForegroundColor Yellow
        exit 1
    }
}
