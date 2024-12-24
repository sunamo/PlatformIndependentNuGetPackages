namespace SunamoRoslyn._sunamo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal static class StringBuilderExtensions
{
    internal static void AddItem(this StringBuilder sb, string postfix, string text)
    {
        sb.Append(text + postfix);
    }
}