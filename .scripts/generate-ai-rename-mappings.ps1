# AI-Powered Rename Mapping Generator
# Analyzes variables and creates intelligent rename suggestions

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$variablesFile = Join-Path $rootPath ".variable-rename-project\analysis\variables-with-context.json"
$outputFile = Join-Path $rootPath ".variable-rename-project\analysis\ai-rename-mappings.json"

Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "AI-POWERED RENAME MAPPING GENERATOR" -ForegroundColor Yellow
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host ""

# Load variables
Write-Host "Loading variables..." -ForegroundColor White
$variables = Get-Content $variablesFile -Raw -Encoding UTF8 | ConvertFrom-Json
Write-Host "Loaded $($variables.Count) variables" -ForegroundColor Green
Write-Host ""

# AI Analysis Function
function Get-AIRenameSuggestion {
    param($variable)

    $name = $variable.Name
    $dataType = $variable.DataType
    $scope = $variable.Scope
    $methodSource = $variable.MethodSource
    $context = $variable.FullContext

    # CZECH NAMES (highest priority)
    $czechMappings = @{
        "hodnota" = "value"
        "paramy" = "values"
        "od" = "from"
        "do" = "to"
        "cislo" = "number"
        "text" = $null  # "text" is OK in English
        "slovo" = "word"
        "pocet" = "count"
        "seznam" = "list"
        "polozka" = "item"
        "radek" = "line"
        "soubor" = "file"
        "cesta" = "path"
        "nazev" = "name"
    }

    if ($czechMappings.ContainsKey($name)) {
        $suggestion = $czechMappings[$name]
        if ($suggestion) {
            return @{
                NewName = $suggestion
                Reason = "Czech name → English"
                Confidence = "High"
            }
        }
    }

    # CONTEXTUALLY INAPPROPRIATE NAMES
    # "id" in parsing methods should be "value"
    if ($name -eq "id" -and $scope -match "(Is|Parse|Try|Convert)") {
        if ($dataType -eq "Type") {
            return @{
                NewName = "type"
                Reason = "Contextually inappropriate (id for Type parameter)"
                Confidence = "High"
            }
        }
        return @{
            NewName = "value"
            Reason = "Contextually inappropriate (id in parsing method)"
            Confidence = "High"
        }
    }

    # "trim" that doesn't trim
    if ($name -eq "trim" -and $scope -notmatch "Trim") {
        return @{
            NewName = "value"
            Reason = "Misleading name (trim in non-trim method)"
            Confidence = "High"
        }
    }

    # INCONSISTENT NAMING
    if ($name -eq "replace" -and $methodSource -match "replaceCommaForDot") {
        return @{
            NewName = "replaceCommaForDot"
            Reason = "Inconsistent naming"
            Confidence = "Medium"
        }
    }

    # SINGLE-LETTER NON-DESCRIPTIVE
    if ($name.Length -eq 1) {
        # Loop variables are OK
        if ($name -match "^[ijk]$" -and $methodSource -match "for\s*\(") {
            return $null
        }

        # Generic type parameters are OK
        if ($name -eq "T" -and $dataType -eq "T") {
            return $null
        }

        # Exception variables are OK
        if ($name -eq "e" -and $dataType -match "Exception") {
            return $null
        }

        # Others need better names
        switch ($name) {
            "n" {
                if ($dataType -eq "bool") {
                    return @{
                        NewName = "negate"
                        Reason = "Single-letter → Descriptive"
                        Confidence = "Medium"
                    }
                }
                return @{
                    NewName = "number"
                    Reason = "Single-letter → Descriptive"
                    Confidence = "Medium"
                }
            }
            "v" {
                return @{
                    NewName = "value"
                    Reason = "Single-letter → Descriptive"
                    Confidence = "High"
                }
            }
            "p" {
                if ($dataType -eq "bool") {
                    return @{
                        NewName = "value"
                        Reason = "Single-letter → Descriptive"
                        Confidence = "High"
                    }
                }
                return @{
                    NewName = "parameter"
                    Reason = "Single-letter → Descriptive"
                    Confidence = "Medium"
                }
            }
            "b" {
                return @{
                    NewName = "value"
                    Reason = "Single-letter → Descriptive"
                    Confidence = "High"
                }
            }
            "c" {
                if ($dataType -eq "char") {
                    return @{
                        NewName = "character"
                        Reason = "Single-letter → Descriptive"
                        Confidence = "High"
                    }
                }
                return @{
                    NewName = "value"
                    Reason = "Single-letter → Descriptive"
                    Confidence = "Medium"
                }
            }
            "s" {
                return @{
                    NewName = "text"
                    Reason = "Single-letter → Descriptive"
                    Confidence = "High"
                }
            }
            "t" {
                if ($dataType -match "DateTime") {
                    return @{
                        NewName = "dateTime"
                        Reason = "Single-letter → Descriptive"
                        Confidence = "High"
                    }
                }
                return @{
                    NewName = "value"
                    Reason = "Single-letter → Descriptive"
                    Confidence = "Medium"
                }
            }
        }
    }

    # ABBREVIATIONS
    $abbreviations = @{
        "vr" = "result"
        "str" = "text"
        "num" = "number"
        "ch" = "character"
        "idx" = "index"
        "cnt" = "count"
        "arr" = "array"
        "obj" = "object"
        "msg" = "message"
        "src" = "source"
        "dst" = "destination"
        "dest" = "destination"
        "cfg" = "config"
    }

    if ($abbreviations.ContainsKey($name)) {
        return @{
            NewName = $abbreviations[$name]
            Reason = "Abbreviation → Full word"
            Confidence = "High"
        }
    }

    # GENERIC NAMES THAT COULD BE BETTER
    if ($name -match "^(tag|tag\d+|same)$") {
        if ($name -eq "same" -and $methodSource -match "Compare") {
            return @{
                NewName = "areEqual"
                Reason = "Improved clarity (verb for boolean)"
                Confidence = "Medium"
            }
        }
    }

    # No suggestion
    return $null
}

