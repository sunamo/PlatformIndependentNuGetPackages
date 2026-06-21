namespace SunamoCryptAlgorithms._sunamo.SunamoExceptions;

// EN: Variable names have been checked and replaced with self-descriptive names
// CZ: Názvy proměnných byly zkontrolovány a nahrazeny samopopisnými názvy
internal partial class ThrowEx
{

    internal static bool Custom(Exception ex, bool reallyThrow = true)
    { return Custom(Exceptions.TextOfExceptions(ex), reallyThrow); }

    internal static bool Custom(string message, bool reallyThrow = true, string secondMessage = "")
    {
        string joined = string.Join(" ", message, secondMessage);
        string? str = Exceptions.Custom(FullNameOfExecutedCode(), joined);
        return ThrowIsNotNull(str, reallyThrow);
    }
    internal static bool DifferentCountInLists(string namefc, int countfc, string namesc, int countsc)
    {
        return ThrowIsNotNull(
            Exceptions.DifferentCountInLists(FullNameOfExecutedCode(), namefc, countfc, namesc, countsc));
    }
    internal static bool DoesntHaveRequiredType(string variableName)
    { return ThrowIsNotNull(Exceptions.DoesntHaveRequiredType(FullNameOfExecutedCode(), variableName)); }

    internal static bool IsNotAllowed(string what)
    { return ThrowIsNotNull(Exceptions.IsNotAllowed(FullNameOfExecutedCode(), what)); }
    internal static bool IsNull(string variableName, object? variable = null)
    { return ThrowIsNotNull(Exceptions.IsNull(FullNameOfExecutedCode(), variableName, variable)); }

    internal static bool NotContains(string text, params string[] shouldContains)
    { return ThrowIsNotNull(Exceptions.NotContains(FullNameOfExecutedCode(), text, shouldContains)); }

    internal static bool NotImplementedCase(object notImplementedName)
    { return ThrowIsNotNull(Exceptions.NotImplementedCase, notImplementedName); }
    internal static bool NotImplementedMethod() { return ThrowIsNotNull(Exceptions.NotImplementedMethod); }

    internal static bool NotSupported() { return ThrowIsNotNull(Exceptions.NotSupported(FullNameOfExecutedCode())); }
    internal static bool WrongNumberOfElements<T>(int requireElements, string nameCollection, IEnumerable<T> collection)
    {
        return ThrowIsNotNull(
            Exceptions.WrongNumberOfElements(FullNameOfExecutedCode(), requireElements, nameCollection, collection));
    }

    #region Other
    internal static string FullNameOfExecutedCode()
    {
        Tuple<string, string, string> placeOfException = Exceptions.PlaceOfException();
        string result = FullNameOfExecutedCode(placeOfException.Item1, placeOfException.Item2, true);
        return result;
    }

    static string FullNameOfExecutedCode(object type, string methodName, bool isFromThrowEx = false)
    {
        if (methodName == null)
        {
            int depth = 2;
            if (isFromThrowEx)
            {
                depth++;
            }

            methodName = Exceptions.CallingMethod(depth);
        }
        string typeFullName;
        if (type is Type resolvedType)
        {
            typeFullName = resolvedType.FullName ?? "Type cannot be get via type is Type";
        }
        else if (type is MethodBase method)
        {
            typeFullName = method.ReflectedType?.FullName ?? "Type cannot be get via type is MethodBase method";
            methodName = method.Name;
        }
        else if (type is string)
        {
            typeFullName = type.ToString() ?? "Type cannot be get via type is string";
        }
        else
        {
            Type runtimeType = type.GetType();
            typeFullName = runtimeType.FullName ?? "Type cannot be get via type.GetType()";
        }
        return string.Concat(typeFullName, ".", methodName);
    }

    internal static bool ThrowIsNotNull(string? exception, bool reallyThrow = true)
    {
        if (exception != null)
        {
            Debugger.Break();
            if (reallyThrow)
            {
                throw new Exception(exception);
            }
            return true;
        }
        return false;
    }

    #region For avoid FullNameOfExecutedCode


    internal static bool ThrowIsNotNull<TArg>(Func<string, TArg, string?> exceptionFactory, TArg argument)
    {
        string? exception = exceptionFactory(FullNameOfExecutedCode(), argument);
        return ThrowIsNotNull(exception);
    }

    internal static bool ThrowIsNotNull(Func<string, string?> exceptionFactory)
    {
        string? exception = exceptionFactory(FullNameOfExecutedCode());
        return ThrowIsNotNull(exception);
    }
    #endregion
    #endregion
}