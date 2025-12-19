# Open Windows Terminal with tabs running Claude for submodules in specified group
# EN: Opens pwsh tabs in Windows Terminal for all submodules in the specified group with Claude running
# CZ: Otevře pwsh taby ve Windows Terminal pro všechny submoduly v zadané skupině se spuštěným Claude

param(
    [Parameter(Mandatory=$true)]
    [int]$GroupNumber
)

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
    if ($inGroup -and $line -match "^- (.+)$") {
        $submodules += $matches[1].Trim()
    }
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in group $GroupNumber" -ForegroundColor Red
    exit 1
}

Write-Host "Opening $($submodules.Count) tabs for group $GroupNumber" -ForegroundColor Green

# EN: Build Windows Terminal command
# CZ: Vytvoř Windows Terminal příkaz
$wtCommand = "wt -w last"
foreach ($submodule in $submodules) {
    $wtCommand += " new-tab --title `"$submodule`" pwsh -NoExit -File `"$scriptDir\start-claude.ps1`" -SubmoduleName `"$submodule`" ``;"
}
$wtCommand = $wtCommand.TrimEnd('`', ';')

Invoke-Expression $wtCommand