# Generate mappings
Write-Host "Analyzing variables with AI..." -ForegroundColor Cyan
$mappings = @()
$processedCount = 0

foreach ($variable in $variables) {
    $processedCount++

    if ($processedCount % 50 -eq 0) {
        Write-Host "  Processed $processedCount / $($variables.Count) variables..." -ForegroundColor Gray
    }

    $suggestion = Get-AIRenameSuggestion $variable

    if ($suggestion) {
        $mappings += [PSCustomObject]@{
            File = $variable.File
            Line = $variable.Line
            Type = $variable.Type
            OldName = $variable.Name
            NewName = $suggestion.NewName
            Reason = $suggestion.Reason
            Confidence = $suggestion.Confidence
            DataType = $variable.DataType
            Scope = $variable.Scope
        }
    }
}

Write-Host ""
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "ANALYSIS COMPLETE" -ForegroundColor Green
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host ""
Write-Host "Total variables analyzed: $($variables.Count)" -ForegroundColor White
Write-Host "Rename suggestions: $($mappings.Count)" -ForegroundColor Yellow
Write-Host ""

# Group by reason
$byReason = $mappings | Group-Object Reason | Sort-Object Count -Descending
Write-Host "Breakdown by reason:" -ForegroundColor Cyan
foreach ($group in $byReason) {
    Write-Host "  $($group.Name): $($group.Count)" -ForegroundColor Yellow
}

Write-Host ""

# Save mappings
$mappings | ConvertTo-Json -Depth 10 | Out-File $outputFile -Encoding UTF8
Write-Host "✅ Saved AI rename mappings to: $outputFile" -ForegroundColor Green

# Show top 20 examples
Write-Host ""
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "TOP 20 RENAME SUGGESTIONS:" -ForegroundColor Yellow
Write-Host "=" * 100 -ForegroundColor Cyan
foreach ($mapping in $mappings | Select-Object -First 20) {
    Write-Host "$($mapping.File):$($mapping.Line)" -ForegroundColor Gray
    Write-Host "  $($mapping.OldName) → $($mapping.NewName)" -ForegroundColor Cyan
    Write-Host "  Reason: $($mapping.Reason) | Confidence: $($mapping.Confidence)" -ForegroundColor DarkGray
    Write-Host "  Context: $($mapping.Type) in $($mapping.Scope)($($mapping.DataType))" -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host "=" * 100 -ForegroundColor Cyan
