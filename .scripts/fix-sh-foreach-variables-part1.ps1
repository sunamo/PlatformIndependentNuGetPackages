# Script to fix foreach variables in SH.cs (PART 1 - first 20 occurrences)
$filePath = "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoString\SunamoString\SH.cs"

# Read the file as lines
$lines = Get-Content -Path $filePath

# Track fixes
$fixCount = 0

# Fix 1: Line 32 - foreach (var item in termParts) → foreach (var term in termParts)
if ($lines[31] -match 'foreach \(var item in termParts\)') {
    $lines[31] = $lines[31] -replace 'foreach \(var item in termParts\)', 'foreach (var term in termParts)'
    $fixCount++
}
# Fix 1: Line 34 - if (!input.Contains(item)) → if (!input.Contains(term))
if ($lines[33] -match 'if \(!input\.Contains\(item\)\)') {
    $lines[33] = $lines[33] -replace 'if \(!input\.Contains\(item\)\)', 'if (!input.Contains(term))'
    $fixCount++
}

# Fix 2: Line 42 - foreach (var item in termParts) → foreach (var searchTerm in termParts)
if ($lines[41] -match 'foreach \(var item in termParts\)') {
    $lines[41] = $lines[41] -replace 'foreach \(var item in termParts\)', 'foreach (var searchTerm in termParts)'
    $fixCount++
}
# Fix 2: Line 44 - if (!input.Contains(item)) → if (!input.Contains(searchTerm))
if ($lines[43] -match 'if \(!input\.Contains\(item\)\)') {
    $lines[43] = $lines[43] -replace 'if \(!input\.Contains\(item\)\)', 'if (!input.Contains(searchTerm))'
    $fixCount++
}

# Fix 3: Line 52 - foreach (var item in termParts) → foreach (var part in termParts)
if ($lines[51] -match 'foreach \(var item in termParts\)') {
    $lines[51] = $lines[51] -replace 'foreach \(var item in termParts\)', 'foreach (var part in termParts)'
    $fixCount++
}
# Fix 3: Line 54 - if (!inputParts.Contains(item)) → if (!inputParts.Contains(part))
if ($lines[53] -match 'if \(!inputParts\.Contains\(item\)\)') {
    $lines[53] = $lines[53] -replace 'if \(!inputParts\.Contains\(item\)\)', 'if (!inputParts.Contains(part))'
    $fixCount++
}

# Fix 4: Line 67 - foreach (var item in input) → foreach (var character in input)
if ($lines[66] -match 'foreach \(var item in input\)') {
    $lines[66] = $lines[66] -replace 'foreach \(var item in input\)', 'foreach (var character in input)'
    $fixCount++
}
# Fix 4: Line 68 - if (char.IsWhiteSpace(item)) → if (char.IsWhiteSpace(character))
if ($lines[67] -match 'if \(char\.IsWhiteSpace\(item\)\)') {
    $lines[67] = $lines[67] -replace 'if \(char\.IsWhiteSpace\(item\)\)', 'if (char.IsWhiteSpace(character))'
    $fixCount++
}
# Fix 4: Line 69 - stringBuilder.Append(item); → stringBuilder.Append(character);
if ($lines[68] -match 'stringBuilder\.Append\(item\);') {
    $lines[68] = $lines[68] -replace 'stringBuilder\.Append\(item\);', 'stringBuilder.Append(character);'
    $fixCount++
}

# Fix 5: Line 153 - foreach (var item in allWords) → foreach (var word in allWords)
if ($lines[152] -match 'foreach \(var item in allWords\)') {
    $lines[152] = $lines[152] -replace 'foreach \(var item in allWords\)', 'foreach (var word in allWords)'
    $fixCount++
}
# Fix 5: Line 154 - if (!input.Contains(item)) → if (!input.Contains(word))
if ($lines[153] -match 'if \(!input\.Contains\(item\)\)') {
    $lines[153] = $lines[153] -replace 'if \(!input\.Contains\(item\)\)', 'if (!input.Contains(word))'
    $fixCount++
}

