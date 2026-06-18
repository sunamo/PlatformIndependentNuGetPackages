#Requires -Version 7.0
# Builds every original NuGet csproj (default: netstandard2.0 only; -AllFrameworks builds all TFMs)
# and writes a per-project error summary.
param(
    [string]$LogPath = "E:\vs\Projects\PlatformIndependentNuGetPackages\.net48\netstandard20-build.log",
    [switch]$AllFrameworks
)

$base = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$projectNames = Get-ChildItem "$base\.net48" -Filter "*.Net48.csproj" | ForEach-Object { $_.BaseName -replace '\.Net48$', '' } | Sort-Object

$results = $projectNames | ForEach-Object -ThrottleLimit 6 -Parallel {
    $name = $_
    $csprojPath = Join-Path $using:base "$name\$name\$name.csproj"
    if (-not (Test-Path $csprojPath)) { return }
    $frameworkArgs = if ($using:AllFrameworks) { @() } else { @("-f", "netstandard2.0") }
    $output = dotnet build $csprojPath @frameworkArgs -v:q -nologo -p:WarningLevel=0 2>&1
    if ($LASTEXITCODE -eq 0) {
        "OK    $name"
    } else {
        $errorLines = $output | Select-String ": error " | ForEach-Object { $_.Line } | Sort-Object -Unique
        @("FAIL  $name ($(@($errorLines).Count) errors)") + ($errorLines | ForEach-Object { "      $_" }) -join "`n"
    }
}

$failedCount = @($results | Where-Object { $_ -match '^FAIL' }).Count
$results | Sort-Object | Out-File $LogPath -Encoding UTF8
"FAILED: $failedCount / $($projectNames.Count)" | Out-File $LogPath -Append
Write-Host "FAILED: $failedCount / $($projectNames.Count) -> $LogPath"
