namespace SunamoGetFiles._sunamo.SunamoStringParts;
internal class SHParts
{
    internal static string RemoveAfterLast(string nameSolution, object delimiter)
    {
        int dex = nameSolution.LastIndexOf(delimiter.ToString());
        if (dex != -1)
        {
            string s = nameSolution.Substring(0, dex); //SHSubstring.Substring(, 0, dex, new SubstringArgs());
            return s;
        }
        return nameSolution;
    }
}
