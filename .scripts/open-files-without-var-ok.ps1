param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionPath,
    [switch]$ListOnly
)

# EN: Check if running in PowerShell 7+ (pwsh) - DTE automation works better in Windows PowerShell 5.1
# CZ: Zkontroluj jestli běží v PowerShell 7+ (pwsh) - DTE automation funguje lépe v Windows PowerShell 5.1
if ($PSVersionTable.PSVersion.Major -ge 7) {
    Write-Host "Detected PowerShell 7+ - Relaunching in Windows PowerShell 5.1 for better COM compatibility..." -ForegroundColor Yellow

    $powershellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    if (Test-Path $powershellPath) {
        # EN: Relaunch this script in Windows PowerShell 5.1
        # CZ: Znovu spusť tento skript ve Windows PowerShell 5.1
        $scriptPath = $MyInvocation.MyCommand.Path

        # EN: Build arguments as array (don't use string split - it breaks quoted paths)
        # CZ: Vytvoř argumenty jako array (nepoužívej string split - rozbije to quoted cesty)
        $arguments = @(
            '-NoProfile',
            '-ExecutionPolicy', 'Bypass',
            '-File', $scriptPath,
            '-SolutionPath', $SolutionPath
        )
        if ($ListOnly) {
            $arguments += '-ListOnly'
        }

        & $powershellPath @arguments
        exit $LASTEXITCODE
    } else {
        Write-Warning "Windows PowerShell 5.1 not found at expected path. Continuing with PowerShell 7+ (COM may not work correctly)..."
    }
}

# EN: Find Visual Studio 2026 devenv.exe (prioritize VS 2026/18)
# CZ: Najdi Visual Studio 2026 devenv.exe (prioritizuj VS 2026/18)
$vsEditions = @('Enterprise', 'Professional', 'Community', 'Preview')
$vsYears = @('18', '2026', '2025', '2024', '2022')  # 18 = VS 2025/2026 Preview
$devenvPath = $null
$vsVersion = $null

foreach ($year in $vsYears) {
    foreach ($edition in $vsEditions) {
        $testPath = "C:\Program Files\Microsoft Visual Studio\$year\$edition\Common7\IDE\devenv.exe"
        if (Test-Path $testPath) {
            $devenvPath = $testPath
            $vsVersion = if ($year -eq '18') { 'VS 2026 Preview' } else { "VS $year" }
            Write-Host "Found $vsVersion $edition" -ForegroundColor Green
            break
        }
    }
    if ($devenvPath) { break }
}

if (-not $devenvPath) {
    Write-Error "Visual Studio not found. Searched years: $($vsYears -join ', '), editions: $($vsEditions -join ', ')"
    exit 1
}

# EN: If SolutionPath is a directory, construct .sln path from folder name
# CZ: Pokud je SolutionPath složka, vytvoř cestu k .sln ze jména složky
if (Test-Path $SolutionPath -PathType Container) {
    $folderName = Split-Path -Leaf $SolutionPath
    $SolutionPath = Join-Path $SolutionPath "$folderName.sln"
    Write-Host "Detected directory input. Looking for: $SolutionPath" -ForegroundColor Cyan
}

# EN: Validate solution file exists
# CZ: Zkontroluj že solution soubor existuje
if (-not (Test-Path $SolutionPath)) {
    Write-Error "Solution file not found: $SolutionPath"
    exit 1
}

$solutionDir = Split-Path -Parent $SolutionPath
Write-Host "Solution directory: $solutionDir" -ForegroundColor Cyan

# EN: Parse .sln file to get project paths
# CZ: Parsuj .sln soubor pro získání cest k projektům
$slnContent = Get-Content $SolutionPath
$projectPaths = @()

foreach ($line in $slnContent) {
    if ($line -match 'Project\(".*?"\)\s*=\s*".*?",\s*"(.*?\.csproj)"') {
        $relativeProjectPath = $matches[1]
        $absoluteProjectPath = Join-Path $solutionDir $relativeProjectPath
        if (Test-Path $absoluteProjectPath) {
            $projectPaths += $absoluteProjectPath
        }
    }
}

Write-Host "Found $($projectPaths.Count) project(s)" -ForegroundColor Cyan

