namespace SunamoEssential._sunamo.SunamoExceptions;

// © www.sunamo.cz. All Rights Reserved.
internal sealed partial class Exceptions
{
    #region Other
    internal static string CheckBefore(string before)
    {
        return string.IsNullOrWhiteSpace(before) ? string.Empty : before + ": ";
    }

    internal static string TextOfExceptions(Exception ex, bool alsoInner = true)
    {
        if (ex == null) return string.Empty;
        StringBuilder stringBuilder = new();
        stringBuilder.Append("Exception:");
        stringBuilder.AppendLine(ex.Message);
        if (alsoInner)
            while (ex.InnerException != null)
            {
                ex = ex.InnerException;
                stringBuilder.AppendLine(ex.Message);
            }
        var result = stringBuilder.ToString();
        return result;
    }

    internal static Tuple<string, string, string> PlaceOfException(
bool isFillAlsoFirstTwo = true)
    {
        StackTrace stackTrace = new();
        var stackTraceText = stackTrace.ToString();
        var lines = stackTraceText.Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries).ToList();
        lines.RemoveAt(0);
        string type = string.Empty;
        string methodName = string.Empty;
        for (int i = 0; i < lines.Count; i++)
        {
            var line = lines[i];
            if (isFillAlsoFirstTwo)
                if (!line.StartsWith("   at ThrowEx"))
                {
                    TypeAndMethodName(line, out type, out methodName);
                    isFillAlsoFirstTwo = false;
                }
            if (line.StartsWith("at System."))
            {
                lines.Add(string.Empty);
                lines.Add(string.Empty);
                break;
            }
        }
        return new Tuple<string, string, string>(type, methodName, string.Join(Environment.NewLine, lines));
    }
    internal static void TypeAndMethodName(string stackLine, out string type, out string methodName)
    {
        var afterAt = stackLine.Split("at ")[1].Trim();
        var fullName = afterAt.Split("(")[0];
        var parts = fullName.Split(new char[] { '.' }, StringSplitOptions.RemoveEmptyEntries).ToList();
        methodName = parts[^1];
        parts.RemoveAt(parts.Count - 1);
        type = string.Join(".", parts);
    }
    internal static string CallingMethod(int value = 1)
    {
        StackTrace stackTrace = new();
        var methodBase = stackTrace.GetFrame(value)?.GetMethod();
        if (methodBase == null)
        {
            return "Method name cannot be get";
        }
        var methodName = methodBase.Name;
        return methodName;
    }
    #endregion

    #region IsNullOrWhitespace
    internal readonly static StringBuilder AdditionalInfoInnerStringBuilder = new();
    internal readonly static StringBuilder AdditionalInfoStringBuilder = new();
    #endregion

    #region OnlyReturnString 

    internal static string? IsNotAllowed(string before, string what)
    {
        return CheckBefore(before) + what + " is not allowed.";
    }
    internal static string? NotSupported(string before)
    {
        return CheckBefore(before) + "Not supported";
    }
    internal static string? DoesntHaveRequiredType(string before, string variableName)
    {
        return CheckBefore(before) + variableName + "does not have required type" + ".";
    }
    internal static string? Custom(string before, string message)
    {
        return CheckBefore(before) + message;
    }
    internal static string? NotImplementedMethod(string before)
    {
        return CheckBefore(before) + "Not implemented method.";
    }
    #endregion

    internal static string? WrongNumberOfElements<T>(string before, int requireElements, string nameCollection,
    IEnumerable<T> collection)
    {
        var count = collection.Count();
        return count != requireElements ? CheckBefore(before) + $" {nameCollection} has {count}, it's required {requireElements}" : null;
    }
    internal static string? IsNull(string before, string variableName, object? variable)
    {
        return variable == null ? CheckBefore(before) + variableName + " " + "is null" + "." : null;
    }
    internal static string? NotImplementedCase(string before, object notImplementedName)
    {
        var forText = string.Empty;
        if (notImplementedName != null)
        {
            forText = " for ";
            if (notImplementedName.GetType() == typeof(Type))
                forText += ((Type)notImplementedName).FullName;
            else
                forText += notImplementedName.ToString();
        }
        return CheckBefore(before) + "Not implemented case" + forText + " . internal program error. Please contact developer" +
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
        : CheckBefore(before) + "Original text dont contains: " + string.Join(",", notContained) + ". Original text: " + originalText;
    }

    internal static string? DifferentCountInLists(string before, string firstCollectionName, int firstCollectionCount, string secondCollectionName, int secondCollectionCount)
    {
        if (firstCollectionCount != secondCollectionCount)
            return CheckBefore(before) + " different count elements in collection" + " " +
            string.Concat(firstCollectionName + "-" + firstCollectionCount) + " vs. " +
            string.Concat(secondCollectionName + "-" + secondCollectionCount);
        return null;
    }
}