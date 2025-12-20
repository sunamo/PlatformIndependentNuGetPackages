# EN: Diagnostic script to find all available Visual Studio DTE objects in Running Object Table (ROT)
# CZ: Diagnostický skript pro nalezení všech dostupných Visual Studio DTE objektů v Running Object Table (ROT)

Write-Host "=== Visual Studio DTE Diagnostic Tool ===" -ForegroundColor Cyan
Write-Host ""

# EN: Find all devenv.exe processes
# CZ: Najdi všechny devenv.exe procesy
$vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue

if (-not $vsProcesses) {
    Write-Host "No Visual Studio processes found running!" -ForegroundColor Red
    exit 1
}

Write-Host "Found Visual Studio process(es):" -ForegroundColor Green
foreach ($proc in $vsProcesses) {
    Write-Host "  PID: $($proc.Id) | Path: $($proc.Path)" -ForegroundColor Gray
}
Write-Host ""

# EN: Try to enumerate Running Object Table (ROT) to find all DTE objects
# CZ: Zkus enumerovat Running Object Table (ROT) pro nalezení všech DTE objektů
Write-Host "Searching for DTE objects in Running Object Table..." -ForegroundColor Cyan
Write-Host ""

# EN: List of ProgIDs to try (including VS 2026 = DTE.20.0)
# CZ: Seznam ProgID k vyzkoušení (včetně VS 2026 = DTE.20.0)
$progIdsToTry = @(
    "VisualStudio.DTE.20.0",  # VS 2026 (possible)
    "VisualStudio.DTE.19.0",  # VS 2025 (possible)
    "VisualStudio.DTE.18.0",  # VS 2024 (possible)
    "VisualStudio.DTE.17.0",  # VS 2022
    "VisualStudio.DTE.16.0",  # VS 2019
    "VisualStudio.DTE.15.0",  # VS 2017
    "VisualStudio.DTE"        # Generic
)

Write-Host "Testing ProgIDs:" -ForegroundColor Yellow
$foundDTE = $null

foreach ($progId in $progIdsToTry) {
    try {
        Write-Host "  Trying: $progId ... " -NoNewline
        $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)

        if ($dte) {
            Write-Host "SUCCESS!" -ForegroundColor Green
            Write-Host "    Version: $($dte.Version)" -ForegroundColor Cyan
            Write-Host "    Edition: $($dte.Edition)" -ForegroundColor Cyan
            Write-Host "    FullName: $($dte.FullName)" -ForegroundColor Cyan

            if ($dte.Solution) {
                Write-Host "    Solution: $($dte.Solution.FullName)" -ForegroundColor Cyan
            }

            if (-not $foundDTE) {
                $foundDTE = @{
                    ProgID = $progId
                    DTE = $dte
                }
            }
        } else {
            Write-Host "Failed (null)" -ForegroundColor Red
        }
    } catch {
        Write-Host "Failed ($($_.Exception.Message))" -ForegroundColor Red
    }
}

Write-Host ""

# EN: Try with process-specific ProgIDs
# CZ: Zkus s process-specifickými ProgID
Write-Host "Testing process-specific ProgIDs:" -ForegroundColor Yellow

foreach ($proc in $vsProcesses) {
    Write-Host "  For PID $($proc.Id):" -ForegroundColor Gray

    $processProgIds = @(
        "!VisualStudio.DTE.20.0:$($proc.Id)",
        "!VisualStudio.DTE.19.0:$($proc.Id)",
        "!VisualStudio.DTE.18.0:$($proc.Id)",
        "!VisualStudio.DTE.17.0:$($proc.Id)",
        "!VisualStudio.DTE.16.0:$($proc.Id)"
    )

    foreach ($progId in $processProgIds) {
        try {
            Write-Host "    Trying: $progId ... " -NoNewline
            $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)

            if ($dte) {
                Write-Host "SUCCESS!" -ForegroundColor Green
                Write-Host "      Version: $($dte.Version)" -ForegroundColor Cyan

                if (-not $foundDTE) {
                    $foundDTE = @{
                        ProgID = $progId
                        DTE = $dte
                    }
                }
            } else {
                Write-Host "Failed (null)" -ForegroundColor Red
            }
        } catch {
            Write-Host "Failed" -ForegroundColor Red
        }
    }
}

Write-Host ""

if ($foundDTE) {
    Write-Host "=== SUMMARY ===" -ForegroundColor Green
    Write-Host "Found working DTE connection:" -ForegroundColor Green
    Write-Host "  ProgID: $($foundDTE.ProgID)" -ForegroundColor Cyan
    Write-Host "  Version: $($foundDTE.DTE.Version)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You should update the ProgID list in open-files-without-var-ok.ps1 to include this ProgID FIRST!" -ForegroundColor Yellow
} else {
    Write-Host "=== ERROR ===" -ForegroundColor Red
    Write-Host "Could not connect to any Visual Studio DTE object!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "  1. Visual Studio is not fully loaded yet - wait a few seconds and try again" -ForegroundColor Gray
    Write-Host "  2. Visual Studio is in a blocking dialog - close all dialogs and try again" -ForegroundColor Gray
    Write-Host "  3. VS 2026 Preview may use a different COM registration mechanism" -ForegroundColor Gray
    Write-Host "  4. PowerShell may not have proper COM access permissions" -ForegroundColor Gray
}
