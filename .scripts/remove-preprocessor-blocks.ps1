param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [switch]$WhatIf
)

# Conditions to KEEP as-is (treat as OTHER - preserve both branches)
$KeepConditions = @(
    'NET5_0_OR_GREATER', '!NET5_0_OR_GREATER',
    'NET9_0_OR_GREATER', 'NETCOREAPP2_0',
    'NETSTANDARD2_0', '!NETSTANDARD2_0',
    '!NET8_0', 'NETFX_CORE',
    'WPF', 'WINDOWS_UWP', 'SILVERLIGHT', 'XAMARIN', 'IOS'
)

function Process-File {
    param([string]$FilePath, [switch]$WhatIf)

    # Skip DotNetZip - leave it completely untouched
    if ($FilePath -match [regex]::Escape('\SunamoDotNetZip\')) { return $false }

    $lines = Get-Content -Path $FilePath -Encoding UTF8
    if ($null -eq $lines) { return $false }

    $newLines = [System.Collections.Generic.List[string]]::new()

    # Stack of frame hashtables:
    # Type: ROOT | SKIP | SKIP_INHERITED | ASYNC_MAIN | ASYNC_ELSE | OTHER
    # OutputContent: bool
    # RemoveDirectives: bool
    $stack = [System.Collections.Generic.Stack[hashtable]]::new()
    $stack.Push(@{ Type = 'ROOT'; OutputContent = $true; RemoveDirectives = $false })

    $changed = $false

    foreach ($line in $lines) {
        $trimmed = $line.TrimStart()
        $top = $stack.Peek()

        # Commented-out special directives - remove them
        if ($trimmed -match '^//\s*#\s*if\s+(DEBUG|MB|ASYNC)\s*$') {
            $changed = $true
            continue
        }

        # #if directive - match single token or negated token
        if ($trimmed -match '^#if\s+(!?\w+)\s*$') {
            $condition = $Matches[1]

            if (-not $top.OutputContent) {
                $stack.Push(@{ Type = 'SKIP_INHERITED'; OutputContent = $false; RemoveDirectives = $false })
            }
            elseif ($condition -eq 'ASYNC') {
                $stack.Push(@{ Type = 'ASYNC_MAIN'; OutputContent = $true; RemoveDirectives = $true })
                $changed = $true
            }
            elseif ($KeepConditions -contains $condition) {
                $stack.Push(@{ Type = 'OTHER'; OutputContent = $true; RemoveDirectives = $false })
                $newLines.Add($line)
            }
            else {
                # Unknown/unwanted condition - delete entire block
                $stack.Push(@{ Type = 'SKIP'; OutputContent = $false; RemoveDirectives = $true })
                $changed = $true
            }
            continue
        }

        # #if directive with complex expression (e.g. #if A || B)
        if ($trimmed -match '^#if\s+.+') {
            $complexCond = $trimmed -replace '^#if\s+', ''
            # Delete specific unwanted complex conditions
            if ($complexCond -match '^DEBUG2\s*&&\s*DEBUG$') {
                $stack.Push(@{ Type = 'SKIP'; OutputContent = $false; RemoveDirectives = $true })
                $changed = $true
                continue
            }
            if (-not $top.OutputContent) {
                $stack.Push(@{ Type = 'SKIP_INHERITED'; OutputContent = $false; RemoveDirectives = $false })
            }
            else {
                $stack.Push(@{ Type = 'OTHER'; OutputContent = $true; RemoveDirectives = $false })
                $newLines.Add($line)
            }
            continue
        }

        # #else directive
        if ($trimmed -match '^#else\b') {
            if ($top.Type -eq 'ASYNC_MAIN') {
                $stack.Pop() | Out-Null
                $stack.Push(@{ Type = 'ASYNC_ELSE'; OutputContent = $false; RemoveDirectives = $true })
            }
            elseif ($top.Type -eq 'SKIP' -or $top.Type -eq 'SKIP_INHERITED' -or $top.Type -eq 'ASYNC_ELSE') {
                # Stay in skip, don't output
            }
            else {
                if ($top.OutputContent) { $newLines.Add($line) }
            }
            continue
        }

        # #endif directive
        if ($trimmed -match '^#endif\b') {
            if ($stack.Count -le 1) {
                $newLines.Add($line)
            }
            else {
                $popped = $stack.Pop()
                $top = $stack.Peek()

                if ($popped.RemoveDirectives -or $popped.Type -eq 'SKIP_INHERITED' -or $popped.Type -eq 'SKIP') {
                    # Don't output #endif
                }
                else {
                    if ($top.OutputContent) { $newLines.Add($line) }
                }
            }
            continue
        }

        # Regular line
        if ($top.OutputContent) { $newLines.Add($line) }
    }

    if ($changed) {
        $newContent = $newLines -join "`r`n"
        if ([string]::IsNullOrEmpty($newContent)) {
            Write-Error "Content became empty after processing, skipping: $FilePath"
            return $false
        }
        if (-not $WhatIf) {
            $newLines | Set-Content -Path $FilePath -Encoding UTF8
        }
        Write-Host "  Modified: $FilePath ($($lines.Count) -> $($newLines.Count) lines)" -ForegroundColor Green
        return $true
    }
    return $false
}

Write-Host "Removing #if DEBUG, #if MB blocks; unwrapping #if ASYNC..." -ForegroundColor Cyan
Write-Host ""

$csFiles = @()

if (Test-Path $Path -PathType Leaf) {
    if ($Path -like "*.cs") {
        $csFiles = @(Get-Item $Path)
    }
    else {
        Write-Error "Not a .cs file: $Path"; exit 1
    }
}
elseif (Test-Path $Path -PathType Container) {
    $csFiles = Get-ChildItem -Path $Path -Filter "*.cs" -Recurse -File | Where-Object {
        $_.FullName -notmatch [regex]::Escape("\obj\") -and
        $_.FullName -notmatch [regex]::Escape("\bin\")
    }
}
else {
    Write-Error "Path not found: $Path"; exit 1
}

Write-Host "Found $($csFiles.Count) .cs files" -ForegroundColor Cyan
if ($WhatIf) { Write-Host "Mode: WhatIf" -ForegroundColor Yellow }
Write-Host ""

$modified = 0
foreach ($file in $csFiles) {
    $result = Process-File -FilePath $file.FullName -WhatIf:$WhatIf
    if ($result) { $modified++ }
}

Write-Host ""
Write-Host "Files modified: $modified / $($csFiles.Count)" -ForegroundColor Yellow
