using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
namespace SunamoBazosCrawler._sunamo;
internal class SH
{
    internal static bool MatchWildcard(string name, string mask)
    {
        return IsMatchRegex(name, mask, AllChars.q, AllChars.asterisk);
    }
    private static bool IsMatchRegex(string str, string pat, char singleWildcard, char multipleWildcard)
    {
        // If I compared .vs with .vs, return false before
        if (str == pat)
        {
            return true;
        }
        string escapedSingle = Regex.Escape(new string(singleWildcard, 1));
        string escapedMultiple = Regex.Escape(new string(multipleWildcard, 1));
        pat = Regex.Escape(pat);
        pat = pat.Replace(escapedSingle, AllStrings.dot);
        pat = "^" + pat.Replace(escapedMultiple, ".*") + "$";
        Regex reg = new Regex(pat);
        return reg.IsMatch(str);
    }
}
