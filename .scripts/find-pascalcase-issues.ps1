# Find public/internal members with camelCase that should be PascalCase
param(
    [string]$BasePath = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoDevCode\SunamoDevCode\_sunamo"
)

Get-ChildItem -Path $BasePath -Filter "*.cs" -Recurse | ForEach-Object {
    $file = $_
    $lines = @(Get-Content $file.FullName)
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Match public/internal static/readonly fields with lowercase start
        # Pattern: "public|internal" + optional "static" + optional "readonly" + type + lowercase_name + "="
        if ($line -match '^\s*(public|internal)\s+(static\s+)?(readonly\s+)?(\w+)\s+([a-z][a-zA-Z0-9_]*)\s*[=;]' -and $line -notmatch '=>\s*') {
            $access = $matches[1]
            $memberType = $matches[4]
            $memberName = $matches[5]
            
            # Skip common patterns that are OK
            if ($memberName -in @("item", "i", "j", "k")) {
                continue
            }
            
            Write-Host "$($file.FullName):$($i+1): $access $memberType $memberName" -ForegroundColor Cyan
        }
        
        # Match public/internal properties with lowercase start
        if ($line -match '^\s*(public|internal)\s+(static\s+)?(\w+)\s+([a-z][a-zA-Z0-9_]*)\s*\{' -and $line -notmatch 'private') {
            $access = $matches[1]
            $propType = $matches[3]
            $propName = $matches[4]
            
            # Skip if it's a method
            if ($propType -in @("void", "Task")) {
                continue
            }
            
            Write-Host "$($file.FullName):$($i+1): $access property $propType $propName" -ForegroundColor Yellow
        }
    }
}
