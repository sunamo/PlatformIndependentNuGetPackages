param(
    [string]$SlnPath,
    [switch]$Recursive,
    [string]$RootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
)

function Convert-SlnToSlnx {
    param([string]$slnFile)

    Write-Host "Converting: $slnFile" -ForegroundColor Cyan

    # Read .sln file
    $content = Get-Content $slnFile -Encoding UTF8

    # Parse projects and folders
    $projects = @()
    $folders = @{}
    $nestedProjects = @{}

    $inNestedProjects = $false

    foreach ($line in $content) {
        # Parse Project lines
        if ($line -match '^Project\("(\{[A-F0-9-]+\})"\)\s*=\s*"([^"]+)",\s*"([^"]+)",\s*"(\{[A-F0-9-]+\})"') {
            $projectTypeGuid = $matches[1]
            $projectName = $matches[2]
            $projectPath = $matches[3]
            $projectGuid = $matches[4]

            # Solution folder type GUID
            $folderTypeGuid = "{2150E333-8FDC-42A3-9474-1A3956D46DE8}"

            if ($projectTypeGuid -eq $folderTypeGuid) {
                # This is a solution folder
                $folders[$projectGuid] = $projectName
            } else {
                # This is a real project
                if ($projectPath -notmatch '\.editorconfig$' -and $projectPath -match '\.(csproj|vbproj|fsproj)$') {
                    $projects += @{
                        Guid = $projectGuid
                        Name = $projectName
                        Path = $projectPath -replace '\\', '\'
                    }
                }
            }
        }

        # Parse NestedProjects section
        if ($line -match '^\s*GlobalSection\(NestedProjects\)') {
            $inNestedProjects = $true
        }
        elseif ($inNestedProjects -and $line -match '^\s*EndGlobalSection') {
            $inNestedProjects = $false
        }
        elseif ($inNestedProjects -and $line -match '^\s*\{([A-F0-9-]+)\}\s*=\s*\{([A-F0-9-]+)\}') {
            $childGuid = "{$($matches[1])}"
            $parentGuid = "{$($matches[2])}"
            $nestedProjects[$childGuid] = $parentGuid
        }
    }

    # Generate .slnx XML
    $xml = New-Object System.Xml.XmlDocument
    $xml.AppendChild($xml.CreateXmlDeclaration("1.0", "utf-8", $null)) | Out-Null

    $solution = $xml.CreateElement("Solution")
    $xml.AppendChild($solution) | Out-Null

    if ($folders.Count -eq 0) {
        # Flat solution - no folders
        foreach ($proj in $projects) {
            $projectElem = $xml.CreateElement("Project")
            $projectElem.SetAttribute("Path", $proj.Path)
            $solution.AppendChild($projectElem) | Out-Null
        }
    } else {
        # Solution with folders
        # Group projects by folder
        $projectsByFolder = @{}

        foreach ($proj in $projects) {
            $parentGuid = $nestedProjects[$proj.Guid]
            if ($parentGuid -and $folders.ContainsKey($parentGuid)) {
                $folderName = $folders[$parentGuid]
                if (-not $projectsByFolder.ContainsKey($folderName)) {
                    $projectsByFolder[$folderName] = @()
                }
                $projectsByFolder[$folderName] += $proj
            } else {
                # Project not in any folder - add to root
                $projectElem = $xml.CreateElement("Project")
                $projectElem.SetAttribute("Path", $proj.Path)
                $solution.AppendChild($projectElem) | Out-Null
            }
        }

        # Create folder elements
        foreach ($folderName in ($projectsByFolder.Keys | Sort-Object)) {
            $folderElem = $xml.CreateElement("Folder")
            $folderElem.SetAttribute("Name", $folderName)

            foreach ($proj in ($projectsByFolder[$folderName] | Sort-Object { $_.Path })) {
                $projectElem = $xml.CreateElement("Project")
                $projectElem.SetAttribute("Path", $proj.Path)
                $folderElem.AppendChild($projectElem) | Out-Null
            }

            $solution.AppendChild($folderElem) | Out-Null
        }
    }

    # Save .slnx file
    $slnxFile = $slnFile -replace '\.sln$', '.slnx'

    # Create StringWriter with UTF8 encoding
    $sw = New-Object System.IO.StringWriter
    $xmlWriter = [System.Xml.XmlWriter]::Create($sw, (New-Object System.Xml.XmlWriterSettings -Property @{
        Indent = $true
        IndentChars = "  "
        OmitXmlDeclaration = $true
        Encoding = [System.Text.Encoding]::UTF8
    }))

    $xml.Save($xmlWriter)
    $xmlWriter.Close()

    # Write to file with UTF8 encoding
    $sw.ToString() | Out-File -FilePath $slnxFile -Encoding UTF8 -NoNewline

    Write-Host "  Created: $slnxFile" -ForegroundColor Green

    return $slnxFile
}

# Main execution
if ($Recursive) {
    # Convert all .sln files recursively
    $slnFiles = Get-ChildItem -Path $RootPath -Filter "*.sln" -Recurse | Select-Object -ExpandProperty FullName

    Write-Host "Found $($slnFiles.Count) .sln files" -ForegroundColor Yellow

    foreach ($slnFile in $slnFiles) {
        Convert-SlnToSlnx -slnFile $slnFile
    }

    Write-Host "`nConversion complete! Converted $($slnFiles.Count) files." -ForegroundColor Green
} elseif ($SlnPath) {
    # Convert single file
    Convert-SlnToSlnx -slnFile $SlnPath
} else {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  Convert single file: .\convert-sln-to-slnx.ps1 -SlnPath 'path\to\solution.sln'"
    Write-Host "  Convert all files:   .\convert-sln-to-slnx.ps1 -Recursive"
}
