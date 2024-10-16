namespace SunamoSepaNet._sunamo.SunamoExceptions;
internal partial class ThrowEx
{
    internal static bool KeyAlreadyExists<T, U>(Dictionary<T, U> dict, T key, string nameOfDict)
    {
        return ThrowIsNotNull(Exceptions.KeyAlreadyExists(FullNameOfExecutedCode(), key, nameOfDict));
    }
    internal static bool NotContains(string text, params string[] shouldContains)
    {
        return ThrowIsNotNull(Exceptions.NotContains(FullNameOfExecutedCode(), text, shouldContains));
    }
    internal static bool IsNotAllowed(string what)
    {
        return ThrowIsNotNull(Exceptions.IsNotAllowed(FullNameOfExecutedCode(), what));
    }
    internal static bool BadFormatOfElementInList(object elVal, string listName, Func<object, string> SH_NullToStringOrDefault)
    {
        return ThrowIsNotNull(Exceptions.BadFormatOfElementInList(FullNameOfExecutedCode(), elVal, listName, SH_NullToStringOrDefault));
    }
    internal static bool IsTheSame(string fst, string sec)
    {
        return ThrowIsNotNull(Exceptions.IsTheSame(FullNameOfExecutedCode(), fst, sec));
    }
    internal static bool WrongNumberOfElements(int requireElements, string nameCount, IEnumerable<string> ele)
    {
        return ThrowIsNotNull(Exceptions.WrongNumberOfElements(FullNameOfExecutedCode(), requireElements,
        nameCount, ele));
    }
    internal static bool DirectoryWasntFound(string folder)
    {
        return ThrowIsNotNull(Exceptions.DirectoryWasntFound(FullNameOfExecutedCode(), folder));
    }
    internal static bool DivideByZero()
    {
        return ThrowIsNotNull(Exceptions.DivideByZero(FullNameOfExecutedCode()));
    }
    internal static bool ViolationSqlIndex(string tableName, string abcToStringColumnsInIndex)
    {
        return ThrowIsNotNull(Exceptions.ViolationSqlIndex(FullNameOfExecutedCode(), tableName,
        abcToStringColumnsInIndex));
    }
    internal static bool Custom(Exception message, bool reallyThrow = true)
    {
        return Custom(Exceptions.TextOfExceptions(message), reallyThrow);
    }
    internal static bool WrongExtension(string path, string ext)
    {
        return ThrowIsNotNull(Exceptions.WrongExtension(FullNameOfExecutedCode(), path, ext));
    }
    internal static bool DuplicatedElements(string nameOfVariable, IList<string> d, string message = "")
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
    internal static bool NotExists(string item)
    {
        return ThrowIsNotNull(
        Exceptions.NotExists(FullNameOfExecutedCode(), item)
        );
    }
    internal static bool Socket(int socketError)
    {
        return ThrowIsNotNull(
        Exceptions.Socket(FullNameOfExecutedCode(), socketError)
        );
    }
    internal static bool NotFoundTranSlationKeyWithCustomError(string message)
    {
        return Custom(message);
    }
    internal static bool NotFoundTranSlationKeyWithoutCustomError(string message)
    {
        return Custom(message);
    }
    internal static bool InvalidExactlyLength(string variableName, int length, int requiredLenght)
    {
        return ThrowIsNotNull(Exceptions.InvalidExactlyLength(FullNameOfExecutedCode(), variableName, length, requiredLenght));
    }
    internal static bool LockedByBitLocker(string path, Func<char, bool> IsLockedByBitLocker)
    {
        return ThrowIsNotNull(Exceptions.LockedByBitLocker(FullNameOfExecutedCode(), path, IsLockedByBitLocker));
    }
    internal static bool CallingSyncMethodInAsyncApp()
    {
        return Custom("Calling sync method in async app");
    }
    internal static bool ExcAsArg(Exception ex, string message = "")
    {
        return ThrowIsNotNull(Exceptions.ExcAsArg, ex, message);
    }
    internal static bool Ftp(string message, Exception ex)
    {
        return ThrowIsNotNull(Exceptions.Ftp, ex, message);
    }
    internal static bool IO(string v)
    {
        return ThrowIsNotNull(Exceptions.IO, v);
    }
    internal static bool InvalidOperation(string s)
    {
        return ThrowIsNotNull(Exceptions.InvalidOperation, s);
    }
    internal static bool ArgumentOutOfRange(string s)
    {
        return ThrowIsNotNull(Exceptions.ArgumentOutOfRange, s);
    }
    internal static bool InvalidCast(string v)
    {
        return ThrowIsNotNull(Exceptions.InvalidCast, v);
    }
    internal static bool ObjectDisposed(string v)
    {
        return ThrowIsNotNull(Exceptions.ObjectDisposed, v);
    }
    internal static bool Timeout(string v)
    {
        return ThrowIsNotNull(Exceptions.Timeout, v);
    }
    internal static bool FtpSecurityNotAvailable(string v)
    {
        return ThrowIsNotNull(Exceptions.FtpSecurityNotAvailable, v);
    }
    internal static bool FtpMissingSocket(Exception ex)
    {
        return ThrowIsNotNull(Exceptions.FtpMissingSocket, ex);
    }
    internal static bool UriFormat(string url, Func<string, bool> uhIsUri)
    {
        return ThrowIsNotNull(Exceptions.UriFormat, url, uhIsUri);
    }
    internal static bool Format(string v)
    {
        return ThrowIsNotNull(Exceptions.Format, v);
    }
    internal static bool UncommentAfterNugetsFinished()
    {
        return ThrowIsNotNull(FullNameOfExecutedCode());
    }
    internal static bool FileAlreadyExists(string file)
    {
        return ThrowIsNotNull(Exceptions.FileAlreadyExists, file);
    }
    internal static bool ListNullOrEmpty<T>(string variableName, IEnumerable<T>? t)
    {
        return ThrowIsNotNull(Exceptions.ListNullOrEmpty(FullNameOfExecutedCode(), variableName, t));
    }
    internal static bool IsOdd(string colName, ICollection e)
    {
        var f = Exceptions.IsOdd;
        return ThrowIsNotNull(f, colName, e);
    }
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
    internal static bool Custom(string message, bool reallyThrow = true, string v2 = "")
    {
        var joined = string.Join("", message, v2);
        var str = Exceptions.Custom(FullNameOfExecutedCode(), joined);
        return ThrowIsNotNull(str, reallyThrow);
    }
    internal static bool IsNotWindowsPathFormat(string argName, string argValue, bool raiseIsNotWindowsPathFormat, Func<string, bool> SunamoFileSystem_IsWindowsPathFormat)
    {
        return ThrowIsNotNull(Exceptions.IsNotWindowsPathFormat(FullNameOfExecutedCode(), argName, argValue, raiseIsNotWindowsPathFormat, SunamoFileSystem_IsWindowsPathFormat));
    }
    internal static bool IsNullOrEmpty(string argName, string argValue)
    {
        return ThrowIsNotNull(Exceptions.IsNullOrWhitespace(FullNameOfExecutedCode(), argName, argValue));
    }
    internal static bool IsNullOrWhitespace(string argName, string argValue)
    {
        return ThrowIsNotNull(Exceptions.IsNullOrWhitespace(FullNameOfExecutedCode(), argName, argValue));
    }
    internal static bool ArgumentOutOfRangeException(string paramName, string message = "")
    {
        return ThrowIsNotNull(Exceptions.ArgumentOutOfRangeException(FullNameOfExecutedCode(), paramName, message));
    }
    internal static bool IsNull(string variableName, object? variable = null)
    {
        return ThrowIsNotNull(Exceptions.IsNull(FullNameOfExecutedCode(), variableName, variable));
    }
#pragma warning disable
    internal static Action<string, string> writeServerError;
#pragma warning enable
    internal static bool NotImplementedCase(object niCase)
    {
        return ThrowIsNotNull(Exceptions.NotImplementedCase, niCase);
    }
    internal static bool NotImplementedMethod()
    {
        return ThrowIsNotNull(Exceptions.NotImplementedMethod);
    }
    internal static bool StartIsHigherThanEnd(int start, int end)
    {
        return ThrowIsNotNull(Exceptions.StartIsHigherThanEnd(FullNameOfExecutedCode(), start, end));
    }
    internal static bool FolderCannotBeDeleted(string repairedBlogPostsFolder, Exception ex)
    {
        return ThrowIsNotNull(Exceptions.FolderCannotBeDeleted(FullNameOfExecutedCode(), repairedBlogPostsFolder, ex));
    }
    internal static bool KeyNotFound<T, U>(IDictionary<T, U> en, string dictName, T key)
    {
        return ThrowIsNotNull(Exceptions.KeyNotFound(FullNameOfExecutedCode(), en, dictName,
        key));
    }
    internal static bool FirstLetterIsNotUpper(string selectedFile)
    {
        return ThrowIsNotNull(Exceptions.FirstLetterIsNotUpper, selectedFile);
    }
    internal static bool NotSupportedExtension(string extension)
    {
        return Custom("Extensions is not supported: " + extension);
    }
    internal static bool BadMappedXaml(string nameControl, string additionalInfo)
    {
        return ThrowIsNotNull(Exceptions.BadMappedXaml(FullNameOfExecutedCode(), nameControl, additionalInfo));
    }
    internal static bool CannotCreateDateTime(int year, int month, int day, int hour, int minute, int seconds,
    Exception ex)
    {
        return ThrowIsNotNull(Exceptions.CannotCreateDateTime(FullNameOfExecutedCode(), year, month, day, hour, minute,
        seconds, ex));
    }
    internal static bool FileDoesntExists(string fulLPath)
    {
        return ThrowIsNotNull(Exceptions.FileExists(FullNameOfExecutedCode(), fulLPath));
    }
    internal static bool UseRlc()
    {
        return ThrowIsNotNull(Exceptions.UseRlc(FullNameOfExecutedCode()));
    }
    internal static bool OutOfRange(string colName, ICollection col, string indexName, int index)
    {
        return ThrowIsNotNull(Exceptions.OutOfRange(FullNameOfExecutedCode(), colName, col, indexName,
        index));
    }
    internal static bool CustomWithStackTrace(Exception ex)
    {
        return Custom(Exceptions.TextOfExceptions(ex));
    }
    internal static bool DirectoryExists(string path)
    {
        return ThrowIsNotNull(Exceptions.DirectoryExists(FullNameOfExecutedCode(), path));
    }
    internal static bool IsWhitespaceOrNull(string variable, object data)
    {
        return ThrowIsNotNull(Exceptions.IsWhitespaceOrNull(FullNameOfExecutedCode(), variable, data));
    }
    internal static bool HaveAllInnerSameCount(List<List<string>> elements)
    {
        return ThrowIsNotNull(Exceptions.HaveAllInnerSameCount(FullNameOfExecutedCode(), elements));
    }
    internal static bool NameIsNotSetted(string nameControl, string nameFromProperty)
    {
        return ThrowIsNotNull(Exceptions.NameIsNotSetted(FullNameOfExecutedCode(), nameControl, nameFromProperty));
    }
    internal static bool HasNotKeyDictionary<Key, Value>(string nameDict, IDictionary<Key, Value> qsDict, Key remains)
    {
        return ThrowIsNotNull(Exceptions.HasNotKeyDictionary(FullNameOfExecutedCode(), nameDict,
        qsDict, remains));
    }
    internal static bool DoesntHaveRequiredType(string variableName)
    {
        return ThrowIsNotNull(Exceptions.DoesntHaveRequiredType(FullNameOfExecutedCode(), variableName));
    }
    internal static bool MoreThanOneElement(string listName, int count, string moreInfo = "")
    {
        var fn = FullNameOfExecutedCode();
        var exc = Exceptions.MoreThanOneElement(fn, listName, count, moreInfo);
        return ThrowIsNotNull(exc);
    }
    internal static bool NotInt(string what, int? value)
    {
        return ThrowIsNotNull(Exceptions.NotInt(FullNameOfExecutedCode(), what, value));
    }
    internal static bool IsNotNull(string variableName, object variable)
    {
        return ThrowIsNotNull(Exceptions.IsNotNull(FullNameOfExecutedCode(), variableName, variable));
    }
    internal static bool ArrayElementContainsUnallowedStrings(string arrayName, int dex, string valueElement,
    params string[] unallowedStrings)
    {
        return ThrowIsNotNull(Exceptions.ArrayElementContainsUnallowedStrings(FullNameOfExecutedCode(), arrayName, dex,
        valueElement, unallowedStrings));
    }
    internal static bool OnlyOneElement(string colName, ICollection list)
    {
        return ThrowIsNotNull(Exceptions.OnlyOneElement(FullNameOfExecutedCode(), colName, list));
    }
    internal static bool StringContainsUnallowedSubstrings(string input, params string[] unallowedStrings)
    {
        return ThrowIsNotNull(
        Exceptions.StringContainsUnallowedSubstrings(FullNameOfExecutedCode(), input, unallowedStrings));
    }
    internal static bool InvalidParameter(string valueVar, string nameVar)
    {
        return ThrowIsNotNull(Exceptions.InvalidParameter(FullNameOfExecutedCode(), valueVar, nameVar));
    }
    internal static bool ElementCantBeFound(string nameCollection, string element)
    {
        return ThrowIsNotNull(Exceptions.ElementCantBeFound(FullNameOfExecutedCode(), nameCollection, element));
    }
    internal static bool NotSupported()
    {
        return ThrowIsNotNull(Exceptions.NotSupported(FullNameOfExecutedCode()));
    }
    internal static bool CheckBackslashEnd(string r)
    {
        return ThrowIsNotNull(Exceptions.CheckBackSlashEnd(FullNameOfExecutedCode(), r));
    }
    internal static bool WasNotKeysHandler(string name, object keysHandler)
    {
        return ThrowIsNotNull(Exceptions.WasNotKeysHandler(FullNameOfExecutedCode(), name, keysHandler));
    }
    internal static bool IsEmpty(IEnumerable folders, string colName, string additionalMessage = "")
    {
        return ThrowIsNotNull(Exceptions.IsEmpty(FullNameOfExecutedCode(), folders, colName, additionalMessage));
    }
    internal static bool NoPassedFolders(ICollection folders)
    {
        return ThrowIsNotNull(Exceptions.NoPassedFolders(FullNameOfExecutedCode(), folders));
    }
    internal static bool RepeatAfterTimeXTimesFailed(int times, int timeoutInMs, string address,
    int sharedAlgorithmSlastError)
    {
        return ThrowIsNotNull(Exceptions.RepeatAfterTimeXTimesFailed(FullNameOfExecutedCode(), times,
        timeoutInMs, address, sharedAlgorithmSlastError));
    }
    internal static bool ElementWasntRemoved(string detailLocation, int before, int after)
    {
        return ThrowIsNotNull(Exceptions.ElementWasntRemoved(FullNameOfExecutedCode(), detailLocation, before, after));
    }
    internal static bool FolderCantBeRemoved(string folder)
    {
        return ThrowIsNotNull(Exceptions.FolderCantBeRemoved(FullNameOfExecutedCode(), folder));
    }
    internal static bool FileHasExtensionNotParseableToImageFormat(string fnOri)
    {
        return ThrowIsNotNull(
        Exceptions.FileHasExtensionNotParseableToImageFormat(FullNameOfExecutedCode(), fnOri));
    }
    internal static bool FileSystemException(Exception ex)
    {
        return ThrowIsNotNull(Exceptions.FileSystemException(FullNameOfExecutedCode(), ex));
    }
    internal static bool FuncionalityDenied(string description)
    {
        return ThrowIsNotNull(Exceptions.FuncionalityDenied(FullNameOfExecutedCode(), description));
    }
    internal static bool CannotMoveFolder(string item, string nova, Exception ex)
    {
        return ThrowIsNotNull(Exceptions.CannotMoveFolder(FullNameOfExecutedCode(), item, nova, ex));
    }
    internal static bool WasAlreadyInitialized()
    {
        return ThrowIsNotNull(FullNameOfExecutedCode() + " was already initialized!");
    }
    internal static bool IsWindowsPathFormat(string input, Func<string, bool> isWindowsPathFormat)
    {
        return ThrowIsNotNull(Exceptions.IsWindowsPathFormat(FullNameOfExecutedCode(), input, isWindowsPathFormat));
    }
    internal static bool FolderIsNotEmpty(string variableName, string path)
    {
        return ThrowIsNotNull(FullNameOfExecutedCode() +
        $"Folder {path} is not empty. Variable name: {variableName}");
    }
    internal static bool NotInRange(string variableName, List<string> item, int isLt, int isGt)
    {
        return ThrowIsNotNull(FullNameOfExecutedCode() +
        $"{variableName} with items {string.Join(",", item)} is out of range, it is < {isLt} or > {isGt}");
    }
    internal static bool PassedListInsteadOfArray<T>(string variableName, T[] v, Func<List<T>, bool> CA_IsListStringWrappedInArray)
    {
        return ThrowIsNotNull(Exceptions.PassedListInsteadOfArray<T>(FullNameOfExecutedCode(), variableName, v.ToList(), CA_IsListStringWrappedInArray));
    }
}