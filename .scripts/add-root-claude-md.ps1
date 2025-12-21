# EN: Add CLAUDE.md to root project folders (not submodule folders)
# CZ: Přidá CLAUDE.md do kořenových složek projektů (ne do podsložek s .csproj)

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"

# Find all first-level directories (project root folders)
$projectRootDirs = Get-ChildItem -Path $rootPath -Directory |
    Where-Object {
        $_.Name -notmatch '^\.' -and  # Skip hidden folders like .scripts
        $_.Name -ne 'packages' -and
        $_.Name -ne 'TestResults'
    }

$claudeMdContent = @"
# INSTRUKCE PRO PŘEJMENOVÁNÍ PROMĚNNÝCH

**VŠECHNY instrukce pro pojmenování proměnných samopopisnými názvy najdeš v:**

``````
E:\vs\Projects\PlatformIndependentNuGetPackages\CLAUDE.md
``````

Přečti si ten soubor před jakoukoliv prací na přejmenování proměnných v tomto projektu!
"@

$created = 0
$updated = 0
$skipped = 0

foreach ($projectDir in $projectRootDirs) {
    $claudeMdPath = Join-Path $projectDir.FullName "CLAUDE.md"

    # Check if CLAUDE.md already exists
    if (Test-Path $claudeMdPath) {
        $existingContent = Get-Content -Path $claudeMdPath -Raw

        # Check if it already has the reference to main CLAUDE.md
        if ($existingContent -match "E:\\vs\\Projects\\PlatformIndependentNuGetPackages\\CLAUDE\.md") {
            Write-Host "⏭️  Already has reference: $($projectDir.Name)" -ForegroundColor Gray
            $skipped++
            continue
        }

        # If it has other content, preserve it
        Write-Host "⚠️  Existing CLAUDE.md found in: $($projectDir.Name)" -ForegroundColor Yellow
        Write-Host "   Preserving existing content..." -ForegroundColor Yellow

        # Add reference at the top, keep original content at the bottom
        $newContent = $claudeMdContent + "`r`n`r`n---`r`n`r`n# PŮVODNÍ OBSAH:`r`n`r`n" + $existingContent
        Set-Content -Path $claudeMdPath -Value $newContent -NoNewline
        Write-Host "✓ Updated: $($projectDir.Name)" -ForegroundColor Green
        $updated++
    }
    else {
        # Create new CLAUDE.md
        Set-Content -Path $claudeMdPath -Value $claudeMdContent -NoNewline
        Write-Host "✓ Created: $($projectDir.Name)" -ForegroundColor Green
        $created++
    }
}

Write-Host "`n📊 SUMMARY:" -ForegroundColor Cyan
Write-Host "Created: $created" -ForegroundColor Green
Write-Host "Updated: $updated" -ForegroundColor Yellow
Write-Host "Skipped: $skipped" -ForegroundColor Gray
Write-Host "Total processed: $($created + $updated + $skipped)" -ForegroundColor Cyan
