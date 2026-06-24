# Spusť v kořeni workspace
Get-ChildItem -Directory | ForEach-Object {
    $name = $_.Name
    $mainProjPath = Join-Path $_.FullName "$name\$name.csproj"
    $testProjPath = Join-Path $_.FullName "$name.Tests\$name.Tests.csproj"
    $runnerProjPath = Join-Path $_.FullName "Runner$name\Runner$name.csproj"

if ((Test-Path $mainProjPath) -and (Test-Path $testProjPath) -and (Test-Path $runnerProjPath)) {
        # Úprava test projektu - reference na hlavní projekt
        [xml]$testXml = Get-Content $testProjPath
        $hasRef = $false
        foreach ($ig in $testXml.Project.ItemGroup) {
            foreach ($pr in $ig.ProjectReference) {
                if ($pr.Include -eq "..\$name\$name.csproj") { $hasRef = $true }
            }
        }
        if (-not $hasRef) {
            $ig = $testXml.CreateElement("ItemGroup")
            $pr = $testXml.CreateElement("ProjectReference")
            $pr.SetAttribute("Include", "..\$name\$name.csproj")
            $ig.AppendChild($pr) | Out-Null
            $testXml.Project.AppendChild($ig) | Out-Null
            $testXml.Save($testProjPath)
        }

        # Úprava runner projektu - reference pouze na test projekt
        [xml]$runnerXml = Get-Content $runnerProjPath
        # Odstraní všechny existující ProjectReference
        foreach ($ig in $runnerXml.Project.ItemGroup) {
            $toRemove = @()
            foreach ($pr in $ig.ProjectReference) { $toRemove += $pr }
            foreach ($pr in $toRemove) { $ig.RemoveChild($pr) | Out-Null }
        }
        # Přidá ProjectReference na test projekt, pokud neexistuje
        $hasTestRef = $false
        foreach ($ig in $runnerXml.Project.ItemGroup) {
            foreach ($pr in $ig.ProjectReference) {
                if ($pr.Include -eq "..\$name.Tests\$name.Tests.csproj") { $hasTestRef = $true }
            }
        }
        if (-not $hasTestRef) {
            $ig = $runnerXml.CreateElement("ItemGroup")
            $pr = $runnerXml.CreateElement("ProjectReference")
            $pr.SetAttribute("Include", "..\$name.Tests\$name.Tests.csproj")
            $ig.AppendChild($pr) | Out-Null
            $runnerXml.Project.AppendChild($ig) | Out-Null
        }
        $runnerXml.Save($runnerProjPath)
    }
}
