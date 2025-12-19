# EN: Start Claude in SunamoAI folder
# CZ: Spustí Claude ve složce SunamoAI

Set-Location "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoAI\"
$host.UI.RawUI.WindowTitle = "SunamoAI"
Write-Host 'SunamoAI' -ForegroundColor Green
claude.cmd --dangerously-skip-permissions --disallowedTools "" --permission-mode bypassPermissions --model sonnet
