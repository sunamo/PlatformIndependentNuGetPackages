namespace SunamoTransactionsStatements._sunamo.SunamoExceptions;
partial class Exceptions
{
    public static string? UseRlc(string before)
    {
        return CheckBefore(before) + "Don't implement, use methods in rlc";
    }
    public static string? RepeatAfterTimeXTimesFailed(string before, int times, int timeoutInMs, string address,
    int sharedAlgorithmslastError)
    {
        return CheckBefore(before) +
        $"Loading uri {address} failed {times} ({timeoutInMs} ms timeout) HTTP Error: {sharedAlgorithmslastError}";
    }
    public static string? NotValidXml(string before, string path, Exception ex)
    {
        return CheckBefore(before) + path + "" + TextOfExceptions(ex);
    }
    public static string? ViolationSqlIndex(string before, string tableName, string abcToStringColumnsInIndex)
    {
        return CheckBefore(before) + $"{tableName} {abcToStringColumnsInIndex}";
    }
    public static string? IsNotAllowed(string before, string what)
    {
        return CheckBefore(before) + what + " is not allowed.";
    }
    public static string? BadFormatOfElementInList(string before, object elVal, string listName, Func<object, string> SH_NullToStringOrDefault)
    {
        return CheckBefore(before) + " Bad format of element" + " " + SH_NullToStringOrDefault(elVal) +
        " in list " + listName;
    }
    public static string? IsTheSame(string before, string fst, string sec)
    {
        return CheckBefore(before) + $"{fst} and {sec} has the same value";
    }
    public static string? DivideByZero(string before)
    {
        return CheckBefore(before) + " is dividing by zero.";
    }
    public static string? AnyElementIsNullOrEmpty(string before, string nameOfCollection, List<int> nulled)
    {
        return CheckBefore(before) + $"In {nameOfCollection} has indexes " + string.Join(",", nulled) +
        " with null value";
    }
    public static string? NotEvenNumberOfElements(string before, string nameOfCollection)
    {
        return CheckBefore(before) + nameOfCollection + " have odd elements count";
    }
    public static string? InvalidExactlyLength(string before, string variableName, int length, int requiredLenght)
    {
        if (length != requiredLenght)
        {
            return CheckBefore(before) + variableName + $" have length {length}, required {requiredLenght}";
        }
        return null;
    }
    public static string? FileHasExtensionNotParseableToImageFormat(string before, string fnOri)
    {
        return CheckBefore(before) + "File " + fnOri + " has wrong file extension";
    }
    public static string? WrongCountInList(string before, int numberOfElementsWithoutPause, int numberOfElementsWithPause,
    int arrLength)
    {
        return CheckBefore(before) + string.Format("Array should have {0} or {1} elements, have {2}", numberOfElementsWithoutPause,
        numberOfElementsWithPause, arrLength);
    }
    public static string? FileExists(string before, string fulLPath)
    {
        return CheckBefore(before) + " " + "does not exists" + ": " + fulLPath;
    }
    public static string? FileWasntFoundInDirectory(string before, string path)
    {
        return CheckBefore(before) + "NotFound" + ": " + path;
    }
    public static string? NotSupported(string before)
    {
        return CheckBefore(before) + TranslateAble.i18n("NotSupported");
    }
    public static string? ToManyElementsInCollection(string before, int max, int actual, string nameCollection)
    {
        return CheckBefore(before) + actual + " elements in " + nameCollection + ", maximum is " + max;
    }
    public static string? FuncionalityDenied(string before, string description)
    {
        return CheckBefore(before) + description;
    }
    public static string? MoreCandidates(string before, List<string> list, string item)
    {
        return CheckBefore(before) + "Under" + " " + item + " is more candidates: " + Environment.NewLine +
        string.Join(Environment.NewLine, list);
    }
    public static string? BadMappedXaml(string before, string nameControl, string additionalInfo)
    {
        return CheckBefore(before) + $"Bad mapped XAML in {nameControl}. {additionalInfo}";
    }
    public static string? ElementCantBeFound(string before, string nameCollection, string element)
    {
        return CheckBefore(before) + element + "cannot be found in " + nameCollection;
    }
    public static string? DoesntHaveRequiredType(string before, string variableName)
    {
        return CheckBefore(before) + variableName + TranslateAble.i18n("DoesnTHaveRequiredType") + ".";
    }
    public static string? ArgumentOutOfRangeException(string before, string paramName, string message)
    {
        return CheckBefore(before) + paramName + " " + message;
    }
    public static string? Custom(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    public static string? FolderCannotBeDeleted(string before, string repairedBlogPostsFolder, Exception ex)
    {
        return CheckBefore(before) + repairedBlogPostsFolder + TextOfExceptions(ex);
    }
    public static string? CannotCreateDateTime(string before, int year, int month, int day, int hour, int minute, int seconds,
Exception ex)
    {
        return CheckBefore(before) +
        $"Cannot create DateTime with: year: {year} month: {month} day: {day} hour: {hour} minute: {minute} seconds: {seconds} " +
        TextOfExceptions(ex);
    }
    public static string? CannotMoveFolder(string before, string item, string nova, Exception ex)
    {
        return CheckBefore(before) + $"Cannot move folder from {item} to {nova} " + TextOfExceptions(ex);
    }
    public static string? ExcAsArg(string before, Exception ex, string message)
    {
        return CheckBefore(before) + message + "" + TextOfExceptions(ex);
    }
    public static string? Ftp(string before, Exception ex, string message)
    {
        return CheckBefore(before) + message + "" + TextOfExceptions(ex);
    }
    public static string? IO(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    public static string? InvalidOperation(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    public static string? ArgumentOutOfRange(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    public static string? Format(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    public static string? FtpSecurityNotAvailable(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    public static string? InvalidCast(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    public static string? ObjectDisposed(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    public static string? Timeout(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    public static string? FtpMissingSocket(string before, Exception ex)
    {
        return CheckBefore(before) + TextOfExceptions(ex);
    }
    public static string? NotImplementedMethod(string before)
    {
        return CheckBefore(before) +
        "Not implemented case. public program error. Please contact developer" + ".";
    }
    public static string? NotExists(string before, string item)
    {
        return CheckBefore(before) + item + " not exists";
    }
    public static string? Socket(string before, int socketError)
    {
        return CheckBefore(before) + " socket error: " + socketError;
    }

    internal static string? KeyAlreadyExists<T>(string before, T? key, string nameOfDict)
    {
        return CheckBefore(before) + $"Key {key} already exists in {nameOfDict}";
    }
}