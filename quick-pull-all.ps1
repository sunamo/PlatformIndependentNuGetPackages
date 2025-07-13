# Quick PowerShell script for pulling all repositories
# Handles diverging branches with merge strategy (no fast-forward)

Write-Host "Quick Pull All Repositories" -ForegroundColor Magenta
Write-Host "===========================" -ForegroundColor Magenta

$rootPath = $PSScriptRoot
$errors = @()

# Function to safely pull a repository
function Pull-Repository {
    param([string]$Path, [string]$Name)
    
    Push-Location $Path
    try {
        Write-Host "Pulling $Name..." -ForegroundColor Green
        
        # Fetch first
        git fetch origin 2>$null
        
        # Pull with no-ff to handle diverging branches
        git pull --no-ff --no-edit origin 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Success" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Failed - trying merge" -ForegroundColor Yellow
            git merge --no-ff --no-edit origin/main 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Merge successful" -ForegroundColor Green
            } else {
                $script:errors += $Name
                Write-Host "  ✗ Failed" -ForegroundColor Red
            }
        }
    }
    catch {
        $script:errors += $Name
        Write-Error "Error pulling $Name`: $($_.Exception.Message)"
    }
    finally {
        Pop-Location
    }
}

# Pull root repository
Pull-Repository -Path $rootPath -Name "ROOT"

# Find and pull all git repositories in subdirectories
$gitFolders = Get-ChildItem -Path $rootPath -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName ".git")
}

foreach ($folder in $gitFolders) {
    Pull-Repository -Path $folder.FullName -Name $folder.Name
}

# Summary
Write-Host "`n===========================" -ForegroundColor Magenta
if ($errors.Count -eq 0) {
    Write-Host "All repositories pulled successfully! ✓" -ForegroundColor Green
} else {
    Write-Host "Some repositories failed:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host "`nYou may need to manually resolve conflicts in failed repositories." -ForegroundColor Yellow
}
