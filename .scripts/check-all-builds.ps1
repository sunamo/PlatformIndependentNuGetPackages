# Check build status of all Sunamo projects
$ErrorActionPreference = "Continue"
$projects = Get-ChildItem -Directory -Filter "Sunamo*" | Sort-Object Name
$failed = @()
$succeeded = @()

foreach ($project in $projects) {
    $solutionFile = Get-ChildItem -Path $project.FullName -Filter "*.sln" | Select-Object -First 1

    if ($solutionFile) {
        Write-Host "`n=== Building $($project.Name) ===" -ForegroundColor Cyan
        Push-Location $project.FullName

        $output = dotnet build $solutionFile.Name 2>&1
        $buildResult = $LASTEXITCODE

        if ($buildResult -eq 0) {
            Write-Host "✓ $($project.Name) - SUCCESS" -ForegroundColor Green
            $succeeded += $project.Name
        } else {
            Write-Host "✗ $($project.Name) - FAILED" -ForegroundColor Red
            $failed += @{
                Name = $project.Name
                Errors = ($output | Where-Object { $_ -match "error CS" })
            }
        }

        Pop-Location
    }
}

Write-Host "`n=== BUILD SUMMARY ===" -ForegroundColor Yellow
Write-Host "Succeeded: $($succeeded.Count)" -ForegroundColor Green
Write-Host "Failed: $($failed.Count)" -ForegroundColor Red

if ($failed.Count -gt 0) {
    Write-Host "`n=== FAILED PROJECTS ===" -ForegroundColor Red
    foreach ($fail in $failed) {
        Write-Host "`n$($fail.Name):" -ForegroundColor Red
        $fail.Errors | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" }
    }
}
