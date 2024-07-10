namespace SunamoStringJoinPairs._sunamo.SunamoExceptions.OnlyInSE;
internal class ThrowEx
{
    #region from ThrowExShared.cs - all ok 17-10-21
    [SuppressMessage("Style", "IDE0060:Remove unused parameter", Justification = "<Pending>")]
    internal static void DummyNotThrow(Exception ex)
    {
    }
    
    
    
    
    
    
    
    
    
    internal static bool NotContains(string p, params string[] after)
    {
        return ThrowIsNotNull(Exceptions.NotContains(FullNameOfExecutedCode(), p, after));
    }
    #region from Local\ThrowExShared64.cs
    internal static void IsNotAllowed(string what)
    {
        ThrowIsNotNull(Exceptions.IsNotAllowed(FullNameOfExecutedCode(), what));
    }
    internal static void BadFormatOfElementInList(object elVal, string listName)
    {
        ThrowIsNotNull(Exceptions.BadFormatOfElementInList(FullNameOfExecutedCode(T.Item1, T.Item2), elVal, listName));
    }
    internal static readonly Type type = typeof(ThrowEx);
    internal static void IsTheSame(string fst, string sec)
    {
        ThrowIsNotNull(Exceptions.IsTheSame(FullNameOfExecutedCode(T.Item1, T.Item2), fst, sec));
    }
    internal static void WrongNumberOfElements(int requireElements, string nameCount, IEnumerable<string> ele)
    {
        ThrowIsNotNull(Exceptions.WrongNumberOfElements(FullNameOfExecutedCode(T.Item1, T.Item2), requireElements,
        nameCount, ele));
    }
    
    
    
    
    
    
    
    internal static void DirectoryWasntFound(string folder1)
    {
        ThrowIsNotNull(Exceptions.DirectoryWasntFound(FullNameOfExecutedCode(), folder1));
    }
    internal static void DivideByZero()
    {
        ThrowIsNotNull(Exceptions.DivideByZero(FullNameOfExecutedCode()));
    }
    internal static void ViolationSqlIndex(string tableName, string abcToStringColumnsInIndex)
    {
        ThrowIsNotNull(Exceptions.ViolationSqlIndex(FullNameOfExecutedCode(), tableName,
        abcToStringColumnsInIndex));
    }
    internal static void Custom(Exception message, bool reallyThrow = true)
    {
        Custom(Exceptions.TextOfExceptions(message), reallyThrow);
    }
    internal static bool WrongExtension(string path, string ext)
    {
        return ThrowIsNotNull(Exceptions.WrongExtension(FullNameOfExecutedCode(), path, ext));
    }
    internal static bool DuplicatedElements(string nameOfVariable, IList<string> d, string message = Consts.se)
    {
        return ThrowIsNotNull(Exceptions.DuplicatedElements(FullNameOfExecutedCode(), nameOfVariable, d, message));
    }
    internal static bool ZeroOrMoreThanOne(string nameOfVariable, List<string> list)
    {
        return ThrowIsNotNull(Exceptions.ZeroOrMoreThanOne(FullNameOfExecutedCode(), nameOfVariable, list));
    }
    internal static bool IsNotPositiveNumber(string nameOfVariable, int? n)
    {
        return ThrowIsNotNull(
        Exceptions.IsNotPositiveNumber(FullNameOfExecutedCode(), nameOfVariable, n)
        );
    }
    
    
    
    
    internal static void NotExists(string item)
    {
        ThrowIsNotNull(
        Exceptions.NotExists(FullNameOfExecutedCode(), item)
        );
    }
    internal static void Socket(int socketError)
    {
        ThrowIsNotNull(
        Exceptions.Socket(FullNameOfExecutedCode(), socketError)
        );
    }
    #endregion
    
    
    
    
    
    
    
    
    internal static bool ThrowIsNotNull(Exception exception)
    {
        if (exception != null)
        {
            Custom(exception);
            return false;
        }
        return true;
    }
    #endregion
    #region Only in xlf
    internal static void NotFoundTranSlationKeyWithCustomError(string message)
    {
        Custom(message);
    }
    internal static void NotFoundTranSlationKeyWithoutCustomError(string message)
    {
        Custom(message);
    }
    #endregion
    #region from ThrowEx.cs
    internal static void InvalidExactlyLength(string variableName, int length, int requiredLenght)
    {
        if (length != requiredLenght)
        {
            ThrowIsNotNull(Exceptions.InvalidExactlyLength(variableName, length, requiredLenght));
        }
    }
    internal static Func<char, bool> IsLockedByBitLocker;
    internal static bool LockedByBitLocker(string path)
    {
        
        if (IsLockedByBitLocker != null)
        {
            var p = path[0];
            if (IsLockedByBitLocker(p))
            {
                Custom($"Drive {p}:\\ is locked by BitLocker");
                return true;
            }
        }
        return false;
    }
    internal static void CallingSyncMethodInAsyncApp()
    {
        Custom("Calling sync method in async app");
    }
    internal static void Argument(string a1, string a2 = null)
    {
        Custom(a1, true, a2);
    }
    internal static void ArgumentNull(string a1, string a2 = null)
    {
        Custom(a1, true, a2);
    }
    internal static void ExcAsArg(Exception ex, string message = Consts.se)
    {
        ThrowIsNotNull(Exceptions.ExcAsArg, ex, message);
    }
    internal static void Ftp(string message, Exception ex = null)
    {
        ThrowIsNotNull(Exceptions.Ftp, ex, message);
    }
    internal static void IO(string v)
    {
        ThrowIsNotNull(Exceptions.IO, v);
    }
    internal static void InvalidOperation(string s)
    {
        ThrowIsNotNull(Exceptions.InvalidOperation, s);
    }
    internal static void ArgumentOutOfRange(string s)
    {
        ThrowIsNotNull(Exceptions.ArgumentOutOfRange, s);
    }
    internal static void FtpCommand(object s)
    {
        ThrowIsNotNull(Exceptions.FtpCommand, s);
    }
    internal static void FtpAuthentication(object s)
    {
        ThrowIsNotNull(Exceptions.FtpAuthentication, s);
    }
    
