# EN: Group submodules into batches of 10 and save to markdown file
# CZ: Seskupí submoduly po 10 a uloží do markdown souboru

$gitmodulesPath = Join-Path $PSScriptRoot "..\.gitmodules"
$outputPath = Join-Path $PSScriptRoot "submodules-grouped.md"

# EN: Check if output file already exists
# CZ: Zkontroluj zda výstupní soubor již existuje
if (Test-Path $outputPath) {
    Write-Host "Output file already exists: $outputPath" -ForegroundColor Yellow
    exit 0
}

# EN: Read .gitmodules and extract submodule paths
# CZ: Přečti .gitmodules a extrahuj cesty submodulů
$content = Get-Content $gitmodulesPath
$submodules = $content | Where-Object { $_ -match '^\s*path\s*=\s*(.+)$' } | ForEach-Object { $matches[1].Trim() }

# EN: Group submodules by 10
# CZ: Seskup submoduly po 10
$grouped = @()
for ($i = 0; $i -lt $submodules.Count; $i += 10) {
    $end = [Math]::Min($i + 10, $submodules.Count)
    $group = $submodules[$i..($end - 1)]
    $grouped += ,@($group)
}

# EN: Create markdown content
# CZ: Vytvoř markdown obsah
$markdown = @()
$markdown += "# Submodules Grouped by 10"
$markdown += ""
$markdown += "Total submodules: $($submodules.Count)"
$markdown += ""

for ($i = 0; $i -lt $grouped.Count; $i++) {
    $groupNum = $i + 1
    $markdown += "## Group $groupNum"
    $markdown += ""
    foreach ($submodule in $grouped[$i]) {
        $markdown += "- $submodule"
    }
    $markdown += ""
}

# EN: Write to file
# CZ: Zapiš do souboru
$markdown | Out-File -FilePath $outputPath -Encoding UTF8
Write-Host "Submodules grouped and saved to: $outputPath" -ForegroundColor Green
