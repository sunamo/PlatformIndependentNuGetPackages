namespace SunamoWikipedia._sunamo.SunamoValues.Values;


internal class AspxConsts
{
    internal static readonly string startAspxComment = "<%--";
    internal static readonly string endAspxComment = "--%>";
    internal static readonly string startHtmlComment = "<!--";
    internal static readonly string endHtmlComment = "-->";
    internal static readonly List<string> all = new List<string>([startAspxComment, endAspxComment, startHtmlComment, endHtmlComment, AllStrings.gt, AllStrings.lt]);
}