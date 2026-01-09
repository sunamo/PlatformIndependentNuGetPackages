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

# EN: Count files with and without "// variables names: ok" comment
# CZ: Spočítej soubory s a bez "// variables names: ok" komentářem
$filesWithOk = 0
$filesWithoutOk = 0

foreach ($file in $allCsFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue

    # EN: Use regex for consistent matching with open-files-without-var-ok.ps1
    # CZ: Použij regex pro konzistentní matching s open-files-without-var-ok.ps1
    if ($content -match '//\s*variables\s+names:\s*ok') {
        $filesWithOk++
    } else {
        $filesWithoutOk++
    }
}

# EN: Display statistics
# CZ: Zobraz statistiky
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Variable Names OK Statistics" -ForegroundColor Green
Write-Host "Statistiky Variable Names OK" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total .cs files (excluding GlobalUsings.cs, bin, obj):" -ForegroundColor Yellow
Write-Host "Celkem .cs souborů (kromě GlobalUsings.cs, bin, obj):" -ForegroundColor Yellow
Write-Host "  $($allCsFiles.Count) files / souborů" -ForegroundColor White
Write-Host ""
Write-Host "Files WITH '// variables names: ok' comment:" -ForegroundColor Green
Write-Host "Soubory S '// variables names: ok' komentářem:" -ForegroundColor Green
Write-Host "  $filesWithOk files / souborů ($([math]::Round($filesWithOk / $allCsFiles.Count * 100, 2))%)" -ForegroundColor White
Write-Host ""
Write-Host "Files WITHOUT '// variables names: ok' comment:" -ForegroundColor Red
Write-Host "Soubory BEZ '// variables names: ok' komentáře:" -ForegroundColor Red
Write-Host "  $filesWithoutOk files / souborů ($([math]::Round($filesWithoutOk / $allCsFiles.Count * 100, 2))%)" -ForegroundColor White
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# EN: Return exit code 0 for success
# CZ: Vrať exit code 0 pro úspěch
exit 0
