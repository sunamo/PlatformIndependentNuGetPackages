# EN: Start Claude in specified submodule folder
# CZ: Spustí Claude v zadané složce submodulu

param(
    [Parameter(Mandatory=$true)]
    [string]$SubmoduleName,

    [Parameter(Mandatory=$false)]
    [string]$Model = "sonnet",

    [Parameter(Mandatory=$false)]
    [string]$PromptFile = ""
)

$submodulePath = "E:\vs\Projects\PlatformIndependentNuGetPackages\$SubmoduleName\"

if (-not (Test-Path $submodulePath)) {
    Write-Host "Submodule folder does not exist: $submodulePath" -ForegroundColor Red
    exit 1
}

Set-Location $submodulePath
$host.UI.RawUI.WindowTitle = $SubmoduleName
Write-Host $SubmoduleName -ForegroundColor Green

if ($PromptFile -and (Test-Path $PromptFile)) {
    Get-Content $PromptFile -Raw | claude.cmd -p --dangerously-skip-permissions --disallowedTools "" --permission-mode bypassPermissions --model $Model
} else {
    claude.cmd --dangerously-skip-permissions --disallowedTools "" --permission-mode bypassPermissions --model $Model
}