# Fix 6: Line 159 - foreach (var item in allWords) → foreach (var word in allWords)
if ($lines[158] -match 'foreach \(var item in allWords\)') {
    $lines[158] = $lines[158] -replace 'foreach \(var item in allWords\)', 'foreach (var word in allWords)'
    $fixCount++
}
# Fix 6: Line 161 - var searchTerm = item; → var searchTerm = word;
if ($lines[160] -match 'var searchTerm = item;') {
    $lines[160] = $lines[160] -replace 'var searchTerm = item;', 'var searchTerm = word;'
    $fixCount++
}

# Fix 7: Line 167 - foreach (var item in allWords) → foreach (var word in allWords)
if ($lines[166] -match 'foreach \(var item in allWords\)') {
    $lines[166] = $lines[166] -replace 'foreach \(var item in allWords\)', 'foreach (var word in allWords)'
    $fixCount++
}
# Fix 7: Line 168 - if (!input.Contains(item)) → if (!input.Contains(word))
if ($lines[167] -match 'if \(!input\.Contains\(item\)\)') {
    $lines[167] = $lines[167] -replace 'if \(!input\.Contains\(item\)\)', 'if (!input.Contains(word))'
    $fixCount++
}

# Fix 8: Line 341 - foreach (var item in addToAnotherCollection) → foreach (var index in addToAnotherCollection)
if ($lines[340] -match 'foreach \(var item in addToAnotherCollection\)') {
    $lines[340] = $lines[340] -replace 'foreach \(var item in addToAnotherCollection\)', 'foreach (var index in addToAnotherCollection)'
    $fixCount++
}
# Fix 8: Line 343 - var count = alreadyProcessedItem1.Where(data => data == item).Count(); → var count = alreadyProcessedItem1.Where(data => data == index).Count();
if ($lines[342] -match 'var count = alreadyProcessedItem1\.Where\(data => data == item\)\.Count\(\);') {
    $lines[342] = $lines[342] -replace 'var count = alreadyProcessedItem1\.Where\(data => data == item\)\.Count\(\);', 'var count = alreadyProcessedItem1.Where(data => data == index).Count();'
    $fixCount++
}
# Fix 8: Line 347 - var sele = additionalPairs.Where(data => data.Item1 == item).ToList(); → var sele = additionalPairs.Where(data => data.Item1 == index).ToList();
if ($lines[346] -match 'var sele = additionalPairs\.Where\(data => data\.Item1 == item\)\.ToList\(\);') {
    $lines[346] = $lines[346] -replace 'var sele = additionalPairs\.Where\(data => data\.Item1 == item\)\.ToList\(\);', 'var sele = additionalPairs.Where(data => data.Item1 == index).ToList();'
    $fixCount++
}

# Fix 9: Line 368 - var item = result[yValue]; → var pairEntry = result[yValue];
if ($lines[367] -match 'var item = result\[yValue\];') {
    $lines[367] = $lines[367] -replace 'var item = result\[yValue\];', 'var pairEntry = result[yValue];'
    $fixCount++
}
# Fix 9: Line 369 - var i = item.Item1; → var startIndex = pairEntry.Item1;
if ($lines[368] -match 'var i = item\.Item1;') {
    $lines[368] = $lines[368] -replace 'var i = item\.Item1;', 'var startIndex = pairEntry.Item1;'
    $fixCount++
}
# Fix 9: Update uses of i to startIndex in following lines
if ($lines[369] -match 'if \(alreadyProcessed\.Contains\(i\)\)') {
    $lines[369] = $lines[369] -replace 'if \(alreadyProcessed\.Contains\(i\)\)', 'if (alreadyProcessed.Contains(startIndex))'
    $fixCount++
}
if ($lines[371] -match 'foundIndex = leftBracketOccurrences\.IndexOf\(i\);') {
    $lines[371] = $lines[371] -replace 'foundIndex = leftBracketOccurrences\.IndexOf\(i\);', 'foundIndex = leftBracketOccurrences.IndexOf(startIndex);'
    $fixCount++
}
if ($lines[374] -match 'i = leftBracketOccurrences\[foundIndex - 1\];') {
    $lines[374] = $lines[374] -replace 'i = leftBracketOccurrences\[foundIndex - 1\];', 'startIndex = leftBracketOccurrences[foundIndex - 1];'
    $fixCount++
}
if ($lines[375] -match 'result\[i\] = new Tuple<int, int>\(i, result\[yValue - 1\]\.Item2\);') {
    $lines[375] = $lines[375] -replace 'result\[i\] = new Tuple<int, int>\(i, result\[yValue - 1\]\.Item2\);', 'result[startIndex] = new Tuple<int, int>(startIndex, result[yValue - 1].Item2);'
    $fixCount++
}
if ($lines[378] -match 'alreadyProcessed\.Add\(i\);') {
    $lines[378] = $lines[378] -replace 'alreadyProcessed\.Add\(i\);', 'alreadyProcessed.Add(startIndex);'
    $fixCount++
}

