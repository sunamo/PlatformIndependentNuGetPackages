# Open Windows Terminal with tabs running Claude in specific folders
# EN: Opens pwsh tabs in Windows Terminal for SunamoAI and SunamoArgs folders with Claude running
# CZ: Otevře pwsh taby ve Windows Terminal pro složky SunamoAI a SunamoArgs se spuštěným Claude

wt -w 0 -d "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoAI\" pwsh -NoExit -Command "Write-Host 'SunamoAI' -ForegroundColor Green; claude.cmd --dangerously-skip-permissions --disallowedTools '' --permission-mode bypassPermissions --model sonnet" ; new-tab -d "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoArgs\" pwsh -NoExit -Command "Write-Host 'SunamoArgs' -ForegroundColor Green; claude.cmd --dangerously-skip-permissions --disallowedTools '' --permission-mode bypassPermissions --model sonnet"
