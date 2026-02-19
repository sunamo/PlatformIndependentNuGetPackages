param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionDir,
    [string]$VsVersion = "2022",  # EN: VS version (2022 or 2026) | CZ: VS verze (2022 nebo 2026)
    [switch]$ListOnly,
    [switch]$ForceDevenvEdit,  # EN: Force use of devenv.exe /Edit instead of DTE | CZ: Vynuť použití devenv.exe /Edit místo DTE
    [switch]$SkipConfirmation,  # EN: Skip confirmation prompt (for non-interactive execution) | CZ: Přeskoč potvrzení (pro non-interaktivní spuštění)
    [switch]$DeleteEmptyFiles,  # EN: Delete empty .cs files instead of opening them | CZ: Smaž prázdné .cs soubory místo jejich otevření
    [switch]$SkipPushToGitAndNuget  # EN: Skip auto-commit and push to git and NuGet | CZ: Přeskoč automatický commit a push do gitu a NuGetu
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
            '-SolutionDir', $SolutionDir,
            '-VsVersion', $VsVersion
        )
        if ($ListOnly) {
            $arguments += '-ListOnly'
        }
        if ($ForceDevenvEdit) {
            $arguments += '-ForceDevenvEdit'
        }
        if ($SkipConfirmation) {
            $arguments += '-SkipConfirmation'
        }
        if ($DeleteEmptyFiles) {
            $arguments += '-DeleteEmptyFiles'
        }
        if ($SkipPushToGitAndNuget) {
            $arguments += '-SkipPushToGitAndNuget'
        }

        & $powershellPath @arguments
        exit $LASTEXITCODE
    } else {
        Write-Warning "Windows PowerShell 5.1 not found at expected path. Continuing with PowerShell 7+ (COM may not work correctly)..."
    }
}

# ============================================
# FUNCTIONS / FUNKCE
# ============================================

