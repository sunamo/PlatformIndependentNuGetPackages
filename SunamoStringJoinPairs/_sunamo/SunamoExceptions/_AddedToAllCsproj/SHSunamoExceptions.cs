namespace SunamoStringJoinPairs._sunamo.SunamoExceptions._AddedToAllCsproj;
internal class SHSunamoExceptions
{
    internal static string JoinNL(List<string> l)
    {
        StringBuilder sb = new();
        foreach (var item in l) sb.AppendLine(item);
        var r = string.Empty;
        r = sb.ToString();
        return r;
    }
    internal static List<string> SplitChar(string s, params char[] dot)
    {
        return s.Split(dot, StringSplitOptions.RemoveEmptyEntries).ToList();
    }
    internal static List<string> Split(string s, params string[] dot)
    {
        return s.Split(dot, StringSplitOptions.RemoveEmptyEntries).ToList();
    }
    internal static List<string> SplitNone(string text, params string[] deli)
    {
        return text.Split(deli, StringSplitOptions.None).ToList();
    }
    internal static string NullToStringOrDefault(object n)
    {
        
        return n == null ? " " + Consts.nulled : AllStrings.space + n;
    }
    internal static string TrimEnd(string name, string ext)
    {
        while (name.EndsWith(ext)) return name.Substring(0, name.Length - ext.Length);
        return name;
    }
}
