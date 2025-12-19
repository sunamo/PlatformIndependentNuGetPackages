# EN: Start Claude in specified submodule folder
# CZ: Spustí Claude v zadané složce submodulu

param(
    [Parameter(Mandatory=$true)]
    [string]$SubmoduleName
)

$submodulePath = "E:\vs\Projects\PlatformIndependentNuGetPackages\$SubmoduleName\"

if (-not (Test-Path $submodulePath)) {
    Write-Host "Submodule folder does not exist: $submodulePath" -ForegroundColor Red
    exit 1
}

Set-Location $submodulePath
$host.UI.RawUI.WindowTitle = $SubmoduleName
Write-Host $SubmoduleName -ForegroundColor Green
claude.cmd --dangerously-skip-permissions --disallowedTools "" --permission-mode bypassPermissions --model sonnet
