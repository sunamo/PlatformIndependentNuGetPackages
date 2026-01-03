param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionDir
)

# EN: Add "// variables names: ok" marker to all .cs files in solution that don't have it
# CZ: Přidat "// variables names: ok" marker do všech .cs souborů v solution, které ho ještě nemají

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "EN: Adding 'variables names: ok' marker to files..." -ForegroundColor Green
Write-Host "CZ: Přidávám 'variables names: ok' marker do souborů..." -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Set-Location $SolutionDir

# EN: Find all .cs files in solution
# CZ: Najít všechny .cs soubory v solution
$csFiles = Get-ChildItem -Path $SolutionDir -Filter "*.cs" -Recurse -File | Where-Object { $_.FullName -notmatch '\\obj\\|\\bin\\' }

$marker = "// variables names: ok"
$markerAddedCount = 0
$skippedCount = 0

foreach ($file in $csFiles) {
    $content = Get-Content -Path $file.FullName -Raw

    # EN: Skip if file already has the marker
    # CZ: Přeskočit pokud soubor již obsahuje marker
    if ($content -match 'variables\s+names\s*:\s*ok') {
        $skippedCount++
        continue
    }

    # EN: Add marker at the beginning
    # CZ: Přidat marker na začátek
    Write-Host "  Adding marker to: $($file.FullName)" -ForegroundColor Green

    # EN: Preserve original line endings by writing directly
    # CZ: Zachovat původní line endings zápisem přímo
    $bytes = [System.Text.Encoding]::UTF8.GetBytes("$marker`r`n")
    $originalBytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $newBytes = $bytes + $originalBytes
    [System.IO.File]::WriteAllBytes($file.FullName, $newBytes)

    $markerAddedCount++
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✓ SUCCESS: Processed $($csFiles.Count) file(s)" -ForegroundColor Green
Write-Host "✓ ÚSPĚCH: Zpracováno $($csFiles.Count) souborů" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Marker added to: $markerAddedCount file(s)" -ForegroundColor Green
Write-Host "  CZ: Marker přidán do: $markerAddedCount souborů" -ForegroundColor Green
Write-Host "  Already had marker: $skippedCount file(s)" -ForegroundColor Yellow
Write-Host "  CZ: Už mělo marker: $skippedCount souborů" -ForegroundColor Yellow
Write-Host ""
Write-Host "EN: Press any key to close..." -ForegroundColor Gray
Write-Host "CZ: Stiskněte klávesu pro zavření..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
