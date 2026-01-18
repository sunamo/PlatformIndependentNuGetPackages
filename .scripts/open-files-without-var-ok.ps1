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

# EN: Test if Visual Studio DTE is available in Running Object Table (ROT)
# CZ: Testuj jestli je Visual Studio DTE dostupné v Running Object Table (ROT)
function Test-DTEAvailability {
    param([int]$ProcessId)

    # EN: Try various ProgID formats
    # CZ: Zkus různé ProgID formáty
    $progIds = @(
        "VisualStudio.DTE.18.0",              # VS 2026
        "!VisualStudio.DTE.18.0:$ProcessId",  # VS 2026 (process-specific)
        "VisualStudio.DTE.17.0",              # VS 2022
        "!VisualStudio.DTE.17.0:$ProcessId",  # VS 2022 (process-specific)
        "VisualStudio.DTE"                    # Generic fallback
    )

    foreach ($progId in $progIds) {
        try {
            $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject($progId)
            if ($dte) {
                return @{
                    Available = $true
                    ProgID = $progId
                    DTE = $dte
                }
            }
        } catch {
            # EN: Continue to next ProgID
            # CZ: Pokračuj na další ProgID
        }
    }

    return @{
        Available = $false
        ProgID = $null
        DTE = $null
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
    $vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
    if ($vsProcesses.Count -eq 0) {
        Write-Host "No VS instance running. Opening solution first..." -ForegroundColor Yellow
        Start-Process -FilePath $DevenvPath -ArgumentList "`"$SolutionPath`"" -Wait:$false
        Write-Host "Waiting for Visual Studio to load (20 seconds)..." -ForegroundColor Cyan
        Start-Sleep -Seconds 20
    } else {
        Write-Host "Found running VS instance (PID: $($vsProcesses[0].Id))" -ForegroundColor Green
        Write-Host "Solution should be open: $SolutionPath" -ForegroundColor Cyan
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

foreach ($year in $vsYears) {
    foreach ($edition in $vsEditions) {
        $testPath = "C:\Program Files\Microsoft Visual Studio\$year\$edition\Common7\IDE\devenv.exe"
        if (Test-Path $testPath) {
            $devenvPath = $testPath
            $vsVersionFound = if ($year -eq '18') { 'VS 2026' } else { "VS $year" }
            Write-Host "Found $vsVersionFound $edition (requested: VS $VsVersion)" -ForegroundColor Green
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
$SolutionPath = Join-Path $SolutionDir "$folderName.sln"
Write-Host "Solution directory: $SolutionDir" -ForegroundColor Cyan
Write-Host "Looking for solution file: $SolutionPath" -ForegroundColor Cyan

# EN: Validate solution file exists
# CZ: Zkontroluj že solution soubor existuje
if (-not (Test-Path $SolutionPath)) {
    Write-Error "Solution file not found: $SolutionPath"
    exit 1
}

$solutionDir = $SolutionDir

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

    # EN: Use regex for consistent matching with generate-progress-report.ps1
    # CZ: Použij regex pro konzistentní matching s generate-progress-report.ps1
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
    # EN: Try to get DTE from Running Object Table
    # CZ: Zkus získat DTE z Running Object Table
    Write-Host "Checking if Visual Studio DTE is available in ROT..." -ForegroundColor Cyan

    $vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
    if ($vsProcesses) {
        $dteResult = Test-DTEAvailability -ProcessId $vsProcesses[0].Id

        if ($dteResult.Available) {
            Write-Host "  SUCCESS: DTE is available via ProgID: $($dteResult.ProgID)" -ForegroundColor Green
            $dte = $dteResult.DTE
            $useDTE = $true
        } else {
            Write-Host "  DTE NOT available in ROT (common in VS 2026 Preview)" -ForegroundColor Yellow
            Write-Host "  Will use devenv.exe /Edit fallback instead" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  No VS process running yet" -ForegroundColor Yellow
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
