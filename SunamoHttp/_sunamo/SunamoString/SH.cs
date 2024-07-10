namespace SunamoHttp._sunamo.SunamoString;
internal class SH
{
    internal static string AppendIfDontEndingWith(string text, string append)
    {
        if (text.EndsWith(append))
        {
            return text;
        }
        return text + append;
    }
}
