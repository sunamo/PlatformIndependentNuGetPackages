param(
    [string[]]$Projects
)

$cutoffDate = "2025-12-26"
$totalRestored = 0
$processedProjects = 0

foreach ($project in $Projects) {
    $processedProjects++
    $projectPath = Join-Path $PSScriptRoot ".." $project

    if (-not (Test-Path $projectPath)) {
        Write-Host "[$processedProjects/$($Projects.Count)] Project not found: $project" -ForegroundColor Red
        continue
    }

    Write-Host "[$processedProjects/$($Projects.Count)] Processing $project..." -ForegroundColor Cyan

    # Find all .cs files
    $csFiles = Get-ChildItem -Path $projectPath -Filter "*.cs" -Recurse -File -ErrorAction SilentlyContinue

    $restoredCount = 0
    $filesChecked = 0

    foreach ($file in $csFiles) {
        $filesChecked++

        # Check if file already has the comment
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -match '//\s*variables\s+names:\s*ok') {
            continue
        }

        # Check if file EVER had the comment in git history (using git log -S)
        Push-Location $projectPath

        # Get proper relative path
        $relativePath = [System.IO.Path]::GetRelativePath($projectPath, $file.FullName).Replace('\', '/')

        # Find commits where this text was added/removed (since 26.12.2025)
        $commits = git log -S "// variables names: ok" --since="$cutoffDate" --format="%H" -- $relativePath 2>$null

        Write-Host "  Checking: $relativePath - commits found: $(if ($commits) { ($commits | Measure-Object).Count } else { 0 })" -ForegroundColor DarkGray

        if ($commits) {
            # Check commits from oldest to newest to find the one that HAD the comment
            $commitsArray = $commits | ForEach-Object { $_ }
            [array]::Reverse($commitsArray)

            foreach ($commit in $commitsArray) {
                $historicalContent = git show "${commit}:$relativePath" 2>$null

                if ($historicalContent -match '//\s*variables\s+names:\s*ok') {
                    # Found a commit that had the comment - add it back
                    $lines = Get-Content -Path $file.FullName

                    # Simply add comment at the very beginning
                    $newContent = @("// variables names: ok") + $lines

                    # Write back to file
                    $newContent | Set-Content -Path $file.FullName -Encoding UTF8

                    Write-Host "  + $relativePath" -ForegroundColor Green
                    $restoredCount++
                    break
                }
            }
        }

        Pop-Location
    }

    if ($restoredCount -gt 0) {
        Write-Host "  ${project}: Added comments to $restoredCount files" -ForegroundColor Yellow
    } else {
        Write-Host "  ${project}: No files to restore" -ForegroundColor Gray
    }

    $totalRestored += $restoredCount
}

Write-Host ""
Write-Host "========================================"  -ForegroundColor Green
Write-Host "Total files with comment added: $totalRestored" -ForegroundColor Green
Write-Host "========================================"  -ForegroundColor Green