# Fix 10: Line 384 - foreach (var item in result) → foreach (var pair in result)
if ($lines[383] -match 'foreach \(var item in result\)') {
    $lines[383] = $lines[383] -replace 'foreach \(var item in result\)', 'foreach (var pair in result)'
    $fixCount++
}
# Fix 10: Line 386 - unmatchedLeftBrackets.Remove(item.Item1); → unmatchedLeftBrackets.Remove(pair.Item1);
if ($lines[385] -match 'unmatchedLeftBrackets\.Remove\(item\.Item1\);') {
    $lines[385] = $lines[385] -replace 'unmatchedLeftBrackets\.Remove\(item\.Item1\);', 'unmatchedLeftBrackets.Remove(pair.Item1);'
    $fixCount++
}
# Fix 10: Line 387 - unmatchedRightBrackets.Remove(item.Item2); → unmatchedRightBrackets.Remove(pair.Item2);
if ($lines[386] -match 'unmatchedRightBrackets\.Remove\(item\.Item2\);') {
    $lines[386] = $lines[386] -replace 'unmatchedRightBrackets\.Remove\(item\.Item2\);', 'unmatchedRightBrackets.Remove(pair.Item2);'
    $fixCount++
}

# Fix 11: Line 429 - foreach (var item in text) → foreach (var character in text)
if ($lines[428] -match 'foreach \(var item in text\)') {
    $lines[428] = $lines[428] -replace 'foreach \(var item in text\)', 'foreach (var character in text)'
    $fixCount++
}
# Fix 11: Line 430 - if (item == (char)160) → if (character == (char)160)
if ($lines[429] -match 'if \(item == \(char\)160\)') {
    $lines[429] = $lines[429] -replace 'if \(item == \(char\)160\)', 'if (character == (char)160)'
    $fixCount++
}
# Fix 11: Line 433 - stringBuilder.Append(item); → stringBuilder.Append(character);
if ($lines[432] -match 'stringBuilder\.Append\(item\);') {
    $lines[432] = $lines[432] -replace 'stringBuilder\.Append\(item\);', 'stringBuilder.Append(character);'
    $fixCount++
}

# Fix 12: Line 664 - foreach (var item in str) → foreach (var character in str)
if ($lines[663] -match 'foreach \(var item in str\)') {
    $lines[663] = $lines[663] -replace 'foreach \(var item in str\)', 'foreach (var character in str)'
    $fixCount++
}
# Fix 12: Line 665 - if (!char.IsNumber(item)) → if (!char.IsNumber(character))
if ($lines[664] -match 'if \(!char\.IsNumber\(item\)\)') {
    $lines[664] = $lines[664] -replace 'if \(!char\.IsNumber\(item\)\)', 'if (!char.IsNumber(character))'
    $fixCount++
}
# Fix 12: Line 666 - if (!nextAllowedChars.Contains(item)) → if (!nextAllowedChars.Contains(character))
if ($lines[665] -match 'if \(!nextAllowedChars\.Contains\(item\)\)') {
    $lines[665] = $lines[665] -replace 'if \(!nextAllowedChars\.Contains\(item\)\)', 'if (!nextAllowedChars.Contains(character))'
    $fixCount++
}

