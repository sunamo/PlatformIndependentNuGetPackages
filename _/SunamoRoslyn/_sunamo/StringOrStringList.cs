namespace SunamoRoslyn._sunamo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal class StringOrStringList
{
    internal StringOrStringList(string s)
    {
        String = s;
    }

    internal StringOrStringList(List<string> list)
    {
        List = list;
    }

    internal string String { get; private set; }
    internal List<string> List { get; private set; }

    internal string GetString()
    {
        if (String != null)
        {
            return String;
        }
        if (List != null)
        {
            if (String == null)
            {
                String = string.Join(" ", List);
            }
            return String;
        }

        throw new Exception("Both is null");
    }

    internal List<string> GetList()
    {
        if (String != null)
        {
            if (List == null)
            {
                var nonLetterNumberChars = String.Where(ch => !char.IsLetterOrDigit(ch)).ToArray();

                List = SH.SplitCharMore(String, nonLetterNumberChars);
            }
            return List;
        }
        if (List != null)
        {
            return List;
        }

        throw new Exception("Both is null");
    }
}