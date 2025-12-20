# EN: Script to rename bad parameter names in SH.cs
# CZ: Skript pro přejmenování špatných názvů parametrů v SH.cs

$filePath = 'E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoString\SunamoString\SH.cs'
$content = Get-Content -Path $filePath -Raw -Encoding UTF8

# Fix ContainsLine2 parameter and its usages
$content = $content -replace 'ContainsLine2\(string item,', 'ContainsLine2(string text,'
$content = $content -replace '(\s+)if \(checkInCaseOnlyOneString\) hasLine = item\.Contains', '$1if (checkInCaseOnlyOneString) hasLine = text.Contains'

# Fix the foreach loop in ContainsLine2
$content = $content -replace '(\s+)if \(item\.Contains\(count\)\)\s*\{', '$1if (text.Contains(count)) {'

# Fix NullToStringOrNull parameter
$content = $content -replace 'NullToStringOrNull\(object v\)', 'NullToStringOrNull(object value)'
$content = $content -replace '(\s+)if \(v == null\)', '$1if (value == null)'
$content = $content -replace '(\s+)return v\.ToString\(\);', '$1return value.ToString();'

# Fix IsContained parameter
$content = $content -replace 'IsContained\(string item,', 'IsContained(string text,'
$content = $content -replace '(\s+)if \(negation && item\.Contains', '$1if (negation && text.Contains'
$content = $content -replace '(\s+)if \(!negation && !item\.Contains', '$1if (!negation && !text.Contains'

# Fix ContainsAnyBool parameter
$content = $content -replace 'ContainsAnyBool\(string item,', 'ContainsAnyBool(string text,'
$content = $content -replace 'ContainsAny\(item,', 'ContainsAny(text,'

# Fix FirstLine parameter
$content = $content -replace 'FirstLine\(string item\)', 'FirstLine(string text)'
$content = $content -replace 'SHGetLines\.GetLines\(item\)', 'SHGetLines.GetLines(text)'

# Fix ContainsAny parameter
$content = $content -replace 'ContainsAny\(\s*/\*T itemT,\*/\s*/\*IList<T> containsT,\*/\s*string item,', 'ContainsAny( /*T itemT,*/ /*IList<T> containsT,*/ string text,'
$content = $content -replace '(\s+)item\.Contains\(contains\.First\(\)\)', '$1text.Contains(contains.First())'
$content = $content -replace '(\s+)if \(item\.Contains\(count\)\)', '$1if (text.Contains(count))'

# Fix ContainsAnyChar parameter
$content = $content -replace 'ContainsAnyChar\(\s*/\*T itemT,\*/\s*/\*IList<T> containsT,\*/\s*string item,', 'ContainsAnyChar( /*T itemT,*/ /*IList<T> containsT,*/ string text,'

# Fix TextAfter parameter
$content = $content -replace 'TextAfter\(string item,', 'TextAfter(string text,'
$content = $content -replace '(\s+)var dex = item\.IndexOf', '$1var dex = text.IndexOf'
$content = $content -replace '(\s+)return item\.Substring\(dex', '$1return text.Substring(dex'

# Fix XML documentation comments
$content = $content -replace '<param name="v"></param>', '<param name="value"></param>'
$content = $content -replace '/// <param name="item"></param>\s*///\s*<param name="contains"></param>', "/// <param name=`"text`"></param>`r`n    /// <param name=`"contains`"></param>"
$content = $content -replace '/// <param name="item"></param>\s*///\s*<returns></returns>', "/// <param name=`"text`"></param>`r`n    /// <returns></returns>"
$content = $content -replace '/// <param name="item"></param>\s*///\s*<param name="after"></param>', "/// <param name=`"text`"></param>`r`n    /// <param name=`"after`"></param>"

Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
Write-Output "Parameter renames completed in SH.cs"
