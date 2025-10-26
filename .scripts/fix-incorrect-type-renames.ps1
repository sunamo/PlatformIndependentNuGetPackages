# EN: Fix incorrect type parameter renames (temp -> T, type -> T)
# CZ: Oprava nesprávných přejmenování type parametrů (temp -> T, type -> T)

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "Fixing incorrect type parameter renames..." -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

$totalFixed = 0
$totalErrors = 0

# EN: Get all submodule paths
# CZ: Získat všechny cesty submodulů
$submodules = git config --file .gitmodules --get-regexp path | ForEach-Object {
    $_ -replace 'submodule\..*\.path ', ''
}

if ($submodules.Count -eq 0) {
    Write-Host "No submodules found in this repository." -ForegroundColor Yellow
    exit
}

function Fix-TypeParameters {
    param([string]$filePath)

    try {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        if (-not $content) {
            return $false
        }

        $originalContent = $content

        Write-Host "    Processing: $filePath" -ForegroundColor Gray

        # EN: FIX 1: Replace 'temp' back to 'T' when used as type parameter
        # CZ: OPRAVA 1: Nahradit 'temp' zpět na 'T' když je použito jako type parametr

        # typeof(temp) -> typeof(T)
        $content = $content -replace 'typeof\(temp\)', 'typeof(T)'

        # <temp> in generic constraints and declarations
        $content = $content -replace '<temp>', '<T>'
        $content = $content -replace '<temp,', '<T,'
        $content = $content -replace ',\s*temp>', ', T>'

        # Method return type: public static temp MethodName -> public static T MethodName
        $content = $content -replace '\bpublic\s+static\s+temp\s+(\w+)\s*<', 'public static T $1<'

        # Method parameter: Func<string, temp> -> Func<string, T>
        $content = $content -replace 'Func<([^>]+),\s*temp>', 'Func<$1, T>'
        $content = $content -replace 'Func<temp>', 'Func<T>'

        # Method return in body: return parse.Invoke(v); where return type is temp
        # This needs context - if method signature has temp as return, change all in method

        # EN: FIX 2: Replace 'type' back to 'T' when used as type parameter
        # CZ: OPRAVA 2: Nahradit 'type' zpět na 'T' když je použito jako type parametr

        # typeof(type) -> typeof(T) (but only in generic class context)
        # We need to be careful - 'type' might be legitimate variable name
        # Only fix if we're in a generic class context

        # Check if file contains generic class definition
        if ($content -match 'class\s+\w+<T>') {
            # In generic class - safe to replace type -> T in specific contexts

            # typeof(type) -> typeof(T)
            $content = $content -replace 'typeof\(type\)', 'typeof(T)'

            # Constructor/method parameters: public Method(type param1, type param2)
            # But be careful with 'Type type' which is valid
            $content = $content -replace '\bpublic\s+(\w+)\(type\s+', 'public $1(T '
            $content = $content -replace ',\s*type\s+', ', T '

            # Property declarations: public type PropertyName
            $content = $content -replace '\bpublic\s+type\s+(\w+)\s*\{', 'public T $1 {'
            $content = $content -replace '\bpublic\s+type\s+(\w+)\s*\r?\n', 'public T $1' + "`r`n"

            # Casts: (type) -> (T)
            $content = $content -replace '\(type\)\(dynamic\)', '(T)(dynamic)'

            # Return type: => (type)(dynamic) -> => (T)(dynamic)
            $content = $content -replace '=>\s*\(type\)', '=> (T)'
        }

        # EN: FIX 3: Fix specific patterns with context
        # CZ: OPRAVA 3: Opravit specifické patterny s kontextem

        # Fix: var type = typeof(type); in generic class should be var typeVar = typeof(T);
        # Actually this is tricky - let's just fix typeof(type) -> typeof(T) which we did above
        # And var type = typeof(T); is OK, type here is variable name

        if ($content -ne $originalContent) {
            Write-Host "      ✓ Changes detected, saving..." -ForegroundColor Green
            Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
            return $true
        } else {
            Write-Host "      - No changes needed" -ForegroundColor Gray
        }

        return $false
    }
    catch {
        Write-Host "      Error: $_" -ForegroundColor Red
        return $null
    }
}

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

        Write-Host "`nProcessing submodule: $submodule" -ForegroundColor Cyan

        # EN: Get files changed in that commit
        # CZ: Získat soubory změněné v tom commitu
        $changedFiles = git show --name-only --pretty=format:"" $commitHash | Where-Object { $_ -like "*.cs" }

        $submoduleFixed = 0

        foreach ($file in $changedFiles) {
            $fullPath = Join-Path $submodulePath $file

            if (-not (Test-Path $fullPath)) {
                continue
            }

            $result = Fix-TypeParameters -filePath $fullPath

            if ($result -eq $true) {
                $submoduleFixed++
                $totalFixed++
            }
            elseif ($result -eq $null) {
                $totalErrors++
            }
        }

        if ($submoduleFixed -gt 0) {
            Write-Host "  ${submodule}: $submoduleFixed files fixed" -ForegroundColor Green
        }

    } catch {
        Write-Host "  Error processing submodule: $_" -ForegroundColor Red
        $totalErrors++
    } finally {
        Pop-Location
    }
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 80) -ForegroundColor Gray
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Files fixed: $totalFixed" -ForegroundColor Green
Write-Host "  Errors: $totalErrors" -ForegroundColor Red
