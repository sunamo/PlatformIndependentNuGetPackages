# Open Windows Terminal with multiple tabs for a single submodule
# EN: Opens N pwsh tabs in Windows Terminal for the specified submodule with Claude running
# CZ: Otevře N pwsh tabů ve Windows Terminal pro zadaný submodul se spuštěným Claude

param(
    [Parameter(Mandatory=$true)]
    [string]$SubmoduleName,

    [Parameter(Mandatory=$false)]
    [int]$Count = 10
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseDir = Split-Path -Parent $scriptDir
$submodulePath = Join-Path $baseDir $SubmoduleName

# EN: Check if submodule exists
# CZ: Zkontroluj zda submodul existuje
if (-not (Test-Path $submodulePath)) {
    Write-Host "Submodule folder does not exist: $submodulePath" -ForegroundColor Red
    exit 1
}

Write-Host "Opening $Count tabs for submodule: $SubmoduleName" -ForegroundColor Green

# EN: Build Windows Terminal command
# CZ: Vytvoř Windows Terminal příkaz
$wtCommand = "wt -w last"

for ($i = 1; $i -le $Count; $i++) {
    $tabTitle = "$SubmoduleName ($i/$Count)"
    $wtCommand += " new-tab --title `"$tabTitle`" pwsh -NoExit -File `"$scriptDir\start-claude.ps1`" -SubmoduleName `"$SubmoduleName`" ``;"
}
$wtCommand = $wtCommand.TrimEnd('`', ';')

Invoke-Expression $wtCommand
