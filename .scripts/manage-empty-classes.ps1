#!/usr/bin/env pwsh
# EN: Find, analyze, and manage empty C# classes with various options
# CZ: Najdi, analyzuj a spravuj prázdné C# třídy s různými možnostmi
#
# Usage examples:
#   .\manage-empty-classes.ps1 -DryRun                          # Find and list (dry run) in all submodules
#   .\manage-empty-classes.ps1 -Submodule "SunamoAsync"         # Work only in SunamoAsync submodule
#   .\manage-empty-classes.ps1 -ListOnly                        # Just list, no actions
#   .\manage-empty-classes.ps1 -OpenInVS                        # Open in Visual Studio
#   .\manage-empty-classes.ps1 -OpenInCursor                    # Open in Cursor (batches of 20)
#   .\manage-empty-classes.ps1 -Remove -Force                   # Remove unused empty files (requires Force)
#   .\manage-empty-classes.ps1 -AutoDelete                      # Auto-delete ALL empty classes (even if used!)
#   .\manage-empty-classes.ps1 -AutoDelete -CheckUsage $false   # Skip usage check and delete all empty classes
#   .\manage-empty-classes.ps1 -Submodule "SunamoDateTime" -Remove -Force  # Remove in specific submodule

param(
    [string]$Submodule = "",           # Submodule name to work in (empty = all submodules)
    [switch]$Force = $false,           # Confirm removal without prompt
    [switch]$DryRun = $false,          # Dry run mode (default false - actually executes)
    [switch]$OpenInVS = $false,        # Open files in Visual Studio
    [switch]$OpenInCursor = $false,    # Open files in Cursor (batches)
    [switch]$Remove = $false,          # Remove empty class files
    [switch]$AutoDelete = $false,      # Automatically delete truly empty classes (only comments/whitespace)
    [switch]$ListOnly = $false,        # Only list files, no actions
    [switch]$SkipConfirmation = $false,# Skip confirmation prompts
    [switch]$CheckUsage = $false       # Check if classes are used elsewhere (default false - skip for speed)
)

# Check if running in PowerShell 7+ and -OpenInVS is specified
# DTE automation works better in Windows PowerShell 5.1
if ($PSVersionTable.PSVersion.Major -ge 7 -and $OpenInVS) {
    Write-Host "Detected PowerShell 7+ with -OpenInVS - Relaunching in Windows PowerShell 5.1 for better COM compatibility..." -ForegroundColor Yellow

    $powershellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    if (Test-Path $powershellPath) {
        $scriptPath = $MyInvocation.MyCommand.Path

        $arguments = @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', $scriptPath
        )
        if ($Submodule) { $arguments += '-Submodule', $Submodule }
        if ($Force) { $arguments += '-Force' }
        if (-not $DryRun) { $arguments += '-DryRun:$false' }
        if ($OpenInVS) { $arguments += '-OpenInVS' }
        if ($OpenInCursor) { $arguments += '-OpenInCursor' }
        if ($Remove) { $arguments += '-Remove' }
        if ($AutoDelete) { $arguments += '-AutoDelete' }
        if ($ListOnly) { $arguments += '-ListOnly' }
        if ($SkipConfirmation) { $arguments += '-SkipConfirmation' }
        if (-not $CheckUsage) { $arguments += '-CheckUsage:$false' }

        & $powershellPath @arguments
        exit $LASTEXITCODE
    } else {
        Write-Warning "Windows PowerShell 5.1 not found. Continuing with PowerShell 7+ (COM may not work correctly)..."
    }
}

$rootPath = Split-Path -Parent $PSScriptRoot

# ============================================
# FUNCTIONS FOR VS OPENING
# ============================================

