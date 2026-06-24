

///// <summary>
///// 
///// Stale se to strida #text, div
///// </summary>
//public class HtmlHelperManipulationWithoutMockTests : HtmlHelperBaseTests
//{
//    //[Fact]
//    public void HasTagName()
//    {
//        // TODO: usage *
//    }

//    //[Fact]
//    public void HighlightingWordsTest()
//    {
//        string words = "Hello world Hello hello";

//        //string veta = SH.XCharsBeforeAndAfterWholeWords(SHReplace.ReplaceAll(celyObsah, AllStrings.space, CA.ToListString(AllChars.whiteSpacesChars).ToArray()), stred, naKazdeStrane);
//        var s = HtmlHelper.HighlightingWords(words, 100, 4, CA.ToListString("Hello"));
//        int i = 0;
//    }

//    //[Fact]
//    public void GetTagOfAtributeTest()
//    {
//        var node = HtmlHelper.GetTagOfAtribute(documentNode, HtmlTags.div, HtmlAttrs.cAttr, cssClassHello);
//        Assert.Null(node);

//        var node2 = HtmlHelper.GetTagOfAtribute(bodyNode, HtmlTags.div, HtmlAttrs.cAttr, cssClassHello);
//        Assert.NotNull(node2);
//    }

//    // OK
//    //[Fact]
//    public void ReturnTagsWithAttrRekTest()
//    {
//        var nodes = HtmlHelper.ReturnTagsWithAttrRek(documentNode, HtmlTags.span, HtmlAttrs.cAttr, cssClassC);
//        Assert.Equal(3, nodes.Count);
//    }

//    // OK
//    //[Fact]
//    public void GetTagOfAtributeRekTest()
//    {
//        var divFirst = HtmlHelper.GetTagOfAtributeRek(documentNode, HtmlTags.div, HtmlAttrs.id, divFirstId);
//        var nodes = HtmlHelper.ReturnTagsWithAttrRek(divFirst, HtmlTags.span, HtmlAttrs.cAttr, cssClassC);
//        Assert.Equal(2, nodes.Count);

//        var node = HtmlHelper.GetTagOfAtributeRek(documentNode, HtmlTags.div, HtmlAttrs.cAttr, cssClassHello);
//        Assert.Null(node);

//        var node2 = HtmlHelper.GetTagOfAtributeRek(bodyNode, HtmlTags.div, HtmlAttrs.cAttr, cssClassHello);
//        Assert.NotNull(node2);
//    }
//}
