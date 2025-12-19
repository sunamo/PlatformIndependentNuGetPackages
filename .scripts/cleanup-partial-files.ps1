# EN: Delete all numbered partial class files that were incorrectly created by split script
# CZ: Smazat všechny číslované partial class soubory vytvořené špatně split skriptem

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

# SunamoString - delete SH*.cs numbered files
$path = Join-Path $rootPath "SunamoString\SunamoString"
Get-ChildItem -Path $path -Recurse -Filter "*.cs" | Where-Object { $_.Name -match '^SH\d+\.cs$' } | ForEach-Object {
    Write-Host "Deleting: $($_.FullName)" -ForegroundColor Yellow
    Remove-Item $_.FullName -Force
}

# SunamoFileSystem - delete FS*.cs and FSGetFiles*.cs numbered files
$path = Join-Path $rootPath "SunamoFileSystem\SunamoFileSystem"
Get-ChildItem -Path $path -Recurse -Filter "*.cs" | Where-Object { $_.Name -match '^(FS|FSGetFiles)\d+\.cs$' } | ForEach-Object {
    Write-Host "Deleting: $($_.FullName)" -ForegroundColor Yellow
    Remove-Item $_.FullName -Force
}

# SunamoCsproj - delete CsprojNsHelper*.cs, CsprojInstance*.cs, PropertyGroupData*.cs numbered files
$path = Join-Path $rootPath "SunamoCsproj\SunamoCsproj"
Get-ChildItem -Path $path -Recurse -Filter "*.cs" | Where-Object { $_.Name -match '^(CsprojNsHelper|CsprojInstance|PropertyGroupData)\d+\.cs$' } | ForEach-Object {
    Write-Host "Deleting: $($_.FullName)" -ForegroundColor Yellow
    Remove-Item $_.FullName -Force
}

# SunamoDotNetZip - delete all numbered .cs files
$path = Join-Path $rootPath "SunamoDotNetZip\SunamoDotNetZip"
Get-ChildItem -Path $path -Recurse -Filter "*.cs" | Where-Object { $_.Name -match '\d+\.cs$' } | ForEach-Object {
    Write-Host "Deleting: $($_.FullName)" -ForegroundColor Yellow
    Remove-Item $_.FullName -Force
}

# SunamoTidy - check for numbered files
$path = Join-Path $rootPath "SunamoTidy"
if (Test-Path $path) {
    Get-ChildItem -Path $path -Recurse -Filter "*.cs" | Where-Object { $_.Name -match '\d+\.cs$' } | ForEach-Object {
        Write-Host "Deleting: $($_.FullName)" -ForegroundColor Yellow
        Remove-Item $_.FullName -Force
    }
}

Write-Host "`nCleanup complete!" -ForegroundColor Green
