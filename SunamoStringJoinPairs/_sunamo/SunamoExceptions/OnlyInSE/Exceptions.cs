namespace SunamoStringJoinPairs._sunamo.SunamoExceptions.OnlyInSE;
internal class Exceptions
{
    internal static string UseRlc(string before)
    {
        return CheckBefore(before) + "Don't implement, use methods in rlc";
    }
    #region MyRegion
    internal static string RepeatAfterTimeXTimesFailed(string before, int times, int timeoutInMs, string address,
    int sharedAlgorithmslastError)
    {
        return before +
        $"Loading uri {address} failed {times} ({timeoutInMs} ms timeout) HTTP Error: {sharedAlgorithmslastError}";
    }
    internal static string NotInt(string before, string what, int? value)
    {
        return !value.HasValue ? before + what + " is not with value " + value + " valid integer number" : null;
    }
    internal static string NotValidXml(string before, string path, Exception ex)
    {
        return before + path + AllStrings.space + TextOfExceptions(ex);
    }
    internal static string ViolationSqlIndex(string before, string tableName, string abcToStringColumnsInIndex)
    {
        return before + $"{tableName} {abcToStringColumnsInIndex}";
    }
    #endregion
    internal static string IsNotAllowed(string before, string what)
    {
        return CheckBefore(before) + what + " is not allowed.";
    }
    
    
    
    
    
    
    
    internal static string IsOdd(string before, string colName, ICollection col)
    {
        return col.Count % 2 == 1 ? CheckBefore(before) + colName + " has odd number of elements " + col.Count : null;
    }
    internal static string BadFormatOfElementInList(string before, object elVal, string listName)
    {
        return before + TranslateAble.i18n("BadFormatOfElement") + " " + SHSunamoExceptions.NullToStringOrDefault(elVal) +
        " in list " + listName;
    }
    internal static string IsTheSame(string before, string fst, string sec)
    {
        return before + $"{fst} and {sec} has the same value";
    }
    internal static string WrongExtension(string before, string path, string ext)
    {
        return System.IO.Path.GetExtension(path) != ext ? before + path + "don't have " + ext + " extension" : null;
    }
    internal static string WrongNumberOfElements(string before, int requireElements, string nameCount,
    IEnumerable<string> ele)
    {
        var c = ele.Count();
        return c != requireElements ? before + $" {nameCount} has {c}, it's required {requireElements}" : null;
    }
    internal static string DirectoryWasntFound(string before, string directory)
    {
        return !Directory.Exists(directory)
        ? CheckBefore(before) + TranslateAble.i18n("Directory") + " " + directory +
        " wasn't found."
        : null;
    }
    internal static string DivideByZero(string before)
    {
        return CheckBefore(before) + " is dividing by zero.";
    }
    internal static string AnyElementIsNullOrEmpty(string before, string nameOfCollection, List<int> nulled)
    {
        return CheckBefore(before) + $"In {nameOfCollection} has indexes " + string.Join(AllStrings.comma, nulled) +
        " with null value";
    }
    #region Called from TemplateLoggerBase
    internal static string NotEvenNumberOfElements(string before, string nameOfCollection)
    {
        return CheckBefore(before) + nameOfCollection + " have odd elements count";
    }
    internal static string PassedListInsteadOfArray<T>(string before, string variableName, List<T> v2)
    {
        var ts = v2.ToString();
        if (CASunamoExceptions.IsListStringWrappedInArray(v2))
            return before + $" {variableName} is List<string>, was passed List<string> into params";
        return null;
    }
    internal static string InvalidExactlyLength(string variableName, int length, int requiredLenght)
    {
        return variableName + $" have length {length}, required {requiredLenght}";
    }
    #endregion
    internal static string IsWhitespaceOrNull(string before, string variable, object data)
    {
        var isNull = false;
        if (data == null)
            isNull = true;
        else if (data.ToString().Trim() == string.Empty) isNull = true;
        return isNull ? CheckBefore(before) + variable + " is null" : null;
    }
    internal static string UncommentNextRows(string before)
    {
        return before + "Uncomment next rows";
    }
    
    
    
    
    
    
    
    
    
