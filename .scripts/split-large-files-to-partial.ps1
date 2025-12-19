# EN: Split large C# files into partial classes
# CZ: Rozdělí velké C# soubory na partial classes

param(
    [int]$MaxLinesPerFile = 500,
    [int]$LimitFiles = 5,
    [string]$SolutionPath = ".",
    [switch]$DryRun = $false
)

Write-Host "Splitting large C# files into partial classes..." -ForegroundColor Cyan
Write-Host "Max lines per file: $MaxLinesPerFile" -ForegroundColor White
Write-Host "Limit to first: $LimitFiles files" -ForegroundColor White
Write-Host "Dry run: $DryRun" -ForegroundColor White
Write-Host ""

# Find large files
$files = Get-ChildItem -Path $SolutionPath -Filter "*.cs" -Recurse -File | Where-Object {
    $_.FullName -notmatch '\\obj\\' -and
    $_.FullName -notmatch '\\bin\\' -and
    $_.FullName -notmatch '\\.git\\' -and
    $_.FullName -notmatch '\\node_modules\\'
}

$largeFiles = @()

foreach ($file in $files) {
    $lineCount = (Get-Content $file.FullName | Measure-Object -Line).Lines

    if ($lineCount -gt 300) {
        $largeFiles += [PSCustomObject]@{
            Path = $file.FullName
            Lines = $lineCount
            Name = $file.Name
        }
    }
}

$largeFiles = $largeFiles | Sort-Object -Property Lines -Descending | Select-Object -First $LimitFiles

Write-Host "Found $($largeFiles.Count) files to process" -ForegroundColor Green
Write-Host ""

function Split-CSharpFile {
    param(
        [string]$FilePath,
        [int]$MaxLines
    )

    $lines = Get-Content $FilePath
    $content = $lines -join "`n"

    # Check if file contains a class definition
    if ($content -notmatch '(public|internal|private|protected)?\s*(static|abstract|sealed|partial)?\s*class\s+(\w+)') {
        Write-Host "  Skipping - not a class file" -ForegroundColor Yellow
        return $false
    }

    $className = $Matches[3]

    # Find namespace (file-scoped or block-scoped)
    $namespace = ""
    $namespaceStyle = "none"
    if ($content -match 'namespace\s+([\w\.]+);') {
        $namespace = $Matches[1]
        $namespaceStyle = "file-scoped"
    } elseif ($content -match 'namespace\s+([\w\.]+)\s*\{') {
        $namespace = $Matches[1]
        $namespaceStyle = "block-scoped"
    }

    # Find using statements
    $usings = @()
    foreach ($line in $lines) {
        if ($line -match '^\s*using\s+') {
            $usings += $line
        }
    }

    # Find where class starts and ends
    $classStartLine = -1
    $classBodyStartLine = -1
    $classEndLine = $lines.Count - 1

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '(public|internal|private|protected)?\s*(static|abstract|sealed|partial)?\s*class\s+' + $className) {
            $classStartLine = $i
            # Find opening brace
            for ($j = $i; $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match '\{') {
                    $classBodyStartLine = $j + 1
                    break
                }
            }
            break
        }
    }

    if ($classStartLine -eq -1) {
        Write-Host "  Could not find class definition" -ForegroundColor Yellow
        return $false
    }

    # Find last closing brace (end of class)
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        if ($lines[$i] -match '^\}s*$') {
            $classEndLine = $i - 1
            break
        }
    }

    # Extract header comments before namespace
    $headerLines = @()
    foreach ($line in $lines) {
        if ($line -match '^\s*//' -or $line -match '^\s*$') {
            $headerLines += $line
        } elseif ($line -match 'namespace|using') {
            break
        }
    }

    # Get class header
    $classHeaderLines = $lines[$classStartLine..($classBodyStartLine - 1)]

    # Make it partial if not already
    $classHeader = ($classHeaderLines -join "`n") -replace "(class\s+$className)", "partial class $className"

    # Get class body
    $classBody = $lines[$classBodyStartLine..$classEndLine]

    Write-Host "  Class body: $($classBody.Count) lines (total file: $($lines.Count) lines)" -ForegroundColor Cyan

    if ($classBody.Count -le ($MaxLines - 20)) {
        Write-Host "  No split needed - class body fits in one file" -ForegroundColor Yellow

        # Still make it partial
        if (-not $DryRun -and $classHeader -ne ($classHeaderLines -join "`n")) {
            $lines[$classStartLine..($classBodyStartLine - 1)] = $classHeader -split "`n"
            Set-Content -Path $FilePath -Value ($lines -join "`r`n") -Encoding UTF8
            Write-Host "  Made class partial" -ForegroundColor Green
        }
        return $false
    }

    # Calculate how many parts we need
    $reservedLines = 20 # for headers, namespace, class declaration
    $linesPerPart = $MaxLines - $reservedLines
    $partCount = [Math]::Ceiling($classBody.Count / $linesPerPart)

    Write-Host "  Splitting into $partCount files" -ForegroundColor Cyan

    # Create split files
    $directory = Split-Path $FilePath -Parent
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $extension = [System.IO.Path]::GetExtension($FilePath)

    $newFiles = @()

    for ($partIndex = 0; $partIndex -lt $partCount; $partIndex++) {
        $startIdx = $partIndex * $linesPerPart
        $endIdx = [Math]::Min($startIdx + $linesPerPart - 1, $classBody.Count - 1)
        $partBody = $classBody[$startIdx..$endIdx]

        if ($partIndex -eq 0) {
            $newFilePath = $FilePath
        } else {
            $newFilePath = Join-Path $directory "$baseName$partIndex$extension"
        }

        $newContent = @()

        # Add header comments
        $newContent += $headerLines

        # Add namespace
        if ($namespace) {
            if ($namespaceStyle -eq "file-scoped") {
                $newContent += "namespace $namespace;"
            } else {
                $newContent += "namespace $namespace"
                $newContent += "{"
            }
            $newContent += ""
        }

        # Add usings
        $newContent += $usings
        if ($usings.Count -gt 0) {
            $newContent += ""
        }

        # Add class header
        $newContent += $classHeader

        # Add part body
        $newContent += $partBody

        # Close class
        $newContent += "}"

        # Close namespace if block-scoped
        if ($namespaceStyle -eq "block-scoped") {
            $newContent += "}"
        }

        $newFiles += @{
            Path = $newFilePath
            Content = $newContent -join "`r`n"
            Lines = $newContent.Count
            IsNew = ($partIndex -gt 0)
        }
    }

    # Save files
    if (-not $DryRun) {
        foreach ($file in $newFiles) {
            Set-Content -Path $file.Path -Value $file.Content -Encoding UTF8
            if ($file.IsNew) {
                Write-Host "    Created: $(Split-Path $file.Path -Leaf) ($($file.Lines) lines)" -ForegroundColor Green
            } else {
                Write-Host "    Updated: $(Split-Path $file.Path -Leaf) ($($file.Lines) lines)" -ForegroundColor Cyan
            }
        }
    } else {
        foreach ($file in $newFiles) {
            if ($file.IsNew) {
                Write-Host "    Would create: $(Split-Path $file.Path -Leaf) ($($file.Lines) lines)" -ForegroundColor Gray
            } else {
                Write-Host "    Would update: $(Split-Path $file.Path -Leaf) ($($file.Lines) lines)" -ForegroundColor Gray
            }
        }
    }

    return $true
}