    internal static void InvalidCast(string v)
    {
        ThrowIsNotNull(Exceptions.InvalidCast, v);
    }
    internal static void ObjectDisposed(string v)
    {
        ThrowIsNotNull(Exceptions.ObjectDisposed, v);
    }
    internal static void Timeout(string v)
    {
        ThrowIsNotNull(Exceptions.Timeout, v);
    }
    internal static void FtpSecurityNotAvailable(string v)
    {
        ThrowIsNotNull(Exceptions.FtpSecurityNotAvailable, v);
    }
    
    internal static void FtpMissingSocket(Exception ex)
    {
        ThrowIsNotNull(Exceptions.FtpMissingSocket, ex);
    }
    internal static void UriFormat(string url, Func<string, bool> uhIsUri)
    {
        ThrowIsNotNull(Exceptions.UriFormat, url, uhIsUri);
    }
    internal static void FtpListParse()
    {
        Custom("FtpListParse");
    }
    internal static void Format(string v)
    {
        ThrowIsNotNull(Exceptions.Format, v);
    }
    #endregion
    #region from ThrowEx.cs
    #region DifferentCountInLists
    #endregion
    #endregion

    internal static void UncommentAfterNugetsFinished()
    {
        ThrowIsNotNull(FullNameOfExecutedCode(T.Item1, T.Item2));
    }

    
    
    
    
    
    