# EN: Collect all .cs files from projects (excluding GlobalUsings.cs)
# CZ: Sesbírej všechny .cs soubory z projektů (kromě GlobalUsings.cs)
$allCsFiles = @()
foreach ($projectPath in $projectPaths) {
    $projectDir = Split-Path -Parent $projectPath
    $csFiles = Get-ChildItem -Path $projectDir -Filter "*.cs" -Recurse -File | Where-Object {
        $_.FullName -notmatch [regex]::Escape("\obj\") -and
        $_.FullName -notmatch [regex]::Escape("\bin\") -and
        $_.Name -ne "GlobalUsings.cs"
    }
    $allCsFiles += $csFiles
}

Write-Host "Found $($allCsFiles.Count) .cs file(s)" -ForegroundColor Cyan

# EN: Filter files without "// variables names: ok"
# CZ: Filtruj soubory bez "// variables names: ok"
$filesToOpen = @()
foreach ($file in $allCsFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    # EN: Use -notlike for simple wildcard matching (more reliable than regex in PowerShell)
    # CZ: Použij -notlike pro jednoduché wildcard matching (spolehlivější než regex v PowerShellu)
    if ($content -notlike '*variables names: ok*') {
        $filesToOpen += $file.FullName
    }
}

Write-Host "`nFiles without '// variables names: ok': $($filesToOpen.Count)" -ForegroundColor Yellow

if ($filesToOpen.Count -eq 0) {
    Write-Host "All files contain '// variables names: ok' marker. Nothing to open." -ForegroundColor Green
    exit 0
}

# EN: List files or open them
# CZ: Vypiš soubory nebo je otevři
if ($ListOnly) {
    Write-Host "`nFiles to open:" -ForegroundColor Yellow
    foreach ($file in $filesToOpen) {
        Write-Host "  $file"
    }
} else {
    # EN: Confirm that user closed all tabs in Visual Studio
    # CZ: Potvrď že uživatel zavřel všechny taby ve Visual Studio
    Write-Host "`n============================================" -ForegroundColor Red
    Write-Host "IMPORTANT / DŮLEŽITÉ:" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "EN: Please close ALL tabs in Visual Studio before continuing!" -ForegroundColor Yellow
    Write-Host "CZ: Prosím zavři VŠECHNY taby ve Visual Studio před pokračováním!" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    $confirmation = Read-Host "EN: Have you closed all tabs? (Y/N) | CZ: Zavřel jsi všechny taby? (Y/N)"

    if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
        Write-Host "`nOperation cancelled. Please close all tabs and run the script again." -ForegroundColor Red
        Write-Host "Operace zrušena. Prosím zavři všechny taby a spusť skript znovu." -ForegroundColor Red
        exit 0
    }

    Write-Host "`nOpening files in Visual Studio..." -ForegroundColor Yellow

    # EN: Function to get DTE using GetActiveObject with ProgID
    # CZ: Funkce pro získání DTE pomocí GetActiveObject s ProgID
    function Get-DTEFromProcess {
        param([int]$ProcessId)

        # EN: Try various ProgID formats with process ID
        # CZ: Zkus různé ProgID formáty s process ID
        $progIds = @(
            "!VisualStudio.DTE.19.0:$ProcessId",  # VS 2026
            "!VisualStudio.DTE.18.0:$ProcessId",  # VS 2025
            "!VisualStudio.DTE.17.0:$ProcessId",  # VS 2022
            "VisualStudio.DTE.19.0",              # VS 2026 (any instance)
            "VisualStudio.DTE.18.0",              # VS 2025 (any instance)
            "VisualStudio.DTE.17.0"               # VS 2022 (any instance)
        )

        foreach ($progId in $progIds) {
            try {
                Write-Host "    Trying ProgID: $progId..." -ForegroundColor Gray
                $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)
                if ($dte) {
                    Write-Host "    Successfully connected via ProgID: $progId" -ForegroundColor Green
                    return $dte
                }
            } catch {
                # EN: Continue to next ProgID
                # CZ: Pokračuj na další ProgID
            }
        }

        return $null
    }

    # EN: Try to get running Visual Studio 2026 instance via ROT
    # CZ: Pokus o získání běžící instance Visual Studio 2026 přes ROT
    $dte = $null

    Write-Host "Looking for running Visual Studio 2026 instance..." -ForegroundColor Cyan

    # EN: First, find devenv.exe processes from VS 2026 installation (folder 18 or 2026)
    # CZ: Nejdřív najdi devenv.exe procesy z VS 2026 instalace (složka 18 nebo 2026)
    $vs2026Processes = Get-Process -Name "devenv" -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -like "*Visual Studio\18\*" -or $_.Path -like "*Visual Studio\2026\*"
    }

    if ($vs2026Processes) {
        Write-Host "  Found $($vs2026Processes.Count) VS 2026 process(es)" -ForegroundColor Green

        # EN: Try to connect to VS 2026 process via GetActiveObject
        # CZ: Zkusit se připojit k VS 2026 procesu přes GetActiveObject
        foreach ($proc in $vs2026Processes) {
            Write-Host "  Attempting to connect to PID $($proc.Id)..." -ForegroundColor Cyan
            $dte = Get-DTEFromProcess -ProcessId $proc.Id

            if ($dte) {
                Write-Host "  Successfully connected to Visual Studio 2026 (PID: $($proc.Id), Version: $($dte.Version))" -ForegroundColor Green
                break
            } else {
                Write-Host "    Could not connect to PID $($proc.Id)" -ForegroundColor Yellow
            }
        }

        # EN: If DTE found, open solution in existing instance
        # CZ: Pokud bylo DTE nalezeno, otevři solution v existující instanci
        if ($dte) {
            Write-Host "Opening solution in existing VS 2026 instance..." -ForegroundColor Cyan
            try {
                $dte.Solution.Open($SolutionPath)
                Write-Host "Solution opened successfully!" -ForegroundColor Green
                Write-Host "Waiting for solution to fully load (8 seconds)..." -ForegroundColor Cyan
                Start-Sleep -Seconds 8

                # EN: Re-acquire DTE reference after opening solution (solution load may invalidate reference)
                # CZ: Znovu získej DTE referenci po otevření solution (načtení solution může invalidovat referenci)
                Write-Host "Re-acquiring DTE reference after solution load..." -ForegroundColor Cyan
                $tempDte = $null
                foreach ($proc in $vs2026Processes) {
                    $tempDte = Get-DTEFromProcess -ProcessId $proc.Id
                    if ($tempDte) {
                        $dte = $tempDte
                        Write-Host "  DTE reference refreshed successfully!" -ForegroundColor Green
                        break
                    }
                }

                if (-not $dte) {
                    Write-Error "Failed to re-acquire DTE reference after opening solution!"
                    exit 1
                }
            } catch {
                Write-Host "Warning: Could not open solution via DTE: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  No VS 2026 processes found running." -ForegroundColor Yellow
        Write-Host "  Checking for other VS versions..." -ForegroundColor Gray

        # EN: Fallback to any VS version if VS 2026 not running
        # CZ: Fallback na jakoukoliv verzi VS pokud VS 2026 neběží
        $vsVersions = @(
            "VisualStudio.DTE.19.0",  # VS 2026
            "VisualStudio.DTE.18.0",  # VS 2025
            "VisualStudio.DTE.17.0",  # VS 2022
            "VisualStudio.DTE"        # Generic fallback
        )

        foreach ($progId in $vsVersions) {
            try {
                Write-Host "    Trying: $progId..." -ForegroundColor Gray
                $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)
                if ($dte) {
                    Write-Host "Found Visual Studio instance (Version: $($dte.Version), ProgID: $progId)" -ForegroundColor Yellow
                    Write-Host "WARNING: This is NOT VS 2026! Files will open in different VS version." -ForegroundColor Red
                    break
                }
            } catch {
                # EN: Continue to next version
                # CZ: Pokračovat na další verzi
            }
        }
    }

    # EN: Determine which method to use - CRITICAL: Must connect to DTE BEFORE opening files
    # CZ: Určit kterou metodu použít - KRITICKÉ: Musíme se připojit k DTE PŘED otevřením souborů
    $vs2026IsRunning = $vs2026Processes.Count -gt 0

    # EN: If no DTE connection yet and VS is running, retry connection BEFORE starting to open files
    # CZ: Pokud ještě není DTE připojení a VS běží, zkus se připojit PŘED začátkem otevírání souborů
    if (-not $dte -and $vs2026IsRunning) {
        Write-Host "`nVS 2026 is running but no DTE connection yet. Retrying connection..." -ForegroundColor Yellow
        Write-Host "Waiting for VS to be ready (5 seconds)..." -ForegroundColor Cyan
        Start-Sleep -Seconds 5

        # EN: Try to connect via ROT to the VS instance - THIS MUST SUCCEED BEFORE OPENING FILES
        # CZ: Zkus se připojit přes ROT k VS instanci - TOTO MUSÍ USPĚT PŘED OTEVŘENÍM SOUBORŮ
        Write-Host "Attempting to connect via ROT..." -ForegroundColor Cyan
        $retryCount = 0
        $maxRetries = 10
        while (-not $dte -and $retryCount -lt $maxRetries) {
            $retryCount++
            Write-Host "  Retry $retryCount of ${maxRetries}..." -ForegroundColor Gray

            # EN: Get all devenv processes (any VS version now)
            # CZ: Získej všechny devenv procesy (jakákoliv verze VS)
            $allVsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue

            foreach ($proc in $allVsProcesses) {
                $dte = Get-DTEFromProcess -ProcessId $proc.Id
                if ($dte) {
                    Write-Host "Successfully connected to Visual Studio via ROT (PID: $($proc.Id))!" -ForegroundColor Green

                    # EN: Open solution in connected instance if not already open
                    # CZ: Otevři solution v připojené instanci pokud ještě není otevřené
                    if ($dte.Solution.FullName -ne $SolutionPath) {
                        Write-Host "Opening solution in existing instance..." -ForegroundColor Cyan
                        try {
                            $dte.Solution.Open($SolutionPath)
                            Write-Host "Waiting for solution to load (3 seconds)..." -ForegroundColor Cyan
                            Start-Sleep -Seconds 3
                        } catch {
                            Write-Host "  Warning: Could not open solution: $($_.Exception.Message)" -ForegroundColor Yellow
                        }
                    }
                    break
                }
            }

            if ($dte) {
                break
            }

            if ($retryCount -lt $maxRetries) {
                Start-Sleep -Seconds 2
            }
        }

        if (-not $dte) {
            Write-Error "FATAL: Could not connect to Visual Studio via DTE after $maxRetries retries!"
            Write-Host "Please ensure Visual Studio is fully loaded and responsive." -ForegroundColor Red
            exit 1
        }
    }

    # EN: If still no VS running, start new instance with solution
    # CZ: Pokud stále neběží žádné VS, spusť novou instanci s solution
    if (-not $dte -and -not $vs2026IsRunning) {
        Write-Host "`nNo VS instance running. Starting new VS 2026 instance with solution..." -ForegroundColor Cyan
        $vsProcess = Start-Process -FilePath $devenvPath -ArgumentList "`"$SolutionPath`"" -PassThru
        Write-Host "Waiting for Visual Studio to fully load (15 seconds)..." -ForegroundColor Cyan
        Start-Sleep -Seconds 15

        # EN: Try to connect to the newly started instance
        # CZ: Zkus se připojit k nově spuštěné instanci
        $retryCount = 0
        $maxRetries = 10
        while (-not $dte -and $retryCount -lt $maxRetries) {
            $retryCount++
            Write-Host "  Connecting to new instance, retry $retryCount of ${maxRetries}..." -ForegroundColor Gray

            $allVsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
            foreach ($proc in $allVsProcesses) {
                $dte = Get-DTEFromProcess -ProcessId $proc.Id
                if ($dte) {
                    Write-Host "Successfully connected to new Visual Studio instance!" -ForegroundColor Green
                    break
                }
            }

            if ($dte) {
                break
            }

            if ($retryCount -lt $maxRetries) {
                Start-Sleep -Seconds 2
            }
        }

        if (-not $dte) {
            Write-Error "FATAL: Could not connect to newly started Visual Studio instance!"
            exit 1
        }
    }

    # EN: At this point we MUST have a DTE connection
    # CZ: V tomto bodě MUSÍME mít DTE připojení
    if (-not $dte) {
        Write-Error "FATAL: No DTE connection available. Cannot open files."
        exit 1
    }

    # EN: Open files using DTE automation
    # CZ: Otevři soubory pomocí DTE automation
    Write-Host "`nOpening $($filesToOpen.Count) files via DTE..." -ForegroundColor Cyan
    $counter = 0

    foreach ($file in $filesToOpen) {
        $counter++
        Write-Host "  [$counter/$($filesToOpen.Count)] Opening: $(Split-Path -Leaf $file)" -ForegroundColor Gray

        # EN: Check if DTE is still valid before each file operation
        # CZ: Zkontroluj jestli je DTE stále platné před každou operací se souborem
        if ($null -eq $dte -or $null -eq $dte.ItemOperations) {
            Write-Host "      DTE reference lost (DTE null: $($null -eq $dte), ItemOps null: $($null -eq $dte.ItemOperations)), re-acquiring..." -ForegroundColor Yellow

            # EN: Retry up to 3 times to get valid DTE with ItemOperations
            # CZ: Zkus až 3x získat platné DTE s ItemOperations
            $retryCount = 0
            $maxRetries = 3
            $validDte = $null

            while ($retryCount -lt $maxRetries -and $null -eq $validDte) {
                $retryCount++
                Write-Host "      Re-acquire attempt $retryCount of $maxRetries..." -ForegroundColor Gray

                $allVsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
                foreach ($proc in $allVsProcesses) {
                    $tempDte = Get-DTEFromProcess -ProcessId $proc.Id
                    if ($tempDte) {
                        # EN: Try to dismiss any open dialogs by sending Escape key to VS window
                        # CZ: Zkus zavřít případné otevřené dialogy posláním Escape do VS okna
                        try {
                            Add-Type -AssemblyName System.Windows.Forms
                            $vsWindows = Get-Process -Name "devenv" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 }
                            foreach ($vsWin in $vsWindows) {
                                # EN: Send Escape key to close any blocking dialog
                                # CZ: Pošli Escape pro zavření blokujícího dialogu
                                $wshell = New-Object -ComObject WScript.Shell
                                $wshell.AppActivate($vsWin.Id) | Out-Null
                                Start-Sleep -Milliseconds 500
                                $wshell.SendKeys("{ESC}")
                                Start-Sleep -Milliseconds 500
                            }
                        } catch {
                            # EN: Ignore errors from SendKeys
                            # CZ: Ignoruj chyby z SendKeys
                        }

                        # EN: Wait for ItemOperations to become available
                        # CZ: Počkej až bude ItemOperations dostupné
                        Start-Sleep -Seconds 2

                        if ($null -ne $tempDte.ItemOperations) {
                            $validDte = $tempDte
                            Write-Host "      DTE reference refreshed with valid ItemOperations!" -ForegroundColor Green
                            break
                        } else {
                            Write-Host "      DTE obtained but ItemOperations still null, retrying..." -ForegroundColor Yellow
                        }
                    }
                }

                if ($null -eq $validDte -and $retryCount -lt $maxRetries) {
                    Write-Host "      Waiting 3 seconds before retry..." -ForegroundColor Gray
                    Start-Sleep -Seconds 3
                }
            }

            if ($null -eq $validDte) {
                Write-Host "      ERROR: Could not re-acquire valid DTE reference after $maxRetries attempts. Skipping remaining files." -ForegroundColor Red
                break
            }

            $dte = $validDte
        }

        try {
            # EN: Use DTE automation to open in existing instance - vsViewKindTextView GUID
            # CZ: Použít DTE automation pro otevření v existující instanci - vsViewKindTextView GUID
            $result = $dte.ItemOperations.OpenFile($file, "{7651A701-06E5-11D1-8EBD-00A0C90F26EA}")
            if ($null -eq $result) {
                Write-Host "      Warning: OpenFile returned null for: $file" -ForegroundColor Yellow
            }
            Start-Sleep -Milliseconds 100
        } catch {
            Write-Host "      Error opening file: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`nDone! Opened $($filesToOpen.Count) file(s) in Visual Studio." -ForegroundColor Green
}
