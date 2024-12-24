namespace SunamoSecurity._sunamo;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal class ThrowEx
{
    internal static void Custom(string ex)
    {
        Debugger.Break();
        throw new Exception(ex);
    }
}