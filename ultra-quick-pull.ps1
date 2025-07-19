param(
    [switch]$Force,
    [int]$ThrottleLimit = 200
)

Write-Host "Super Quick Pull - Ultra-Fast Edition" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

$startTime = Get-Date

# Find git repositories
Write-Host "Scanning for git repositories..." -ForegroundColor Yellow
$gitRepos = Get-ChildItem -Directory | Where-Object { Test-Path "$($_.FullName)\.git" }
Write-Host "Found $($gitRepos.Count) git repositories" -ForegroundColor Green
Write-Host "Starting parallel processing (ThrottleLimit: $ThrottleLimit)..." -ForegroundColor Yellow

# Process all repositories in parallel
$gitRepos | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
    $repoDir = $_.FullName
    $repoName = $_.Name
    
    try {
        Set-Location $repoDir
        
        # Skip if uncommitted changes and not forced
        if (-not $using:Force) {
            $status = git status --porcelain 2>$null
            if ($status) {
                Write-Host "$repoName - SKIPPED (uncommitted changes)" -ForegroundColor Yellow
                return
            }
        }
        
        # Fetch and check for updates
        git fetch --quiet origin 2>$null
        $behind = git rev-list --count HEAD..origin/master 2>$null
        
        if (-not $behind -or $behind -eq "0") {
            Write-Host "$repoName - Up to date" -ForegroundColor Green
            return
        }
        
        # Try fast-forward pull
        $pullResult = git pull --ff-only --quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$repoName - Updated ($behind commits)" -ForegroundColor Cyan
            return
        }
        
        # If fast-forward fails, try regular pull
        $pullResult = git pull --no-ff --quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$repoName - Merged ($behind commits)" -ForegroundColor Green
            return
        }
        
        Write-Host "$repoName - FAILED to pull" -ForegroundColor Red
        
    } catch {
        Write-Host "$repoName - ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

$elapsed = (Get-Date) - $startTime
Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host "Completed in $([math]::Round($elapsed.TotalSeconds, 1)) seconds" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
