# EN: Cleanup incorrectly split files
# CZ: Vyčistí nesprávně rozdělené soubory

Write-Host "Cleaning up split files..." -ForegroundColor Cyan

# Delete split files
$filesToDelete = @(
    "SunamoString\SunamoString\SH1.cs",
    "SunamoString\SunamoString\SH2.cs",
    "SunamoString\SunamoString\SH3.cs",
    "SunamoString\SunamoString\SH4.cs",
    "SunamoString\SunamoString\SH5.cs",
    "SunamoString\SunamoString\SH6.cs",
    "SunamoString\SunamoString\SH7.cs",
    "SunamoFileSystem\SunamoFileSystem\FS1.cs",
    "SunamoFileSystem\SunamoFileSystem\FS2.cs",
    "SunamoFileSystem\SunamoFileSystem\FS3.cs",
    "SunamoFileSystem\SunamoFileSystem\FS4.cs",
    "SunamoFileSystem\SunamoFileSystem\FS5.cs",
    "SunamoFileSystem\SunamoFileSystem\FS6.cs",
    "SunamoFileSystem\SunamoFileSystem\FS7.cs",
    "SunamoFileSystem\SunamoFileSystem\FS8.cs",
    "SunamoDotNetZip\SunamoDotNetZip\Zip\ZipFile1.cs",
    "SunamoDotNetZip\SunamoDotNetZip\Zip\ZipFile2.cs",
    "SunamoDotNetZip\SunamoDotNetZip\Zip\ZipFile3.cs",
    "SunamoDotNetZip\SunamoDotNetZip\Zip\ZipFile4.cs",
    "SunamoDotNetZip\SunamoDotNetZip\Zip\ZipFile5.cs",
    "SunamoDotNetZip\SunamoDotNetZip\Zip\ZipFile6.cs",
    "SunamoDotNetZip\SunamoDotNetZip\Zip\ZipFile7.cs",
    "SunamoShared\SunamoShared\_public\SunamoXlfKeys\XlfKeys1.cs",
    "SunamoShared\SunamoShared\_public\SunamoXlfKeys\XlfKeys2.cs",
    "SunamoShared\SunamoShared\_public\SunamoXlfKeys\XlfKeys3.cs",
    "SunamoShared\SunamoShared\_public\SunamoXlfKeys\XlfKeys4.cs",
    "SunamoShared\SunamoShared\_public\SunamoXlfKeys\XlfKeys5.cs",
    "SunamoShared\SunamoShared\_public\SunamoXlfKeys\XlfKeys6.cs",
    "SunamoShared\SunamoShared\_public\SunamoXlfKeys\XlfKeys7.cs",
    "SunamoShared\SunamoShared\_public\SunamoXlfKeys\XlfKeys8.cs",
    "SunamoShared\SunamoShared\_public\SunamoXlfKeys\XlfKeys9.cs",
    "SunamoShared\SunamoShared\_public\SunamoXlfKeys\XlfKeys10.cs"
)

foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "  Deleted: $file" -ForegroundColor Green
    }
}

# Restore original files from git
$projects = @("SunamoString", "SunamoFileSystem", "SunamoDotNetZip", "SunamoShared")

foreach ($project in $projects) {
    Write-Host "Restoring $project..." -ForegroundColor Yellow
    $gitPath = "C:\Program Files\Git\bin\git.exe"

    if (Test-Path $gitPath) {
        & $gitPath -C $project checkout .
        Write-Host "  Restored from git" -ForegroundColor Green
    } else {
        Write-Host "  Git not found at: $gitPath" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Cleanup complete!" -ForegroundColor Green