    internal static string OutOfRange(string v, string colName, ICollection col, string indexName, int index)
    {
        return col.Count <= index
        ? CheckBefore(v) + $"{index} (variable {indexName}) is out of range in {colName}"
        : null;
    }
    
    
    
    internal static string FileHasExtensionNotParseableToImageFormat(string before, string fnOri)
    {
        return CheckBefore(before) + "File " + fnOri + " has wrong file extension";
    }
    internal static string WrongCountInList2(int numberOfElementsWithoutPause, int numberOfElementsWithPause,
    int arrLength)
    {
        return string.Format("Array should have {0} or {1} elements, have {2}", numberOfElementsWithoutPause,
        numberOfElementsWithPause, arrLength);
    }
    internal static string HaveAllInnerSameCount(string before, List<List<string>> elements)
    {
        var first = elements[0].Count;
        List<int> wrongCount = new();
        for (var i = 1; i < elements.Count; i++)
            if (first != elements[i].Count)
                wrongCount.Add(i);
        return wrongCount.Count > 0
        ? before + $"Elements {string.Join(AllChars.comma, wrongCount)} have different count than 0 (first)"
        : null;
    }
    internal static string DirectoryExists(string before, string fulLPath)
    {
        return Directory.Exists(fulLPath)
        ? null
        : CheckBefore(before) + " " + TranslateAble.i18n("DoesnTExists") + ": " + fulLPath;
    }
    internal static string FileExists(string before, string fulLPath)
    {
        
        
        
        
        return CheckBefore(before) + " " + TranslateAble.i18n("DoesnTExists") + ": " + fulLPath;
    }
    internal static string CheckBackslashEnd(string before, string r)
    {
        if (r.Length != 0)
            if (r[r.Length - 1] != AllChars.bs)
                return CheckBefore(before) + TranslateAble.i18n("StringHasNotBeenInPathFormat") + "!";
        return null;
    }
    internal static string FileWasntFoundInDirectory(string before, string path)
    {
        return CheckBefore(before) + "NotFound" + ": " + path;
    }
    internal static string NotSupported(string v)
    {
        return CheckBefore(v) + TranslateAble.i18n("NotSupported");
    }
    internal static string IsNotNull(string before, string variableName, object variable)
    {
        return variable != null ? CheckBefore(before) + variableName + " must be null." : null;
    }
    internal static string ToManyElementsInCollection(string before, int max, int actual, string nameCollection)
    {
        return CheckBefore(before) + actual + " elements in " + nameCollection + ", maximum is " + max;
    }
    internal static string ArrayElementContainsUnallowedStrings(string before, string arrayName, int dex,
    string valueElement, params string[] unallowedStrings)
    {
        var foundedUnallowed = unallowedStrings.Where(d => valueElement.Contains(d)).ToList();
        return foundedUnallowed.Count != 0
        ? CheckBefore(before) + " " + TranslateAble.i18n("ElementOf") + " " + arrayName + " on index " + dex +
        " with value " + valueElement + " contains unallowed string(" + foundedUnallowed.Count + "): " +
        string.Join(AllChars.comma, unallowedStrings)
        : null;
    }
    internal static string StartIsHigherThanEnd(string before, int start, int end)
    {
        return start > end ? CheckBefore(before) + $"Start {start} is higher than end {end}" : null;
    }
    internal static string WasNotKeysHandler(string before, string name, object keysHandler)
    {
        return keysHandler == null
        ? CheckBefore(before) + name + " " + TranslateAble.i18n("wasNotIKeysHandler")
        : null;
    }
    internal static string FolderCantBeRemoved(string v, string folder)
    {
        return CheckBefore(v) + TranslateAble.i18n("CanTDeleteFolder") + ": " + folder;
    }
    
    
    
    
    
    
    
