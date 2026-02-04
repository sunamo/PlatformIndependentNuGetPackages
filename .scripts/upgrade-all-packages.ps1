# Upgrade all NuGet packages to latest versions in all csproj files

Write-Host "Upgrading all NuGet packages to latest versions..." -ForegroundColor Cyan

$csprojFiles = Get-ChildItem -Recurse -Filter "*.csproj" | Where-Object { $_.FullName -notlike "*\obj\*" -and $_.FullName -notlike "*\bin\*" }

$totalFiles = $csprojFiles.Count
$currentFile = 0

foreach ($csproj in $csprojFiles) {
    $currentFile++
    $relativePath = $csproj.FullName.Replace($PWD.Path + "\", "")
    Write-Host "`n[$currentFile/$totalFiles] Processing: $relativePath" -ForegroundColor Yellow
    
    Push-Location (Split-Path $csproj.FullName)
    
    # Get outdated packages
    $outdated = dotnet list package --outdated 2>&1
    
    if ($outdated -match "no updates") {
        Write-Host "  All packages are up to date" -ForegroundColor Green
    } else {
        # Parse outdated packages and update them
        $outdated | ForEach-Object {
            if ($_ -match '>\s+(\S+)\s+\S+\s+\S+\s+(\S+)') {
                $packageName = $matches[1]
                $latestVersion = $matches[2]
                Write-Host "  Updating $packageName to $latestVersion..." -ForegroundColor Cyan
                dotnet add package $packageName --version $latestVersion 2>&1 | Out-Null
            }
        }
    }
    
    Pop-Location
}

Write-Host "`n=== UPGRADE COMPLETE ===" -ForegroundColor Green
Write-Host "Processed $totalFiles project files" -ForegroundColor Green
