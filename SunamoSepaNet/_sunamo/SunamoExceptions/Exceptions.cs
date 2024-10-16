namespace SunamoSepaNet._sunamo.SunamoExceptions;
internal sealed partial class Exceptions
{
    internal static string? FileAlreadyExists(string before, string path)
    {
        if (File.Exists(path))
        {
            return CheckBefore(before) + path + " already exists";
        }
        return null;
    }
    internal static string? ListNullOrEmpty<T>(string before, string variableName, IEnumerable<T>? t)
    {
        if (t == null)
        {
            return CheckBefore(before) + variableName + " is null";
        }
        bool isEmpty = true;
        foreach (var item in t)
        {
            isEmpty = false;
            break;
        }
        if (isEmpty)
        {
            return CheckBefore(before) + variableName + " is empty!";
        }
        return null;
    }
    internal static string? LockedByBitLocker(string before, string path, Func<char, bool> IsLockedByBitLocker)
    {
        if (IsLockedByBitLocker != null)
        {
            var p = path[0];
            if (IsLockedByBitLocker(p))
            {
                return CheckBefore(before) + $"Drive {p}:\\ is locked by BitLocker";
            }
        }
        return null;
    }
    internal static string? NotInt(string before, string what, int? value)
    {
        return !value.HasValue ? CheckBefore(before) + what + " is not with value " + value + " valid integer number" : null;
    }
    internal static string? IsOdd(string before, string colName, ICollection col)
    {
        return col.Count % 2 == 1 ? CheckBefore(before) + colName + " has odd number of elements " + col.Count : null;
    }
    internal static string? WrongExtension(string before, string path, string ext)
    {
        return System.IO.Path.GetExtension(path) != ext ? CheckBefore(before) + path + "don't have " + ext + " extension" : null;
    }
    internal static string? WrongNumberOfElements(string before, int requireElements, string nameCount,
    IEnumerable<string> ele)
    {
        var c = ele.Count();
        return c != requireElements ? CheckBefore(before) + $" {nameCount} has {c}, it's required {requireElements}" : null;
    }
    internal static string? DirectoryWasntFound(string before, string directory)
    {
        return !Directory.Exists(directory)
        ? CheckBefore(before) + " Directory" + " " + directory +
        " wasn't found."
        : null;
    }
    internal static string? PassedListInsteadOfArray<T>(string before, string variableName, List<T> v2, Func<List<T>, bool> CA_IsListStringWrappedInArray)
    {
        if (CA_IsListStringWrappedInArray(v2))
            return CheckBefore(before) + $" {variableName} is List<string>, was passed List<string> into params";
        return null;
    }
    internal static string? IsWhitespaceOrNull(string before, string variable, object data)
    {
        var isNull = false;
        var isWhitespace = false;
        if (data == null)
            isNull = true;
        else if ((data.ToString() ?? "").Trim() == string.Empty) isWhitespace = true;
        return isNull || isWhitespace ? CheckBefore(before) + variable + (isNull ? " is null" : " is whitespace") : null;
    }
    internal static string? UncommentNextRows(string before)
    {
        return CheckBefore(before) + "Uncomment next rows";
    }
    internal static string? OutOfRange(string before, string colName, ICollection col, string indexName, int index)
    {
        return col.Count <= index
        ? CheckBefore(before) + $"{index} (variable {indexName}) is out of range in {colName}"
        : null;
    }
    internal static string? HaveAllInnerSameCount(string before, List<List<string>> elements)
    {
        var first = elements[0].Count;
        List<int> wrongCount = [];
        for (var i = 1; i < elements.Count; i++)
            if (first != elements[i].Count)
                wrongCount.Add(i);
        return wrongCount.Count > 0
        ? CheckBefore(before) + $"Elements {string.Join(',', wrongCount)} have different count than 0 (first)"
        : null;
    }
    internal static string? DirectoryExists(string before, string fulLPath)
    {
        return Directory.Exists(fulLPath)
        ? null
        : CheckBefore(before) + " " + "does not exists" + ": " + fulLPath;
    }
    internal static string? CheckBackslashEnd(string before, string r)
    {
        if (r.Length != 0)
            if (r[^1] != '\\')
                return CheckBefore(before) + " string has not been in path format" + "!";
        return null;
    }
    internal static string? IsNotNull(string before, string variableName, object variable)
    {
        return variable != null ? CheckBefore(before) + variableName + " must be null." : null;
    }
    internal static string? ArrayElementContainsUnallowedStrings(string before, string arrayName, int dex,
    string valueElement, params string[] unallowedStrings)
    {
        var foundedUnallowed = unallowedStrings.Where(d => valueElement.Contains(d)).ToList();
        return foundedUnallowed.Count != 0
        ? CheckBefore(before) + " " + TranslateAble.i18n("ElementOf") + " " + arrayName + " on index " + dex +
        " with value " + valueElement + " contains unallowed string(" + foundedUnallowed.Count + "): " +
        string.Join(',', unallowedStrings)
        : null;
    }
    internal static string? StartIsHigherThanEnd(string before, int start, int end)
    {
        return start > end ? CheckBefore(before) + $"Start {start} is higher than end {end}" : null;
    }
    internal static string? WasNotKeysHandler(string before, string name, object keysHandler)
    {
        return keysHandler == null
        ? CheckBefore(before) + name + " " + "was not IKeysHandler"
        : null;
    }
    internal static string? FolderCantBeRemoved(string before, string folder)
    {
        return CheckBefore(before) + TranslateAble.i18n("CanTDeleteFolder") + ": " + folder;
    }
    internal static string? ElementWasntRemoved(string before, string detailLocation, int before2, int after)
    {
        return before2 == after
        ? CheckBefore(before) + TranslateAble.i18n("ElementWasntRemovedDuring") + ": " +
        detailLocation
        : null;
    }
    internal static string? NoPassedFolders(string before, ICollection folders)
    {
        return folders.Count == 0 ? CheckBefore(before) + TranslateAble.i18n("NoPassedFolderInto") : null;
    }
    internal static string? FileSystemException(string v, Exception ex)
    {
        return ex != null ? CheckBefore(v) + " " + TextOfExceptions(ex) : null;
    }
    internal static string? InvalidParameter(string before, string valueVar, string nameVar)
    {
        return valueVar != WebUtility.UrlDecode(valueVar)
        ? CheckBefore(before) + valueVar + " is url encoded " + nameVar
        : null;
    }
    internal static string? MoreThanOneElement(string before, string listName, int count, string moreInfo = "")
    {
        return count > 1
        ? CheckBefore(before) + listName + " has " + count + " elements, which is more than 1. " + moreInfo
        : null;
    }
    internal static string? NameIsNotSetted(string before, string nameControl, string nameFromProperty)
    {
        return string.IsNullOrWhiteSpace(nameFromProperty)
        ? CheckBefore(before) + nameControl + " " + TranslateAble.i18n("doesntHaveSettedName")
        : null;
    }
    internal static string? OnlyOneElement(string before, string colName, ICollection list)
    {
        return list.Count == 1 ? CheckBefore(before) + colName + " has only one element" : null;
    }
    internal static string? StringContainsUnallowedSubstrings(string before, string input,
    params string[] unallowedStrings)
    {
        List<string> foundedUnallowed = [];
        foreach (var item in unallowedStrings)
            if (input.Contains(item))
                foundedUnallowed.Add(item);
        return foundedUnallowed.Count > 0
        ? CheckBefore(before) + input + " contains unallowed chars: " +
        string.Join("", unallowedStrings)
        : null;
    }
    internal static string? IsNull(string before, string variableName, object? variable)
    {
        return variable == null ? CheckBefore(before) + variableName + " " + "is null" + "." : null;
    }
    internal static string? NotImplementedCase(string before, object niCase)
    {
        var fr = string.Empty;
        if (niCase != null)
        {
            fr = " for ";
            if (niCase.GetType() == typeof(Type))
                fr += ((Type)niCase).FullName;
            else
                fr += niCase.ToString();
        }
        return CheckBefore(before) + "Not implemented case" + fr + " . internal program error. Please contact developer" +
        ".";
    }
    internal static string? NotContains(string before, string originalText, params string[] shouldContains)
    {
        List<string> notContained = [];
        foreach (var item in shouldContains)
            if (!originalText.Contains(item))
                notContained.Add(item);
        return notContained.Count == 0
        ? null
        : CheckBefore(before) + originalText + " dont contains: " + string.Join(",", notContained);
    }
    internal static string? HasNotKeyDictionary<Key, Value>(string before, string nameDict, IDictionary<Key, Value> qsDict,
    Key remains)
    {
        return !qsDict.ContainsKey(remains) ? CheckBefore(before) + nameDict + " does not contains key " + remains : null;
    }
    internal static string? IsEmpty(string before, IEnumerable folders, string colName,
    string additionalMessage = "")
    {
        // Nemůže tu být žádná taková validace, protože vyhodí výjimku i když kolekce není prázdná
        // if (string.IsNullOrEmpty(additionalMessage))
        // {
        //     throw new ArgumentException($"'{nameof(additionalMessage)}' cannot be null or empty.", nameof(additionalMessage));
        // }
        return !folders.OfType<object>().Any()
        ? CheckBefore(before) + colName + " has no elements. " + additionalMessage
        : null;
    }
    internal static string? UriFormat(string before, string url, Func<string, bool> uhIsUri)
    {
        if (uhIsUri(url))
        {
            return null;
        }
        return CheckBefore(before) + "Is not correct url format: " + url;
    }
    internal static string? IsWindowsPathFormat(string before, string input, Func<string, bool> isWindowsPathFormat)
    {
        if (isWindowsPathFormat(input))
            return CheckBefore(before) + input + "is path but only key is expected";
        return null;
    }
    internal static string? IsNotWindowsPathFormat(string before, string argName, string argValue, bool raiseIsNotWindowsPathFormat, Func<string, bool> SunamoFileSystem_IsWindowsPathFormat)
    {
        if (raiseIsNotWindowsPathFormat)
        {
            var badFormat = !SunamoFileSystem_IsWindowsPathFormat(argValue);
            if (badFormat)
                return CheckBefore(before) + " " + argName + " is not in Windows path format";
        }
        return null;
    }
    internal static string? DifferentCountInLists(string before, string namefc, int countfc, string namesc, int countsc)
    {
        if (countfc != countsc)
            return CheckBefore(before) + " different count elements in collection" + " " +
            string.Concat(namefc + "-" + countfc) + " vs. " +
            string.Concat(namesc + "-" + countsc);
        return null;
    }
    internal static string? FirstLetterIsNotUpper(string before, string p)
    {
        return p.Length == 0 ? null :
        char.IsLower(p[0]) ? CheckBefore(before) + "First letter is not upper: " + p : null;
    }
    internal static string? KeyNotFound<T, U>(string before, IDictionary<T, U> en, string dictName, T key)
    {
        return !en.ContainsKey(key)
        ? CheckBefore(before) + key + " is not exists in dictionary" + " " + dictName
        : null;
    }
    internal static string? DuplicatedElements(string before, string nameOfVariable, IList<string> d,
    string message = "")
    {
        return d.Count != 0
        ? CheckBefore(before) + $"Duplicated elements in {nameOfVariable} list: " + string.Join(',', [.. d]) +
        " " + message
        : null;
    }
    internal static string? ZeroOrMoreThanOne(string before, string nameOfVariable, List<string> list)
    {
        return list.Count == 0 || list.Count > 1
        ? CheckBefore(before) + $"{list.Count} elements in {nameOfVariable} which is zero or more than one"
        : null;
    }
    internal static string? IsNotPositiveNumber(string before, string nameOfVariable, int? n)
    {
        return !n.HasValue ? CheckBefore(before) + nameOfVariable + " is not int" :
        n.Value > 0 ? null : CheckBefore(before) + nameOfVariable + " is int but not > 0";
    }
    internal static string? CheckBackSlashEnd(string before, string r)
    {
        if (!r.EndsWith('\\')) return CheckBefore(before) + " " + r + " don't end with \\";
        return null;
    }
}