    internal static bool IsOdd(string colName, ICollection e)
    {
        var f = Exceptions.IsOdd;
        return ThrowIsNotNull(f, colName, e);
    }
    #region from ThrowExShared64.cs - all ok 17-10-21
    private static Tuple<string, string, string> T => Exc.GetStackTrace2();
    internal static bool DifferentCountInListsTU<T, U>(string namefc, List<T> countfc, string namesc, List<U> countsc)
    {
        return ThrowIsNotNull(Exceptions.DifferentCountInLists(FullNameOfExecutedCode(), namefc, countfc.Count, namesc,
        countsc.Count));
    }
    internal static bool DifferentCountInLists<T>(string namefc, List<T> countfc, string namesc, List<T> countsc)
    {
        return ThrowIsNotNull(Exceptions.DifferentCountInLists(FullNameOfExecutedCode(), namefc, countfc.Count, namesc,
        countsc.Count));
    }
    internal static bool DifferentCountInLists(string namefc, int countfc, string namesc, int countsc)
    {
        return ThrowIsNotNull(Exceptions.DifferentCountInLists(FullNameOfExecutedCode(), namefc, countfc, namesc,
        countsc));
    }
    internal static void Custom(string message, bool reallyThrow = true, string v2 = Consts.se)
    {
        var joined = string.Join(Consts.se, message, v2);
        ThrowIsNotNull(Exceptions.Custom(FullNameOfExecutedCode(), joined), reallyThrow);
    }
    internal static bool reallyThrow2 = true;
#if MB
static void ShowMb(string s)
{
PD.ShowMb(s);
}
#endif
    internal static bool ThrowIsNotNull<A, B>(Func<string, A, B, string> f, A ex, B message)
    {
        var exc = f(FullNameOfExecutedCode(T.Item1, T.Item2), ex, message);
        return ThrowIsNotNull(exc);
    }
    internal static bool ThrowIsNotNull<A>(Func<string, A, string> f, A o)
    {
        var exc = f(FullNameOfExecutedCode(T.Item1, T.Item2), o);
        return ThrowIsNotNull(exc);
    }
    internal static bool ThrowIsNotNull(Func<string, string> f)
    {
        var exc = f(FullNameOfExecutedCode(T.Item1, T.Item2));
        return ThrowIsNotNull(exc);
    }
    
    
    
    
    
    private static string lastMethod;
    
    
    
    
    
    internal static bool debuggerBreakOnEveryExc = false;
    
    
    
    
    
    
    internal static bool ThrowIsNotNull(string exception, bool reallyThrow = true)
    {
        if (debuggerBreakOnEveryExc)
        {
            System.Diagnostics.Debugger.Break();
        }
        
        
        var cm = T.Item2;
        if (exception != null)
        {
            if (lastMethod == cm)
                
                
                
                
                
                return false;
            if (lastMethod == null)
            {
                
                
                
                
                
            }
            else
            {
                var lastMethodIs = "lastMethod = " + lastMethod;
#if MB
ShowMb();
#endif
                
            }
            lastMethod = cm;
            if (Exc.aspnet)
            {
                
                
                writeServerError(T.Item3, exception);
                if (reallyThrow && reallyThrow2) throw new Exception(exception);
            }
            else
            {
#if MB

#endif
                if (reallyThrow && reallyThrow2)
                {
#if MB
ShowMb("Throw exc");
#endif
                    throw new Exception(exception);
                }
            }
        }
        return true;
    }
    
    
    
    
    
    
    
    
    internal static void IsNotWindowsPathFormat(string argName, string argValue)
    {
        ThrowIsNotNull(Exceptions.IsNotWindowsPathFormat(null, argName, argValue));
    }
    internal static string FullNameOfExecutedCode()
    {
        
        var f = FullNameOfExecutedCode(T.Item1, T.Item2, true);
        return f;
    }
    internal static void IsNullOrEmpty(string argName, string argValue)
    {
        ThrowIsNotNull(Exceptions.IsNullOrWhitespace(FullNameOfExecutedCode(), argName, argValue));
    }
    internal static void IsNullOrWhitespace(string argName, string argValue)
    {
        ThrowIsNotNull(Exceptions.IsNullOrWhitespace(FullNameOfExecutedCode(), argName, argValue));
    }
    internal static void ArgumentOutOfRangeException(string paramName, string message = null)
    {
        ThrowIsNotNull(Exceptions.ArgumentOutOfRangeException(FullNameOfExecutedCode(), paramName, message));
    }
    internal static void IsNull(string variableName, object variable = null)
    {
        ThrowIsNotNull(Exceptions.IsNull(FullNameOfExecutedCode(), variableName, variable));
    }
#pragma warning disable
    
    
    
    
    