    internal static string ElementWasntRemoved(string before, string detailLocation, int before2, int after)
    {
        return before2 == after
        ? CheckBefore(before) + TranslateAble.i18n("ElementWasntRemovedDuring") + ": " +
        detailLocation
        : null;
    }
    
    
    
    
    
    
    internal static string NoPassedFolders(string before, ICollection folders)
    {
        return folders.Count == 0 ? CheckBefore(before) + TranslateAble.i18n("NoPassedFolderInto") : null;
    }
    internal static string FileSystemException(string v, Exception ex)
    {
        return ex != null ? CheckBefore(v) + " " + TextOfExceptions(ex) : null;
    }
    internal static string FuncionalityDenied(string before, string description)
    {
        return CheckBefore(before) + description;
    }
    
    
    
    
    
    
    
    internal static string InvalidParameter(string before, string valueVar, string nameVar)
    {
        return valueVar != WebUtility.UrlDecode(valueVar)
        ? CheckBefore(before) + valueVar + " is url encoded " + nameVar
        : null;
    }
    internal static string ElementCantBeFound(string before, string nameCollection, string element)
    {
        return CheckBefore(before) + element + "cannot be found in " + nameCollection;
    }
    internal static string MoreCandidates(string before, List<string> list, string item)
    {
        return CheckBefore(before) + "Under" + " " + item + " is more candidates: " + Environment.NewLine +
        string.Join(Environment.NewLine, list);
    }
    internal static string BadMappedXaml(string before, string nameControl, string additionalInfo)
    {
        return CheckBefore(before) + $"Bad mapped XAML in {nameControl}. {additionalInfo}";
    }
    #region Without parameters
    internal static string MoreThanOneElement(string before, string listName, int count, string moreInfo = Consts.se)
    {
        return count > 1
        ? CheckBefore(before) + listName + " has " + count + " elements, which is more than 1. " + moreInfo
        : null;
    }
    internal static string NameIsNotSetted(string before, string nameControl, string nameFromProperty)
    {
        return string.IsNullOrWhiteSpace(nameFromProperty)
        ? CheckBefore(before) + nameControl + " " + TranslateAble.i18n("doesntHaveSettedName")
        : null;
    }
    internal static string OnlyOneElement(string before, string colName, ICollection list)
    {
        return list.Count == 1 ? CheckBefore(before) + colName + " has only one element" : null;
    }
    internal static string StringContainsUnallowedSubstrings(string before, string input,
    params string[] unallowedStrings)
    {
        List<string> foundedUnallowed = new();
        foreach (var item in unallowedStrings)
            if (input.Contains(item))
                foundedUnallowed.Add(item);
        return foundedUnallowed.Count > 0
        ? CheckBefore(before) + input + " contains unallowed chars: " +
        string.Join(AllStrings.space, unallowedStrings)
        : null;
    }
    internal static string DoesntHaveRequiredType(string before, string variableName)
    {
        return before + variableName + TranslateAble.i18n("DoesnTHaveRequiredType") + ".";
    }
    #endregion
    #region From easy copy from ExceptionsShared64.cs - all ok 16-10-21
    
    
    
    
    
