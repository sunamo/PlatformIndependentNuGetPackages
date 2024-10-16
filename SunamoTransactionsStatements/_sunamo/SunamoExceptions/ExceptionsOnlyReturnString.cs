namespace SunamoTransactionsStatements._sunamo.SunamoExceptions;
partial class Exceptions
{
    internal static string? UseRlc(string before)
    {
        return CheckBefore(before) + "Don't implement, use methods in rlc";
    }
    internal static string? RepeatAfterTimeXTimesFailed(string before, int times, int timeoutInMs, string address,
    int sharedAlgorithmslastError)
    {
        return CheckBefore(before) +
        $"Loading uri {address} failed {times} ({timeoutInMs} ms timeout) HTTP Error: {sharedAlgorithmslastError}";
    }
    internal static string? NotValidXml(string before, string path, Exception ex)
    {
        return CheckBefore(before) + path + "" + TextOfExceptions(ex);
    }
    internal static string? ViolationSqlIndex(string before, string tableName, string abcToStringColumnsInIndex)
    {
        return CheckBefore(before) + $"{tableName} {abcToStringColumnsInIndex}";
    }
    internal static string? IsNotAllowed(string before, string what)
    {
        return CheckBefore(before) + what + " is not allowed.";
    }
    internal static string? BadFormatOfElementInList(string before, object elVal, string listName, Func<object, string> SH_NullToStringOrDefault)
    {
        return CheckBefore(before) + " Bad format of element" + " " + SH_NullToStringOrDefault(elVal) +
        " in list " + listName;
    }
    internal static string? IsTheSame(string before, string fst, string sec)
    {
        return CheckBefore(before) + $"{fst} and {sec} has the same value";
    }
    internal static string? DivideByZero(string before)
    {
        return CheckBefore(before) + " is dividing by zero.";
    }
    internal static string? AnyElementIsNullOrEmpty(string before, string nameOfCollection, List<int> nulled)
    {
        return CheckBefore(before) + $"In {nameOfCollection} has indexes " + string.Join(",", nulled) +
        " with null value";
    }
    internal static string? NotEvenNumberOfElements(string before, string nameOfCollection)
    {
        return CheckBefore(before) + nameOfCollection + " have odd elements count";
    }
    internal static string? InvalidExactlyLength(string before, string variableName, int length, int requiredLenght)
    {
        if (length != requiredLenght)
        {
            return CheckBefore(before) + variableName + $" have length {length}, required {requiredLenght}";
        }
        return null;
    }
    internal static string? FileHasExtensionNotParseableToImageFormat(string before, string fnOri)
    {
        return CheckBefore(before) + "File " + fnOri + " has wrong file extension";
    }
    internal static string? WrongCountInList(string before, int numberOfElementsWithoutPause, int numberOfElementsWithPause,
    int arrLength)
    {
        return CheckBefore(before) + string.Format("Array should have {0} or {1} elements, have {2}", numberOfElementsWithoutPause,
        numberOfElementsWithPause, arrLength);
    }
    internal static string? FileExists(string before, string fulLPath)
    {
        return CheckBefore(before) + " " + "does not exists" + ": " + fulLPath;
    }
    internal static string? FileWasntFoundInDirectory(string before, string path)
    {
        return CheckBefore(before) + "NotFound" + ": " + path;
    }
    internal static string? NotSupported(string before)
    {
        return CheckBefore(before) + TranslateAble.i18n("NotSupported");
    }
    internal static string? ToManyElementsInCollection(string before, int max, int actual, string nameCollection)
    {
        return CheckBefore(before) + actual + " elements in " + nameCollection + ", maximum is " + max;
    }
    internal static string? FuncionalityDenied(string before, string description)
    {
        return CheckBefore(before) + description;
    }
    internal static string? MoreCandidates(string before, List<string> list, string item)
    {
        return CheckBefore(before) + "Under" + " " + item + " is more candidates: " + Environment.NewLine +
        string.Join(Environment.NewLine, list);
    }
    internal static string? BadMappedXaml(string before, string nameControl, string additionalInfo)
    {
        return CheckBefore(before) + $"Bad mapped XAML in {nameControl}. {additionalInfo}";
    }
    internal static string? ElementCantBeFound(string before, string nameCollection, string element)
    {
        return CheckBefore(before) + element + "cannot be found in " + nameCollection;
    }
    internal static string? DoesntHaveRequiredType(string before, string variableName)
    {
        return CheckBefore(before) + variableName + TranslateAble.i18n("DoesnTHaveRequiredType") + ".";
    }
    internal static string? ArgumentOutOfRangeException(string before, string paramName, string message)
    {
        return CheckBefore(before) + paramName + " " + message;
    }
    internal static string? Custom(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    internal static string? FolderCannotBeDeleted(string before, string repairedBlogPostsFolder, Exception ex)
    {
        return CheckBefore(before) + repairedBlogPostsFolder + TextOfExceptions(ex);
    }
    internal static string? CannotCreateDateTime(string before, int year, int month, int day, int hour, int minute, int seconds,
Exception ex)
    {
        return CheckBefore(before) +
        $"Cannot create DateTime with: year: {year} month: {month} day: {day} hour: {hour} minute: {minute} seconds: {seconds} " +
        TextOfExceptions(ex);
    }
    internal static string? CannotMoveFolder(string before, string item, string nova, Exception ex)
    {
        return CheckBefore(before) + $"Cannot move folder from {item} to {nova} " + TextOfExceptions(ex);
    }
    internal static string? ExcAsArg(string before, Exception ex, string message)
    {
        return CheckBefore(before) + message + "" + TextOfExceptions(ex);
    }
    internal static string? Ftp(string before, Exception ex, string message)
    {
        return CheckBefore(before) + message + "" + TextOfExceptions(ex);
    }
    internal static string? IO(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    internal static string? InvalidOperation(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    internal static string? ArgumentOutOfRange(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    internal static string? Format(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    internal static string? FtpSecurityNotAvailable(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    internal static string? InvalidCast(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    internal static string? ObjectDisposed(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    internal static string? Timeout(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    internal static string? FtpMissingSocket(string before, Exception ex)
    {
        return CheckBefore(before) + TextOfExceptions(ex);
    }
    internal static string? NotImplementedMethod(string before)
    {
        return CheckBefore(before) +
        "Not implemented case. internal program error. Please contact developer" + ".";
    }
    internal static string? NotExists(string before, string item)
    {
        return CheckBefore(before) + item + " not exists";
    }
    internal static string? Socket(string before, int socketError)
    {
        return CheckBefore(before) + " socket error: " + socketError;
    }

    internal static string? KeyAlreadyExists<T>(string before, T? key, string nameOfDict)
    {
        return CheckBefore(before) + $"Key {key} already exists in {nameOfDict}";
    }
}