    internal static Action<string, string> writeServerError;
#pragma warning enable
    
    
    
    
    
    internal static string FullNameOfExecutedCode(object type, string methodName, bool fromThrowEx = false)
    {
        if (methodName == null)
        {
            var depth = 2;
            if (fromThrowEx) depth++;
            methodName = Exc.CallingMethod(depth);
        }
        var typeFullName = string.Empty;
        if (type is Type)
        {
            var type2 = (Type)type;
            typeFullName = type2.FullName;
        }
        else if (type is MethodBase)
        {
            var method = (MethodBase)type;
            typeFullName = method.ReflectedType.FullName;
            methodName = method.Name;
        }
        else if (type is string)
        {
            typeFullName = type.ToString();
        }
        else
        {
            var t = type.GetType();
            typeFullName = t.FullName;
        }
        return string.Concat(typeFullName, AllStrings.dot, methodName);
    }
    #endregion
    #region from ThrowEx64.cs
    internal static void NotImplementedCase(object niCase)
    {
        ThrowIsNotNull(Exceptions.NotImplementedCase, niCase);
    }
    internal static void NotImplementedMethod()
    {
        ThrowIsNotNull(Exceptions.NotImplementedMethod);
    }
    #endregion
    internal static void StartIsHigherThanEnd(int start, int end)
    {
        ThrowIsNotNull(Exceptions.StartIsHigherThanEnd(FullNameOfExecutedCode(T.Item1, T.Item2), start, end));
    }
    internal static void FolderCannotBeDeleted(string repairedBlogPostsFolder, Exception ex)
    {
        ThrowIsNotNull(Exceptions.FolderCannotBeDeleted(FullNameOfExecutedCode(), repairedBlogPostsFolder, ex));
    }
    internal static Action<object> showExceptionWindow = null;
    
    
    
    
    
    
    
    
    
    
    internal static void KeyNotFound<T, U>(IDictionary<T, U> en, string dictName, T key)
    {
        ThrowIsNotNull(Exceptions.KeyNotFound(FullNameOfExecutedCode(ThrowEx.T.Item1, ThrowEx.T.Item2), en, dictName,
        key));
    }
    internal static void FirstLetterIsNotUpper(string selectedFile)
    {
        ThrowIsNotNull(Exceptions.FirstLetterIsNotUpper, selectedFile);
    }
    internal static void NotSupportedExtension(string extension)
    {
        Custom("Extensions is not supported: " + extension);
    }
    #region from Local\ThrowEx.cs
    #region Must be as first - newly created method fall into this
    internal static void BadMappedXaml(string nameControl, string additionalInfo)
    {
        ThrowIsNotNull(Exceptions.BadMappedXaml(FullNameOfExecutedCode(), nameControl, additionalInfo));
    }
    internal static void CannotCreateDateTime(int year, int month, int day, int hour, int minute, int seconds,
    Exception ex)
    {
        ThrowIsNotNull(Exceptions.CannotCreateDateTime(FullNameOfExecutedCode(), year, month, day, hour, minute,
        seconds, ex));
    }
    
    
    
    
    
    
    
