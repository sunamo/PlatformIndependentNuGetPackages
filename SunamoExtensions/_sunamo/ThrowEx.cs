namespace SunamoExtensions._sunamo;
using System;

internal class ThrowEx
{
    internal static void Custom(string v)
    {
        Debugger.Break();
        throw new Exception(v);
    }
}