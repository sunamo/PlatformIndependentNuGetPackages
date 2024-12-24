namespace SunamoRoslyn._sunamo;
using SunamoRoslyn._public;

internal class CA
{
    /// <summary>
    ///     Return A2 if start something in A1
    ///     A2 can be null
    /// </summary>
    /// <param name="suMethods"></param>
    /// <param name="line"></param>
    /// <returns></returns>
    internal static string StartWith(List<string> suMethods, string line)
    {
        string element = null;
        return StartWith(suMethods, line, out element);
    }

    /// <summary>
    ///     Return A2 if start something in A1
    ///     Really different method than string, List
    ///     <string>
    ///         A1 can be null
    /// </summary>
    /// <param name="suMethods"></param>
    /// <param name="line"></param>
    internal static string StartWith(List<string> suMethods, string line, out string element)
    {
        element = null;

        if (suMethods != null)
            foreach (var method in suMethods)
                if (line.StartsWith(method))
                {
                    element = method;
                    return line;
                }

        return null;
    }
    internal static List<string> ReturnWhichContains(List<string> lines, string term, out List<int> founded,
    ContainsCompareMethodRoslyn parseNegations = ContainsCompareMethodRoslyn.WholeInput)
    {
        founded = new List<int>();
        var result = new List<string>();
        var i = 0;

        List<string> w = null;
        if (parseNegations == ContainsCompareMethodRoslyn.SplitToWords ||
            parseNegations == ContainsCompareMethodRoslyn.Negations)
        {
            WhitespaceCharService whitespaceChar = new();
            w = SHSplit.SplitNone(term, whitespaceChar.whiteSpaceChars.ConvertAll(d => d.ToString()).ToArray());
        }
        if (parseNegations == ContainsCompareMethodRoslyn.WholeInput)
            foreach (var item in lines)
            {
                if (item.Contains(term))
                {
                    founded.Add(i);
                    result.Add(item);
                }

                i++;
            }
        else if (parseNegations == ContainsCompareMethodRoslyn.SplitToWords ||
                 parseNegations == ContainsCompareMethodRoslyn.Negations)
            foreach (var item in lines)
            {
                if (w.All(d => item.Contains(d))) //SH.ContainsAll(item, w, parseNegations))
                {
                    founded.Add(i);
                    result.Add(item);
                }

                i++;
            }
        else
            ThrowEx.NotImplementedCase(parseNegations);

        return result;
    }
    internal static List<string> WrapWith(List<string> whereIsUsed2, string v)
    {
        return WrapWith(whereIsUsed2, v, v);
    }

    /// <summary>
    ///     direct edit
    /// </summary>
    /// <param name="whereIsUsed2"></param>
    /// <param name="v"></param>
    internal static List<string> WrapWith(List<string> whereIsUsed2, string before, string after)
    {
        for (var i = 0; i < whereIsUsed2.Count; i++) whereIsUsed2[i] = before + whereIsUsed2[i] + after;
        return whereIsUsed2;
    }
    internal static bool EndsWith(string fn, List<string> allowedExtension)
    {
        foreach (var item in allowedExtension)
            if (fn.EndsWith(item))
                return true;
        return false;
    }

    internal static List<int> ReturnWhichContainsIndexes(IList<string> value, string term,
        SearchStrategyRoslyn searchStrategy = SearchStrategyRoslyn.FixedSpace)
    {
        var result = new List<int>();
        var i = 0;
        if (value != null)
            foreach (var item in value)
            {
                if (item.Contains(term) /*.Contains(item, term, searchStrategy)*/) result.Add(i);
                i++;
            }

        return result;
    }
    internal static List<string> Prepend(string v, List<string> toReplace)
    {
        for (var i = 0; i < toReplace.Count; i++)
            if (!toReplace[i].StartsWith(v))
                toReplace[i] = v + toReplace[i];
        return toReplace;
    }
    internal static void RemoveLines(List<string> lines, List<int> removeLines)
    {
        removeLines.Sort();
        for (var i = removeLines.Count - 1; i >= 0; i--)
        {
            var dx = removeLines[i];
            lines.RemoveAt(dx);
        }
    }
    internal static List<string> RemoveStringsEmptyTrimBefore(List<string> mySites)
    {
        for (var i = mySites.Count - 1; i >= 0; i--)
            if (mySites[i].Trim() == string.Empty)
                mySites.RemoveAt(i);
        return mySites;
    }
}