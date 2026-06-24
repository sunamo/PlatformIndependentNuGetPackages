#!/usr/bin/env pwsh

param(
    [switch]$Force,
    [int]$ThrottleLimit = 200
)

Write-Host "Super Quick Push - Ultra-Fast Edition" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

$startTime = Get-Date

# Find git repositories
Write-Host "Scanning for git repositories..." -ForegroundColor Yellow
$gitRepos = Get-ChildItem -Directory | Where-Object { Test-Path "$($_.FullName)\.git" }
Write-Host "Found $($gitRepos.Count) git repositories" -ForegroundColor Green
Write-Host "Starting parallel processing (ThrottleLimit: $ThrottleLimit)..." -ForegroundColor Yellow

# Collections for results
$pushed = [System.Collections.Concurrent.ConcurrentBag[string]]::new()
$upToDate = [System.Collections.Concurrent.ConcurrentBag[string]]::new()
$failed = [System.Collections.Concurrent.ConcurrentBag[string]]::new()
$skipped = [System.Collections.Concurrent.ConcurrentBag[string]]::new()

# Process all repositories in parallel
$gitRepos | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
    $repoDir = $_.FullName
    $repoName = $_.Name
    
    # Import concurrent collections
    $pushed = $using:pushed
    $upToDate = $using:upToDate
    $failed = $using:failed
    $skipped = $using:skipped
    
    try {
        Set-Location $repoDir
        
        # Skip if uncommitted changes and not forced
        if (-not $using:Force) {
            $status = git status --porcelain 2>$null
            if ($status) {
                Write-Host "$repoName - SKIPPED (uncommitted changes)" -ForegroundColor Yellow
                $skipped.Add($repoName)
                return
            }
        }
        
        # Check if we're ahead of origin
        git fetch --quiet origin 2>$null
        $ahead = git rev-list --count HEAD ^origin/master 2>$null
        
        if (-not $ahead -or $ahead -eq "0") {
            Write-Host "$repoName - Up to date" -ForegroundColor Green
            $upToDate.Add($repoName)
            return
        }
        
        # Push the commits
        Write-Host "$repoName - Pushing $ahead commit(s)..." -ForegroundColor Yellow
        $pushResult = git push origin master 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$repoName - ✓ Pushed $ahead commit(s)" -ForegroundColor Cyan
            $pushed.Add("$repoName ($ahead commits)")
        } else {
            Write-Host "$repoName - ✗ FAILED to push" -ForegroundColor Red
            $failed.Add("$repoName - $pushResult")
        }
        
    } catch {
        Write-Host "$repoName - ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $failed.Add("$repoName - Exception: $($_.Exception.Message)")
    }
}

$elapsed = (Get-Date) - $startTime

# Summary
Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host "PUSH SUMMARY" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

if ($pushed.Count -gt 0) {
    Write-Host "`nPUSHED ($($pushed.Count)):" -ForegroundColor Green
    $pushed | Sort-Object | ForEach-Object { Write-Host "  ✓ $_" -ForegroundColor Green }
}

if ($upToDate.Count -gt 0) {
    Write-Host "`nUP TO DATE ($($upToDate.Count)):" -ForegroundColor Gray
    $upToDate | Sort-Object | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }
}

if ($skipped.Count -gt 0) {
    Write-Host "`nSKIPPED ($($skipped.Count)):" -ForegroundColor Yellow
    $skipped | Sort-Object | ForEach-Object { Write-Host "  ⚠ $_" -ForegroundColor Yellow }
}

if ($failed.Count -gt 0) {
    Write-Host "`nFAILED ($($failed.Count)):" -ForegroundColor Red
    $failed | Sort-Object | ForEach-Object { Write-Host "  ✗ $_" -ForegroundColor Red }
}

Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host "Completed in $([math]::Round($elapsed.TotalSeconds, 1)) seconds" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan

# Exit with error code if any pushes failed
if ($failed.Count -gt 0) {
    exit 1
}