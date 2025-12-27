# Open Windows Terminal with tabs running Claude for submodules in specified group
# EN: Opens pwsh tabs in Windows Terminal for all submodules in the specified group with Claude running
# CZ: Otevře pwsh taby ve Windows Terminal pro všechny submoduly v zadané skupině se spuštěným Claude

param(
    [Parameter(Mandatory=$true)]
    [int]$GroupNumber,

    [Parameter(Mandatory=$false)]
    [int]$Count = 0
)

# EN: Function to check if all .cs files in submodule have the "variables names: ok" comment
# CZ: Funkce pro kontrolu zda všechny .cs soubory v submodulu mají komentář "variables names: ok"
function Test-SubmoduleComplete {
    param([string]$SubmodulePath)

    $csFiles = Get-ChildItem -Path $SubmodulePath -Filter "*.cs" -Recurse -File

    if ($csFiles.Count -eq 0) {
        return $false
    }

    foreach ($file in $csFiles) {
        $firstLine = Get-Content $file.FullName -First 1 -ErrorAction SilentlyContinue
        if ($firstLine -notmatch "^\s*//\s*variables\s+names:\s*ok") {
            return $false
        }
    }

    return $true
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$groupedFile = Join-Path $scriptDir "submodules-grouped.md"

if (-not (Test-Path $groupedFile)) {
    Write-Host "Grouped submodules file not found: $groupedFile" -ForegroundColor Red
    Write-Host "Run .scripts\group-submodules.ps1 first" -ForegroundColor Yellow
    exit 1
}

# EN: Read submodules from the specified group
# CZ: Přečti submoduly ze zadané skupiny
$content = Get-Content $groupedFile
$inGroup = $false
$submodules = @()

foreach ($line in $content) {
    if ($line -match "^## Group $GroupNumber$") {
        $inGroup = $true
        continue
    }
    if ($inGroup -and $line -match "^## Group \d+$") {
        break
    }
    if ($inGroup -and $line -match "^- ([^\s(]+)") {
        $submodules += $matches[1].Trim()
    }
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in group $GroupNumber" -ForegroundColor Red
    exit 1
}

# EN: Filter out submodules that don't exist on disk
# CZ: Odfiltruj submoduly které neexistují na disku
$baseDir = Split-Path -Parent $scriptDir
$existingSubmodules = @()
$missingSubmodules = @()

foreach ($submodule in $submodules) {
    $submodulePath = Join-Path $baseDir $submodule
    if (Test-Path $submodulePath) {
        $existingSubmodules += $submodule
    } else {
        $missingSubmodules += $submodule
    }
}

if ($missingSubmodules.Count -gt 0) {
    Write-Host "Skipping $($missingSubmodules.Count) missing submodules:" -ForegroundColor Yellow
    foreach ($missing in $missingSubmodules) {
        Write-Host "  - $missing" -ForegroundColor Yellow
    }
}

if ($existingSubmodules.Count -eq 0) {
    Write-Host "No existing submodules found in group $GroupNumber" -ForegroundColor Red
    exit 1
}

# EN: Take only last N submodules if Count is specified
# CZ: Vezmi pouze posledních N submodulů pokud je Count zadaný
if ($Count -gt 0) {
    if ($Count -ge $existingSubmodules.Count) {
        Write-Host "Count ($Count) is greater than or equal to existing submodules ($($existingSubmodules.Count)), opening all" -ForegroundColor Yellow
    } else {
        $existingSubmodules = $existingSubmodules | Select-Object -Last $Count
        Write-Host "Taking last $Count submodules from group $GroupNumber" -ForegroundColor Cyan
    }
}

Write-Host "Opening $($existingSubmodules.Count) tabs for group $GroupNumber" -ForegroundColor Green

# EN: Check which submodules are complete and which need Claude
# CZ: Zkontroluj které submoduly jsou hotové a které potřebují Claude
$completeSubmodules = @()
$incompleteSubmodules = @()

foreach ($submodule in $existingSubmodules) {
    $submodulePath = Join-Path $baseDir $submodule
    if (Test-SubmoduleComplete -SubmodulePath $submodulePath) {
        $completeSubmodules += $submodule
        Write-Host "  ✓ $submodule (complete)" -ForegroundColor Green
    } else {
        $incompleteSubmodules += $submodule
        Write-Host "  → $submodule (needs work)" -ForegroundColor Yellow
    }
}

# EN: Build Windows Terminal command
# CZ: Vytvoř Windows Terminal příkaz
$wtCommand = "wt -w last"

foreach ($submodule in $existingSubmodules) {
    $submodulePath = Join-Path $baseDir $submodule
    if (Test-SubmoduleComplete -SubmodulePath $submodulePath) {
        # EN: For complete submodules, just open a tab and display the name
        # CZ: Pro hotové submoduly pouze otevři tab a vypiš název
        $wtCommand += " new-tab --title `"$submodule`" pwsh -NoExit -Command `"Write-Host '$submodule - COMPLETE' -ForegroundColor Green`" ``;"
    } else {
        # EN: For incomplete submodules, start Claude
        # CZ: Pro nedokončené submoduly spusť Claude
        $wtCommand += " new-tab --title `"$submodule`" pwsh -NoExit -File `"$scriptDir\start-claude.ps1`" -SubmoduleName `"$submodule`" ``;"
    }
}
$wtCommand = $wtCommand.TrimEnd('`', ';')

Invoke-Expression $wtCommand
