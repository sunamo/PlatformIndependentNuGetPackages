# EN: Add "// variables names: ok" marker to a single file (for VS External Tool)
# CZ: Přidat "// variables names: ok" marker do jednoho souboru (pro VS External Tool)

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

# EN: Validate file exists and is a C# file
# CZ: Ověřit že soubor existuje a je C# soubor
if (-not (Test-Path $FilePath)) {
    Write-Error "File not found: $FilePath"
    exit 1
}

if (-not $FilePath.EndsWith('.cs')) {
    Write-Error "Not a C# file: $FilePath"
    exit 1
}

# EN: Skip GlobalUsings.cs files
# CZ: Přeskočit GlobalUsings.cs soubory
if ($FilePath -like '*GlobalUsings.cs') {
    Write-Host "Skipping GlobalUsings.cs file" -ForegroundColor Yellow
    exit 0
}

# EN: Read file content
# CZ: Přečíst obsah souboru
$content = Get-Content -Path $FilePath -Raw -ErrorAction Stop

# EN: Check if already has marker
# CZ: Zkontrolovat jestli už má marker
if ($content -like '*// variables names: ok*') {
    Write-Host "✓ Marker already present in: $(Split-Path $FilePath -Leaf)" -ForegroundColor Green
    exit 0
}

# EN: Add marker at the beginning
# CZ: Přidat marker na začátek
$newContent = "// variables names: ok`r`n" + $content
Set-Content -Path $FilePath -Value $newContent -NoNewline -Encoding UTF8

Write-Host "✓ Added marker to: $(Split-Path $FilePath -Leaf)" -ForegroundColor Green
exit 0
