public class HtmlHelperTextTests
{
    [Fact]
    public void InsertMissingEndingTagsTest()
    {
        var input = "ab <a href=\"http://mobilovinky.blog.mobilmania.cz/2011/06/vodafone-a-cd-75-sleva-na-tarif/\" target=\"_blank\">http://mobilovinky.blog.mobilmania.cz/2011/06/vodafone-a-cd-75-sleva-na-tarif/ c <a href=\"d\">d</a> <a>e ";

        var excepted = "ab <a href=\"http://mobilovinky.blog.mobilmania.cz/2011/06/vodafone-a-cd-75-sleva-na-tarif/\" target=\"_blank\">http://mobilovinky.blog.mobilmania.cz/2011/06/vodafone-a-cd-75-sleva-na-tarif/</a> c <a href=\"d\">d</a> <a>e</a> ";

        input = HtmlHelperText.InsertMissingEndingTags(input, "a");

        Assert.Equal(excepted, input);
    }

    [Fact]
    public void RemoveAllNodesTest()
    {
        var input = "amp<sup id=\"cite_ref - semicolon_1 - 3\" class=\"reference\"><a href=\"#cite_note-semicolon-1\">[a]</a></sup>, AMP<sup id=\"cite_ref-semicolon_1-4\" class=\"reference\"><a href=\"#cite_note-semicolon-1\">[a]</a></sup>";
        var excepted = "amp, AMP";

        var actual = HtmlHelperText.RemoveAllNodes(input);

        Assert.Equal(excepted, actual);
    }

    [Fact]
    public void GetAllTagsTest()
    {
        var tags = HtmlHelperText.GetAllTags("sth = { <a> <b c=\"d\"> <e> ");

    }
}
