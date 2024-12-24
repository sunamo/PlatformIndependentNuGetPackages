namespace SunamoRoslyn._sunamo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal class SHReplace
{
    internal static string ReplaceOnce(string input, string what, string zaco)
    {
        if (what == "") return input;
        var pos = input.IndexOf(what);
        if (pos == -1) return input;
        return input.Substring(0, pos) + zaco + input.Substring(pos + what.Length);
    }
}