$processedCount = 0
$skippedCount = 0
$changedProjects = @{}

foreach ($file in $largeFiles) {
    Write-Host "Processing: $($file.Name) ($($file.Lines) lines)" -ForegroundColor Yellow

    $result = Split-CSharpFile -FilePath $file.Path -MaxLines $MaxLinesPerFile

    if ($result) {
        $processedCount++

        # Track which project this file belongs to
        $relativePath = $file.Path.Replace($PWD.Path, "")
        $parts = $relativePath -split '\\'
        if ($parts.Count -ge 2) {
            $projectName = $parts[1]
            if (-not $changedProjects.ContainsKey($projectName)) {
                $changedProjects[$projectName] = @()
            }
            $changedProjects[$projectName] += $file.Name
        }
    } else {
        $skippedCount++
    }

    Write-Host ""
}

Write-Host ("=" * 80) -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Processed: $processedCount files" -ForegroundColor Green
Write-Host "  Skipped: $skippedCount files" -ForegroundColor Yellow
Write-Host ""

if ($changedProjects.Count -gt 0) {
    Write-Host "Changed projects:" -ForegroundColor Cyan
    foreach ($project in $changedProjects.Keys | Sort-Object) {
        Write-Host "  - $project ($($changedProjects[$project].Count) files)" -ForegroundColor White
        foreach ($fileName in $changedProjects[$project] | Sort-Object) {
            Write-Host "    - $fileName" -ForegroundColor Gray
        }
    }
}

Write-Host ""
if ($DryRun) {
    Write-Host "DRY RUN - No files were modified" -ForegroundColor Yellow
} else {
    Write-Host "Files have been split successfully" -ForegroundColor Green
}
