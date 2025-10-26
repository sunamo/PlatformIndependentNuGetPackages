# EN: Master fix script for ALL refactoring issues - type parameters and incomplete variable renames
# CZ: Hlavní fix skript pro VŠECHNY problémy refactoringu - type parametry a neúplná přejmenování proměnných

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "FIXING ALL REFACTORING ISSUES" -ForegroundColor Yellow
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host ""

$totalFixed = 0
$totalErrors = 0
$filesProcessed = 0

# EN: Get all submodule paths
# CZ: Získat všechny cesty submodulů
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -replace 'submodule\..*\.path ', ''
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in this repository." -ForegroundColor Yellow
    exit
}

function Fix-AllIssues {
    param([string]$filePath)

    try {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        if (-not $content) {
            return $false
        }

        $originalContent = $content

        # EN: FIX 1: Replace 'temp' back to 'T' when used as type parameter
        # CZ: OPRAVA 1: Nahradit 'temp' zpět na 'T' když je použito jako type parametr

        # typeof(temp) -> typeof(T)
        $content = $content -replace 'typeof\(temp\)', 'typeof(T)'

        # <temp> in generic constraints and declarations
        $content = $content -replace '<temp>', '<T>'
        $content = $content -replace '<temp,', '<T,'
        $content = $content -replace ',\s*temp>', ', T>'

        # Method return type and parameters: public static temp Method -> public static T Method
        $content = $content -replace '\bpublic\s+static\s+temp\s+', 'public static T '
        $content = $content -replace '\bprivate\s+static\s+temp\s+', 'private static T '
        $content = $content -replace '\bprotected\s+static\s+temp\s+', 'protected static T '
        $content = $content -replace '\binternal\s+static\s+temp\s+', 'internal static T '

        # Method parameter: Func<string, temp> -> Func<string, T>
        $content = $content -replace 'Func<([^>]+),\s*temp>', 'Func<$1, T>'
        $content = $content -replace 'Func<temp>', 'Func<T>'
        $content = $content -replace 'List<temp>', 'List<T>'
        $content = $content -replace 'IList<temp>', 'IList<T>'
        $content = $content -replace 'IEnumerable<temp>', 'IEnumerable<T>'

        # Method parameters: (temp param) -> (T param)
        $content = $content -replace '\(temp\s+', '(T '
        $content = $content -replace ',\s*temp\s+', ', T '

        # EN: FIX 2: Replace 'type' back to 'T' when used as type parameter in generic classes
        # CZ: OPRAVA 2: Nahradit 'type' zpět na 'T' když je použito jako type parametr v generických třídách

        # Check if file contains generic class definition
        if ($content -match 'class\s+\w+<T>') {
            # typeof(type) -> typeof(T)
            $content = $content -replace 'typeof\(type\)', 'typeof(T)'

            # Constructor/method parameters: public Method(type param1, type param2)
            # But be careful with 'Type type' which is valid
            $content = $content -replace '([^a-zA-Z])type\s+from\b', '$1T from'
            $content = $content -replace '([^a-zA-Z])type\s+to\b', '$1T to'
            $content = $content -replace '\(type\s+', '(T '
            $content = $content -replace ',\s*type\s+', ', T '

            # Property declarations: public type PropertyName
            $content = $content -replace '\bpublic\s+type\s+(\w+)\s*\{', 'public T $1 {'
            $content = $content -replace '\bprivate\s+type\s+(\w+)\s*\{', 'private T $1 {'
            $content = $content -replace '\bprotected\s+type\s+(\w+)\s*\{', 'protected T $1 {'

            # Casts: (type) -> (T)
            $content = $content -replace '\(type\)\(dynamic\)', '(T)(dynamic)'

            # Return type: => (type)(dynamic) -> => (T)(dynamic)
            $content = $content -replace '=>\s*\(type\)', '=> (T)'
        }

        # EN: FIX 3: Fix for loops where declaration uses 'index' but condition/increment uses 'i'
        # CZ: OPRAVA 3: Opravit for cykly kde deklarace používá 'index' ale podmínka/inkrement používá 'i'

        # Pattern: for (int index = X; i >= 0; i--) -> for (int index = X; index >= 0; index--)
        $content = $content -replace 'for\s*\(\s*int\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*i--\s*\)', 'for (int index =$1; index $2$3; index--)'
        $content = $content -replace 'for\s*\(\s*int\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*i\+\+\s*\)', 'for (int index =$1; index $2$3; index++)'
        $content = $content -replace 'for\s*\(\s*int\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*\+\+i\s*\)', 'for (int index =$1; index $2$3; ++index)'
        $content = $content -replace 'for\s*\(\s*int\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*--i\s*\)', 'for (int index =$1; index $2$3; --index)'

        # Pattern: for (var index = X; i < Y; i++) -> for (var index = X; index < Y; index++)
        $content = $content -replace 'for\s*\(\s*var\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*i\+\+\s*\)', 'for (var index =$1; index $2$3; index++)'
        $content = $content -replace 'for\s*\(\s*var\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*i--\s*\)', 'for (var index =$1; index $2$3; index--)'
        $content = $content -replace 'for\s*\(\s*var\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*\+\+i\s*\)', 'for (var index =$1; index $2$3; ++index)'
        $content = $content -replace 'for\s*\(\s*var\s+index\s*=([^;]+);\s*i\s*(>=|>|<=|<|==|!=)([^;]+);\s*--i\s*\)', 'for (var index =$1; index $2$3; --index)'

        # EN: FIX 4: Similar fixes for columnIndex/j and thirdIndex/k
        # CZ: OPRAVA 4: Podobné opravy pro columnIndex/j a thirdIndex/k

        # columnIndex patterns
        $content = $content -replace 'for\s*\(\s*int\s+columnIndex\s*=([^;]+);\s*j\s*(>=|>|<=|<|==|!=)([^;]+);\s*j--\s*\)', 'for (int columnIndex =$1; columnIndex $2$3; columnIndex--)'
        $content = $content -replace 'for\s*\(\s*int\s+columnIndex\s*=([^;]+);\s*j\s*(>=|>|<=|<|==|!=)([^;]+);\s*j\+\+\s*\)', 'for (int columnIndex =$1; columnIndex $2$3; columnIndex++)'
        $content = $content -replace 'for\s*\(\s*var\s+columnIndex\s*=([^;]+);\s*j\s*(>=|>|<=|<|==|!=)([^;]+);\s*j\+\+\s*\)', 'for (var columnIndex =$1; columnIndex $2$3; columnIndex++)'
        $content = $content -replace 'for\s*\(\s*var\s+columnIndex\s*=([^;]+);\s*j\s*(>=|>|<=|<|==|!=)([^;]+);\s*j--\s*\)', 'for (var columnIndex =$1; columnIndex $2$3; columnIndex--)'

        # thirdIndex patterns
        $content = $content -replace 'for\s*\(\s*int\s+thirdIndex\s*=([^;]+);\s*k\s*(>=|>|<=|<|==|!=)([^;]+);\s*k--\s*\)', 'for (int thirdIndex =$1; thirdIndex $2$3; thirdIndex--)'
        $content = $content -replace 'for\s*\(\s*int\s+thirdIndex\s*=([^;]+);\s*k\s*(>=|>|<=|<|==|!=)([^;]+);\s*k\+\+\s*\)', 'for (int thirdIndex =$1; thirdIndex $2$3; thirdIndex++)'
        $content = $content -replace 'for\s*\(\s*var\s+thirdIndex\s*=([^;]+);\s*k\s*(>=|>|<=|<|==|!=)([^;]+);\s*k\+\+\s*\)', 'for (var thirdIndex =$1; thirdIndex $2$3; thirdIndex++)'
        $content = $content -replace 'for\s*\(\s*var\s+thirdIndex\s*=([^;]+);\s*k\s*(>=|>|<=|<|==|!=)([^;]+);\s*k--\s*\)', 'for (var thirdIndex =$1; thirdIndex $2$3; thirdIndex--)'

        if ($content -ne $originalContent) {
            Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
            return $true
        }

        return $false
    }
    catch {
        Write-Host "      ERROR in $filePath : $_" -ForegroundColor Red
        return $null
    }
}

