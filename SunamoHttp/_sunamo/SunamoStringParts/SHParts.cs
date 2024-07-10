namespace SunamoHttp._sunamo.SunamoStringParts;
internal class SHParts
{
    internal static string RemoveAfterFirst(string t, string ch)
    {
        int dex = t.IndexOf(ch);
        if (dex == -1 || dex == t.Length - 1)
        {
            return t;
        }

        string vr = t.Remove(dex);
        return vr;
    }
}
