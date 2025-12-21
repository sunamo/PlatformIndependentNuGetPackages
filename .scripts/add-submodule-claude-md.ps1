# EN: Add CLAUDE.md to all submodules with reference to main CLAUDE.md
# CZ: Přidá CLAUDE.md do všech submodulů s odkazem na hlavní CLAUDE.md

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$mainClaudeMd = "$rootPath\CLAUDE.md"

# Find all .csproj files to identify submodules
$csprojFiles = Get-ChildItem -Path $rootPath -Filter "*.csproj" -Recurse -File

$submoduleDirs = @()
foreach ($csproj in $csprojFiles) {
    $submoduleDir = $csproj.Directory.FullName

    # Skip if it's in obj/bin folders
    if ($submoduleDir -match '\\obj\\|\\bin\\') {
        continue
    }

    $submoduleDirs += $submoduleDir
}

# Remove duplicates
$submoduleDirs = $submoduleDirs | Sort-Object -Unique

Write-Host "Found $($submoduleDirs.Count) submodules" -ForegroundColor Cyan

$claudeMdContent = @"
# INSTRUKCE PRO PŘEJMENOVÁNÍ PROMĚNNÝCH

**VŠECHNY instrukce pro pojmenování proměnných samopopisnými názvy najdeš v:**

``````
E:\vs\Projects\PlatformIndependentNuGetPackages\CLAUDE.md
``````

Přečti si ten soubor před jakoukoliv prací na přejmenování proměnných v tomto projektu!

**KRITICKÉ pravidla (zkrácená verze, plná verze v hlavním CLAUDE.md):**
- ❌ NIKDY nepřidávej komentář ``// variables names: ok`` - to dělá pouze uživatel
- ❌ NIKDY nepoužívaj doménově specifické názvy (``columnCount``, ``rowSize``) pro univerzální parametry → použij ``groupSize``, ``chunkSize``
- ❌ NIKDY nepoužívaj jednoslovné názvy (``s``, ``v``, ``l``) → použij ``text``, ``value``, ``list``
- ❌ NIKDY nepoužívaj ``item`` pro parametry metod → vyhrazeno pro foreach
- ✅ VŽDY maž nepoužívané parametry z hlaviček metod
- ✅ VŽDY dbej na konzistenci v rámci jednoho souboru
"@

foreach ($submoduleDir in $submoduleDirs) {
    $claudeMdPath = Join-Path $submoduleDir "CLAUDE.md"

    # Check if CLAUDE.md already exists
    if (Test-Path $claudeMdPath) {
        $existingContent = Get-Content -Path $claudeMdPath -Raw

        # Check if it's already a reference to main CLAUDE.md
        if ($existingContent -match "E:\\vs\\Projects\\PlatformIndependentNuGetPackages\\CLAUDE\.md") {
            Write-Host "⏭️  Skipping (already has reference): $submoduleDir" -ForegroundColor Gray
            continue
        }

        # If it has other content, show it for manual review
        Write-Host "⚠️  Existing CLAUDE.md found in: $submoduleDir" -ForegroundColor Yellow
        Write-Host "   Content preview: $($existingContent.Substring(0, [Math]::Min(100, $existingContent.Length)))..." -ForegroundColor Yellow
        Write-Host "   Please review manually if this content should be moved to main CLAUDE.md" -ForegroundColor Yellow

        # Add reference at the top
        $newContent = $claudeMdContent + "`r`n`r`n---`r`n`r`n# PŮVODNÍ OBSAH TOHOTO SOUBORU:`r`n`r`n" + $existingContent
        Set-Content -Path $claudeMdPath -Value $newContent -NoNewline
        Write-Host "✓ Updated with reference: $submoduleDir" -ForegroundColor Green
    }
    else {
        # Create new CLAUDE.md
        Set-Content -Path $claudeMdPath -Value $claudeMdContent -NoNewline
        Write-Host "✓ Created new CLAUDE.md: $submoduleDir" -ForegroundColor Green
    }
}

Write-Host "`n✅ Processed $($submoduleDirs.Count) submodules" -ForegroundColor Cyan