Write-Host "Processing submodules..." -ForegroundColor White
Write-Host ""

foreach ($submodule in $submodules) {
    $submodulePath = Join-Path $rootPath $submodule

    if (-not (Test-Path $submodulePath)) {
        continue
    }

    Push-Location $submodulePath

    try {
        # EN: Find commit with refactoring message
        # CZ: Najít commit s refactoringovou zprávou
        $commitHash = git log --all --oneline --grep="feat: Replace variables names with self-describe names" --format="%H" | Select-Object -First 1

        if (-not $commitHash) {
            Pop-Location
            continue
        }

        Write-Host "[$submodule]" -ForegroundColor Cyan

        # EN: Get files changed in that commit
        # CZ: Získat soubory změněné v tom commitu
        $changedFiles = git show --name-only --pretty=format:"" $commitHash | Where-Object { $_ -like "*.cs" }

        $submoduleFixed = 0

        foreach ($file in $changedFiles) {
            $fullPath = Join-Path $submodulePath $file

            if (-not (Test-Path $fullPath)) {
                continue
            }

            $filesProcessed++
            $result = Fix-AllIssues -filePath $fullPath

            if ($result -eq $true) {
                $submoduleFixed++
                $totalFixed++
                Write-Host "  ✓ $file" -ForegroundColor Green
            }
            elseif ($result -eq $null) {
                $totalErrors++
            }
        }

        if ($submoduleFixed -eq 0) {
            Write-Host "  - No changes" -ForegroundColor Gray
        }

    } catch {
        Write-Host "  ERROR processing submodule: $_" -ForegroundColor Red
        $totalErrors++
    } finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Yellow
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "Files processed: $filesProcessed" -ForegroundColor White
Write-Host "Files fixed: $totalFixed" -ForegroundColor Green
if ($totalErrors -gt 0) {
    Write-Host "Errors: $totalErrors" -ForegroundColor Red
} else {
    Write-Host "Errors: 0" -ForegroundColor Green
}
Write-Host ""
