# PowerShell script to pull all submodules and root repository
# Handles diverging branches with merge strategy

param(
    [string]$Strategy = "merge",  # Options: "merge", "rebase", "ff-only"
    [switch]$Force = $false,
    [switch]$Verbose = $false
)

# Function to perform git pull with specified strategy
function Invoke-GitPull {
    param(
        [string]$Path,
        [string]$RepoName,
        [string]$Strategy
    )
    
    Push-Location $Path
    
    try {
        Write-Host "Processing: $RepoName" -ForegroundColor Green
        
        # Check if we have any uncommitted changes
        $status = git status --porcelain
        if ($status -and !$Force) {
            Write-Warning "Repository $RepoName has uncommitted changes. Use -Force to proceed anyway."
            return $false
        }
        
        # Fetch first to get latest refs
        Write-Host "  Fetching..." -ForegroundColor Yellow
        git fetch origin
        
        # Check if we're behind the remote
        $behind = git rev-list --count HEAD..@{u} 2>$null
        if ($behind -eq "0" -or $behind -eq $null) {
            Write-Host "  Already up to date" -ForegroundColor Cyan
            return $true
        }
        
        Write-Host "  Pulling with strategy: $Strategy" -ForegroundColor Yellow
        
        switch ($Strategy) {
            "merge" {
                git pull --no-ff --no-edit origin
            }
            "rebase" {
                git pull --rebase origin
            }
            "ff-only" {
                git pull --ff-only origin
            }
            default {
                git pull --no-ff --no-edit origin
            }
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Success!" -ForegroundColor Green
            return $true
        } else {
            Write-Error "  Failed to pull $RepoName"
            return $false
        }
    }
    catch {
        Write-Error "  Error processing $RepoName: $($_.Exception.Message)"
        return $false
    }
    finally {
        Pop-Location
    }
}

# Main execution
$rootPath = $PSScriptRoot
$successCount = 0
$failCount = 0

Write-Host "Starting pull operation with strategy: $Strategy" -ForegroundColor Magenta
Write-Host "Root path: $rootPath" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta

# Pull root repository first
Write-Host "`n1. Pulling root repository..." -ForegroundColor Blue
if (Invoke-GitPull -Path $rootPath -RepoName "ROOT" -Strategy $Strategy) {
    $successCount++
} else {
    $failCount++
}

# Get all submodules
Write-Host "`n2. Detecting submodules..." -ForegroundColor Blue
Push-Location $rootPath

try {
    # Check if .gitmodules exists
    if (Test-Path ".gitmodules") {
        # Update submodules first
        Write-Host "  Updating submodule references..." -ForegroundColor Yellow
        git submodule update --init --recursive
        
        # Get list of submodules
        $submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
            $_.Split(' ')[1]
        }
        
        if ($submodules) {
            Write-Host "  Found $($submodules.Count) submodules" -ForegroundColor Cyan
            
            # Pull each submodule
            $counter = 3
            foreach ($submodule in $submodules) {
                $submodulePath = Join-Path $rootPath $submodule
                if (Test-Path $submodulePath) {
                    Write-Host "`n$counter. Pulling submodule: $submodule" -ForegroundColor Blue
                    if (Invoke-GitPull -Path $submodulePath -RepoName $submodule -Strategy $Strategy) {
                        $successCount++
                    } else {
                        $failCount++
                    }
                    $counter++
                } else {
                    Write-Warning "Submodule path not found: $submodulePath"
                }
            }
        } else {
            Write-Host "  No submodules found in .gitmodules" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  No .gitmodules file found - checking for folder-based submodules" -ForegroundColor Yellow
        
        # Alternative: Check for folders that might be git repositories
        $potentialSubmodules = Get-ChildItem -Path $rootPath -Directory | Where-Object {
            Test-Path (Join-Path $_.FullName ".git")
        }
        
        if ($potentialSubmodules) {
            Write-Host "  Found $($potentialSubmodules.Count) potential git repositories" -ForegroundColor Cyan
            
            $counter = 3
            foreach ($folder in $potentialSubmodules) {
                Write-Host "`n$counter. Pulling repository: $($folder.Name)" -ForegroundColor Blue
                if (Invoke-GitPull -Path $folder.FullName -RepoName $folder.Name -Strategy $Strategy) {
                    $successCount++
                } else {
                    $failCount++
                }
                $counter++
            }
        } else {
            Write-Host "  No git repositories found in subdirectories" -ForegroundColor Yellow
        }
    }
}
finally {
    Pop-Location
}

# Summary
Write-Host "`n================================================" -ForegroundColor Magenta
Write-Host "Pull operation completed!" -ForegroundColor Magenta
Write-Host "Success: $successCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor Red

if ($failCount -gt 0) {
    Write-Host "`nSome repositories failed to pull. Check the output above for details." -ForegroundColor Yellow
    Write-Host "You may need to manually resolve conflicts or use different strategies:" -ForegroundColor Yellow
    Write-Host "  - For merge strategy: .\pull-all-submodules.ps1 -Strategy merge" -ForegroundColor Cyan
    Write-Host "  - For rebase strategy: .\pull-all-submodules.ps1 -Strategy rebase" -ForegroundColor Cyan
    Write-Host "  - For fast-forward only: .\pull-all-submodules.ps1 -Strategy ff-only" -ForegroundColor Cyan
    Write-Host "  - To force pull with uncommitted changes: .\pull-all-submodules.ps1 -Force" -ForegroundColor Cyan
}

exit $failCount
