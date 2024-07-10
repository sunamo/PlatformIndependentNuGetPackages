namespace SunamoSerializer._sunamo.SunamoExceptions.InSunamoIsDerivedFrom;
internal class CASE
{
    internal static List<string> Trim(List<string> l)
    {
        for (var i = 0; i < l.Count; i++) l[i] = l[i].Trim();

        return l;
    }
}
