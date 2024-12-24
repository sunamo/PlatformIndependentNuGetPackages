namespace SunamoRoslyn._sunamo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal static class CSharpHelper
{
    internal static List<string> Usings(CompilationUnitSyntax root)
    {
        List<string> result = new();

        foreach (UsingDirectiveSyntax usingDirective in root.Usings)
        {
            // Z�sk�n� n�zvu using direktivy
            result.Add(usingDirective.Name.ToString());

        }
        return result;
    }

}