    internal static void FileDoesntExists(string fulLPath)
    {
        ThrowIsNotNull(Exceptions.FileExists(FullNameOfExecutedCode(), fulLPath));
    }
    internal static void UseRlc()
    {
        ThrowIsNotNull(Exceptions.UseRlc(FullNameOfExecutedCode()));
    }
    internal static bool OutOfRange(string colName, ICollection col, string indexName, int index)
    {
        return ThrowIsNotNull(Exceptions.OutOfRange(FullNameOfExecutedCode(T.Item1, T.Item2), colName, col, indexName,
        index));
    }
    internal static void CustomWithStackTrace(Exception ex)
    {
        Custom(Exceptions.TextOfExceptions(ex));
    }
    
    
    
    
    
    
    internal static bool DirectoryExists(string path)
    {
        return ThrowIsNotNull(Exceptions.DirectoryExists(FullNameOfExecutedCode(), path));
    }
    internal static void IsWhitespaceOrNull(string variable, object data)
    {
        ThrowIsNotNull(Exceptions.IsWhitespaceOrNull(FullNameOfExecutedCode(), variable, data));
    }
    internal static void HaveAllInnerSameCount(List<List<string>> elements)
    {
        ThrowIsNotNull(Exceptions.HaveAllInnerSameCount(FullNameOfExecutedCode(), elements));
    }
    internal static bool NotContains(object p1, Type type, string v1, string p2, string v2, string v3)
    {
        return false;
    }
    
    
    
    
    internal static void NameIsNotSetted(string nameControl, string nameFromProperty)
    {
        ThrowIsNotNull(Exceptions.NameIsNotSetted(FullNameOfExecutedCode(), nameControl, nameFromProperty));
    }
    internal static void HasNotKeyDictionary<Key, Value>(string nameDict, IDictionary<Key, Value> qsDict, Key remains)
    {
        ThrowIsNotNull(Exceptions.HasNotKeyDictionary(FullNameOfExecutedCode(T.Item1, T.Item2), nameDict,
        qsDict, remains));
    }
    internal static void DoesntHaveRequiredType(string variableName)
    {
        ThrowIsNotNull(Exceptions.DoesntHaveRequiredType(FullNameOfExecutedCode(), variableName));
    }

    internal static void MoreThanOneElement(string listName, int count, string moreInfo = Consts.se)
    {
        var fn = FullNameOfExecutedCode();
        var exc = Exceptions.MoreThanOneElement(fn, listName, count, moreInfo);
        ThrowIsNotNull(exc);
    }
    internal static bool NotInt(string what, int? value)
    {
        return ThrowIsNotNull(Exceptions.NotInt(FullNameOfExecutedCode(), what, value));
    }
    
    
    
    
    
    
    
    
    
    
    internal static void IsNotNull(string variableName, object variable)
    {
        ThrowIsNotNull(Exceptions.IsNotNull(FullNameOfExecutedCode(), variableName, variable));
    }
    internal static void ArrayElementContainsUnallowedStrings(string arrayName, int dex, string valueElement,
    params string[] unallowedStrings)
    {
        ThrowIsNotNull(Exceptions.ArrayElementContainsUnallowedStrings(FullNameOfExecutedCode(), arrayName, dex,
        valueElement, unallowedStrings));
    }
    internal static void OnlyOneElement(string colName, ICollection list)
    {
        ThrowIsNotNull(Exceptions.OnlyOneElement(FullNameOfExecutedCode(), colName, list));
    }
    internal static void StringContainsUnallowedSubstrings(string input, params string[] unallowedStrings)
    {
        ThrowIsNotNull(
        Exceptions.StringContainsUnallowedSubstrings(FullNameOfExecutedCode(), input, unallowedStrings));
    }
    
    
    
    
    
    
    
    
    internal static void InvalidParameter(string valueVar, string nameVar)
    {
        ThrowIsNotNull(Exceptions.InvalidParameter(FullNameOfExecutedCode(), valueVar, nameVar));
    }
    internal static void ElementCantBeFound(string nameCollection, string element)
    {
        ThrowIsNotNull(Exceptions.ElementCantBeFound(FullNameOfExecutedCode(), nameCollection, element));
    }
    
