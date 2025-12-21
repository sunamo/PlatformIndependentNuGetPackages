param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

$comment = "// variables names: ok"

if (-not (Test-Path $Path)) {
    Write-Error "Path not found: $Path"
    exit 1
}

$csFiles = Get-ChildItem -Path $Path -Filter "*.cs" -Recurse -File

$addedCount = 0
$skippedCount = 0

foreach ($file in $csFiles) {
    $content = Get-Content $file.FullName -Raw

    if ($content -match "^\s*//\s*variables\s+names:\s*ok") {
        Write-Host "Skipped (already has comment): $($file.FullName)" -ForegroundColor Yellow
        $skippedCount++
        continue
    }

    $newContent = "$comment`r`n$content"
    Set-Content -Path $file.FullName -Value $newContent -NoNewline

    Write-Host "Added comment to: $($file.FullName)" -ForegroundColor Green
    $addedCount++
}

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  Files processed: $($csFiles.Count)"
Write-Host "  Comments added: $addedCount" -ForegroundColor Green
Write-Host "  Files skipped: $skippedCount" -ForegroundColor Yellow