    internal static string TextOfExceptions(Exception ex, bool alsoInner = true)
    {
        if (ex == null) return Consts.se;
        StringBuilder sb = new();
        sb.Append(Consts.Exception);
        sb.AppendLine(ex.Message);
        if (alsoInner)
            while (ex.InnerException != null)
            {
                ex = ex.InnerException;
                sb.AppendLine(ex.Message);
            }
        var r = sb.ToString();
        return r;
    }
    internal static string ArgumentOutOfRangeException(string before, string paramName, string message)
    {
        if (paramName == null) paramName = string.Empty;
        if (message == null) message = string.Empty;
        return CheckBefore(before) + paramName + " " + message;
    }
    internal static string IsNull(string before, string variableName, object variable)
    {
        return variable == null ? CheckBefore(before) + variableName + " " + "is null" + "." : null;
    }
    internal static string NotImplementedCase(string before, object niCase)
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
    internal static string Custom(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    private static string CheckBefore(string before)
    {
        return string.IsNullOrWhiteSpace(before) ? "" : before + ": ";
    }
    #endregion
    #region from ExceptionsShared.cs
    
    
    
    
    
    
    internal static string NotContains(string before, string originalText, params string[] shouldContains)
    {
        List<string> notContained = new();
        foreach (var item in shouldContains)
            if (!originalText.Contains(item))
                notContained.Add(item);
        return notContained.Count == 0
        ? null
        : CheckBefore(before) + originalText + " dont contains: " + string.Join(AllStrings.comma, notContained);
    }
    internal static string FolderCannotBeDeleted(string v, string repairedBlogPostsFolder, Exception ex)
    {
        return v + repairedBlogPostsFolder + TextOfExceptions(ex);
    }
    internal static string HasNotKeyDictionary<Key, Value>(string v, string nameDict, IDictionary<Key, Value> qsDict,
    Key remains)
    {
        return !qsDict.ContainsKey(remains) ? CheckBefore(v) + nameDict + " does not contains key " + remains : null;
    }
    internal static string CannotCreateDateTime(string v, int year, int month, int day, int hour, int minute, int seconds,
    Exception ex)
    {
        return v +
        $"Cannot create DateTime with: year: {year} month: {month} day: {day} hour: {hour} minute: {minute} seconds: {seconds} " +
        TextOfExceptions(ex);
    }
    internal static string IsEmpty(string before, IEnumerable folders, string colName,
    string additionalMessage = Consts.se)
    {
        if (string.IsNullOrEmpty(additionalMessage))
        {
            throw new ArgumentException($"'{nameof(additionalMessage)}' cannot be null or empty.", nameof(additionalMessage));
        }
        
        return folders.OfType<object>().Count() == 0
        ? before + colName + " has no elements. " + additionalMessage
        : null;
    }
    internal const string sp = AllStrings.space;
    internal static string CannotMoveFolder(string before, string item, string nova, Exception ex)
    {
        return before + $"Cannot move folder from {item} to {nova}" + sp + TextOfExceptions(ex);
    }
    internal static string ExcAsArg(string before, Exception ex, string message)
    {
        return before + message + AllStrings.space + TextOfExceptions(ex);
    }
    internal static string Ftp(string before, Exception ex, string message)
    {
        return before + message + AllStrings.space + TextOfExceptions(ex);
    }
    internal static string IO(string before, string message)
    {
        return before + message;
    }
    internal static string InvalidOperation(string before, string message)
    {
        return before + message;
    }
    internal static string ArgumentOutOfRange(string before, string message)
    {
        return before + message;
    }
    internal static string Format(string before, string message)
    {
        return before + message;
    }
    internal static string FtpSecurityNotAvailable(string before, string message)
    {
        return before + message;
    }
    internal static string FtpCommand(string before, object s)
    {
        return before + DumpAsString(s);
    }
    internal static string FtpAuthentication(string before, object s)
    {
        return before + DumpAsString(s);
    }
    internal static string DumpAsString(object s)
    {
        return null; 
    }
    internal static string InvalidCast(string before, string message)
    {
        return before + message;
    }
    internal static string ObjectDisposed(string before, string message)
    {
        return before + message;
    }
    internal static string Timeout(string before, string message)
    {
        return before + message;
    }
    internal static string FtpMissingSocket(string before, Exception ex)
    {
        return before + TextOfExceptions(ex);
    }
    internal static string UriFormat(string before, string url, Func<string, bool> uhIsUri)
    {
        if (uhIsUri(url))
        {
            return null;
        }
        return before + "Is not correct url format: " + url;
    }
    #endregion
    #region From easy copy from ExceptionsShared64.cs
    internal static bool RaiseIsNotWindowsPathFormat;
    internal static Func<string, bool> IsWindowsPathFormat;
    internal static string NotImplementedMethod(string before)
    {
        return CheckBefore(before) +
        "Not implemented case. internal program error. Please contact developer" + ".";
    }
    internal static string IsNotWindowsPathFormat(string before, string argName, string argValue)
    {
        if (RaiseIsNotWindowsPathFormat)
        {
            var badFormat = !IsWindowsPathFormat(argValue);
            if (badFormat)
                return CheckBefore(before) + " " + argName + " " + TranslateAble.i18n("isNotInWindowsPathFormat");
        }
        return null;
    }
    internal static string IsNullOrWhitespace(string before, string argName, string argValue)
    {
        string addParams;
        if (argValue == null)
        {
            addParams = AddParams();
            return CheckBefore(before) + argName + " is null" + addParams;
        }
        if (argValue == string.Empty)
        {
            addParams = AddParams();
            return CheckBefore(before) + argName + " is empty (without trim)" + addParams;
        }
        if (argValue.Trim() == string.Empty)
        {
            addParams = AddParams();
            return CheckBefore(before) + argName + " is empty (with trim)" + addParams;
        }
        return null;
    }
    internal static StringBuilder sbAdditionalInfoInner = new();
    internal static StringBuilder sbAdditionalInfo = new();
    internal static object FS { get; private set; }
    private static string AddParams()
    {
        sbAdditionalInfo.Insert(0, Environment.NewLine);
        sbAdditionalInfo.Insert(0, "Outer:");
        sbAdditionalInfo.Insert(0, Environment.NewLine);
        sbAdditionalInfoInner.Insert(0, Environment.NewLine);
        sbAdditionalInfoInner.Insert(0, "Inner:");
        sbAdditionalInfoInner.Insert(0, Environment.NewLine);
        var addParams = sbAdditionalInfo.ToString();
        var addParamsInner = sbAdditionalInfoInner.ToString();
        return addParams + addParamsInner;
    }
    #endregion
    #region from Exceptions.cs - all ok 16-10-21
    internal static string DifferentCountInLists(string before, string namefc, int countfc, string namesc, int countsc)
    {
        if (countfc != countsc)
            
            
            return CheckBefore(before) + " " + TranslateAble.i18n("DifferentCountElementsInCollection") + " " +
            string.Concat(namefc + AllStrings.swda + countfc) + " vs. " +
            string.Concat(namesc + AllStrings.swda + countsc);
        return null;
    }
    internal static string FirstLetterIsNotUpper(string before, string p)
    {
        return p.Length == 0 ? null :
        char.IsLower(p[0]) ? CheckBefore(before) + "First letter is not upper: " + p : null;
    }
    internal static string KeyNotFound<T, U>(string before, IDictionary<T, U> en, string dictName, T key)
    {
        return !en.ContainsKey(key)
        ? before + key + " " + TranslateAble.i18n("isNotExistsInDictionary") + " " + dictName
        : null;
    }
    internal static string DuplicatedElements(string before, string nameOfVariable, IList<string> d,
    string message = Consts.se)
    {
        return d.Count != 0
        ? before + $"Duplicated elements in {nameOfVariable} list: " + string.Join(AllChars.comma, d.ToArray()) +
        " " + message
        : null;
    }
    internal static string ZeroOrMoreThanOne(string before, string nameOfVariable, List<string> list)
    {
        return list.Count == 0 || list.Count > 1
        ? before + $"{list.Count} elements in {nameOfVariable} which is zero or more than one"
        : null;
    }
    
    
    
    
    
    
    
    internal static string IsNotPositiveNumber(string before, string nameOfVariable, int? n)
    {
        return !n.HasValue ? before + nameOfVariable + " is not int" :
        n.Value > 0 ? null : nameOfVariable + " is int but not > 0";
    }
    
    
    
    
    
    
    
    
    
    
    
    
    internal static string NotExists(string before, string item)
    {
        return before + item + " not exists";
    }
    internal static string CheckBackSlashEnd(string before, string r)
    {
        if (!r.EndsWith("\\")) return before + " " + r + " don't end with \\";
        return null;
    }
    internal static string Socket(string before, int socketError)
    {
        return before + " socket error: " + socketError;
    }
    #endregion
}
