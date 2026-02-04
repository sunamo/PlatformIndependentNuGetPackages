# Fast upgrade all PackageReferences to latest versions

Write-Host "Finding all .csproj files..." -ForegroundColor Cyan

$csprojFiles = Get-ChildItem -Recurse -Filter "*.csproj" |
    Where-Object { $_.FullName -notlike "*\obj\*" -and $_.FullName -notlike "*\bin\*" }

Write-Host "Found $($csprojFiles.Count) project files" -ForegroundColor Green
Write-Host "`nUpgrading packages..." -ForegroundColor Cyan

$totalUpdated = 0

foreach ($csproj in $csprojFiles) {
    [xml]$xml = Get-Content $csproj.FullName
    $packageRefs = $xml.Project.ItemGroup.PackageReference | Where-Object { $_.Version -and $_.Version -ne "*" }
    
    if ($packageRefs) {
        $relativePath = $csproj.FullName.Replace($PWD.Path + "\", "")
        Write-Host "`nProcessing: $relativePath" -ForegroundColor Yellow
        
        Push-Location (Split-Path $csproj.FullName)
        
        foreach ($pkg in $packageRefs) {
            $name = $pkg.Include
            $currentVer = $pkg.Version
            
            Write-Host "  Upgrading $name from $currentVer..." -ForegroundColor Cyan
            dotnet add package $name 2>&1 | Out-Null
            $totalUpdated++
        }
        
        Pop-Location
    }
}

Write-Host "`n=== UPGRADE COMPLETE ===" -ForegroundColor Green
Write-Host "Updated $totalUpdated packages" -ForegroundColor Green
