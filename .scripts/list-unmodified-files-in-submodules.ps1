# EN: Script to open unmodified files in submodules via Visual Studio DTE, one submodule at a time with user confirmation
# CZ: Skript pro otevření nezměněných souborů v submodulech přes Visual Studio DTE, po jednom submodulu s potvrzením uživatele

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$solutionPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\PlatformIndependentNuGetPackages.sln"
Set-Location $rootPath

Write-Host "Opening unmodified files from submodules in Visual Studio..." -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

# EN: Try to get running Visual Studio instance via DTE
# CZ: Pokus o získání běžící instance Visual Studia přes DTE
$dte = $null

Write-Host "Looking for running Visual Studio instance..." -ForegroundColor Cyan

# EN: Try different Visual Studio versions (2025, 2022, 2019, 2017, generic)
# CZ: Zkusit různé verze Visual Studia (2025, 2022, 2019, 2017, generická)
$vsVersions = @(
    "VisualStudio.DTE.18.0",  # VS 2025
    "VisualStudio.DTE.17.0",  # VS 2022
    "VisualStudio.DTE.16.0",  # VS 2019
    "VisualStudio.DTE.15.0",  # VS 2017
    "VisualStudio.DTE"        # Generic fallback
)

foreach ($progId in $vsVersions) {
    try {
        Write-Host "  Trying: $progId..." -ForegroundColor Gray
        $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)
        if ($dte) {
            Write-Host "Found Visual Studio instance (Version: $($dte.Version), ProgID: $progId)" -ForegroundColor Green
            break
        }
    } catch {
        # EN: Continue to next version
        # CZ: Pokračovat na další verzi
    }
}

# EN: If still not found, try ROT enumeration with proper COM interfaces
# CZ: Pokud stále nenalezeno, zkusit enumeraci ROT se správnými COM rozhraními
if (-not $dte) {
    Write-Host "  Trying to enumerate Running Object Table..." -ForegroundColor Gray
    try {
        # EN: Use proper COM interop
        # CZ: Použít správný COM interop
        $code = @"
using System;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Collections.Generic;

public class VisualStudioLocator
{
    [DllImport("ole32.dll")]
    private static extern int CreateBindCtx(uint reserved, out IBindCtx ppbc);

    [DllImport("ole32.dll")]
    private static extern void GetRunningObjectTable(int reserved, out IRunningObjectTable prot);

    public static object GetDTE()
    {
        IRunningObjectTable rot;
        GetRunningObjectTable(0, out rot);

        IEnumMoniker enumMoniker;
        rot.EnumRunning(out enumMoniker);
        enumMoniker.Reset();

        IMoniker[] monikers = new IMoniker[1];
        IntPtr fetched = IntPtr.Zero;

        while (enumMoniker.Next(1, monikers, fetched) == 0)
        {
            IBindCtx bindCtx;
            CreateBindCtx(0, out bindCtx);

            string displayName;
            monikers[0].GetDisplayName(bindCtx, null, out displayName);

            if (displayName.Contains("VisualStudio.DTE"))
            {
                object obj;
                rot.GetObject(monikers[0], out obj);

                if (obj != null)
                {
                    return obj;
                }
            }
        }

        return null;
    }
}
"@
        Add-Type -TypeDefinition $code -ReferencedAssemblies "System.Runtime.InteropServices"

        $dteObj = [VisualStudioLocator]::GetDTE()
        if ($dteObj) {
            $dte = $dteObj
            Write-Host "Found Visual Studio instance via ROT (Version: $($dte.Version))" -ForegroundColor Green
        }
    } catch {
        Write-Host "  Error enumerating ROT: $_" -ForegroundColor Red
    }
}

# EN: If still not found, try alternative approach - search for VS process and try to attach
# CZ: Pokud stále nenalezeno, zkusit alternativní přístup - najít VS proces a zkusit se připojit
if (-not $dte) {
    Write-Host "  Trying alternative approach via process..." -ForegroundColor Gray

    # EN: Find devenv.exe processes
    # CZ: Najít devenv.exe procesy
    $vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue

    if ($vsProcesses) {
        Write-Host "  Found $($vsProcesses.Count) Visual Studio process(es)" -ForegroundColor Gray

        # EN: Try to get DTE from process using different method
        # CZ: Zkusit získat DTE z procesu jiným způsobem
        foreach ($proc in $vsProcesses) {
            try {
                # EN: Build ProgID with process ID
                # CZ: Sestavit ProgID s ID procesu
                $progIds = @(
                    "!VisualStudio.DTE.18.0:$($proc.Id)",
                    "!VisualStudio.DTE.17.0:$($proc.Id)",
                    "!VisualStudio.DTE.16.0:$($proc.Id)",
                    "!VisualStudio.DTE.15.0:$($proc.Id)"
                )

                foreach ($progId in $progIds) {
                    try {
                        Write-Host "    Trying process $($proc.Id) with $progId..." -ForegroundColor DarkGray
                        $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)
                        if ($dte) {
                            Write-Host "Found Visual Studio instance (PID: $($proc.Id), Version: $($dte.Version))" -ForegroundColor Green
                            break
                        }
                    } catch {
                        # EN: Continue to next ProgID
                        # CZ: Pokračovat na další ProgID
                    }
                }

                if ($dte) {
                    break
                }
            } catch {
                # EN: Continue to next process
                # CZ: Pokračovat na další proces
            }
        }
    } else {
        Write-Host "  No Visual Studio processes (devenv.exe) found running." -ForegroundColor Yellow
    }
}