# EN: Find VS DTE instance that has the specified solution open (iterates ALL running VS processes)
# CZ: Najdi VS DTE instanci která má otevřené zadané řešení (prochází VŠECHNY běžící VS procesy)
function Find-DTEForSolution {
    param([string]$TargetSolutionPath)

    $vsProcesses = Get-Process -Name "devenv", "DevHub" -ErrorAction SilentlyContinue
    if (-not $vsProcesses) {
        Write-Host "  No VS processes found" -ForegroundColor Yellow
        return $null
    }

    Write-Host "  Found $($vsProcesses.Count) VS process(es), searching for solution match..." -ForegroundColor Cyan

    $normalizedTarget = $TargetSolutionPath.TrimEnd('\').ToLower()

    # EN: Process-specific ProgID formats (PID-based) - more reliable than generic ones
    # CZ: ProgID formáty specifické pro proces (PID) - spolehlivější než generické
    $progIdFormats = @(
        "!VisualStudio.DTE.18.0:{0}",  # VS 2026
        "!VisualStudio.DTE.17.0:{0}",  # VS 2022
        "!VisualStudio.DTE.16.0:{0}"   # VS 2019
    )

    $fallbackDte = $null

    foreach ($proc in $vsProcesses) {
        foreach ($format in $progIdFormats) {
            $progId = $format -f $proc.Id
            try {
                $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)
                if ($null -eq $dte) { continue }

                if ($null -eq $fallbackDte) {
                    $fallbackDte = @{ DTE = $dte; ProcessId = $proc.Id; ProgID = $progId }
                }

                $slnFull = $dte.Solution.FullName
                if ([string]::IsNullOrEmpty($slnFull)) {
                    Write-Host "    PID $($proc.Id): no solution open" -ForegroundColor Gray
                    break
                }

                if ($slnFull.TrimEnd('\').ToLower() -eq $normalizedTarget) {
                    Write-Host "    PID $($proc.Id): MATCH! Solution: $slnFull" -ForegroundColor Green
                    return @{ DTE = $dte; ProcessId = $proc.Id; ProgID = $progId }
                } else {
                    Write-Host "    PID $($proc.Id): different solution: $(Split-Path -Leaf $slnFull)" -ForegroundColor Gray
                }
                break  # Got DTE for this process, try next process
            } catch {
                # EN: ProgID not registered for this process, try next format
                # CZ: ProgID není registrované pro tento proces, zkus další formát
            }
        }
    }

    if ($fallbackDte) {
        Write-Host "  WARNING: No VS instance found with matching solution. Using fallback (PID: $($fallbackDte.ProcessId))" -ForegroundColor Yellow
        return $fallbackDte
    }

    return $null
}

# EN: Find VS process with matching solution by window title and bring it to foreground
# CZ: Najdi VS proces s odpovídajícím řešením podle titulku okna a přesuň ho do popředí
function Set-VSWindowForeground {
    param([string]$TargetSolutionPath)

    $solutionName = [System.IO.Path]::GetFileNameWithoutExtension($TargetSolutionPath)
    $vsProcesses = Get-Process -Name "devenv", "DevHub" -ErrorAction SilentlyContinue

    if (-not $vsProcesses) { return $false }

    # EN: Find the process whose window title contains the solution name
    # CZ: Najdi proces jehož titulek okna obsahuje název řešení
    $matchingProc = $vsProcesses | Where-Object { $_.MainWindowTitle -like "*$solutionName*" } | Select-Object -First 1

    if (-not $matchingProc) {
        Write-Host "  WARNING: No VS window found with title containing '$solutionName'" -ForegroundColor Yellow
        Write-Host "           devenv /Edit may open files in wrong VS instance!" -ForegroundColor Yellow
        return $false
    }

    Write-Host "  Found VS window: '$($matchingProc.MainWindowTitle)' (PID: $($matchingProc.Id))" -ForegroundColor Green

    try {
        if (-not ([System.Management.Automation.PSTypeName]'VSWindowActivator').Type) {
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class VSWindowActivator {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@
        }
        [VSWindowActivator]::ShowWindow($matchingProc.MainWindowHandle, 9)  # SW_RESTORE
        [VSWindowActivator]::SetForegroundWindow($matchingProc.MainWindowHandle)
        Write-Host "  Activated VS window for solution: $solutionName" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
        return $true
    } catch {
        Write-Host "  WARNING: Could not activate VS window: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

# EN: Open files using devenv.exe /Edit command line (MOST ROBUST - works even without DTE in ROT)
# CZ: Otevři soubory pomocí devenv.exe /Edit command line (NEJROBUSTNĚJŠÍ - funguje i bez DTE v ROT)
function Open-FilesViaDevenvEdit {
    param(
        [string]$DevenvPath,
        [array]$FilesToOpen,
        [string]$SolutionPath
    )

    Write-Host "`n=== Using devenv.exe /Edit method (ROBUST) ===" -ForegroundColor Cyan
    Write-Host "This method works even if DTE is not registered in ROT!" -ForegroundColor Green
    Write-Host ""

    # EN: First, ensure solution is open in existing VS instance
    # CZ: Nejdřív zajisti že solution je otevřené v existující VS instanci
    $vsProcesses = Get-Process -Name "devenv", "DevHub" -ErrorAction SilentlyContinue
    if ($vsProcesses.Count -eq 0) {
        Write-Host "No VS instance running. Opening solution first..." -ForegroundColor Yellow
        Start-Process -FilePath $DevenvPath -ArgumentList "`"$SolutionPath`"" -Wait:$false
        Write-Host "Waiting for Visual Studio to load (20 seconds)..." -ForegroundColor Cyan
        Start-Sleep -Seconds 20
    } else {
        # EN: Activate the correct VS window (the one with matching solution) so devenv /Edit targets it
        # CZ: Aktivuj správné VS okno (to s odpovídajícím řešením) aby devenv /Edit cílil na něj
        Write-Host "Activating VS window with solution: $(Split-Path -Leaf $SolutionPath)..." -ForegroundColor Cyan
        $activated = Set-VSWindowForeground -TargetSolutionPath $SolutionPath
        if (-not $activated) {
            Write-Host "Fallback: using first running VS instance (PID: $($vsProcesses[0].Id))" -ForegroundColor Yellow
        }
        Write-Host ""
    }

    # EN: Open files in batches (devenv.exe has command line length limit)
    # CZ: Otevři soubory v dávkách (devenv.exe má limit délky command line)
    $batchSize = 20  # EN: Safe batch size / CZ: Bezpečná velikost dávky
    $totalFiles = $FilesToOpen.Count
    $batchCount = [Math]::Ceiling($totalFiles / $batchSize)

    Write-Host "Opening $totalFiles file(s) in $batchCount batch(es)..." -ForegroundColor Cyan
    Write-Host ""

    for ($i = 0; $i -lt $batchCount; $i++) {
        $start = $i * $batchSize
        $end = [Math]::Min($start + $batchSize, $totalFiles)
        $batch = $FilesToOpen[$start..($end - 1)]

        Write-Host "Batch $($i + 1)/$batchCount : Opening $($batch.Count) file(s)..." -ForegroundColor Yellow

        # EN: Build arguments - /Edit opens files in existing instance
        # CZ: Vytvoř argumenty - /Edit otevře soubory v existující instanci
        $arguments = @('/Edit') + $batch

        # EN: Start devenv.exe with /Edit - this will use existing instance
        # CZ: Spusť devenv.exe s /Edit - použije existující instanci
        try {
            Start-Process -FilePath $DevenvPath -ArgumentList $arguments -Wait:$false
            Write-Host "  Started devenv.exe /Edit for batch $($i + 1)" -ForegroundColor Green

            # EN: Wait between batches to avoid overwhelming VS
            # CZ: Počkej mezi dávkami aby VS nestihlo
            if ($i -lt $batchCount - 1) {
                Write-Host "  Waiting 2 seconds before next batch..." -ForegroundColor Gray
                Start-Sleep -Seconds 2
            }
        } catch {
            Write-Host "  ERROR: Failed to start devenv.exe: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "Done! Files should now be opening in Visual Studio." -ForegroundColor Green
    Write-Host "Note: It may take a few seconds for all files to appear." -ForegroundColor Yellow
}

# EN: Open files using DTE automation (legacy method, only works if VS is in ROT)
# CZ: Otevři soubory pomocí DTE automation (legacy metoda, funguje pouze pokud je VS v ROT)
function Open-FilesViaDTE {
    param(
        [object]$DTE,
        [array]$FilesToOpen
    )

    Write-Host "`n=== Using DTE automation method ===" -ForegroundColor Cyan
    Write-Host "Opening $($FilesToOpen.Count) files via DTE..." -ForegroundColor Cyan
    Write-Host ""

    $counter = 0
    $vsViewKindTextView = "{7651A701-06E5-11D1-8EBD-00A0C90F26EA}"

    foreach ($file in $FilesToOpen) {
        $counter++
        Write-Host "  [$counter/$($FilesToOpen.Count)] Opening: $(Split-Path -Leaf $file)" -ForegroundColor Gray

        # EN: Check if DTE is still valid before each file operation
        # CZ: Zkontroluj jestli je DTE stále platné před každou operací
        if ($null -eq $DTE -or $null -eq $DTE.ItemOperations) {
            Write-Host "    ERROR: DTE reference lost! Falling back to devenv.exe /Edit..." -ForegroundColor Red

            # EN: Fall back to devenv.exe /Edit for remaining files
            # CZ: Fallback na devenv.exe /Edit pro zbývající soubory
            $remainingFiles = $FilesToOpen[$counter-1..($FilesToOpen.Count-1)]
            $devenvPath = $DTE.FullName
            Open-FilesViaDevenvEdit -DevenvPath $devenvPath -FilesToOpen $remainingFiles -SolutionPath ""
            return
        }

        try {
            $result = $DTE.ItemOperations.OpenFile($file, $vsViewKindTextView)
            if ($null -eq $result) {
                Write-Host "      Warning: OpenFile returned null" -ForegroundColor Yellow
            }
            Start-Sleep -Milliseconds 100
        } catch {
            Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "Done! Opened $($FilesToOpen.Count) file(s) via DTE." -ForegroundColor Green
}

# ============================================
# MAIN SCRIPT / HLAVNÍ SKRIPT
# ============================================

# EN: Find Visual Studio devenv.exe (prioritize version specified in $VsVersion parameter)
# CZ: Najdi Visual Studio devenv.exe (prioritizuj verzi specifikovanou v $VsVersion parametru)
$vsEditions = @('Enterprise', 'Professional', 'Community', 'Preview')

# EN: Prioritize VS years based on $VsVersion parameter
# CZ: Prioritizuj VS roky na základě $VsVersion parametru
if ($VsVersion -eq "2026") {
    $vsYears = @('18', '2026', '2025', '2024', '2022')  # 18 = VS 2026 Preview
} else {
    $vsYears = @('2022', '2024', '2025', '2026', '18')  # Prioritize VS 2022
}

$devenvPath = $null
$vsVersionFound = $null
$isDevHub = $false

foreach ($year in $vsYears) {
    foreach ($edition in $vsEditions) {
        # EN: VS 2026+ uses DevHub.exe instead of devenv.exe at a different path
        # CZ: VS 2026+ pouziva DevHub.exe misto devenv.exe na jine ceste
        $testPathDevenv = "C:\Program Files\Microsoft Visual Studio\$year\$edition\Common7\IDE\devenv.exe"
        $testPathDevHub = "C:\Program Files\Microsoft Visual Studio\$year\$edition\Common7\ServiceHub\Hosts\ServiceHub.Host.Extensibility.amd64\DevHub.exe"

        if (Test-Path $testPathDevenv) {
            $devenvPath = $testPathDevenv
            $vsVersionFound = if ($year -eq '18') { 'VS 2026' } else { "VS $year" }
            Write-Host "Found $vsVersionFound $edition (requested: VS $VsVersion) [devenv.exe]" -ForegroundColor Green
            break
        } elseif (Test-Path $testPathDevHub) {
            $devenvPath = $testPathDevHub
            $isDevHub = $true
            $vsVersionFound = if ($year -eq '18') { 'VS 2026' } else { "VS $year" }
            Write-Host "Found $vsVersionFound $edition (requested: VS $VsVersion) [DevHub.exe]" -ForegroundColor Green
            break
        }
    }
    if ($devenvPath) { break }
}

if (-not $devenvPath) {
    Write-Error "Visual Studio not found. Searched years: $($vsYears -join ', '), editions: $($vsEditions -join ', ')"
    exit 1
}

# EN: Construct .sln path from solution directory
# CZ: Vytvoř cestu k .sln ze solution directory
if (-not (Test-Path $SolutionDir -PathType Container)) {
    Write-Error "Solution directory not found: $SolutionDir"
    exit 1
}

$folderName = Split-Path -Leaf $SolutionDir
Write-Host "Solution directory: $SolutionDir" -ForegroundColor Cyan

# EN: Search for solution file in order of priority: .sln, .slnx, .slnj
# CZ: Hledej solution soubor v poradi priority: .sln, .slnx, .slnj
$SolutionPath = $null
$solutionExtensions = @('.sln', '.slnx', '.slnj')
foreach ($ext in $solutionExtensions) {
    $testSlnPath = Join-Path $SolutionDir "$folderName$ext"
    if (Test-Path $testSlnPath) {
        $SolutionPath = $testSlnPath
        break
    }
}

if (-not $SolutionPath) {
    $searchedPaths = ($solutionExtensions | ForEach-Object { "$folderName$_" }) -join ', '
    Write-Error "Solution file not found in $SolutionDir. Searched for: $searchedPaths"
    exit 1
}

Write-Host "Found solution file: $SolutionPath" -ForegroundColor Green

$solutionDir = $SolutionDir

# EN: Parse solution file to get project paths (supports .sln, .slnx, .slnj)
# CZ: Parsuj solution soubor pro ziskani cest k projektum (podporuje .sln, .slnx, .slnj)
$slnContent = Get-Content $SolutionPath -Raw
$projectPaths = @()
$slnExtension = [System.IO.Path]::GetExtension($SolutionPath).ToLower()

if ($slnExtension -eq '.sln') {
    # EN: Classic .sln format: Project("...") = "Name", "path.csproj"
    # CZ: Klasicky .sln format
    foreach ($line in ($slnContent -split "`n")) {
        if ($line -match 'Project\(".*?"\)\s*=\s*".*?",\s*"(.*?\.csproj)"') {
            $relativeProjectPath = $matches[1]
            $absoluteProjectPath = Join-Path $solutionDir $relativeProjectPath
            if (Test-Path $absoluteProjectPath) {
                $projectPaths += $absoluteProjectPath
            }
        }
    }
} elseif ($slnExtension -eq '.slnx') {
    # EN: XML .slnx format: <Project Path="path.csproj" />
    # CZ: XML .slnx format
    [xml]$slnXml = $slnContent
    foreach ($project in $slnXml.Solution.Project) {
        $relativeProjectPath = $project.Path
        if ($relativeProjectPath -like '*.csproj') {
            $absoluteProjectPath = Join-Path $solutionDir $relativeProjectPath
            if (Test-Path $absoluteProjectPath) {
                $projectPaths += $absoluteProjectPath
            }
        }
    }
} elseif ($slnExtension -eq '.slnj') {
    # EN: JSON .slnj format: { "solution": { "projects": ["path.csproj"] } }
    # CZ: JSON .slnj format
    $slnJson = $slnContent | ConvertFrom-Json
    $jsonProjects = @()
    if ($slnJson.solution -and $slnJson.solution.projects) {
        $jsonProjects = $slnJson.solution.projects
    } elseif ($slnJson.projects) {
        $jsonProjects = $slnJson.projects
    }
    foreach ($relativeProjectPath in $jsonProjects) {
        if ($relativeProjectPath -like '*.csproj') {
            $absoluteProjectPath = Join-Path $solutionDir $relativeProjectPath
            if (Test-Path $absoluteProjectPath) {
                $projectPaths += $absoluteProjectPath
            }
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

# EN: Filter files without "// variables names: ok" and handle empty files
# CZ: Filtruj soubory bez "// variables names: ok" a zpracuj prázdné soubory
$filesToOpen = @()
$emptyFilesToDelete = @()

foreach ($file in $allCsFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue

    # EN: Handle null/empty content
    # CZ: Zpracuj null/prázdný obsah
    if ([string]::IsNullOrWhiteSpace($content)) {
        if ($DeleteEmptyFiles) {
            $emptyFilesToDelete += $file.FullName
        } else {
            $filesToOpen += $file.FullName
        }
        continue
    }

    # EN: Use regex for consistent matching with check-group.ps1
    # CZ: Použij regex pro konzistentní matching s check-group.ps1
    if ($content -notmatch '//\s*variables\s+names:\s*ok') {
        $filesToOpen += $file.FullName
    }
}

# EN: Delete empty files if requested
# CZ: Smaž prázdné soubory pokud je to požadováno
if ($DeleteEmptyFiles -and $emptyFilesToDelete.Count -gt 0) {
    Write-Host "`nFound $($emptyFilesToDelete.Count) empty .cs file(s):" -ForegroundColor Yellow
    foreach ($emptyFile in $emptyFilesToDelete) {
        Write-Host "  $emptyFile" -ForegroundColor Gray
    }

    if (-not $SkipConfirmation) {
        Write-Host "`n============================================" -ForegroundColor Red
        Write-Host "WARNING / VAROVÁNÍ:" -ForegroundColor Red
        Write-Host "============================================" -ForegroundColor Red
        Write-Host "EN: About to DELETE $($emptyFilesToDelete.Count) empty file(s)!" -ForegroundColor Yellow
        Write-Host "CZ: Chystám se SMAZAT $($emptyFilesToDelete.Count) prázdný/é soubor/y!" -ForegroundColor Yellow
        Write-Host "============================================" -ForegroundColor Red
        Write-Host ""
        $confirmation = Read-Host "EN: Proceed with deletion? (Y/N) | CZ: Pokračovat se smazáním? (Y/N)"

        if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
            Write-Host "`nDeletion cancelled." -ForegroundColor Red
            Write-Host "Smazání zrušeno." -ForegroundColor Red
            $emptyFilesToDelete = @()
        }
    }

    if ($emptyFilesToDelete.Count -gt 0) {
        Write-Host "`nDeleting empty files..." -ForegroundColor Yellow
        foreach ($emptyFile in $emptyFilesToDelete) {
            try {
                Remove-Item -Path $emptyFile -Force
                Write-Host "  DELETED: $emptyFile" -ForegroundColor Green
            } catch {
                Write-Host "  ERROR: Failed to delete $emptyFile - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        Write-Host "`nDeleted $($emptyFilesToDelete.Count) empty file(s)" -ForegroundColor Green
    }
}

Write-Host "`nFiles without '// variables names: ok': $($filesToOpen.Count)" -ForegroundColor Yellow

if ($filesToOpen.Count -eq 0) {
    Write-Host "All files contain '// variables names: ok' marker. Nothing to open." -ForegroundColor Green
    exit 0
}

# EN: Limit to max 50 files and report how many were skipped
# CZ: Omez na max 50 souborů a vypiš kolik bylo přeskočeno
$maxFilesToOpen = 50
$originalFileCount = $filesToOpen.Count
$skippedFileCount = 0

if ($filesToOpen.Count -gt $maxFilesToOpen) {
    $skippedFileCount = $filesToOpen.Count - $maxFilesToOpen
    $filesToOpen = $filesToOpen[0..($maxFilesToOpen - 1)]

    Write-Host "`n============================================" -ForegroundColor Yellow
    Write-Host "EN: File limit reached! Opening only first $maxFilesToOpen files." -ForegroundColor Yellow
    Write-Host "CZ: Dosažen limit souborů! Otevírám pouze prvních $maxFilesToOpen souborů." -ForegroundColor Yellow
    Write-Host "EN: Skipped $skippedFileCount file(s) (total was $originalFileCount)" -ForegroundColor Red
    Write-Host "CZ: Přeskočeno $skippedFileCount soubor(ů) (celkem bylo $originalFileCount)" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Yellow
    Write-Host ""
}

# EN: List files or open them
# CZ: Vypiš soubory nebo je otevři
if ($ListOnly) {
    Write-Host "`nFiles to open:" -ForegroundColor Yellow
    foreach ($file in $filesToOpen) {
        Write-Host "  $file"
    }
    if ($skippedFileCount -gt 0) {
        Write-Host "`n(... and $skippedFileCount more file(s) not shown due to limit)" -ForegroundColor Red
    }
    exit 0
}

# EN: Confirm that user closed all tabs in Visual Studio (skip if running non-interactively)
# CZ: Potvrď že uživatel zavřel všechny taby ve Visual Studio (přeskoč pokud běží non-interaktivně)
if (-not $SkipConfirmation) {
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
} else {
    Write-Host "`nSkipping confirmation (non-interactive mode)" -ForegroundColor Cyan
    Write-Host "EN: Assuming all tabs are closed in Visual Studio" -ForegroundColor Yellow
    Write-Host "CZ: Předpokládám že všechny taby jsou zavřené ve Visual Studio" -ForegroundColor Yellow
}

Write-Host "`nOpening files in Visual Studio..." -ForegroundColor Yellow
Write-Host ""

# ============================================
# DETERMINE METHOD: DTE or devenv.exe /Edit
# URČENÍ METODY: DTE nebo devenv.exe /Edit
# ============================================

$useDTE = $false
$dte = $null

if (-not $ForceDevenvEdit) {
    # EN: Search all VS instances for the one that has our solution open
    # CZ: Prohledej všechny VS instance a najdi tu která má otevřené naše řešení
    Write-Host "Searching for VS instance with solution: $(Split-Path -Leaf $SolutionPath)..." -ForegroundColor Cyan

    $dteResult = Find-DTEForSolution -TargetSolutionPath $SolutionPath

    if ($dteResult) {
        Write-Host "  SUCCESS: DTE is available via ProgID: $($dteResult.ProgID)" -ForegroundColor Green
        $dte = $dteResult.DTE
        $useDTE = $true
    } else {
        Write-Host "  DTE NOT available in ROT (common in VS 2026 Preview)" -ForegroundColor Yellow
        Write-Host "  Will use devenv.exe /Edit fallback instead" -ForegroundColor Yellow
    }
} else {
    Write-Host "ForceDevenvEdit flag set - skipping DTE detection" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# OPEN FILES USING SELECTED METHOD
# OTEVŘI SOUBORY POMOCÍ VYBRANÉ METODY
# ============================================

if ($useDTE) {
    # EN: Method 1: DTE automation (legacy, only works if VS is in ROT)
    # CZ: Metoda 1: DTE automation (legacy, funguje pouze pokud je VS v ROT)
    try {
        # EN: Ensure solution is open
        # CZ: Zajisti že solution je otevřené
        if ($dte.Solution.FullName -ne $SolutionPath) {
            Write-Host "Opening solution via DTE..." -ForegroundColor Cyan
            $dte.Solution.Open($SolutionPath)
            Write-Host "Waiting for solution to load (5 seconds)..." -ForegroundColor Cyan
            Start-Sleep -Seconds 5
        }

        Open-FilesViaDTE -DTE $dte -FilesToOpen $filesToOpen
    } catch {
        Write-Host "ERROR: DTE method failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Falling back to devenv.exe /Edit method..." -ForegroundColor Yellow
        Open-FilesViaDevenvEdit -DevenvPath $devenvPath -FilesToOpen $filesToOpen -SolutionPath $SolutionPath
    }
} else {
    # EN: Method 2: devenv.exe /Edit (ROBUST - works even without DTE in ROT!)
    # CZ: Metoda 2: devenv.exe /Edit (ROBUSTNÍ - funguje i bez DTE v ROT!)
    Open-FilesViaDevenvEdit -DevenvPath $devenvPath -FilesToOpen $filesToOpen -SolutionPath $SolutionPath
}

# EN: Auto-commit and push to git and NuGet (only if not skipped)
# CZ: Automatický commit a push do gitu a NuGetu (pouze pokud není přeskočen)
if (-not $SkipPushToGitAndNuget) {
    Write-Host "`n=== Running PushToGitAndNuget ===" -ForegroundColor Cyan
    $commitMessage = "feat: Improved code quality"

    if (Get-Command PushToGitAndNuget -ErrorAction SilentlyContinue) {
        Write-Host "Using PushToGitAndNuget function from profile" -ForegroundColor Green
        PushToGitAndNuget $commitMessage
    } else {
        Write-Host "PushToGitAndNuget function not found, calling CommandsToAllCsprojs.Cmd.exe directly" -ForegroundColor Yellow
        $exePath = "D:\SyncTrayzor\_sunamo\CommandsToAllCsprojs.Cmd\CommandsToAllCsprojs.Cmd.exe"
        if (Test-Path $exePath) {
            & $exePath "PushToGitAndNuget" $commitMessage
        } else {
            Write-Host "ERROR: CommandsToAllCsprojs.Cmd.exe not found at: $exePath" -ForegroundColor Red
        }
    }
} else {
    Write-Host "`nSkipping PushToGitAndNuget (SkipPushToGitAndNuget flag set)" -ForegroundColor Cyan
}

Write-Host "`n=== DONE ===" -ForegroundColor Green
Write-Host "All files have been queued for opening in Visual Studio." -ForegroundColor Green
Write-Host ""
