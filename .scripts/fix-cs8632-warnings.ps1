# Build and get files with CS8632 warnings
$buildOutput = dotnet build SunamoCollections/RunnerCollections/RunnerCollections.csproj --no-incremental 2>&1
$cs8632Lines = $buildOutput | Select-String -Pattern 'warning CS8632'

# Extract unique file paths
$affectedFiles = @{}
foreach ($line in $cs8632Lines) {
    if ($line -match '([A-Z]:\\[^:]+\.cs)\([0-9]+,[0-9]+\):') {
        $filePath = $matches[1]
        $affectedFiles[$filePath] = $true
    }
}

Write-Host "Found $($affectedFiles.Count) unique files with CS8632 warnings"

# Add #nullable disable to each affected file
$count = 0
foreach ($filePath in $affectedFiles.Keys) {
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw

        # Check if #nullable disable is already there
        if ($content -notmatch '#nullable disable') {
            # Add #nullable disable after namespace declaration or at the beginning
            if ($content -match '^namespace\s+[^;]+;') {
                # File-scoped namespace - add after it
                $content = $content -replace '(^namespace\s+[^;]+;)', "`$1`n#nullable disable"
            } elseif ($content -match '^namespace\s+[\w.]+\s*{') {
                # Block namespace - add after opening brace
                $content = $content -replace '(^namespace\s+[\w.]+\s*{)', "`$1`n#nullable disable"
            } else {
                # No namespace - add at beginning
                $content = "#nullable disable`n" + $content
            }

            Set-Content -Path $filePath -Value $content -NoNewline
            $count++
            Write-Host "Fixed: $filePath"
        }
    }
}

Write-Host "`nTotal files fixed: $count"
