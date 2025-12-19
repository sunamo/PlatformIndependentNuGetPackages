# EN: Apply variable rename mappings from JSON file to specific C# files
# CZ: Aplikovat přejmenování proměnných z JSON souboru na konkrétní C# soubory

param(
    [string]$MappingFile = "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\variable-rename-mappings.json",
    [string]$RootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollections\SunamoCollections"
)

Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "APPLYING VARIABLE RENAME MAPPINGS" -ForegroundColor Yellow
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host ""

# EN: Load mapping file
# CZ: Načíst mapping soubor
if (-not (Test-Path $MappingFile)) {
    Write-Error "Mapping file not found: $MappingFile"
    exit 1
}

$mappings = Get-Content $MappingFile -Raw | ConvertFrom-Json

# EN: Process each file in mappings
# CZ: Zpracovat každý soubor v mappings
foreach ($fileName in $mappings.PSObject.Properties.Name) {
    $filePath = Get-ChildItem -Path $RootPath -Recurse -Filter $fileName | Select-Object -First 1

    if (-not $filePath) {
        Write-Host "File not found: $fileName" -ForegroundColor Yellow
        continue
    }

    Write-Host "`nProcessing: $fileName" -ForegroundColor Cyan
    Write-Host "  Path: $($filePath.FullName)" -ForegroundColor Gray

    $content = Get-Content $filePath.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $changesApplied = 0

    # EN: Get mappings for this file
    # CZ: Získat mappings pro tento soubor
    $fileMapping = $mappings.$fileName

    # EN: Apply each variable rename
    # CZ: Aplikovat každé přejmenování proměnné
    foreach ($oldName in $fileMapping.PSObject.Properties.Name) {
        $newName = $fileMapping.$oldName

        Write-Host "    Renaming: '$oldName' -> '$newName'" -ForegroundColor Gray

        # EN: Use word boundary regex to match whole words only
        # CZ: Použít word boundary regex pro matchování celých slov
        $pattern = "\b$oldName\b"
        $matches = [regex]::Matches($content, $pattern)

        if ($matches.Count -gt 0) {
            $content = $content -replace $pattern, $newName
            $changesApplied += $matches.Count
            Write-Host "      Found and replaced $($matches.Count) occurrence(s)" -ForegroundColor Green
        } else {
            Write-Host "      No occurrences found" -ForegroundColor Yellow
        }
    }

    # EN: Save file if changes were made
    # CZ: Uložit soubor pokud byly provedeny změny
    if ($changesApplied -gt 0) {
        Set-Content -Path $filePath.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  SAVED: $changesApplied change(s) applied to $fileName" -ForegroundColor Green
    } else {
        Write-Host "  NO CHANGES: No occurrences found in $fileName" -ForegroundColor Yellow
    }
}

Write-Host "`n" + "=" * 100 -ForegroundColor Cyan
Write-Host "VARIABLE RENAME MAPPINGS COMPLETED" -ForegroundColor Green
Write-Host "=" * 100 -ForegroundColor Cyan
