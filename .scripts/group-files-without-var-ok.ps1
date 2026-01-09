param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionDir
)

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

Write-Host "Found $($allCsFiles.Count) .cs file(s) (total)" -ForegroundColor Cyan
Write-Host ""

# EN: Filter files without "// variables names: ok" comment
# CZ: Filtruj soubory bez "// variables names: ok" komentáře
$filesWithoutOk = @()

foreach ($file in $allCsFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue

    # EN: Use regex for consistent matching
    # CZ: Použij regex pro konzistentní matching
    if ($content -notmatch '//\s*variables\s+names:\s*ok') {
        $filesWithoutOk += $file.FullName
    }
}

$totalFilesWithoutOk = $filesWithoutOk.Count

if ($totalFilesWithoutOk -eq 0) {
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "All files contain '// variables names: ok' marker!" -ForegroundColor Green
    Write-Host "Všechny soubory obsahují '// variables names: ok' značku!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    exit 0
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Files Without '// variables names: ok' - Grouped by 10" -ForegroundColor Yellow
Write-Host "Soubory bez '// variables names: ok' - Seskupené po 10 skupinách" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total files without OK marker: $totalFilesWithoutOk" -ForegroundColor White
Write-Host "Celkem souborů bez OK značky: $totalFilesWithoutOk" -ForegroundColor White
Write-Host ""

# EN: Calculate group size (divide by 10)
# CZ: Vypočítej velikost skupiny (dělit 10)
$groupSize = [Math]::Ceiling($totalFilesWithoutOk / 10.0)
Write-Host "Group size: $groupSize files per group" -ForegroundColor Cyan
Write-Host "Velikost skupiny: $groupSize souborů na skupinu" -ForegroundColor Cyan
Write-Host ""

# EN: Divide files into 10 groups
# CZ: Rozděl soubory do 10 skupin
for ($groupIndex = 0; $groupIndex -lt 10; $groupIndex++) {
    $startIndex = $groupIndex * $groupSize
    $endIndex = [Math]::Min($startIndex + $groupSize - 1, $totalFilesWithoutOk - 1)

    # EN: Skip empty groups (if total files < 10)
    # CZ: Přeskoč prázdné skupiny (pokud celkový počet souborů < 10)
    if ($startIndex -ge $totalFilesWithoutOk) {
        break
    }

    $groupNumber = $groupIndex + 1
    $filesInGroup = $filesWithoutOk[$startIndex..$endIndex]

    Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "Group $groupNumber / Skupina $groupNumber ($($filesInGroup.Count) files / souborů)" -ForegroundColor Green
    Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

    $fileNumber = 1
    foreach ($file in $filesInGroup) {
        # EN: Display relative path from solution directory
        # CZ: Zobraz relativní cestu od solution directory
        $relativePath = $file.Replace($solutionDir, "").TrimStart('\')
        Write-Host "  $fileNumber. $relativePath" -ForegroundColor Gray
        $fileNumber++
    }
    Write-Host ""
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Done! / Hotovo!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# EN: Return exit code 0 for success
# CZ: Vrať exit code 0 pro úspěch
exit 0
