namespace SunamoRoslyn._sunamo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal class SHSplit
{
    internal static List<string> SplitNone(string p, params string[] newLine)
    {
        return p.Split(newLine, StringSplitOptions.None).ToList();
    }
}