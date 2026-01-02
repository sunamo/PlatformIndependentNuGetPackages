# Parallel submodule cloning script for PlatformIndependentNuGetPackages
# PowerShell version for Windows

Write-Host "Starting parallel submodule cloning..." -ForegroundColor Green
$submoduleCount = (git submodule status | Measure-Object -Line).Lines
Write-Host "Found $submoduleCount submodules" -ForegroundColor Yellow

# Number of parallel jobs
$maxJobs = 8

# Initialize submodules config
git submodule init

# Get all submodules
$submodules = git config --file .gitmodules --get-regexp "path" | ForEach-Object {
    if ($_ -match 'submodule\.(.+)\.path (.+)') {
        @{
            Name = $matches[1]
            Path = $matches[2]
        }
    }
}

# Script block for parallel execution
$scriptBlock = {
    param($path, $name)
    
    if (-not (Test-Path "$path\.git")) {
        Write-Host "Cloning: $path" -ForegroundColor Cyan
        git submodule update --init --recursive $path 2>&1 | ForEach-Object { "[$path] $_" }
    } else {
        Write-Host "Already exists: $path" -ForegroundColor Gray
    }
}

# Process submodules in parallel
$jobs = @()
foreach ($submodule in $submodules) {
    # Wait if we have too many jobs
    while ((Get-Job -State Running).Count -ge $maxJobs) {
        Start-Sleep -Milliseconds 100
    }
    
    $jobs += Start-Job -ScriptBlock $scriptBlock -ArgumentList $submodule.Path, $submodule.Name
}

# Wait for all jobs to complete
Write-Host "Waiting for all cloning jobs to complete..." -ForegroundColor Yellow
$jobs | Wait-Job | Out-Null

# Display results
$jobs | Receive-Job

# Clean up jobs
$jobs | Remove-Job

Write-Host "All submodules cloned successfully!" -ForegroundColor Green
Write-Host "Updating submodules to latest commits..." -ForegroundColor Yellow

# Update all submodules to their recorded commits
git submodule update --recursive

Write-Host "Done! All submodules are ready." -ForegroundColor Green