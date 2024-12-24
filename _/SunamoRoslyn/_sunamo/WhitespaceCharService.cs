namespace SunamoRoslyn._sunamo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal class WhitespaceCharService
{
    internal List<char> whiteSpaceChars;
    internal readonly List<int> whiteSpacesCodes = new(new[]
{
9, 10, 11, 12, 13, 32, 133, 160, 5760, 6158, 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202,
8232, 8233, 8239, 8287, 12288
});

    internal void ConvertWhiteSpaceCodesToChars()
    {

        whiteSpaceChars = new List<char>(whiteSpacesCodes.Count);
        foreach (var item in whiteSpacesCodes)
        {
            var s = char.ConvertFromUtf32(item);
            var ch = Convert.ToChar(s);
            whiteSpaceChars.Add(ch);
        }
    }

}