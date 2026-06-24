namespace sunamo.Tests.Html;

public class HtmlAgilityHelperManipulationWithoutMockTests : HtmlHelperBaseTests
{
    public HtmlAgilityHelperManipulationWithoutMockTests()
    {
        //GetHtml
    }
    bool noRecursive = true;

    //[Fact]
    public void NodesTest()
    {
        List<HtmlNode> nodes = null;

        noRecursive = true;

        //Recursively
        nodes = HtmlAgilityHelper.Nodes(documentNode, true, HtmlTags.span);
        Assert.Equal(5, nodes.Count);
        // Non-recursively 
        if (noRecursive)
        {
            nodes = HtmlAgilityHelper.Nodes(bodyNode, false, HtmlTags.span);
            Assert.Equal(2, nodes.Count);
        }




        // Recursively
        nodes = HtmlAgilityHelper.Nodes(bodyNode, true, AllStrings.asterisk);
        Assert.Equal(10, nodes.Count);
        // Non-recursively 
        if (noRecursive)
        {
            nodes = HtmlAgilityHelper.Nodes(bodyNode, false, AllStrings.asterisk);
            Assert.Equal(7, nodes.Count);
        }

    }

    //[Fact]
    public void NodesWithAttrTest()
    {
        List<HtmlNode> nodes = null;

        // Recursively
        nodes = HtmlAgilityHelper.NodesWithAttr(documentNode, true, HtmlTags.span, HtmlAttrs.c, cssClassC);
        Assert.Equal(3, nodes.Count);
        // Non-recursively 
        if (noRecursive)
        {
            nodes = HtmlAgilityHelper.NodesWithAttr(bodyNode, false, HtmlTags.span, HtmlAttrs.c, cssClassC);
            Assert.Equal(1, nodes.Count);
        }

        // Recursively
        nodes = HtmlAgilityHelper.NodesWithAttr(bodyNode, true, AllStrings.asterisk, HtmlAttrs.c, cssClassC);
        Assert.Equal(4, nodes.Count);
        // Non-recursively 
        if (noRecursive)
        {
            nodes = HtmlAgilityHelper.NodesWithAttr(bodyNode, false, AllStrings.asterisk, HtmlAttrs.c, cssClassC);
            Assert.Equal(2, nodes.Count);
        }

        // Recursively
        nodes = HtmlAgilityHelper.NodesWithAttr(bodyNode, true, AllStrings.asterisk, HtmlAttrs.c, cssClassA, true);
        Assert.Equal(3, nodes.Count);
        // Non-recursively 
        if (noRecursive)
        {
            nodes = HtmlAgilityHelper.NodesWithAttr(bodyNode, false, AllStrings.asterisk, HtmlAttrs.c, cssClassC, true);
            Assert.Equal(2, nodes.Count);
        }

        // Recursively
        nodes = HtmlAgilityHelper.NodesWithAttr(bodyNode, true, AllStrings.asterisk, HtmlAttrs.c, AllStrings.asterisk, true);
        Assert.Equal(10, nodes.Count);
        // Non-recursively 
        if (noRecursive)
        {
            nodes = HtmlAgilityHelper.NodesWithAttr(bodyNode, false, AllStrings.asterisk, HtmlAttrs.c, AllStrings.asterisk, true);
            Assert.Equal(7, nodes.Count);
        }
    }

    //[Fact]
    public void NodesWhichContainsInAttrTest()
    {
        List<HtmlNode> nodes = null;

        // Recursively
        nodes = HtmlAgilityHelper.NodesWhichContainsInAttr(documentNode, true, HtmlTags.span, HtmlAttrs.c, cssClassA);
        Assert.Equal(2, nodes.Count);
        // Non-recursively 
        if (noRecursive)
        {
            nodes = HtmlAgilityHelper.NodesWhichContainsInAttr(bodyNode, false, HtmlTags.span, HtmlAttrs.c, cssClassA);
            Assert.Single(nodes);
        }

        // Recursively
        nodes = HtmlAgilityHelper.NodesWhichContainsInAttr(documentNode, true, AllStrings.asterisk, HtmlAttrs.c, cssClassA);
        Assert.Equal(3, nodes.Count);
        // Non-recursively 
        if (noRecursive)
        {
            nodes = HtmlAgilityHelper.NodesWhichContainsInAttr(bodyNode, false, AllStrings.asterisk, HtmlAttrs.c, cssClassA);
            Assert.Equal(2, nodes.Count);
        }
    }

    //[Fact]
    public void NodeTest()
    {
        HtmlNode node = null;

        // Recursively
        node = HtmlAgilityHelper.Node(documentNode, true, HtmlTags.span);
        Assert.NotNull(node);

        node = HtmlAgilityHelper.Node(documentNode, true, HtmlTags.img);
        Assert.Null(node);

        node = HtmlAgilityHelper.Node(documentNode, true, AllStrings.asterisk);
        Assert.NotNull(node);

        // Non-recursively 
        if (noRecursive)
        {
            node = HtmlAgilityHelper.Node(bodyNode, false, HtmlTags.span);
            Assert.NotNull(node);

            node = HtmlAgilityHelper.Node(bodyNode, false, HtmlTags.img);
            Assert.Null(node);

            node = HtmlAgilityHelper.Node(bodyNode, false, AllStrings.asterisk);
            Assert.NotNull(node);
        }
    }

    //[Fact]
    public void NodeWithAttrTest()
    {
        HtmlNode node = null;

        // Recursively
        node = HtmlAgilityHelper.NodeWithAttr(documentNode, true, HtmlTags.span, HtmlAttrs.c, cssClassC);
        Assert.NotNull(node);

        // exists but "a b"
        node = HtmlAgilityHelper.NodeWithAttr(documentNode, true, HtmlTags.span, HtmlAttrs.c, cssClassA);
        Assert.Null(node);

        node = HtmlAgilityHelper.NodeWithAttr(documentNode, true, AllStrings.asterisk, HtmlAttrs.cAttr, cssClassA);
        Assert.Null(node);

        node = HtmlAgilityHelper.NodeWithAttr(documentNode, true, HtmlTags.img, HtmlAttrs.cAttr, cssClassA);
        Assert.Null(node);

        // Non-recursively 
        if (noRecursive)
        {
            node = HtmlAgilityHelper.NodeWithAttr(bodyNode, false, HtmlTags.span, HtmlAttrs.c, cssClassC);
            Assert.NotNull(node);

            // exists but "a b"
            node = HtmlAgilityHelper.NodeWithAttr(bodyNode, false, HtmlTags.span, HtmlAttrs.c, cssClassA);
            Assert.Null(node);

            node = HtmlAgilityHelper.NodeWithAttr(bodyNode, false, AllStrings.asterisk, HtmlAttrs.c, cssClassC);
            Assert.NotNull(node);
        }
    }

    //[Fact]
    public void ReplacePlainUriForAnchors()
    {
        string actual = "I tried https://www.nuget.org/p/ because <a href=\"http://jepsano.net/\">http://jepsano.net/</a> another text";
        string excepted = "I tried <a href=\"https://www.nuget.org/p/\">https://www.nuget.org/p/</a> because <a href=\"http://jepsano.net/\">http://jepsano.net/</a> another text";

        string result = HtmlAgilityHelper.ReplacePlainUriForAnchors(actual);
        Assert.Equal(excepted, result);
    }
}
