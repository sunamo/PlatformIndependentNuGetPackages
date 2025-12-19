# EN: Start Claude in SunamoArgs folder
# CZ: Spustí Claude ve složce SunamoArgs

Set-Location "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoArgs\"
$host.UI.RawUI.WindowTitle = "SunamoArgs"
Write-Host 'SunamoArgs' -ForegroundColor Green
claude.cmd --dangerously-skip-permissions --disallowedTools "" --permission-mode bypassPermissions --model sonnet
