namespace SunamoText._sunamo.SunamoString;
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
    internal static int OccurencesOfStringIn(string source, string p_2)
    {
        return source.Split(new string[] { p_2 }, StringSplitOptions.None).Length - 1;
    }
    internal static bool ContainsAll(string input, IList<string> allWords, ContainsCompareMethod ccm = ContainsCompareMethod.WholeInput)
    {
        if (ccm == ContainsCompareMethod.SplitToWords)
        {
            foreach (var item in allWords)
            {
                if (!input.Contains(item))
                {
                    return false;
                }
            }
        }
        else if (ccm == ContainsCompareMethod.Negations)
        {
            foreach (var item in allWords)
            {
                var c = item.ToString();
                if (!IsContained(input, ref c))
                {
                    return false;
                }
            }
        }
        else if (ccm == ContainsCompareMethod.WholeInput)
        {
            foreach (var item in allWords)
            {
                if (!input.Contains(item))
                {
                    return false;
                }
            }
        }
        return true;
    }

    internal static bool IsContained(string item, ref string contains)
    {
        var (negation, contains2) = IsNegationTuple(contains);
        contains = contains2;

        if (negation && item.Contains(contains))
        {
            return false;
        }
        else if (!negation && !item.Contains(contains))
        {
            return false;
        }

        return true;
    }

    internal static bool IsContained(string item, string contains)
    {
        var (negation, contains2) = IsNegationTuple(contains);
        contains = contains2;

        if (negation && item.Contains(contains))
        {
            return false;
        }
        else if (!negation && !item.Contains(contains))
        {
            return false;
        }

        return true;
    }

    internal static (bool, string) IsNegationTuple(string contains)
    {
        if (contains[0] == '!')
        {
            contains = contains.Substring(1);
            return (true, contains);
        }

        return (false, contains);
    }
}
