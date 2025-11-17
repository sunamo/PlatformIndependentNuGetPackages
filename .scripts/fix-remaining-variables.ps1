# Script to fix remaining problematic variable names in SH.cs
$filePath = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoString\SunamoString\SH.cs"
$content = Get-Content -Path $filePath -Raw
$replacementCount = 0

function Replace-Exact {
    param([string]$Content, [string]$Old, [string]$New)
    if ($Content.Contains($Old)) {
        $script:replacementCount++
        Write-Host "Replaced: $Old"
        return $Content.Replace($Old, $New)
    }
    return $Content
}

Write-Host "Fixing remaining variable names..." -ForegroundColor Green

# Line 1470: ReturnOccurencesOfStringFromTo - already done in first script, check for usage
$content = Replace-Exact $content "for (var Index = 0; Index < searchText.Length - searchTerm.Length + 1 && Index < to; Index++)" "for (var Index = 0; Index < searchText.Length - searchTerm.Length + 1 && Index < to; Index++)"

# Line 1575: WrapWith(string input, string h)
$content = $content -replace '(public static string WrapWith\(string input, string )h\)', '${1}wrapper)'

# Line 1580: WrapWithChar(string input, char v)
$content = $content -replace '(public static string WrapWithChar\(string input, char )v(, bool alsoIfIsWhitespaceOrEmpty = true\))', '${1}wrapperChar${2}'
$content = $content -replace '(public static string WrapWithChar\(string input, char )v\)', '${1}wrapperChar)'

# Line 2088: GetWordOnIndex(string input, int v)
$content = $content -replace '(public static string GetWordOnIndex\(string input, int )v\)', '${1}index)'

# Line 2392: AnotherOtherThanLetterOrDigit(string input, int v)
$content = $content -replace '(public static bool AnotherOtherThanLetterOrDigit\(string input, int )v\)', '${1}startIndex)'

# Line 2495: PadRight(string input, int v)
$content = $content -replace '(public static string PadRight\(string input, int )v\)', '${1}count)'

# Line 2540: ToNumber(string v)
$content = $content -replace '(public static int ToNumber\(string )v\)', '${1}input)'

# Line 2570: InsertEndingBracket(string v)
$content = $content -replace '(public static string InsertEndingBracket\(string )v\)', '${1}input)'

# Line 2645, 2650: GetBracketFromBegin(string input, char v)
$content = $content -replace '(public static int GetBracketFromBegin\(string input, char )v\)', '${1}bracket)'

# Line 3251: RemovePrefix(string input, string v)
$content = $content -replace '(public static string RemovePrefix\(string input, string )v\)', '${1}prefix)'

# Save
Set-Content -Path $filePath -Value $content -NoNewline
Write-Host "`nTotal additional replacements: $replacementCount" -ForegroundColor Green
