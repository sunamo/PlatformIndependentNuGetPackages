param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionDir
)

# EN: Check if all CS files in solution contain "// variables names: ok" marker
# CZ: Zkontrolovat zda všechny CS soubory v řešení obsahují marker "// variables names: ok"

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "EN: Checking Variables Names Marker" -ForegroundColor Cyan
Write-Host "CZ: Kontrola Variables Names Marker" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "EN: Solution Directory: $SolutionDir" -ForegroundColor White
Write-Host "CZ: Adresář řešení: $SolutionDir" -ForegroundColor White
Write-Host ""

# EN: Find all .cs files in solution directory
# CZ: Najít všechny .cs soubory v adresáři řešení
$csFiles = Get-ChildItem -Path $SolutionDir -Filter "*.cs" -Recurse | Where-Object {
    # EN: Exclude obj and bin folders
    # CZ: Vyloučit obj a bin složky
    $_.FullName -notmatch '\\obj\\' -and $_.FullName -notmatch '\\bin\\'
}

Write-Host "EN: Found $($csFiles.Count) CS files" -ForegroundColor White
Write-Host "CZ: Nalezeno $($csFiles.Count) CS souborů" -ForegroundColor White
Write-Host ""

# EN: Check which files don't contain the marker
# CZ: Zkontrolovat které soubory neobsahují marker
$filesWithoutMarker = @()

foreach ($file in $csFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    if ($content -notmatch '// variables names: ok') {
        $filesWithoutMarker += $file
    }
}

if ($filesWithoutMarker.Count -eq 0) {
    Write-Host "✓ SUCCESS: All CS files contain '// variables names: ok' marker!" -ForegroundColor Green
    Write-Host "✓ ÚSPĚCH: Všechny CS soubory obsahují marker '// variables names: ok'!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Press any key to exit... / Stiskněte klávesu pro ukončení..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

# EN: Display files without marker
# CZ: Zobrazit soubory bez markeru
Write-Host "⚠️  WARNING: Found $($filesWithoutMarker.Count) CS files without '// variables names: ok' marker:" -ForegroundColor Yellow
Write-Host "⚠️  VAROVÁNÍ: Nalezeno $($filesWithoutMarker.Count) CS souborů bez markeru '// variables names: ok':" -ForegroundColor Yellow
Write-Host ""

foreach ($file in $filesWithoutMarker) {
    $relativePath = $file.FullName.Replace($SolutionDir, "").TrimStart('\')
    Write-Host "  - $relativePath" -ForegroundColor Red
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# EN: Ask user if they want to open files using Open-FilesWithoutVarOk
# CZ: Zeptat se uživatele, zda chce otevřít soubory pomocí Open-FilesWithoutVarOk
Write-Host "EN: Do you want to open these files using Open-FilesWithoutVarOk? (Y/N)" -ForegroundColor Yellow
Write-Host "CZ: Chcete otevřít tyto soubory pomocí Open-FilesWithoutVarOk? (Y/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq 'Y' -or $response -eq 'y') {
    # EN: Extract submodule name from solution directory
    # CZ: Extrahovat název submodulu z adresáře řešení
    # EN: Assuming solution directory structure like: E:\vs\Projects\PlatformIndependentNuGetPackages\{submodule}\
    # CZ: Předpokládáme strukturu adresáře řešení jako: E:\vs\Projects\PlatformIndependentNuGetPackages\{submodule}\

    Write-Host ""
    Write-Host "EN: Calling Open-FilesWithoutVarOk -SolutionPath '$SolutionDir'" -ForegroundColor Cyan
    Write-Host "CZ: Volám Open-FilesWithoutVarOk -SolutionPath '$SolutionDir'" -ForegroundColor Cyan

    # EN: Check if function exists in PowerShell profile
    # CZ: Zkontrolovat zda funkce existuje v PowerShell profilu
    if (Get-Command Open-FilesWithoutVarOk -ErrorAction SilentlyContinue) {
        Open-FilesWithoutVarOk -SolutionPath $SolutionDir
    } else {
        Write-Host ""
        Write-Host "⚠️  ERROR: Function Open-FilesWithoutVarOk not found in PowerShell profile!" -ForegroundColor Red
        Write-Host "⚠️  CHYBA: Funkce Open-FilesWithoutVarOk nenalezena v PowerShell profilu!" -ForegroundColor Red
        Write-Host ""
        Write-Host "EN: Please ensure the function is defined in your PowerShell profile." -ForegroundColor Yellow
        Write-Host "CZ: Prosím ujistěte se, že funkce je definována ve vašem PowerShell profilu." -ForegroundColor Yellow
        Write-Host ""
    }
} else {
    Write-Host ""
    Write-Host "EN: Operation cancelled. Files will not be opened." -ForegroundColor Yellow
    Write-Host "CZ: Operace zrušena. Soubory nebudou otevřeny." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Press any key to exit... / Stiskněte klávesu pro ukončení..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
