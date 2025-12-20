# Script to fix all problematic variable names in SH.cs
# This script performs context-aware renaming to avoid false positives

$filePath = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoString\SunamoString\SH.cs"
$content = Get-Content -Path $filePath -Raw

# Track number of replacements
$replacementCount = 0

# Function to perform context-aware replacement
function Replace-InContext {
    param(
        [string]$Content,
        [string]$Pattern,
        [string]$Replacement
    )

    $newContent = $Content -replace $Pattern, $Replacement
    if ($newContent -ne $Content) {
        $script:replacementCount++
        Write-Host "Replaced: $Pattern -> $Replacement"
    }
    return $newContent
}

Write-Host "Starting variable renames in SH.cs..." -ForegroundColor Green

# Line 64: WhiteSpaceFromStart(string v) -> WhiteSpaceFromStart(string input)
$content = Replace-InContext $content '(public static string WhiteSpaceFromStart\(string )v\)' '${1}input)'
$content = Replace-InContext $content '(WhiteSpaceFromStart\(string v\)\s+\{\s+var stringBuilder = new StringBuilder\(\);[\s\S]*?foreach \(var item in )v\)' '${1}input)'

# Line 231: RemoveEndingPairCharsWhenDontHaveStarting parameters
$content = Replace-InContext $content '(public static string RemoveEndingPairCharsWhenDontHaveStarting\(string )vr(, string )cbl(, string )cbr\)' '${1}input${2}leftBracket${3}rightBracket)'
$content = Replace-InContext $content '(RemoveEndingPairCharsWhenDontHaveStarting\(string vr, string cbl, string cbr\)\s+\{\s+var removeOnIndexes = new List<int>\(\);[\s\S]*?var stringBuilder = new StringBuilder\()vr\)' '${1}input)'
$content = Replace-InContext $content '(var leftBracketOccurrences = ReturnOccurencesOfString\()vr(, )cbl\)' '${1}input${2}leftBracket)'
$content = Replace-InContext $content '(var rightBracketOccurrences = ReturnOccurencesOfString\()vr(, )cbr\)' '${1}input${2}rightBracket)'

# Line 445: ReturnOccurencesOfString(string vcem, string co)
$content = Replace-InContext $content '(public static List<int> ReturnOccurencesOfString\(string )vcem(, string )co\)' '${1}searchText${2}searchTerm)'
$content = Replace-InContext $content '(ReturnOccurencesOfString\(string vcem, string co\)[\s\S]{0,200}for \(var Index = 0; Index < )vcem(\.Length - )co(\.Length)' '${1}searchText${2}searchTerm${3}'
$content = Replace-InContext $content '(var subs = )vcem(\.Substring\(Index, )co(\.Length\))' '${1}searchText${2}searchTerm${3}'
$content = Replace-InContext $content '(var firstCharOfSearchTerm = )co(\[0\];)' '${1}searchTerm${2}'

# Line 495: WrapWithIf(string v, string f)
$content = Replace-InContext $content '(public static string WrapWithIf\(string )v(, string )f\)' '${1}wrapper${2}predicate)'

# Line 515, 537, 546: GetPartsByLocation parameters
$content = Replace-InContext $content '(public static string GetPartsByLocation\(string input, string )za(, GetLocation )' '${1}after${2}'
$content = Replace-InContext $content '(public static string GetPartsByLocation\(string input, GetLocation fromEnd, string )or\)' '${1}delimiter)'
$content = Replace-InContext $content '(public static string GetPartsByLocation\(string input, string or, GetLocation fromEnd\))' '${1}input, string delimiter, GetLocation fromEnd)'

# Line 735: SwitchSwap(string co, string v)
$content = Replace-InContext $content '(public static string SwitchSwap\(string )co(, string )v\)' '${1}input${2}delimiter)'

# Line 741: InsertBeforeEndingBracket(string input, string v)
$content = Replace-InContext $content '(public static string InsertBeforeEndingBracket\(string input, string )v\)' '${1}textToInsert)'
$content = Replace-InContext $content '(InsertBeforeEndingBracket\(string input, string v\)[\s\S]{0,100}var )dx( = )' '${1}bracketIndex${2}'

# Line 785, 1131: local variable ch -> currentChar (multiple occurrences)
# These need careful handling to avoid conflicts

# Line 1140: Leading(string v)
$content = Replace-InContext $content '(public static string Leading\(string )v\)' '${1}input)'

# Line 1150: IsOnIndex(string input, int dx)
$content = Replace-InContext $content '(public static bool IsOnIndex\(string input, int )dx\)' '${1}index)'

# Line 1269: HasCharRightFormat(char ch)
$content = Replace-InContext $content '(public static bool HasCharRightFormat\(char )ch\)' '${1}character)'

