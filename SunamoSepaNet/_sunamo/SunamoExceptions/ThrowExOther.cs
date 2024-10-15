namespace SunamoExceptions;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

partial class ThrowEx
{
    public static string FullNameOfExecutedCode()
    {
        var placeOfExc = Exceptions.PlaceOfException();

        var f = FullNameOfExecutedCode(placeOfExc.Item1, placeOfExc.Item2, true);
        return f;
    }

    private static string FullNameOfExecutedCode(object type, string methodName, bool fromThrowEx = false)
    {
        if (methodName == null)
        {
            var depth = 2;
            if (fromThrowEx) depth++;
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
            var t = type.GetType();
            typeFullName = t.FullName ?? "Type cannot be get via type.GetType()";
        }
        return string.Concat(typeFullName, AllStrings.dot, methodName);
    }

    public static bool ThrowIsNotNull(string? exception, bool reallyThrow = true)
    {
        if (exception == null)
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

    public static bool ThrowIsNotNull(Exception exception, bool reallyThrow = true)
    {
        if (exception != null)
        {
            ThrowIsNotNull(exception.Message, reallyThrow);
            return false;
        }
        return true;
    }

    public static bool ThrowIsNotNull<A, B>(Func<string, A, B, string?> f, A ex, B message)
    {
        var exc = f(FullNameOfExecutedCode(), ex, message);
        return ThrowIsNotNull(exc);
    }
    public static bool ThrowIsNotNull<A>(Func<string, A, string?> f, A o)
    {
        var exc = f(FullNameOfExecutedCode(), o);
        return ThrowIsNotNull(exc);
    }
    public static bool ThrowIsNotNull(Func<string, string?> f)
    {
        var exc = f(FullNameOfExecutedCode());
        return ThrowIsNotNull(exc);
    }
}
