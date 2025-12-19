# Convert and filter comprehensive mappings to PinpVariableRenamer format

$inputFile = "E:\vs\Projects\PlatformIndependentNuGetPackages\.variable-rename-project\analysis\sunamostring-comprehensive-mappings.json"
$outputFile = "E:\vs\Projects\PlatformIndependentNuGetPackages\.variable-rename-project\mappings\SunamoString-complete-mappings.json"

Write-Host "Reading input file: $inputFile" -ForegroundColor Cyan
$mappings = Get-Content $inputFile -Raw | ConvertFrom-Json

$converted = @()
$stats = @{
    Parameter = 0
    Local = 0
    FieldSimple = 0
    FieldToProperty = 0
    Skipped = 0
    SkippedTypes = @{}
}

foreach ($mapping in $mappings) {
    $type = $mapping.Type

    # Skip unsupported types
    if ($type -eq "ClassName" -or $type -eq "MethodName") {
        $stats.Skipped++
        if (-not $stats.SkippedTypes.ContainsKey($type)) {
            $stats.SkippedTypes[$type] = 0
        }
        $stats.SkippedTypes[$type]++
        continue
    }

    # Fix file path: remove duplicate submodule name
    $filePath = $mapping.File
    if ($filePath -match "^(.+?)\\\\1\\(.+)$") {
        $filePath = "$($Matches[1])\$($Matches[2])"
    } elseif ($filePath -match "^SunamoString\\SunamoString\\(.+)$") {
        $filePath = "SunamoString\$($Matches[1])"
    }

    $newMapping = @{
        FilePath = $filePath
        LineNumber = $mapping.Line
        OldName = $mapping.OldName
        NewName = $mapping.NewName
    }

    # Add optional fields if present
    if ($mapping.Reason) {
        $newMapping.Reason = $mapping.Reason
    }
    if ($mapping.Confidence) {
        $newMapping.Confidence = $mapping.Confidence
    }
    if ($mapping.DataType) {
        $newMapping.DataType = $mapping.DataType
    }

    # Determine scope and operation type
    switch ($type) {
        "Parameter" {
            $newMapping.Scope = "Parameter"
            $newMapping.OperationType = "SimpleRename"
            $stats.Parameter++
        }
        "LocalVariable" {
            $newMapping.Scope = "Local"
            $newMapping.OperationType = "SimpleRename"
            $stats.Local++
        }
        "Field" {
            $newMapping.Scope = "Field"
            if ($mapping.AdditionalAction -eq "ConvertToProperty") {
                $newMapping.OperationType = "ConvertFieldToProperty"
                $newMapping.ConvertToProperty = $true
                $stats.FieldToProperty++
            } else {
                $newMapping.OperationType = "SimpleRename"
                $stats.FieldSimple++
            }
        }
        default {
            $stats.Skipped++
            if (-not $stats.SkippedTypes.ContainsKey($type)) {
                $stats.SkippedTypes[$type] = 0
            }
            $stats.SkippedTypes[$type]++
            continue
        }
    }

    $converted += $newMapping
}

# Create output directory if it doesn't exist
$outputDir = Split-Path $outputFile -Parent
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    Write-Host "Created directory: $outputDir" -ForegroundColor Green
}

# Write output file
$converted | ConvertTo-Json -Depth 10 | Set-Content $outputFile -Encoding UTF8

Write-Host "`nConversion complete!" -ForegroundColor Green
Write-Host "Output file: $outputFile" -ForegroundColor Cyan
Write-Host "`nStatistics:" -ForegroundColor Yellow
Write-Host "  Parameters:           $($stats.Parameter)" -ForegroundColor White
Write-Host "  Local Variables:      $($stats.Local)" -ForegroundColor White
Write-Host "  Fields (Simple):      $($stats.FieldSimple)" -ForegroundColor White
Write-Host "  Fields (To Property): $($stats.FieldToProperty)" -ForegroundColor White
Write-Host "  Total Converted:      $($converted.Count)" -ForegroundColor Green
Write-Host "  Skipped:              $($stats.Skipped)" -ForegroundColor Red

if ($stats.SkippedTypes.Count -gt 0) {
    Write-Host "`nSkipped by type:" -ForegroundColor Red
    foreach ($key in $stats.SkippedTypes.Keys) {
        Write-Host "  $key : $($stats.SkippedTypes[$key])" -ForegroundColor DarkRed
    }
}
