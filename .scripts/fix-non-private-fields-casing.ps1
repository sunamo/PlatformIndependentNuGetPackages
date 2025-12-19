# EN: Script to fix non-private field names to PascalCase
# CZ: Skript pro opravu názvů non-private fieldů na PascalCase

param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionPath
)

$ErrorActionPreference = "Stop"

# EN: IMPORTANT: Do NOT add "// variables names: ok" header automatically!
# CZ: DŮLEŽITÉ: NEPŘIDÁVEJ "// variables names: ok" header automaticky!
# This header is added manually by the user after verification
# Tento header přidává uživatel ručně po kontrole

# EN: Validate solution file exists
# CZ: Zkontroluj že solution soubor existuje
if (-not (Test-Path $SolutionPath)) {
    Write-Error "Solution file not found: $SolutionPath"
    exit 1
}

$solutionDir = Split-Path -Parent $SolutionPath
Write-Host "Solution directory: $solutionDir" -ForegroundColor Cyan

# EN: Parse .sln file to get project paths
# CZ: Parsuj .sln soubor pro získání cest k projektům
$slnContent = Get-Content $SolutionPath
$projectPaths = @()

foreach ($line in $slnContent) {
    if ($line -match 'Project\(".*?"\)\s*=\s*".*?",\s*"(.*?\.csproj)"') {
        $relativeProjectPath = $matches[1]
        $absoluteProjectPath = Join-Path $solutionDir $relativeProjectPath
        if (Test-Path $absoluteProjectPath) {
            $projectPaths += $absoluteProjectPath
        }
    }
}

Write-Host "Found $($projectPaths.Count) project(s)" -ForegroundColor Cyan

