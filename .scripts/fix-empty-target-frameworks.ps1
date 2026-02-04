# Fix empty or duplicate TargetFramework in all .csproj files
# EN: Finds and fixes projects with empty, missing, or duplicate TargetFramework
# CZ: Najde a opraví projekty s prázdným, chybějícím nebo duplicitním TargetFramework

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$csprojFiles = Get-ChildItem -Path $rootPath -Filter "*.csproj" -Recurse

Write-Host "Found $($csprojFiles.Count) .csproj files" -ForegroundColor Cyan
Write-Host ""

$fixedCount = 0
$errorCount = 0
$okCount = 0

foreach ($file in $csprojFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw
        $originalContent = $content
        $changed = $false
        $issues = @()

        # Check for duplicate TargetFramework lines
        $tfMatches = [regex]::Matches($content, '<TargetFramework>')
        if ($tfMatches.Count -gt 1) {
            $issues += "Duplicate <TargetFramework> tags"
            # Remove all TargetFramework lines and add one correct one
            $content = $content -replace '<TargetFramework>[^<]*</TargetFramework>\s*[\r\n]*', ''
            # Add one TargetFramework after <PropertyGroup>
            $content = $content -replace '(<PropertyGroup[^>]*>[\r\n\s]*)', "`$1    <TargetFramework>net10.0</TargetFramework>`r`n    "
            $changed = $true
        }

        # Check for empty TargetFramework
        if ($content -match '<TargetFramework>\s*</TargetFramework>') {
            $issues += "Empty <TargetFramework>"
            $content = $content -replace '<TargetFramework>\s*</TargetFramework>', '<TargetFramework>net10.0</TargetFramework>'
            $changed = $true
        }

        # Check for empty TargetFrameworks
        if ($content -match '<TargetFrameworks>\s*</TargetFrameworks>') {
            $issues += "Empty <TargetFrameworks>"
            $content = $content -replace '<TargetFrameworks>\s*</TargetFrameworks>', '<TargetFramework>net10.0</TargetFramework>'
            $changed = $true
        }

        if ($changed) {
            # Save the file
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $fixedCount++
            Write-Host "✓ Fixed: $($file.Name)" -ForegroundColor Green
            Write-Host "  Path: $($file.Directory.Name)" -ForegroundColor Gray
            foreach ($issue in $issues) {
                Write-Host "  - $issue" -ForegroundColor Yellow
            }
            Write-Host ""
        } else {
            $okCount++
        }
    }
    catch {
        $errorCount++
        Write-Host "✗ Error processing: $($file.Name)" -ForegroundColor Red
        Write-Host "  Path: $($file.FullName)" -ForegroundColor Gray
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Fixed: $fixedCount" -ForegroundColor Green
Write-Host "OK (no changes needed): $okCount" -ForegroundColor Cyan
Write-Host "Errors: $errorCount" -ForegroundColor Red
Write-Host "Total: $($csprojFiles.Count)" -ForegroundColor White
Write-Host ""

if ($fixedCount -gt 0) {
    Write-Host "✓ Fixed $fixedCount project(s). Ready to build!" -ForegroundColor Green
} else {
    Write-Host "✓ All projects OK!" -ForegroundColor Green
}
