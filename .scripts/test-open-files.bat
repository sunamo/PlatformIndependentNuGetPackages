@echo off
echo Testing Open-FilesWithoutVarOk script...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0open-files-without-var-ok.ps1" -SolutionPath "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollections\"
echo.
echo Test completed!
pause