# EN: Collect all .cs files from projects (excluding GlobalUsings.cs)
# CZ: Sesbírej všechny .cs soubory z projektů (kromě GlobalUsings.cs)
$allCsFiles = @()
foreach ($projectPath in $projectPaths) {
    $projectDir = Split-Path -Parent $projectPath
    $csFiles = Get-ChildItem -Path $projectDir -Filter "*.cs" -Recurse -File | Where-Object {
        $_.FullName -notmatch [regex]::Escape("\obj\") -and
        $_.FullName -notmatch [regex]::Escape("\bin\") -and
        $_.Name -ne "GlobalUsings.cs"
    }
    $allCsFiles += $csFiles
}

Write-Host "Found $($allCsFiles.Count) .cs file(s)" -ForegroundColor Cyan

# EN: Filter files without "// variables names: ok" to find fields to rename
# CZ: Filtruj soubory bez "// variables names: ok" pro nalezení fieldů k přejmenování
$filesToScanForFields = @()
foreach ($file in $allCsFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -notmatch '//\s*variables\s+names:\s*ok') {
        $filesToScanForFields += $file.FullName
    }
}

Write-Host "Files without '// variables names: ok' (to scan for fields): $($filesToScanForFields.Count)" -ForegroundColor Yellow

if ($filesToScanForFields.Count -eq 0) {
    Write-Host "All files contain '// variables names: ok' marker. Nothing to process." -ForegroundColor Green
    exit 0
}

# EN: STEP 1: Collect all field renames from files without header
# CZ: KROK 1: Sesbírej všechna přejmenování fieldů ze souborů bez headeru
Write-Host "`nStep 1: Scanning for non-private fields with camelCase names..." -ForegroundColor Cyan
$globalFieldRenames = @{}

foreach ($filePath in $filesToScanForFields) {
    $content = Get-Content $filePath -Raw
    $fieldPattern = '(?m)^\s*(public|internal|protected|protected\s+internal)\s+(?:(static|readonly|const)\s+)*(\w+(?:<[^>]+>)?)\s+([a-z]\w*)\s*(=|;)'
    $matches = [regex]::Matches($content, $fieldPattern)

    foreach ($match in $matches) {
        $fieldName = $match.Groups[4].Value
        $newFieldName = $fieldName.Substring(0, 1).ToUpper() + $fieldName.Substring(1)

        if (-not $globalFieldRenames.ContainsKey($fieldName)) {
            $globalFieldRenames[$fieldName] = $newFieldName
            Write-Host "  Found field to rename: $fieldName -> $newFieldName" -ForegroundColor Gray
        }
    }
}

Write-Host "Total unique fields to rename: $($globalFieldRenames.Count)" -ForegroundColor Yellow

if ($globalFieldRenames.Count -eq 0) {
    Write-Host "No non-private fields with camelCase names found." -ForegroundColor Green
    exit 0
}

# EN: STEP 2: Apply renames to ALL .cs files in the solution
# CZ: KROK 2: Aplikuj přejmenování na VŠECHNY .cs soubory ve solution
Write-Host "`nStep 2: Applying renames to all .cs files..." -ForegroundColor Cyan

# EN: Statistics
# CZ: Statistiky
$stats = @{
    TotalFiles = $allCsFiles.Count
    ProcessedFiles = 0
    SkippedFiles = 0
    TotalReplacements = 0
    FilesWithChanges = 0
}

$counter = 0

foreach ($file in $allCsFiles) {
    $filePath = $file.FullName
    $counter++
    Write-Host "`n[$counter/$($stats.TotalFiles)] Processing: $(Split-Path -Leaf $filePath)" -ForegroundColor Gray

    try {
        $content = Get-Content $filePath -Raw
        $originalContent = $content
        $fileReplacements = 0

        # EN: Apply all global field renames to this file
        # CZ: Aplikuj všechna globální přejmenování fieldů do tohoto souboru
        foreach ($oldName in $globalFieldRenames.Keys) {
            $newName = $globalFieldRenames[$oldName]

            # EN: Replace field name in entire file (declarations and usages)
            # CZ: Nahraď název fieldu v celém souboru (deklarace i použití)
            $pattern = "(?<!\w)$oldName(?!\w)"
            $beforeCount = ([regex]::Matches($content, $pattern)).Count

            if ($beforeCount -gt 0) {
                $content = $content -replace $pattern, $newName
                Write-Host "  Replaced $beforeCount occurrence(s) of '$oldName' -> '$newName'" -ForegroundColor Gray
                $fileReplacements += $beforeCount
                $stats.TotalReplacements += $beforeCount
            }
        }

        # EN: Check if content was modified
        # CZ: Zkontroluj zda byl obsah změněn
        if ($fileReplacements -gt 0) {
            # EN: Write modified content back to file (WITHOUT adding header)
            # CZ: Zapiš upravený obsah zpět do souboru (BEZ přidání headeru)
            # IMPORTANT: Header "// variables names: ok" is added manually by user after verification!
            Set-Content -Path $filePath -Value $content -NoNewline -Encoding UTF8

            Write-Host "  ✓ File updated with $fileReplacements replacement(s)" -ForegroundColor Green
            $stats.FilesWithChanges++
        } else {
            $stats.SkippedFiles++
        }

        $stats.ProcessedFiles++

    } catch {
        Write-Host "  ✗ Error processing file: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# EN: Print summary
# CZ: Vypiš souhrn
Write-Host "`n" -NoNewline
Write-Host ("=" * 80) -ForegroundColor Gray
Write-Host "SUMMARY / SOUHRN" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray
Write-Host "Total files processed:     $($stats.ProcessedFiles)" -ForegroundColor White
Write-Host "Files with changes:        $($stats.FilesWithChanges)" -ForegroundColor Green
Write-Host "Files skipped (no changes): $($stats.SkippedFiles)" -ForegroundColor Gray
Write-Host "Total field renames:       $($stats.TotalReplacements)" -ForegroundColor Yellow
Write-Host ("=" * 80) -ForegroundColor Gray

if ($stats.FilesWithChanges -gt 0) {
    Write-Host "`nDone! Please verify the changes and run build to ensure everything compiles." -ForegroundColor Green
}
