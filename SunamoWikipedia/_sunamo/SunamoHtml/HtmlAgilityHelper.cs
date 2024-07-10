namespace SunamoWikipedia._sunamo.SunamoHtml;
/// <summary>
/// Protože klasický HtmlAgilityHelper chce HtmlHelper který má miliardu deps
/// </summary>
internal class HtmlAgilityHelper
{
    internal static HtmlDocument CreateHtmlDocument()
    {
        ThrowEx.NotImplementedMethod();
        return null;
    }

    internal static List<HtmlNode> Nodes(object item, bool v1, string v2)
    {
        ThrowEx.NotImplementedMethod();
        return null;
    }

    internal static IEnumerable<object> NodesWhichContainsInAttr(object documentNode, bool v1, string v2, string v3, string v4)
    {
        ThrowEx.NotImplementedMethod();
        return null;
    }

    internal static List<HtmlNode> NodesWithAtstr(HtmlNode mwParserOutputNode, bool v1, string v2, string v3, string v4)
    {
        ThrowEx.NotImplementedMethod();
        return null;
    }

    internal static List<HtmlNode> NodesWithAttr(object mwParserOutputNode, bool v1, string v2, string v3, string v4)
    {
        ThrowEx.NotImplementedMethod();
        return null;
    }

    internal static HtmlNode NodeWithAttr(object documentNode, bool v1, string v2, string v3, string v4)
    {
        ThrowEx.NotImplementedMethod();
        return null;
    }
}