# Fix 13: Line 754 - foreach (var item in charsToStrategy) → foreach (var character in charsToStrategy)
if ($lines[753] -match 'foreach \(var item in charsToStrategy\)') {
    $lines[753] = $lines[753] -replace 'foreach \(var item in charsToStrategy\)', 'foreach (var character in charsToStrategy)'
    $fixCount++
}
# Fix 13: Line 755 - list.Add(item, 0); → list.Add(character, 0);
if ($lines[754] -match 'list\.Add\(item, 0\);') {
    $lines[754] = $lines[754] -replace 'list\.Add\(item, 0\);', 'list.Add(character, 0);'
    $fixCount++
}
# Fix 13: Line 756 - foreach (var item in between) → foreach (var character in between)
if ($lines[755] -match 'foreach \(var item in between\)') {
    $lines[755] = $lines[755] -replace 'foreach \(var item in between\)', 'foreach (var character in between)'
    $fixCount++
}
# Fix 13: Line 759 - if (ignoreCompletely.Contains(item)) → if (ignoreCompletely.Contains(character))
if ($lines[758] -match 'if \(ignoreCompletely\.Contains\(item\)\)') {
    $lines[758] = $lines[758] -replace 'if \(ignoreCompletely\.Contains\(item\)\)', 'if (ignoreCompletely.Contains(character))'
    $fixCount++
}
# Fix 13: Line 761 - DictionaryHelper.AddOrPlus(list, item, 1); → DictionaryHelper.AddOrPlus(list, character, 1);
if ($lines[760] -match 'DictionaryHelper\.AddOrPlus\(list, item, 1\);') {
    $lines[760] = $lines[760] -replace 'DictionaryHelper\.AddOrPlus\(list, item, 1\);', 'DictionaryHelper.AddOrPlus(list, character, 1);'
    $fixCount++
}

# Fix 14: Line 821 - foreach (var item in list) → foreach (var searchValue in list)
if ($lines[820] -match 'foreach \(var item in list\)') {
    $lines[820] = $lines[820] -replace 'foreach \(var item in list\)', 'foreach (var searchValue in list)'
    $fixCount++
}
# Fix 14: Line 823 - if (text.ToString().Contains(item)) result.Add(matchIndex); → if (text.ToString().Contains(searchValue)) result.Add(matchIndex);
if ($lines[822] -match 'if \(text\.ToString\(\)\.Contains\(item\)\) result\.Add\(matchIndex\);') {
    $lines[822] = $lines[822] -replace 'if \(text\.ToString\(\)\.Contains\(item\)\) result\.Add\(matchIndex\);', 'if (text.ToString().Contains(searchValue)) result.Add(matchIndex);'
    $fixCount++
}

# Fix 15: Line 888 - foreach (string item in result) → foreach (string element in result)
if ($lines[887] -match 'foreach \(string item in result\)') {
    $lines[887] = $lines[887] -replace 'foreach \(string item in result\)', 'foreach (string element in result)'
    $fixCount++
}
# Fix 15: Line 888 - stringBuilder.Append(item + " "); → stringBuilder.Append(element + " ");
if ($lines[887] -match 'stringBuilder\.Append\(item \+ " "\);') {
    $lines[887] = $lines[887] -replace 'stringBuilder\.Append\(item \+ " "\);', 'stringBuilder.Append(element + " ");'
    $fixCount++
}

# Fix 16: Line 893 - foreach (var item in list) → foreach (var text in list)
if ($lines[892] -match 'foreach \(var item in list\)') {
    $lines[892] = $lines[892] -replace 'foreach \(var item in list\)', 'foreach (var text in list)'
    $fixCount++
}
# Fix 16: Line 894 - if (IsNullOrWhiteSpace(item)) → if (IsNullOrWhiteSpace(text))
if ($lines[893] -match 'if \(IsNullOrWhiteSpace\(item\)\)') {
    $lines[893] = $lines[893] -replace 'if \(IsNullOrWhiteSpace\(item\)\)', 'if (IsNullOrWhiteSpace(text))'
    $fixCount++
}