    #endregion
    #region Without parameters
    internal static void NotSupported()
    {
        ThrowIsNotNull(Exceptions.NotSupported(FullNameOfExecutedCode()));
    }
    #endregion
    #region Without locating executing code
    internal static void CheckBackslashEnd(string stacktrace, string r)
    {
        ThrowIsNotNull(Exceptions.CheckBackSlashEnd(FullNameOfExecutedCode(T.Item1, T.Item2), r));
    }
    #endregion
    internal static void WasNotKeysHandler(string name, object keysHandler)
    {
        ThrowIsNotNull(Exceptions.WasNotKeysHandler(FullNameOfExecutedCode(T.Item1, T.Item2), name, keysHandler));
    }
    #region Helpers
    internal static void IsEmpty(IEnumerable folders, string colName, string additionalMessage = Consts.stringEmpty)
    {
        ThrowIsNotNull(Exceptions.IsEmpty(FullNameOfExecutedCode(), folders, colName, additionalMessage));
    }
    internal static void NoPassedFolders(ICollection folders)
    {
        ThrowIsNotNull(Exceptions.NoPassedFolders(FullNameOfExecutedCode(), folders));
    }
    internal static void RepeatAfterTimeXTimesFailed(int times, int timeoutInMs, string address,
    int sharedAlgorithmSlastError)
    {
        ThrowIsNotNull(Exceptions.RepeatAfterTimeXTimesFailed(FullNameOfExecutedCode(T.Item1, T.Item2), times,
        timeoutInMs, address, sharedAlgorithmSlastError));
    }
    
    
    
    
    
    
    
    
    internal static void ElementWasntRemoved(string detailLocation, int before, int after)
    {
        ThrowIsNotNull(Exceptions.ElementWasntRemoved(FullNameOfExecutedCode(), detailLocation, before, after));
    }
    internal static void FolderCantBeRemoved(string folder)
    {
        ThrowIsNotNull(Exceptions.FolderCantBeRemoved(FullNameOfExecutedCode(), folder));
    }
    internal static void FileHasExtensionNotParseableToImageFormat(string fnOri)
    {
        ThrowIsNotNull(
        Exceptions.FileHasExtensionNotParseableToImageFormat(FullNameOfExecutedCode(T.Item1, T.Item2), fnOri));
    }
    internal static void FileSystemException(Exception ex)
    {
        ThrowIsNotNull(Exceptions.FileSystemException(FullNameOfExecutedCode(T.Item1, T.Item2), ex));
    }
    internal static void FuncionalityDenied(string description)
    {
        ThrowIsNotNull(Exceptions.FuncionalityDenied(FullNameOfExecutedCode(T.Item1, T.Item2), description));
    }
    internal static void CannotMoveFolder(string item, string nova, Exception ex)
    {
        ThrowIsNotNull(Exceptions.CannotMoveFolder(FullNameOfExecutedCode(T.Item1, T.Item2), item, nova, ex));
    }
    internal static bool NotContains(string p, string folderWithProjectsFolders)
    {
        return false;
    }
    internal static void WasAlreadyInitialized()
    {
        ThrowIsNotNull(FullNameOfExecutedCode(T.Item1, T.Item2) + " was already initialized!");
    }
    internal static void IsWindowsPathFormat(string input, Func<string, bool> isWindowsPathFormat)
    {
        if (isWindowsPathFormat(input))
            ThrowIsNotNull(FullNameOfExecutedCode(T.Item1, T.Item2) + input + "is path but only key is expected");
    }
    internal static void FolderIsNotEmpty(string variableName, string path)
    {
        ThrowIsNotNull(FullNameOfExecutedCode(T.Item1, T.Item2) +
        $"Folder {path} is not empty. Variable name: {variableName}");
    }
    internal static void NotInRange(string variableName, List<string> item, int isLt, int isGt)
    {
        ThrowIsNotNull(FullNameOfExecutedCode(T.Item1, T.Item2) +
        $"{variableName} with items {JoinNL(item)} is out of range, it is < {isLt} or > {isGt}");
    }
    internal static void PassedListInsteadOfArray(string variableName, string[] v)
    {
        ThrowIsNotNull(Exceptions.PassedListInsteadOfArray(FullNameOfExecutedCode(T.Item1, T.Item2), variableName, v.ToList()));
    }
    #endregion
    #endregion
    static string JoinNL(List<string> l)
    {
        StringBuilder sb = new();
        foreach (var item in l) sb.AppendLine(item);
        var r = string.Empty;
        r = sb.ToString();
        return r;
    }



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
