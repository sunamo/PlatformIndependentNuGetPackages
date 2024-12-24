namespace SunamoRoslyn._sunamo;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal class ThrowEx
{
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

    internal static bool NotImplementedCase(object notImplementedName)
    { return ThrowIsNotNull(Exceptions.NotImplementedCase, notImplementedName); }

    internal static bool ThrowIsNotNull<A>(Func<string, A, string?> f, A ex)
    {
        string? exc = f(FullNameOfExecutedCode(), ex);
        return ThrowIsNotNull(exc);
    }

    internal static string FullNameOfExecutedCode()
    {
        Tuple<string, string, string> placeOfExc = Exceptions.PlaceOfException();
        string f = FullNameOfExecutedCode(placeOfExc.Item1, placeOfExc.Item2, true);
        return f;
    }



    internal static bool NotImplementedMethod() { return ThrowIsNotNull(Exceptions.NotImplementedMethod); }

    internal static bool ThrowIsNotNull(Func<string, string?> f)
    {
        string? exc = f(FullNameOfExecutedCode());
        return ThrowIsNotNull(exc);
    }

    static string FullNameOfExecutedCode(object type, string methodName, bool fromThrowEx = false)
    {
        if (methodName == null)
        {
            int depth = 2;
            if (fromThrowEx)
            {
                depth++;
            }

            methodName = Exceptions.CallingMethod(depth);
        }
        string typeFullName;
        if (type is Type type2)
        {
            typeFullName = type2.FullName ?? "Type cannot be get via type is Type type2";
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
            Type t = type.GetType();
            typeFullName = t.FullName ?? "Type cannot be get via type.GetType()";
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
}