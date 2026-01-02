param(
    [string[]]$Projects
)

$cutoffDate = "2025-12-27"

function Restore-VariablesOkComment {
    param($projectPath)

    $projectName = Split-Path $projectPath -Leaf
    Write-Host "Processing $projectName..." -ForegroundColor Cyan

    # Find all .cs files
    $csFiles = Get-ChildItem -Path $projectPath -Filter "*.cs" -Recurse -File -ErrorAction SilentlyContinue

    $restoredCount = 0

    foreach ($file in $csFiles) {
        # Check if file already has the comment
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -match '//\s*variables\s+names:\s*ok') {
            continue
        }

        # Check git history for this file since cutoff date
        Push-Location $projectPath

        # Get commits that modified this file since cutoff date
        $relativePath = $file.FullName.Replace($projectPath, "").TrimStart('\')
        $commits = git log --since="$cutoffDate" --pretty=format:"%H" -- $relativePath 2>$null

        if ($commits) {
            foreach ($commit in $commits) {
                # Check if this commit had the comment
                $historicalContent = git show "${commit}:$relativePath" 2>$null

                if ($historicalContent -match '//\s*variables\s+names:\s*ok') {
                    # Add comment to the beginning (preserving existing content)
                    $lines = Get-Content -Path $file.FullName

                    # Simply add comment at the very beginning
                    $newContent = @("// variables names: ok") + $lines

                    # Write back to file (preserving encoding)
                    $newContent | Set-Content -Path $file.FullName -Encoding UTF8

                    Write-Host "  Added comment: $relativePath" -ForegroundColor Green
                    $restoredCount++
                    break
                }
            }
        }

        Pop-Location
    }

    Write-Host "${projectName}: Restored $restoredCount files" -ForegroundColor Yellow
    return $restoredCount
}

# Process all projects in parallel
$jobs = @()

foreach ($project in $Projects) {
    $projectPath = Join-Path $PSScriptRoot ".." $project

    if (-not (Test-Path $projectPath)) {
        Write-Host "Project not found: $project" -ForegroundColor Red
        continue
    }

    # Start parallel job
    $job = Start-Job -ScriptBlock {
        param($projectPath, $functionDef, $cutoffDate)

        # Define function in job scope
        Invoke-Expression $functionDef

        Restore-VariablesOkComment -projectPath $projectPath
    } -ArgumentList $projectPath, ${function:Restore-VariablesOkComment}.ToString(), $cutoffDate

    $jobs += $job
}

Write-Host "`nWaiting for all jobs to complete..." -ForegroundColor Cyan

# Wait for all jobs and collect results
$totalRestored = 0
foreach ($job in $jobs) {
    $result = Wait-Job $job | Receive-Job
    $totalRestored += $result
    Remove-Job $job
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Total files restored: $totalRestored" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
