public class HtmlTableParserTests
{
    //[Fact]
    public
    async Task
 HtmlTableParserTest()
    {
        var a = @"D:\_Test\sunamo\sunamo\Html\HtmlTableParserTests\a.html";
        var hd = HtmlAgilityHelper.CreateHtmlDocument();
        hd.LoadHtml(
    await
 TF.ReadAllText(a));
        var table = HtmlAgilityHelper.Node(hd.DocumentNode, true, "table");
        HtmlTableParser p = new HtmlTableParser(table, false);
        var v = p.ColumnValues("1", false, false);
        int i = 0;
    }
}
