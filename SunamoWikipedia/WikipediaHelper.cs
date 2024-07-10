namespace SunamoWikipedia;


public class WikipediaHelper
{
    const string Character = "Character";
    const string Names = "Names";

    public static string HtmlEntitiesList(Func<List<string>, List<string>, string> CSharpHelperGetDictionaryValuesFromTwoList)
    {
        var c = string.Empty;
        //c = File.ReadAllTextAsync(@"D:\_Test\sunamo\shared\WikipediaHelper\ParseTable.html");

        var tables = ParseTable(c, Character, Names);

        var table = tables.First();

        List<string> chars = table.ColumnValues(Character, true, false);
        List<string> names = table.ColumnValues(Names, true, true);

        return CSharpHelperGetDictionaryValuesFromTwoList(names, chars);
    }

    /// <param name="html"></param>
    /// <param name="columns"></param>
    /// <returns></returns>
    public static List<HtmlTableParserWiki> ParseTable(string html, params string[] columns)
    {
        List<HtmlTableParserWiki> htmls = new List<HtmlTableParserWiki>();
        var hd = HtmlAgilityHelper.CreateHtmlDocument();
        hd.LoadHtml(html);

        //var mwParserOutputNode = HtmlAgilityHelper.NodeWithAttr(hd.DocumentNode, true, "*", "class", "mw-parser-output");

        var subNodes = HtmlAgilityHelper.NodesWhichContainsInAttr(hd.DocumentNode, true, "*", "class", "wikitable");

        List<string> result = new List<string>();

        foreach (var item in subNodes)
        {
            List<HtmlNode> theads = HtmlAgilityHelper.Nodes(item, true, "th");

            var headers = new List<string>(theads.Count);
            foreach (var th in theads)
            {
                headers.Add(th.InnerText.Trim());
            }

            bool rightTable = true;

            foreach (var item2 in columns)
            {
                if (!headers.Contains(item2))
                {
                    rightTable = false;
                }
            }

            if (rightTable)
            {
                HtmlTableParserWiki tp = new HtmlTableParserWiki(item, false);

                htmls.Add(tp);
            }
        }

        return htmls;
    }

    /// <summary>
    /// Dont know for what page it was used
    /// I try to find with several page
    /// </summary>
    /// <param name="html"></param>
    /// <returns></returns>
    public static List<string> ParseList(string html)
    {
        var hd = HtmlAgilityHelper.CreateHtmlDocument();

        hd.LoadHtml(html);

        HtmlNode mwParserOutputNode = HtmlAgilityHelper.NodeWithAttr(hd.DocumentNode, true, "*", "class", "mw-parser-output");

        List<HtmlNode> subNodes = HtmlAgilityHelper.NodesWithAtstr(mwParserOutputNode, false, "*", "class", "div-col columns column-width");

        List<string> result = new List<string>();

        foreach (var item in subNodes)
        {
            var anchors = HtmlAgilityHelper.Nodes(item, true, "a");

            foreach (var anchor in anchors)
            {
                result.Add(anchor.InnerText.Trim());
            }
        }

        return result;
    }


}
