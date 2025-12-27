param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath
)

# EN: Load Windows Forms for MessageBox
# CZ: Načíst Windows Forms pro MessageBox
Add-Type -AssemblyName System.Windows.Forms

# EN: Check if file exists
# CZ: Zkontrolovat zda soubor existuje
if (-not (Test-Path $FilePath)) {
    [System.Windows.Forms.MessageBox]::Show(
        "File does not exist!`n`nCZ: Soubor neexistuje!`n`nPath: $FilePath",
        "Error / Chyba",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}

# EN: Get file info for display
# CZ: Získat info o souboru pro zobrazení
$fileInfo = Get-Item $FilePath
$fileName = $fileInfo.Name
$fileDir = $fileInfo.DirectoryName

# EN: Show confirmation dialog
# CZ: Zobrazit potvrzovací dialog
$message = @"
Do you really want to DELETE this file?
CZ: Opravdu chcete SMAZAT tento soubor?

File / Soubor: $fileName
Path / Cesta: $fileDir

This action CANNOT be undone!
CZ: Tuto akci NELZE vrátit zpět!
"@

$result = [System.Windows.Forms.MessageBox]::Show(
    $message,
    "Delete File Confirmation / Potvrzení smazání souboru",
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Warning,
    [System.Windows.Forms.MessageBoxDefaultButton]::Button1  # EN: Default to "Yes" / CZ: Výchozí "Ano"
)

# EN: If user clicked Yes, delete the file
# CZ: Pokud uživatel klikl na Ano, smazat soubor
if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
    try {
        Remove-Item -Path $FilePath -Force

        [System.Windows.Forms.MessageBox]::Show(
            "File deleted successfully!`n`nCZ: Soubor úspěšně smazán!`n`nDeleted / Smazáno: $fileName",
            "Success / Úspěch",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )

        Write-Host "File deleted successfully: $FilePath" -ForegroundColor Green
        exit 0
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to delete file!`n`nCZ: Selhalo smazání souboru!`n`nError / Chyba: $($_.Exception.Message)",
            "Error / Chyba",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )

        Write-Host "Failed to delete file: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}
else {
    [System.Windows.Forms.MessageBox]::Show(
        "File deletion cancelled.`n`nCZ: Smazání souboru zrušeno.",
        "Cancelled / Zrušeno",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )

    Write-Host "File deletion cancelled by user." -ForegroundColor Yellow
    exit 0
}