# EN: If DTE still not found, fall back to using devenv.exe /Edit (will open new windows)
# CZ: Pokud DTE stále nenalezeno, použít fallback na devenv.exe /Edit (otevře nová okna)
$useFallbackMethod = $false
if (-not $dte) {
    Write-Host "`nWARNING: Could not connect to Visual Studio via DTE automation!" -ForegroundColor Yellow
    Write-Host "Debug info: Tried these ProgIDs:" -ForegroundColor DarkGray
    foreach ($progId in $vsVersions) {
        Write-Host "  - $progId" -ForegroundColor DarkGray
    }
    Write-Host "`nFalling back to devenv.exe /Edit method (will open files in new VS windows)" -ForegroundColor Yellow
    Write-Host "Press ENTER to continue or Ctrl+C to cancel..." -ForegroundColor Cyan
    Read-Host
    $useFallbackMethod = $true
}

# Get all submodule paths
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -replace 'submodule\..*\.path ', ''
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in this repository." -ForegroundColor Yellow
    exit
}

$totalSubmodules = $submodules.Count
$currentIndex = 0

foreach ($submodule in $submodules) {
    $currentIndex++
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        Write-Host "[$currentIndex/$totalSubmodules] Skipping $submodule - path not found" -ForegroundColor Yellow
        continue
    }

    Write-Host "`n[$currentIndex/$totalSubmodules] Processing: $submodule" -ForegroundColor Green

    Push-Location $submodulePath

    try {
        # Get all tracked files (files that are in git)
        $trackedFiles = git ls-files

        # Get files with changes (modified, added, deleted, untracked)
        $changedFiles = git status --porcelain | ForEach-Object {
            # Remove status prefix (first 3 characters like "M  ", "A  ", "?? ")
            $_.Substring(3)
        }

        # Convert to hashtable for faster lookup
        $changedFilesHash = @{}
        foreach ($file in $changedFiles) {
            $changedFilesHash[$file] = $true
        }

        # Find files that are tracked but NOT changed
        $unmodifiedFiles = $trackedFiles | Where-Object {
            -not $changedFilesHash.ContainsKey($_)
        }

        # Filter only .cs files AND files that actually exist on disk
        # EN: Filter .cs files, exclude obj/bin folders, and verify file exists
        # CZ: Filtrovat .cs soubory, vyloučit obj/bin složky a ověřit že soubor existuje
        $csFiles = $unmodifiedFiles | Where-Object {
            $_ -like "*.cs" -and
            $_ -notlike "*/obj/*" -and
            $_ -notlike "*/bin/*" -and
            (Test-Path (Join-Path $submodulePath $_))
        }

        if ($csFiles.Count -gt 0) {
            Write-Host "  Found $($csFiles.Count) unmodified .cs files" -ForegroundColor White

            # EN: Open each file - use DTE if available, otherwise fallback to devenv.exe
            # CZ: Otevřít každý soubor - použít DTE pokud je k dispozici, jinak fallback na devenv.exe
            foreach ($file in $csFiles) {
                $fullPath = Join-Path $submodulePath $file
                Write-Host "    Opening: $file" -ForegroundColor Gray

                # EN: Check if file exists before attempting to open
                # CZ: Zkontrolovat zda soubor existuje před pokusem o otevření
                if (-not (Test-Path $fullPath)) {
                    Write-Host "      Warning: File not found at path: $fullPath" -ForegroundColor Yellow
                    continue
                }

                try {
                    if ($useFallbackMethod) {
                        # EN: Use devenv.exe /Edit (opens new windows)
                        # CZ: Použít devenv.exe /Edit (otevře nová okna)
                        Start-Process "devenv.exe" -ArgumentList "/Edit `"$fullPath`"" -NoNewWindow
                        Start-Sleep -Milliseconds 200
                    } else {
                        # EN: Open file in the existing VS instance via DTE
                        # CZ: Otevřít soubor v existující VS instanci přes DTE
                        # EN: Ensure DTE object is still valid
                        # CZ: Zajistit že DTE objekt je stále platný
                        if ($null -eq $dte) {
                            Write-Host "      Error: DTE object is null" -ForegroundColor Red
                            continue
                        }

                        # EN: Use "{7651A701-06E5-11D1-8EBD-00A0C90F26EA}" which is vsViewKindTextView
                        # CZ: Použít "{7651A701-06E5-11D1-8EBD-00A0C90F26EA}" což je vsViewKindTextView
                        $result = $dte.ItemOperations.OpenFile($fullPath, "{7651A701-06E5-11D1-8EBD-00A0C90F26EA}")
                        if ($null -eq $result) {
                            Write-Host "      Warning: OpenFile returned null for: $fullPath" -ForegroundColor Yellow
                        }
                        Start-Sleep -Milliseconds 100
                    }
                } catch {
                    Write-Host "      Error opening file: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host "      Full path attempted: $fullPath" -ForegroundColor DarkGray
                }
            }

            Write-Host "`n  All files from $submodule opened in Visual Studio." -ForegroundColor Green
            Write-Host "  Press ENTER to continue to next submodule..." -ForegroundColor Yellow
            Read-Host

        } else {
            Write-Host "  No unmodified .cs files found" -ForegroundColor DarkYellow
        }

    } catch {
        Write-Host "  Error processing submodule: $_" -ForegroundColor Red
    } finally {
        Pop-Location
    }
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 80) -ForegroundColor Gray
Write-Host "Complete! Processed $totalSubmodules submodules." -ForegroundColor Cyan
