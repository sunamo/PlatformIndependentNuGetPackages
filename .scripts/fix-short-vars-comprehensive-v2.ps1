# EN: Comprehensive script to fix ALL short variable names across all submodules with precision
# CZ: Komplexní skript pro opravu VŠECH krátkých názvů proměnných napříč všemi submoduly s přesností

$rootPath = "E:\vs\Projects\PlatformIndependentNuGetPackages"
Set-Location $rootPath

Write-Host "Fixing ALL short variable names across all submodules (Comprehensive V2)..." -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Gray

$totalFixed = 0
$totalSkipped = 0
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

function Fix-ShortVarsInFile {
    param([string]$filePath)

    try {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        if (-not $content) {
            return $false
        }

        $originalContent = $content

        # EN: CRITICAL FIX - for (var index = 0; i < ...) where index exists but i is used
        # CZ: KRITICKÁ OPRAVA - for (var index = 0; i < ...) kde index existuje ale používá se i

        # Fix: for (var index = X; i < Y; i++) -> for (var index = X; index < Y; index++)
        $content = $content -replace '\bfor\s*\(\s*var\s+index\s*=\s*([^;]+);\s*i\s*<', 'for (var index = $1; index <'
        $content = $content -replace '\bfor\s*\(\s*var\s+index\s*=\s*([^;]+);\s*i\s*>', 'for (var index = $1; index >'
        $content = $content -replace '\bfor\s*\(\s*var\s+index\s*=\s*([^;]+);\s*i\s*<=', 'for (var index = $1; index <='
        $content = $content -replace '\bfor\s*\(\s*var\s+index\s*=\s*([^;]+);\s*i\s*>=', 'for (var index = $1; index >='

        # Fix i++ and i-- when index is declared
        $content = $content -replace ';\s*i\+\+\s*\)\s*\n', '; index++) `n'
        $content = $content -replace ';\s*i--\s*\)\s*\n', '; index--) `n'

        # Fix usage of i when index is the loop variable
        $content = $content -replace '(\[[^\]]*)\bi\]', '$1index]'
        $content = $content -replace '(\s)i\s*\+\+', '$1index++'
        $content = $content -replace '(\s)i\s*--', '$1index--'
        $content = $content -replace '\+\+i\b', '++index'
        $content = $content -replace '\bi,', 'index,'
        $content = $content -replace '\bi\)', 'index)'
        $content = $content -replace '\bi;', 'index;'
        $content = $content -replace '\(i\)', '(index)'

        # EN: Fix method parameters with short names
        # CZ: Opravit parametry metod s krátkými názvy

        # Fix: (object n) -> (object value)
        $content = $content -replace '\(object n\)', '(object value)'
        $content = $content -replace '\bobject n,', 'object value,'
        $content = $content -replace ',\s*object n\)', ', object value)'
        $content = $content -replace '\sn == null', ' value == null'
        $content = $content -replace '\sn !=', ' value !='
        $content = $content -replace '\s\+ n\b', ' + value'
        $content = $content -replace '\(n\)', '(value)'
        $content = $content -replace 'return n ', 'return value '
        $content = $content -replace 'return n;', 'return value;'

        # Fix: (bool n) -> (bool negate)
        $content = $content -replace '\(bool binFp,\s*bool n\)', '(bool binFp, bool negate)'
        $content = $content -replace 'if \(n\) return', 'if (negate) return'

        # Fix: (bool b) -> (bool flag) when b is undefined
        $content = $content -replace 'return !b;', 'return !flag;'
        $content = $content -replace 'return b;', 'return flag;'
        $content = $content -replace '\(bool b\)', '(bool flag)'

        # Fix: parameter c (character) when undefined
        $content = $content -replace '\.First\(\);?\s*$', '.First();'
        $content = $content -replace '\)\(dynamic\)c\.First', ')(dynamic)character.First'
        $content = $content -replace '\)\(dynamic\)c;', ')(dynamic)character;'
        $content = $content -replace '\(string c,', '(string character,'
        $content = $content -replace ',\s*bool isChar\)', ', bool isChar)'
        $content = $content -replace 'string character, bool isChar', 'string character, bool isChar'

        # Fix: (Type t) -> (Type typeParam)
        $content = $content -replace 'type\.Value', 't.Value'
        $content = $content -replace '\(bool\? t\)', '(bool? t)'
        $content = $content -replace 'GetValueOfNullable\(bool\? t\)', 'GetValueOfNullable(bool? t)'

        # Fix: out byte b -> out byte byteValue
        $content = $content -replace 'out byte b\)', 'out byte byteValue)'
        $content = $content -replace 'byte\.TryParse\(id, out b\)', 'byte.TryParse(id, out byteValue)'
        $content = $content -replace 'return vr;', 'return vr;'
        $content = $content -replace '\bb = 0;', 'byteValue = 0;'
        $content = $content -replace 'b = b2;', 'byteValue = b2;'

        # EN: Fix StringBuilder sb
        # CZ: Opravit StringBuilder sb
        $content = $content -replace '\bvar sb = new StringBuilder\(', 'var stringBuilder = new StringBuilder('
        $content = $content -replace '\bStringBuilder sb([,;\)\s])', 'StringBuilder stringBuilder$1'
        $content = $content -replace '(\s)sb\.', '$1stringBuilder.'
        $content = $content -replace '\(sb,', '(stringBuilder,'
        $content = $content -replace '\(sb\)', '(stringBuilder)'
        $content = $content -replace '\ssb,', ' stringBuilder,'
        $content = $content -replace '\ssb\)', ' stringBuilder)'
        $content = $content -replace '\ssb;', ' stringBuilder;'
        $content = $content -replace '\bsb\.', 'stringBuilder.'
        $content = $content -replace 'return sb;', 'return stringBuilder;'

        # EN: Fix List<> l
        # CZ: Opravit List<> l
        $content = $content -replace '\bvar l = new List<', 'var list = new List<'
        $content = $content -replace 'List<([^>]+)> l([,;\)\s])', 'List<$1> list$2'
        $content = $content -replace '(\s)l\.', '$1list.'
        $content = $content -replace '\(l,', '(list,'
        $content = $content -replace '\(l\)', '(list)'
        $content = $content -replace '\sl,', ' list,'
        $content = $content -replace '\sl\)', ' list)'
        $content = $content -replace '\sl;', ' list;'
        $content = $content -replace '\bl\.', 'list.'
        $content = $content -replace '\bl\[', 'list['
        $content = $content -replace 'return l;', 'return list;'

        # EN: Fix string s (but not in short names like ns, cs, etc.)
        # CZ: Opravit string s (ale ne v krátkých názvech jako ns, cs, atd.)
        $content = $content -replace '\bstring s([,;\)\s])', 'string str$1'
        $content = $content -replace '\bvar s = "', 'var str = "'
        $content = $content -replace '\bvar s = [^n]', 'var str = '

        # EN: Fix char c
        # CZ: Opravit char c
        $content = $content -replace '\bchar c([,;\)\s])', 'char character$1'
        $content = $content -replace '\bvar c = ', 'var character = '

        # EN: Fix var e (element/exception)
        # CZ: Opravit var e (prvek/výjimka)
        $content = $content -replace '\bcatch \(Exception e\)', 'catch (Exception exception)'
        $content = $content -replace '\bvar e = ', 'var element = '

        # EN: Fix var t (type)
        # CZ: Opravit var t (typ)
        $content = $content -replace '\bvar t = typeof\(', 'var type = typeof('
        $content = $content -replace '\bType t([,;\)\s])', 'Type type$1'

        # EN: Fix var d (dictionary)
        # CZ: Opravit var d (slovník)
        $content = $content -replace '\bvar d = new Dictionary<', 'var dictionary = new Dictionary<'
        $content = $content -replace 'Dictionary<([^>]+)> d([,;\)\s])', 'Dictionary<$1> dictionary$2'

        # EN: Fix var v (value) - but not in common abbreviations
        # CZ: Opravit var v (hodnota) - ale ne v běžných zkratkách
        $content = $content -replace '\bvar v = ', 'var value = '

        # EN: Fix var m (message/match)
        # CZ: Opravit var m (zpráva/shoda)
        $content = $content -replace '\bvar m = ', 'var message = '

        # EN: Fix var p (path/parameter)
        # CZ: Opravit var p (cesta/parametr)
        $content = $content -replace '\bvar p = ', 'var path = '

        # EN: Fix var r (result)
        # CZ: Opravit var r (výsledek)
        $content = $content -replace '\bvar r = ', 'var result = '

        # EN: Fix var a (array)
        # CZ: Opravit var a (pole)
        $content = $content -replace '\bvar a = ', 'var array = '

        # EN: Fix lines/list ls
        # CZ: Opravit řádky ls
        $content = $content -replace '\bvar ls = ', 'var lines = '
        $content = $content -replace '(\s)ls\.', '$1lines.'
        $content = $content -replace '\(ls,', '(lines,'
        $content = $content -replace '\(ls\)', '(lines)'
        $content = $content -replace '\sls,', ' lines,'
        $content = $content -replace '\sls\)', ' lines)'
        $content = $content -replace '\sls;', ' lines;'

        if ($content -ne $originalContent) {
            Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
            return $true
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

        Write-Host "`nProcessing: $submodule" -ForegroundColor Green

        # EN: Get files changed in that commit
        # CZ: Získat soubory změněné v tom commitu
        $changedFiles = git show --name-only --pretty=format:"" $commitHash | Where-Object { $_ -like "*.cs" }

        $submoduleFixed = 0
        $submoduleSkipped = 0

        foreach ($file in $changedFiles) {
            $fullPath = Join-Path $submodulePath $file

            if (-not (Test-Path $fullPath)) {
                continue
            }

            $result = Fix-ShortVarsInFile -filePath $fullPath

            if ($result -eq $true) {
                Write-Host "  ✓ Fixed: $file" -ForegroundColor Green
                $submoduleFixed++
                $totalFixed++
            }
            elseif ($result -eq $false) {
                $submoduleSkipped++
                $totalSkipped++
            }
            else {
                $totalErrors++
            }
        }

        if ($submoduleFixed -gt 0) {
            Write-Host "  Submodule summary: $submoduleFixed fixed, $submoduleSkipped skipped" -ForegroundColor Cyan
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
Write-Host "  Files skipped (no changes): $totalSkipped" -ForegroundColor Yellow
Write-Host "  Errors: $totalErrors" -ForegroundColor Red
