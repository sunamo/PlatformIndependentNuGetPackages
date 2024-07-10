namespace SunamoStringParts;
public class SHParts
{
    /// <summary>
    /// Remove with char
    ///
    /// nameSolution musí být první kvůli ChangeContent
    /// </summary>
    /// <param name="us"></param>
    /// <param name="nameSolution"></param>
    public static string RemoveAfterLast(string nameSolution, object delimiter)
    {
        int dex = nameSolution.LastIndexOf(delimiter.ToString());
        if (dex != -1)
        {
            string s = nameSolution.Substring(0, dex); //SHSubstring.Substring(, 0, dex, new SubstringArgs());
            return s;
        }
        return nameSolution;
    }
    public static string RemoveAfterFirstChar(string name, char dot)
    {
        return RemoveAfterFirst(name, dot.ToString());
    }
    public static string RemoveAfterFirstFunc(string v, Func<char, bool> isSpecial, params char[] canBe)
    {
        v = v.Trim();
        for (int i = 0; i < v.Length; i++)
        {
            if (isSpecial(v[i]))
            {
                if (canBe.Contains(v[i]))
                {
                    continue;
                }
                return v.Substring(0, i);
            }
        }
        return v;
    }
    /// <summary>
    ///     Usage: Exc.TypeAndMethodName
    ///     Remove with A2
    /// </summary>
    /// <param name="t"></param>
    /// <param name="ch"></param>
    public static string RemoveAfterFirst(string t, char ch)
    {
        int dex = t.IndexOf(ch);
        return dex == -1 || dex == t.Length - 1 ? t : t.Substring(0, dex);
    }
    /// <summary>
    /// Remove also A2
    /// Don't trim
    /// </summary>
    /// <param name="t"></param>
    /// <param name="ch"></param>
    public static string RemoveAfterFirst(string t, string ch)
    {
        int dex = t.IndexOf(ch);
        if (dex == -1 || dex == t.Length - 1)
        {
            return t;
        }
        string vr = t.Remove(dex);
        return vr;
    }
    private static string TrimStart(string target, string trimString)
    {
        if (string.IsNullOrEmpty(trimString)) return target;
        string result = target;
        while (result.StartsWith(trimString))
        {
            result = result.Substring(trimString.Length);
        }
        return result;
    }
    public static string KeepAfterFirst(string searchQuery, string after, bool keepDeli = false)
    {
        var dx = searchQuery.IndexOf(after);
        if (dx != -1)
        {
            searchQuery = TrimStart(searchQuery.Substring(dx), after);
            if (keepDeli)
            {
                searchQuery = after + searchQuery;
            }
        }
        return searchQuery;
    }
    public static string KeepAfterLast(string searchQuery, string after)
    {
        var dx = searchQuery.LastIndexOf(after);
        if (dx != -1)
        {
            return TrimStart(searchQuery.Substring(dx), after);
        }
        return searchQuery;
    }
}
