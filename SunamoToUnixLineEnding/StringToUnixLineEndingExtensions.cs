namespace SunamoToUnixLineEnding;
public static class StringToUnixLineEndingExtensions
{
    public static string ToUnixLineEnding(this string s)
    {
        return s.ReplaceLineEndings(Consts2.nl);
    }
}
