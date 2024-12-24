namespace SunamoRoslyn.Services;
internal class RoslynFormatService
{
    public static string Format3(string format)
    {
        // Decode from HTML -
        format = WebUtility.HtmlDecode(format);
        // Replace all <br> with empty
        format = Regex.Replace(format, RegexHelper.rBrTagCaseInsensitive.ToString(), string.Empty);
        // Create SyntaxTree
        SyntaxTree firstTree = CSharpSyntaxTree.ParseText(format);
        var root = firstTree.GetRoot();
        // Format() is in Roslyn.Services which is not actually on nuget
        //root.Format(FormattingOptions.GetDefaultOptions()).GetFormattedRoot().GetText().ToString();
        return null;
    }
    /// <summary>
    /// Format good
    /// Format2 = remove empty lines Format = keep empty lines
    /// code must be compilable
    /// when isnt ; i) instead od ; i++), private in variables return input without changes
    ///
    /// </summary>
    /// <param name="format"></param>
    public static string Format2(string format)
    {
        // Decode from HTML -
        format = WebUtility.HtmlDecode(format);
        // Replace all <br> with empty
        format = Regex.Replace(format, RegexHelper.rBrTagCaseInsensitive.ToString(), string.Empty);
        var workspace = MSBuildWorkspace.Create();
        // Create SyntaxTree
        SyntaxTree firstTree = CSharpSyntaxTree.ParseText(format);
        var root = firstTree.GetRoot();
        var vr = Microsoft.CodeAnalysis.Formatting.Formatter.Format(root, workspace);
        // Instert space between all tokens, replace all nl by spaces
        //vr = root.NormalizeWhitespace();
        // With ToFullString and ToString is output the same - good but without new lines
        var formattedText = vr.ToFullString();
        return FinalizeFormat(formattedText);
    }
    /// <summary>
    /// Format good
    /// Format2 = remove empty lines Format = keep empty lines
    /// code must be compilable
    /// when isnt ; i) instead od ; i++), private in variables return input without changes
    /// </summary>
    /// <param name="format"></param>
    public static string Format(string format)
    {
        // Decode from HTML -
        format = WebUtility.HtmlDecode(format);
        // Replace all <br> with empty
        format = Regex.Replace(format, RegexHelper.rBrTagCaseInsensitive.ToString(), string.Empty);
        var workspace = MSBuildWorkspace.Create();
        StringBuilder sb = new StringBuilder();
        // Create SyntaxTree
        SyntaxTree firstTree = CSharpSyntaxTree.ParseText(format);
        // Get root of ST
        var firstRoot = firstTree.GetRoot();
        #region Process all incomplete nodes in ChildNodesAndTokens and insert into syntaxNodes2
        // Get all Child nodes
        var syntaxNodes = firstRoot.ChildNodesAndTokens();
        // Whether at least one in syntaxNodes is SyntaxNodeOrToken - take its parent
        bool token = false;
        // Whether at least one in syntaxNodes is SyntaxNode - take itself
        bool node2 = false;
        // Parent if token or itself if node2
        SyntaxNode node = null;
        List<SyntaxNode> syntaxNodes2 = new List<SyntaxNode>();
        // Process all incomplete members
        #region If its only code fragment, almost everything will be here IncompleteMember and on end will be delete from code
        //foreach (var item in syntaxNodes.Where(d => d.Kind() == SyntaxKind.IncompleteMember))
        //{
        //    // zde nevím co to dělá
        //    var node3 = item.AsNode();
        //    // insert output of AsNode
        //    syntaxNodes2.Add(node3);
        //}
        #endregion
        #endregion
        // Again get ChildNodesAndTokens, dont know why because should be immutable
        syntaxNodes = firstRoot.ChildNodesAndTokens();
        // WTF? Process all syntaxNodes but output of all elements is save to 2 variables?
        // Must be set only to one variable due to raise exception
        foreach (var syntaxNode in syntaxNodes)
        {
            var syntaxNodeType = syntaxNode.GetType();
            string s = syntaxNodeType.FullName.ToString();
            if (syntaxNodeType == typeof(SyntaxNodeOrToken))
            {
                token = true;
                node = syntaxNode.Parent;
                break;
            }
            else if (syntaxNodeType == typeof(SyntaxNode))
            {
                node2 = true;
                node = (SyntaxNode)syntaxNode;
            }
            else
            {
                ThrowEx.NotImplementedCase(syntaxNodeType);
            }
        }
        if (node2 && token)
        {
            throw new Exception("CantProcessTokenAndSyntaxNodeOutputCouldBeDuplicated");
        }
        // Early if token we get Parent, so now we dont get Parent again
        var node4 = node.Parent;
        if (token)
        {
            node4 = node;
        }
        // Remove nodes which was marked as Incomplete members
        node = node4.ReplaceNode(node, node.RemoveNodes(syntaxNodes2, SyntaxRemoveOptions.AddElasticMarker));
        // Only for debugging
        var nodesAndTokens = node.ChildNodesAndTokens();
        // Dont get to OptionSet - abstract. DocumentOptionSet - sealed, no static member, no ctor.
        //OptionSet os = new DocumentOptionSet()
        var formattedResult = Microsoft.CodeAnalysis.Formatting.Formatter.Format(node, workspace);
        sb.AppendLine(formattedResult.ToFullString().Trim());
        string result = sb.ToString();
        //var formattedResult2 = RoslynServicesHelper.Format(result);
        return FinalizeFormat(result);
    }
    static string FinalizeFormat(string result)
    {
        var lines = SHGetLines.GetLines(result);
        //SH.MultiWhitespaceLineToSingle(lines);
        SH.IndentAsPreviousLine(lines);
        // Important, otherwise is every line delimited by empty
        CA.RemoveStringsEmptyTrimBefore(lines);
        for (int i = lines.Count - 1; i >= 0; i--)
        {
            var line = lines[i];
            var trimmedLine = lines[i].Trim();
            if (trimmedLine.StartsWith(CSharpConsts.lc) && !trimmedLine.StartsWith("///"))
            {
                if (i != 0)
                {
                    if (lines[i - 1].Trim() != "{")
                    {
                        lines.Insert(i, string.Empty);
                    }
                }
            }
        }
        var nl = string.Join(Environment.NewLine, lines);
        //nl = nl.Replace(CsKeywords.ns, Environment.NewLine + CsKeywords.ns);
        return nl;
    }
}