# Fix 17: Line 905 - foreach (var item in line) → foreach (var character in line)
if ($lines[904] -match 'foreach \(var item in line\)') {
    $lines[904] = $lines[904] -replace 'foreach \(var item in line\)', 'foreach (var character in line)'
    $fixCount++
}
# Fix 17: Line 906 - if (char.IsWhiteSpace(item)) → if (char.IsWhiteSpace(character))
if ($lines[905] -match 'if \(char\.IsWhiteSpace\(item\)\)') {
    $lines[905] = $lines[905] -replace 'if \(char\.IsWhiteSpace\(item\)\)', 'if (char.IsWhiteSpace(character))'
    $fixCount++
}
# Fix 17: Line 907 - stringBuilder.Append(item); → stringBuilder.Append(character);
if ($lines[906] -match 'stringBuilder\.Append\(item\);') {
    $lines[906] = $lines[906] -replace 'stringBuilder\.Append\(item\);', 'stringBuilder.Append(character);'
    $fixCount++
}

# Fix 18: Line 1027 - foreach (var item in counted) → foreach (var kvp in counted)
if ($lines[1026] -match 'foreach \(var item in counted\)') {
    $lines[1026] = $lines[1026] -replace 'foreach \(var item in counted\)', 'foreach (var kvp in counted)'
    $fixCount++
}
# Fix 18: Line 1027 - stringBuilder.AppendLine(item.Value + "x " + item.Key); → stringBuilder.AppendLine(kvp.Value + "x " + kvp.Key);
if ($lines[1026] -match 'stringBuilder\.AppendLine\(item\.Value \+ "x " \+ item\.Key\);') {
    $lines[1026] = $lines[1026] -replace 'stringBuilder\.AppendLine\(item\.Value \+ "x " \+ item\.Key\);', 'stringBuilder.AppendLine(kvp.Value + "x " + kvp.Key);'
    $fixCount++
}

# Fix 19: Line 1082 - foreach (var item in line) → foreach (var character in line)
if ($lines[1081] -match 'foreach \(var item in line\)') {
    $lines[1081] = $lines[1081] -replace 'foreach \(var item in line\)', 'foreach (var character in line)'
    $fixCount++
}
# Fix 19: Line 1083 - if (char.IsWhiteSpace(item)) → if (char.IsWhiteSpace(character))
if ($lines[1082] -match 'if \(char\.IsWhiteSpace\(item\)\)') {
    $lines[1082] = $lines[1082] -replace 'if \(char\.IsWhiteSpace\(item\)\)', 'if (char.IsWhiteSpace(character))'
    $fixCount++
}
# Fix 19: Line 1084 - stringBuilder.Append(item); → stringBuilder.Append(character);
if ($lines[1083] -match 'stringBuilder\.Append\(item\);') {
    $lines[1083] = $lines[1083] -replace 'stringBuilder\.Append\(item\);', 'stringBuilder.Append(character);'
    $fixCount++
}

# Fix 20: Line 1143 - foreach (var item in input) → foreach (var character in input)
if ($lines[1142] -match 'foreach \(var item in input\)') {
    $lines[1142] = $lines[1142] -replace 'foreach \(var item in input\)', 'foreach (var character in input)'
    $fixCount++
}
# Fix 20: Line 1144 - if (isWhiteSpace.Invoke(item)) → if (isWhiteSpace.Invoke(character))
if ($lines[1143] -match 'if \(isWhiteSpace\.Invoke\(item\)\)') {
    $lines[1143] = $lines[1143] -replace 'if \(isWhiteSpace\.Invoke\(item\)\)', 'if (isWhiteSpace.Invoke(character))'
    $fixCount++
}
# Fix 20: Line 1145 - stringBuilder.Append(item); → stringBuilder.Append(character);
if ($lines[1144] -match 'stringBuilder\.Append\(item\);') {
    $lines[1144] = $lines[1144] -replace 'stringBuilder\.Append\(item\);', 'stringBuilder.Append(character);'
    $fixCount++
}

# Write back to file
$lines | Set-Content -Path $filePath

Write-Host "Applied $fixCount fixes to $filePath"
Write-Host "Done!"