# Line 1304: RemoveBracketsWithTextCaseInsensitive
$content = Replace-InContext $content '(public static string RemoveBracketsWithTextCaseInsensitive\(string )vr(, string )zaCo(, params string\[\] )co\)' '${1}input${2}replacement${3}patterns)'

# Line 1313: RemoveBracketsWithoutText(string vr)
$content = Replace-InContext $content '(public static string RemoveBracketsWithoutText\(string )vr\)' '${1}input)'

# Line 1317: WithoutSpecialChars(string v)
$content = Replace-InContext $content '(public static string WithoutSpecialChars\(string )v\)' '${1}input)'

# Line 1327: RemoveBracketsFromStart(string vr)
$content = Replace-InContext $content '(public static string RemoveBracketsFromStart\(string )vr\)' '${1}input)'

# Line 1380: ToCase(string v, TextCasing textCasing)
$content = Replace-InContext $content '(public static string ToCase\(string )v(, TextCasing textCasing\))' '${1}input${2}'

# Line 1470: ReturnOccurencesOfStringFromTo(string vcem, string co, ...)
$content = Replace-InContext $content '(public static List<int> ReturnOccurencesOfStringFromTo\(string )vcem(, string )co(, int from, int to\))' '${1}searchText${2}searchTerm${3}'

# Line 1575: WrapWith(string input, string h)
$content = Replace-InContext $content '(public static string WrapWith\(string input, string )h\)' '${1}wrapper)'

# Line 1580: WrapWithChar(string input, char v)
$content = Replace-InContext $content '(public static string WrapWithChar\(string input, char )v\)' '${1}wrapperChar)'

# Line 1615: CountOf(string pi, char v)
$content = Replace-InContext $content '(public static int CountOf\(string )pi(, char )v\)' '${1}input${2}character)'

# Line 2088: GetWordOnIndex(string input, int v)
$content = Replace-InContext $content '(public static string GetWordOnIndex\(string input, int )v\)' '${1}index)'

# Line 2392: AnotherOtherThanLetterOrDigit(string input, int v)
$content = Replace-InContext $content '(public static bool AnotherOtherThanLetterOrDigit\(string input, int )v\)' '${1}startIndex)'

# Line 2407: TabToNewLine(string v)
$content = Replace-InContext $content '(public static string TabToNewLine\(string )v\)' '${1}input)'

# Line 2443: IndexesOfChars(string input, char ch)
$content = Replace-InContext $content '(public static List<int> IndexesOfChars\(string input, char )ch\)' '${1}searchChar)'

# Line 2476: ClosingBracketFor(char v)
$content = Replace-InContext $content '(public static char ClosingBracketFor\(char )v\)' '${1}openingBracket)'

# Line 2495: PadRight(string input, int v)
$content = Replace-InContext $content '(public static string PadRight\(string input, int )v\)' '${1}count)'

# Line 2540: ToNumber(string v)
$content = Replace-InContext $content '(public static int ToNumber\(string )v\)' '${1}input)'

# Line 2552: IsNumbered(string v)
$content = Replace-InContext $content '(public static bool IsNumbered\(string )v\)' '${1}input)'

# Line 2570: InsertEndingBracket(string v)
$content = Replace-InContext $content '(public static string InsertEndingBracket\(string )v\)' '${1}input)'

# Line 2645, 2650: GetBracketFromBegin(string input, char v)
$content = Replace-InContext $content '(public static int GetBracketFromBegin\(string input, char )v\)' '${1}bracket)'

# Line 2776: TelephonePrefixToBrackets(string v)
$content = Replace-InContext $content '(public static string TelephonePrefixToBrackets\(string )v\)' '${1}phoneNumber)'

# Line 2788, 2824: ContainsVariable parameters
$content = Replace-InContext $content '(public static bool ContainsVariable\(string input, char k\))' '${1}input, char closingChar)'
$content = Replace-InContext $content '(ContainsVariable\(string input, char )k\)' '${1}closingChar)'

# Line 3170: GetFirstPartByLocation local variable dx
$content = Replace-InContext $content '(GetFirstPartByLocation[\s\S]{0,200}var )dx( = input\.IndexOf\(delimiter\);)' '${1}delimiterIndex${2}'

# Line 3251: RemovePrefix(string input, string v)
$content = Replace-InContext $content '(public static string RemovePrefix\(string input, string )v\)' '${1}prefix)'

# Line 3270: NullToStringOrEmpty(object v)
$content = Replace-InContext $content '(public static string NullToStringOrEmpty\(object )v\)' '${1}value)'

# Line 3319, 3328: FirstCharOfEveryWordUpperDash(string v)
$content = Replace-InContext $content '(public static string FirstCharOfEveryWordUpperDash\(string )v\)' '${1}input)'

# Save the modified content
Set-Content -Path $filePath -Value $content -NoNewline

Write-Host "`nTotal replacements made: $replacementCount" -ForegroundColor Green
Write-Host "File updated: $filePath" -ForegroundColor Green
