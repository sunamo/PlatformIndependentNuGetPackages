# EN: Simple check if Visual Studio is registered in Running Object Table (ROT)
# CZ: Jednoduchá kontrola jestli je Visual Studio zaregistrované v Running Object Table (ROT)

Write-Host "=== Visual Studio ROT Check ===" -ForegroundColor Cyan
Write-Host ""

# EN: Find all Visual Studio processes
# CZ: Najdi všechny Visual Studio procesy
$vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue

if (-not $vsProcesses) {
    Write-Host "No Visual Studio processes found!" -ForegroundColor Red
    exit 1
}

Write-Host "Found Visual Studio process(es):" -ForegroundColor Green
foreach ($proc in $vsProcesses) {
    $vsPath = $proc.Path
    $vsVersion = "Unknown"

    # EN: Detect version from path
    # CZ: Detekuj verzi z cesty
    if ($vsPath -match "\\18\\") { $vsVersion = "2026 (v18)" }
    elseif ($vsPath -match "\\2026\\") { $vsVersion = "2026" }
    elseif ($vsPath -match "\\17\\") { $vsVersion = "2022 (v17)" }
    elseif ($vsPath -match "\\2022\\") { $vsVersion = "2022" }

    Write-Host "  PID: $($proc.Id) | Version: $vsVersion" -ForegroundColor Gray
    Write-Host "  Path: $vsPath" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Testing DTE connection with GetActiveObject..." -ForegroundColor Cyan
Write-Host ""

# EN: Test various ProgID combinations
# CZ: Testuj různé kombinace ProgID
$progIdsGeneric = @(
    @{ ProgID = "VisualStudio.DTE.18.0"; Description = "VS 2026 (generic)" },
    @{ ProgID = "VisualStudio.DTE.17.0"; Description = "VS 2022 (generic)" },
    @{ ProgID = "VisualStudio.DTE.16.0"; Description = "VS 2019 (generic)" },
    @{ ProgID = "VisualStudio.DTE"; Description = "Any VS version" }
)

$foundGeneric = $false

foreach ($item in $progIdsGeneric) {
    $progId = $item.ProgID
    $desc = $item.Description

    Write-Host "  Testing: $progId ($desc) ... " -NoNewline

    try {
        $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)

        if ($dte) {
            Write-Host "SUCCESS!" -ForegroundColor Green

            try {
                Write-Host "    Version: $($dte.Version)" -ForegroundColor Cyan
                Write-Host "    Edition: $($dte.Edition)" -ForegroundColor Cyan

                if ($dte.Solution -and $dte.Solution.FullName) {
                    Write-Host "    Solution: $($dte.Solution.FullName)" -ForegroundColor Cyan
                } else {
                    Write-Host "    Solution: (none loaded)" -ForegroundColor Yellow
                }

                Write-Host "    MainWindow.Visible: $($dte.MainWindow.Visible)" -ForegroundColor Cyan
            } catch {
                Write-Host "    (Could not read DTE properties: $($_.Exception.Message))" -ForegroundColor Yellow
            }

            $foundGeneric = $true
            Write-Host ""
        } else {
            Write-Host "FAILED (returned null)" -ForegroundColor Red
        }
    } catch {
        Write-Host "FAILED" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Testing process-specific ProgIDs..." -ForegroundColor Cyan
Write-Host ""

$foundProcessSpecific = $false

foreach ($proc in $vsProcesses) {
    Write-Host "  For PID $($proc.Id):" -ForegroundColor Yellow

    $progIdsSpecific = @(
        "!VisualStudio.DTE.18.0:$($proc.Id)",
        "!VisualStudio.DTE.17.0:$($proc.Id)",
        "!VisualStudio.DTE.16.0:$($proc.Id)"
    )

    foreach ($progId in $progIdsSpecific) {
        Write-Host "    Testing: $progId ... " -NoNewline

        try {
            $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)

            if ($dte) {
                Write-Host "SUCCESS!" -ForegroundColor Green

                try {
                    Write-Host "      Version: $($dte.Version)" -ForegroundColor Cyan
                } catch {
                    Write-Host "      (Could not read version)" -ForegroundColor Yellow
                }

                $foundProcessSpecific = $true
            } else {
                Write-Host "FAILED (null)" -ForegroundColor Red
            }
        } catch {
            Write-Host "FAILED" -ForegroundColor Red
        }
    }
    Write-Host ""
}

Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host ""

if ($foundGeneric -or $foundProcessSpecific) {
    Write-Host "SUCCESS: Visual Studio IS registered in ROT and accessible!" -ForegroundColor Green
    Write-Host ""
    Write-Host "The open-files-without-var-ok.ps1 script SHOULD work." -ForegroundColor Green
} else {
    Write-Host "FAILURE: Visual Studio is NOT accessible via DTE!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "  1. Visual Studio is still loading - wait 10-20 seconds and try again" -ForegroundColor Gray
    Write-Host "  2. Visual Studio is in a blocking dialog - close all dialogs" -ForegroundColor Gray
    Write-Host "  3. Visual Studio is waiting for user input" -ForegroundColor Gray
    Write-Host "  4. Try restarting Visual Studio completely" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Suggested actions:" -ForegroundColor Yellow
    Write-Host "  1. Make sure NO dialogs are open in Visual Studio" -ForegroundColor Cyan
    Write-Host "  2. Make sure a solution is loaded (not just welcome screen)" -ForegroundColor Cyan
    Write-Host "  3. Wait a few more seconds after VS startup" -ForegroundColor Cyan
    Write-Host "  4. Try pressing ESC in VS to dismiss any hidden dialogs" -ForegroundColor Cyan
}

Write-Host ""
