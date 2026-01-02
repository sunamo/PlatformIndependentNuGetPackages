#!/usr/bin/env pwsh

param(
    [int]$ThrottleLimit = 50
)

Write-Host "Force Push All Submodules - Ultra-Aggressive Edition" -ForegroundColor Red
Write-Host "===================================================" -ForegroundColor Red
Write-Host "WARNING: This will FORCE PUSH all repositories!" -ForegroundColor Yellow
Write-Host "Local versions will OVERWRITE remote versions!" -ForegroundColor Yellow
Write-Host "===================================================" -ForegroundColor Red

$startTime = Get-Date

# Find git repositories
Write-Host "Scanning for git repositories..." -ForegroundColor Yellow
$gitRepos = Get-ChildItem -Directory | Where-Object { Test-Path "$($_.FullName)\.git" }
Write-Host "Found $($gitRepos.Count) git repositories" -ForegroundColor Green
Write-Host "Starting parallel force push processing (ThrottleLimit: $ThrottleLimit)..." -ForegroundColor Yellow

# Collections for results
$forcePushed = [System.Collections.Concurrent.ConcurrentBag[string]]::new()
$upToDate = [System.Collections.Concurrent.ConcurrentBag[string]]::new()
$failed = [System.Collections.Concurrent.ConcurrentBag[string]]::new()

# Process all repositories in parallel
$gitRepos | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
    $repoDir = $_.FullName
    $repoName = $_.Name
    
    # Import concurrent collections
    $forcePushed = $using:forcePushed
    $upToDate = $using:upToDate
    $failed = $using:failed
    
    try {
        Set-Location $repoDir
        
        # Add all changes (if any)
        git add -A 2>$null
        
        # Commit any uncommitted changes
        $status = git status --porcelain 2>$null
        if ($status) {
            Write-Host "$repoName - Committing local changes..." -ForegroundColor Yellow
            git commit -m "Auto-commit before force push" 2>$null
        }
        
        # Get current branch
        $currentBranch = git branch --show-current 2>$null
        if (-not $currentBranch) {
            $currentBranch = "master"
        }
        
        # Fetch to get latest remote info
        git fetch --all --quiet 2>$null
        
        # Check if we have any commits to push
        $localCommits = git rev-list --count HEAD 2>$null
        if (-not $localCommits -or $localCommits -eq "0") {
            Write-Host "$repoName - No commits to push" -ForegroundColor Gray
            $upToDate.Add($repoName)
            return
        }
        
        # Force push - this will overwrite remote with local version
        Write-Host "$repoName - FORCE PUSHING to $currentBranch..." -ForegroundColor Red
        $pushResult = git push --force origin $currentBranch 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$repoName - ✓ FORCE PUSHED successfully" -ForegroundColor Cyan
            $forcePushed.Add("$repoName (branch: $currentBranch)")
        } else {
            Write-Host "$repoName - ✗ FAILED to force push" -ForegroundColor Red
            $failed.Add("$repoName - $pushResult")
        }
        
    } catch {
        Write-Host "$repoName - ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $failed.Add("$repoName - Exception: $($_.Exception.Message)")
    }
}

$elapsed = (Get-Date) - $startTime

# Summary
Write-Host "`n===================================================" -ForegroundColor Red
Write-Host "FORCE PUSH SUMMARY" -ForegroundColor Red
Write-Host "===================================================" -ForegroundColor Red

if ($forcePushed.Count -gt 0) {
    Write-Host "`nFORCE PUSHED ($($forcePushed.Count)):" -ForegroundColor Green
    $forcePushed | Sort-Object | ForEach-Object { Write-Host "  ✓ $_" -ForegroundColor Green }
}

if ($upToDate.Count -gt 0) {
    Write-Host "`nNO COMMITS TO PUSH ($($upToDate.Count)):" -ForegroundColor Gray
    $upToDate | Sort-Object | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }
}

if ($failed.Count -gt 0) {
    Write-Host "`nFAILED ($($failed.Count)):" -ForegroundColor Red
    $failed | Sort-Object | ForEach-Object { Write-Host "  ✗ $_" -ForegroundColor Red }
}

Write-Host "`n===================================================" -ForegroundColor Red
Write-Host "Completed in $([math]::Round($elapsed.TotalSeconds, 1)) seconds" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Red

# Exit with error code if any pushes failed
if ($failed.Count -gt 0) {
    exit 1
}