# Test if Visual Studio DTE is available in Running Object Table (ROT)
function Test-DTEAvailability {
    param([int]$ProcessId)

    $progIds = @(
        "VisualStudio.DTE.18.0",              # VS 2026
        "!VisualStudio.DTE.18.0:$ProcessId",  # VS 2026 (process-specific)
        "VisualStudio.DTE.17.0",              # VS 2022
        "!VisualStudio.DTE.17.0:$ProcessId",  # VS 2022 (process-specific)
        "VisualStudio.DTE"                    # Generic fallback
    )

    foreach ($progId in $progIds) {
        try {
            $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)
            if ($dte) {
                return @{
                    Available = $true
                    ProgID = $progId
                    DTE = $dte
                }
            }
        } catch {
            # Continue to next ProgID
        }
    }

    return @{
        Available = $false
        ProgID = $null
        DTE = $null
    }
}

# Open files using DTE automation (preferred method)
function Open-FilesViaDTE {
    param(
        [object]$DTE,
        [array]$FilesToOpen
    )

    Write-Host "`n=== Using DTE automation method ===" -ForegroundColor Cyan
    Write-Host "Opening $($FilesToOpen.Count) files via DTE..." -ForegroundColor Cyan
    Write-Host ""

    $counter = 0
    $vsViewKindTextView = "{7651A701-06E5-11D1-8EBD-00A0C90F26EA}"

    foreach ($file in $FilesToOpen) {
        $counter++
        Write-Host "  [$counter/$($FilesToOpen.Count)] Opening: $(Split-Path -Leaf $file)" -ForegroundColor Gray

        if ($null -eq $DTE -or $null -eq $DTE.ItemOperations) {
            Write-Host "    ERROR: DTE reference lost!" -ForegroundColor Red
            return $false
        }

        try {
            $result = $DTE.ItemOperations.OpenFile($file, $vsViewKindTextView)
            if ($null -eq $result) {
                Write-Host "      Warning: OpenFile returned null" -ForegroundColor Yellow
            }
            Start-Sleep -Milliseconds 100
        } catch {
            Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "Done! Opened $($FilesToOpen.Count) file(s) via DTE." -ForegroundColor Green
    return $true
}

# Open files using devenv.exe /Edit (fallback method)
function Open-FilesViaDevenvEdit {
    param(
        [string]$DevenvPath,
        [array]$FilesToOpen
    )

    Write-Host "`n=== Using devenv.exe /Edit method (fallback) ===" -ForegroundColor Cyan
    Write-Host ""

    $batchSize = 20
    $totalFiles = $FilesToOpen.Count
    $batchCount = [Math]::Ceiling($totalFiles / $batchSize)

    Write-Host "Opening $totalFiles file(s) in $batchCount batch(es)..." -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $batchCount; $i++) {
        $start = $i * $batchSize
        $end = [Math]::Min($start + $batchSize, $totalFiles)
        $batch = $FilesToOpen[$start..($end - 1)]

        Write-Host "Batch $($i + 1)/$batchCount : Opening $($batch.Count) file(s)..." -ForegroundColor Yellow

        $arguments = @('/Edit') + $batch

        try {
            Start-Process -FilePath $DevenvPath -ArgumentList $arguments -Wait:$false
            Write-Host "  Started devenv.exe /Edit for batch $($i + 1)" -ForegroundColor Green

            if ($i -lt $batchCount - 1) {
                Write-Host "  Waiting 2 seconds before next batch..." -ForegroundColor Gray
                Start-Sleep -Seconds 2
            }
        } catch {
            Write-Host "  ERROR: Failed to start devenv.exe: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "Done! Files should be opening in Visual Studio." -ForegroundColor Green
}

# ============================================
# END FUNCTIONS
# ============================================

# Determine search path based on Submodule parameter
$submodulesToProcess = @()

if ([string]::IsNullOrEmpty($Submodule)) {
    # Find all submodules (directories in root, excluding special folders)
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "EMPTY C# CLASSES MANAGER" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Finding all submodules..." -ForegroundColor Cyan

    $allDirs = Get-ChildItem -Path $rootPath -Directory | Where-Object {
        $_.Name -notmatch '^\.' -and  # Skip .git, .scripts, etc.
        $_.Name -ne 'bin' -and
        $_.Name -ne 'obj' -and
        $_.Name -ne 'packages'
    }

    foreach ($dir in $allDirs) {
        # Check if it's a C# project (has .csproj or .cs files)
        $hasCsFiles = (Get-ChildItem -Path $dir.FullName -Filter "*.cs" -Recurse -ErrorAction SilentlyContinue).Count -gt 0
        if ($hasCsFiles) {
            $submodulesToProcess += [PSCustomObject]@{
                Name = $dir.Name
                Path = $dir.FullName
            }
        }
    }

    Write-Host "Found $($submodulesToProcess.Count) submodules with C# files" -ForegroundColor Green
    Write-Host ""
} else {
    # Single submodule specified
    $searchPath = Join-Path $rootPath $Submodule
    if (-not (Test-Path $searchPath)) {
        Write-Host "ERROR: Submodule '$Submodule' not found at: $searchPath" -ForegroundColor Red
        exit 1
    }
    $submodulesToProcess += [PSCustomObject]@{
        Name = $Submodule
        Path = $searchPath
    }

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "EMPTY C# CLASSES MANAGER" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Working on submodule: $Submodule" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Step 1: Finding empty classes..." -ForegroundColor Cyan
Write-Host ""

$emptyClasses = @()

# Process each submodule
for ($i = 0; $i -lt $submodulesToProcess.Count; $i++) {
    $searchPath = $submodulesToProcess[$i].Path
    $submoduleName = $submodulesToProcess[$i].Name

    if ($submodulesToProcess.Count -gt 1) {
        Write-Host "  Scanning: $submoduleName..." -ForegroundColor Gray
    }

    Get-ChildItem -Path $searchPath -Filter "*.cs" -Recurse | ForEach-Object {
        $filePath = $_.FullName

        # Skip obj and bin directories
        if ($filePath -match [regex]::Escape("\obj\") -or $filePath -match [regex]::Escape("\bin\")) {
            return
        }

        $content = Get-Content $filePath -Raw -ErrorAction SilentlyContinue

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

                # Remove all comments (single-line, multi-line, XML doc comments), #region directives, and whitespace
                $cleanBody = $classBody -replace '///.*', '' -replace '//.*', '' -replace '/\*[\s\S]*?\*/', '' -replace '#region.*', '' -replace '#endregion.*', '' -replace '\s', ''

                if ($cleanBody -eq '') {
                    $relativePath = $filePath.Replace($rootPath, "").TrimStart('\')
                    $currentSubmoduleName = $relativePath.Split('\')[0]

                    $emptyClasses += [PSCustomObject]@{
                        File = $relativePath
                        Class = $className
                        FullPath = $filePath
                        Submodule = $currentSubmoduleName
                    }
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

# Step 2: Check usage if requested (skip if AutoDelete is enabled)
$usedClasses = @()
$unusedClasses = @()

if ($AutoDelete) {
    Write-Host "AutoDelete mode: All empty classes will be deleted without checking usage" -ForegroundColor Yellow
    Write-Host "(Empty classes with only comments/whitespace cannot be functionally used)" -ForegroundColor Gray
    Write-Host ""
    # All empty classes are candidates for deletion
    $unusedClasses = $emptyClasses
} elseif ($CheckUsage) {
    Write-Host "Step 2: Loading all .cs files for usage checking..." -ForegroundColor Cyan

    # Load all .cs files and their content once (optimization)
    $allFiles = @{}
    Get-ChildItem -Path $rootPath -Filter "*.cs" -Recurse | ForEach-Object {
        # Skip obj and bin directories
        if ($_.FullName -match [regex]::Escape("\obj\") -or $_.FullName -match [regex]::Escape("\bin\")) {
            return
        }

        $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        if (-not [string]::IsNullOrEmpty($content)) {
            $allFiles[$_.FullName] = $content
        }
    }

    Write-Host "Loaded $($allFiles.Count) files" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Step 3: Checking which classes are used elsewhere..." -ForegroundColor Cyan
    Write-Host ""

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
            Write-Host "  [$($_.Submodule)] $($_.File)" -ForegroundColor DarkYellow
            Write-Host "    Class: $($_.Class)" -ForegroundColor Gray
        }
        Write-Host ""
    }

    Write-Host "Unused empty classes (candidates for removal): $($unusedClasses.Count)" -ForegroundColor Green
    if ($unusedClasses.Count -gt 0) {
        $unusedClasses | ForEach-Object {
            Write-Host "  [$($_.Submodule)] $($_.File)" -ForegroundColor White
            Write-Host "    Class: $($_.Class)" -ForegroundColor Gray
        }
        Write-Host ""
    }

    if ($unusedClasses.Count -eq 0) {
        Write-Host "All empty classes are used somewhere. Nothing to remove." -ForegroundColor Green
        exit 0
    }
} else {
    Write-Host "Step 2: Skipping usage check (-CheckUsage:`$false)" -ForegroundColor Yellow
    Write-Host ""
    # If not checking usage, all empty classes are candidates
    $unusedClasses = $emptyClasses
}

# Step 3: Handle actions based on parameters
$targetClasses = $unusedClasses

if ($ListOnly) {
    Write-Host "List-only mode. Exiting." -ForegroundColor Yellow
    exit 0
}

# Open in Visual Studio
if ($OpenInVS) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "UPOZORNĚNÍ: NEJDŘÍVE ZAVŘETE VŠECHNY TABY V VS!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""

    if (-not $SkipConfirmation) {
        Write-Host "Stiskněte ENTER pro otevření $($targetClasses.Count) souborů ve Visual Studio..." -ForegroundColor Yellow
        Read-Host
    }

    Write-Host "Opening $($targetClasses.Count) files in Visual Studio..." -ForegroundColor Cyan
    Write-Host ""

    # Find Visual Studio devenv.exe
    $vsEditions = @('Preview', 'Enterprise', 'Professional', 'Community')
    $vsYears = @('18', '2026', '2022')  # 18 = VS 2026 Preview
    $vsPath = $null
    $vsVersionFound = $null

    foreach ($year in $vsYears) {
        foreach ($edition in $vsEditions) {
            $testPath = "C:\Program Files\Microsoft Visual Studio\$year\$edition\Common7\IDE\devenv.exe"
            if (Test-Path $testPath) {
                $vsPath = $testPath
                $vsVersionFound = if ($year -eq '18') { 'VS 2026 Preview' } else { "VS $year" }
                Write-Host "Found $vsVersionFound $edition at: $testPath" -ForegroundColor Green
                break
            }
        }
        if ($vsPath) { break }
    }

    if (-not $vsPath) {
        Write-Host "ERROR: Visual Studio not found!" -ForegroundColor Red
        exit 1
    }

    # Get file paths to open
    $filePaths = $targetClasses | ForEach-Object { $_.FullPath }

    # Try to use DTE automation first (preferred - uses running instance)
    $useDTE = $false
    $dte = $null

    Write-Host "Checking if Visual Studio DTE is available in ROT..." -ForegroundColor Cyan

    $vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
    if ($vsProcesses) {
        Write-Host "Found running VS process (PID: $($vsProcesses[0].Id))" -ForegroundColor Green

        $dteResult = Test-DTEAvailability -ProcessId $vsProcesses[0].Id

        if ($dteResult.Available) {
            Write-Host "  SUCCESS: DTE is available via ProgID: $($dteResult.ProgID)" -ForegroundColor Green
            $dte = $dteResult.DTE
            $useDTE = $true
        } else {
            Write-Host "  DTE NOT available in ROT (common in VS 2026 Preview)" -ForegroundColor Yellow
            Write-Host "  Will use devenv.exe /Edit fallback instead" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  No VS process running yet" -ForegroundColor Yellow
        Write-Host "  Will use devenv.exe /Edit method" -ForegroundColor Yellow
    }

    Write-Host ""

    # Open files using selected method
    if ($useDTE) {
        # Method 1: DTE automation (preferred - uses running instance)
        try {
            $success = Open-FilesViaDTE -DTE $dte -FilesToOpen $filePaths
            if (-not $success) {
                Write-Host "DTE method failed, falling back to devenv.exe /Edit..." -ForegroundColor Yellow
                Open-FilesViaDevenvEdit -DevenvPath $vsPath -FilesToOpen $filePaths
            }
        } catch {
            Write-Host "ERROR: DTE method failed: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Falling back to devenv.exe /Edit method..." -ForegroundColor Yellow
            Open-FilesViaDevenvEdit -DevenvPath $vsPath -FilesToOpen $filePaths
        }
    } else {
        # Method 2: devenv.exe /Edit (fallback)
        Open-FilesViaDevenvEdit -DevenvPath $vsPath -FilesToOpen $filePaths
    }

    Write-Host ""
    Write-Host "=== DONE ===" -ForegroundColor Green

    exit 0
}

# Open in Cursor (batches)
if ($OpenInCursor) {
    if (-not $SkipConfirmation) {
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Yellow
        Write-Host "Open all $($targetClasses.Count) files in Cursor? (ENTER/Y)" -ForegroundColor Yellow
        Write-Host "============================================" -ForegroundColor Yellow
        $confirmation = Read-Host "Continue? (Y/N)"
        if ($confirmation -ne 'Y' -and $confirmation -ne 'y' -and $confirmation -ne '') {
            Write-Host "Cancelled." -ForegroundColor Yellow
            exit 0
        }
    }

    Write-Host ""
    Write-Host "Opening files in Cursor (batches of 20)..." -ForegroundColor Cyan

    $filePaths = $targetClasses | ForEach-Object { $_.FullPath }
    $batchSize = 20
    $totalFiles = $filePaths.Count
    $batchCount = [Math]::Ceiling($totalFiles / $batchSize)
    $filesOpened = 0
    $filesDeleted = 0
    $previousBatch = @()

    for ($i = 0; $i -lt $batchCount; $i++) {
        $start = $i * $batchSize
        $end = [Math]::Min($start + $batchSize, $totalFiles)
        $batch = $filePaths[$start..($end - 1)]

        Write-Host ""
        Write-Host "========== Batch $($i + 1)/$batchCount (files $($start + 1)-$end) ==========" -ForegroundColor Cyan
        $batch | ForEach-Object {
            $relativePath = $_.Replace($rootPath, "").TrimStart('\')
            $submodule = $relativePath.Split('\')[0]
            Write-Host "  [$submodule] $(Split-Path -Leaf $_)" -ForegroundColor Gray
        }

        & cursor $batch
        $filesOpened += $batch.Count
        Write-Host "Opened $($batch.Count) files ($filesOpened/$totalFiles total)" -ForegroundColor Green

        if ($i -lt $batchCount - 1) {
            Write-Host ""
            Write-Host "Open next batch? (ENTER/Y deletes previous batch!)" -ForegroundColor Yellow
            $confirmation = Read-Host "Continue? (Y/N)"
            if ($confirmation -ne 'Y' -and $confirmation -ne 'y' -and $confirmation -ne '') {
                Write-Host "Stopped. Opened $filesOpened/$totalFiles, Deleted $filesDeleted" -ForegroundColor Yellow
                exit 0
            }

            if ($previousBatch.Count -gt 0) {
                Write-Host "Deleting previous $($previousBatch.Count) files..." -ForegroundColor Red
                foreach ($f in $previousBatch) {
                    Remove-Item $f -Force -ErrorAction SilentlyContinue
                    $filesDeleted++
                }
                Write-Host "Deleted $($previousBatch.Count) files" -ForegroundColor Green
            }
        }

        $previousBatch = $batch
    }

    if ($previousBatch.Count -gt 0) {
        Write-Host ""
        Write-Host "Delete last $($previousBatch.Count) files? (ENTER/Y)" -ForegroundColor Red
        $confirmation = Read-Host "Delete? (Y/N)"
        if ($confirmation -eq 'Y' -or $confirmation -eq 'y' -or $confirmation -eq '') {
            foreach ($f in $previousBatch) {
                Remove-Item $f -Force -ErrorAction SilentlyContinue
                $filesDeleted++
            }
            Write-Host "Deleted $($previousBatch.Count) files" -ForegroundColor Green
        }
    }

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "DONE! Opened $filesOpened | Deleted $filesDeleted" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green

    exit 0
}

# AutoDelete: automatically delete truly empty classes
if ($AutoDelete) {
    Write-Host ""
    Write-Host "Step 3: Auto-deleting truly empty classes..." -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        Write-Host "DRY RUN: Would auto-delete these $($targetClasses.Count) files (use -DryRun:`$false to actually remove):" -ForegroundColor Magenta
        $targetClasses | ForEach-Object {
            Write-Host "  Would remove: [$($_.Submodule)] $($_.File)" -ForegroundColor DarkGray
        }
        Write-Host ""
        Write-Host "Tip: Use -AutoDelete -DryRun:`$false to actually remove" -ForegroundColor Cyan
    } else {
        Write-Host "Auto-deleting $($targetClasses.Count) truly empty class files..." -ForegroundColor Red
        Write-Host "(These classes contain only comments/whitespace and cannot be functionally used)" -ForegroundColor Gray
        Write-Host ""
        $targetClasses | ForEach-Object {
            Write-Host "  Removing: [$($_.Submodule)] $($_.File)" -ForegroundColor DarkRed
            Remove-Item -Path $_.FullPath -Force
        }
        Write-Host ""
        Write-Host "Done! Removed $($targetClasses.Count) file(s)." -ForegroundColor Green
    }
    exit 0
}

# Remove files (with usage check)
if ($Remove) {
    Write-Host ""
    Write-Host "Step 4: Removing unused empty classes..." -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        Write-Host "DRY RUN: Would remove these $($targetClasses.Count) files (use -DryRun:`$false to actually remove):" -ForegroundColor Magenta
        $targetClasses | ForEach-Object {
            Write-Host "  Would remove: [$($_.Submodule)] $($_.File)" -ForegroundColor DarkGray
        }
        Write-Host ""
        Write-Host "Tip: Use -Remove -DryRun:`$false -Force to actually remove" -ForegroundColor Cyan
    } else {
        if ($Force) {
            Write-Host "Removing $($targetClasses.Count) unused empty class files..." -ForegroundColor Red
            $targetClasses | ForEach-Object {
                Write-Host "  Removing: [$($_.Submodule)] $($_.File)" -ForegroundColor DarkRed
                Remove-Item -Path $_.FullPath -Force
            }
            Write-Host ""
            Write-Host "Done! Removed $($targetClasses.Count) file(s)." -ForegroundColor Green
        } else {
            Write-Host "ERROR: Use -Force to confirm removal" -ForegroundColor Red
            Write-Host "Example: .\manage-empty-classes.ps1 -Remove -DryRun:`$false -Force" -ForegroundColor Yellow
            exit 1
        }
    }
} else {
    Write-Host ""
    Write-Host "Tip: Use one of these options:" -ForegroundColor Cyan
    Write-Host "  -OpenInVS          Open files in Visual Studio" -ForegroundColor Gray
    Write-Host "  -OpenInCursor      Open files in Cursor (batches)" -ForegroundColor Gray
    Write-Host "  -Remove            Remove empty class files (with usage check)" -ForegroundColor Gray
    Write-Host "  -AutoDelete        Auto-delete truly empty classes (only comments)" -ForegroundColor Gray
    Write-Host "  -ListOnly          Just list files" -ForegroundColor Gray
}
