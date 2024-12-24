namespace SunamoRoslyn;
public class RoslynHelper
{
    static Type type = typeof(RoslynHelper);

    public static List<Type> GetTypesInAssembly(Assembly assembly, string contains)
    {
        var types = assembly.GetTypes();
        return types.Where(t => t.Name.Contains(contains)).ToList();
    }
    /// <summary>
    /// A1 can be SyntaxNode or string
    /// </summary>
    /// <param name="o"></param>
    /// <returns></returns>
    public static string AddWhereIsUsedVariablesInMethods(object o)
    {
        SyntaxNode root = RoslynParser.SyntaxNodeFromObjectOrString(o);
        var methods = ChildNodes.MethodsDescendant(root);
        var fields = ChildNodes.FieldsDescendant(root);
        string before = null;
        string after = null;
        StringBuilder sb = new StringBuilder();
        sb.Append(root.ToFullString());
        Tuple<List<string>, List<string>> ls = null;
        Dictionary<string, List<string>> dict = new Dictionary<string, List<string>>();
        string methodName = null;
        foreach (MethodDeclarationSyntax oldMethodNode in methods)
        {
            ls = RoslynParser.ParseVariables(oldMethodNode);
            methodName = oldMethodNode.Identifier.Text;
            foreach (var item in ls.Item2)
            {
                DictionaryHelper.AddOrCreate<string, string, object>(dict, item, methodName);
            }
            #region MyRegion
            //        var testDocumentation = SyntaxFactory.DocumentationCommentTrivia(
            //        SyntaxKind.SingleLineDocumentationCommentTrivia,
            //        SyntaxFactory.List<XmlNodeSyntax>(
            //            new XmlNodeSyntax[]{
            //    SyntaxFactory.XmlText()
            //    .WithTextTokens(
            //        SyntaxFactory.TokenList(
            //            SyntaxFactory.XmlTextLiteral(
            //                SyntaxFactory.TriviaList(
            //                    SyntaxFactory.DocumentationCommentExterior("///")),
            //                " ",
            //                " ",
            //                SyntaxFactory.TriviaList()))),
            //    SyntaxFactory.XmlElement(
            //        SyntaxFactory.XmlElementStartTag(
            //            SyntaxFactory.XmlName(
            //                SyntaxFactory.Identifier("summary"))),
            //        SyntaxFactory.XmlElementEndTag(
            //            SyntaxFactory.XmlName(
            //                SyntaxFactory.Identifier("summary"))))
            //    .WithContent(
            //        SyntaxFactory.SingletonList<XmlNodeSyntax>(
            //            SyntaxFactory.XmlText()
            //            .WithTextTokens(
            //                SyntaxFactory.TokenList(
            //                    SyntaxFactory.XmlTextLiteral(
            //                        SyntaxFactory.TriviaList(),
            //                        "test",
            //                        "test",
            //                        SyntaxFactory.TriviaList()))))),
            //    SyntaxFactory.XmlText()
            //    .WithTextTokens(
            //        SyntaxFactory.TokenList(
            //            SyntaxFactory.XmlTextNewLine(
            //                SyntaxFactory.TriviaList(),
            //                "\n",
            //                "\n",
            //                SyntaxFactory.TriviaList())))}));
            //        var newMethodNode = oldMethodNode.WithModifiers(
            //SyntaxFactory.TokenList(
            //    new[]{
            //    SyntaxFactory.Token(
            //        SyntaxFactory.TriviaList(
            //            SyntaxFactory.Trivia(testDocumentation)), // xmldoc
            //            SyntaxKind.PublicKeyword, // original 1st token
            //            SyntaxFactory.TriviaList())
            //        //SyntaxFactory.Token(SyntaxKind.StaticKeyword)
            //    }));
            //var leadingTrivia = oldMethodNode.GetLeadingTrivia();
            //for (i = leadingTrivia.Count - 1; i >= 0; i--)
            //{
            //    leadingTrivia.RemoveAt(i);
            //}
            #endregion
        }
        string variableName = null;
        List<string> usedIn = null;
        foreach (var oldMethodNode in fields)
        {
            variableName = oldMethodNode.Declaration.Variables.First().Identifier.Text;
            if (dict.ContainsKey(variableName))
            {
                usedIn = dict[variableName];
            }
            else
            {
                continue;
            }
            CA.Prepend("/// ", usedIn);
            var doc = @"
/// <summary>
" + string.Join(Environment.NewLine, usedIn) + @"
/// </summary>
";
            var p = oldMethodNode.Parent;
            if (IsGlobalVariable(oldMethodNode))
            {
                var lt = SyntaxFactory.Comment(doc);
                var oldMethodNode2 = oldMethodNode.WithLeadingTrivia(SyntaxTriviaList.Create(lt));
                before = oldMethodNode.ToFullString();
                //root = root.ReplaceNode(oldMethodNode, oldMethodNode2);
                after = oldMethodNode2.ToFullString();
                sb = sb.Replace(before, after);
            }
        }
        var result = sb.ToString(); // root.ToFullString();
        return result;
    }
    /// <summary>
    /// VariableDeclarationSyntax->CSharpSyntaxNode
    /// FieldDeclarationSyntax->BaseFieldDeclarationSyntax->MemberDeclarationSyntax->CSharpSyntaxNode
    /// </summary>
    /// <param name="oldMethodNode"></param>
    /// <returns></returns>
    private static bool IsGlobalVariable(CSharpSyntaxNode oldMethodNode)
    {
        var parent = oldMethodNode.Parent;
        while (parent != null)
        {
            if (parent is BlockSyntax)
            {
                return false;
            }
            else if (parent is ClassDeclarationSyntax)
            {
                return true;
            }
            parent = parent.Parent;
        }
        return false;
    }
    /// <summary>
    /// Return also referenced projects (sunamo return also duo and Resources, although is not in sunamo)
    /// If I want what is only in sln, use AP.GetProjectsInSlnFile
    /// </summary>
    /// <param name="slnPath"></param>
    /// <param name="SkipUnrecognizedProjects"></param>
    public static
#if ASYNC
        async Task<List<Project>>
#else
    List<Project>
#endif
        GetAllProjectsInSolution(string slnPath, bool SkipUnrecognizedProjects = false)
    {
        var _ = typeof(Microsoft.CodeAnalysis.CSharp.Formatting.CSharpFormattingOptions);
        var msWorkspace = MSBuildWorkspace.Create();
        // Will include also referenced file
        msWorkspace.SkipUnrecognizedProjects = SkipUnrecognizedProjects;
        msWorkspace.LoadMetadataForReferencedProjects = false;
        //msWorkspace.Options.WithChangedOption(OptionKey.)
        //msWorkspace.Properties.
        //msWorkspace.Services.
        var solution =
#if ASYNC
            await msWorkspace.OpenSolutionAsync(slnPath);
#else
            // not have non async
            msWorkspace.OpenSolutionAsync(slnPath).Result;
#endif
        // Solution or project cant be dumped with Yaml
        //////DebugLogger.Instance.DumpObject("solution", solution, DumpProvider.Yaml);
        //foreach (var project in solution.Projects)
        //{
        //    ////DebugLogger.Instance.DumpObject("", project, DumpProvider.Yaml);
        //}
        return solution.Projects.ToList();
    }
    public static string WrapIntoClass(string code)
    {
        return RoslynNotTranslateAble.classDummy + " {" + code + "}";
    }
    /// <summary>
    /// A2 - first must be class or namespace
    /// </summary>
    /// <param name="code"></param>
    /// <param name="wrapIntoClass"></param>
    public static SyntaxTree GetSyntaxTree(string code, bool wrapIntoClass = false)
    {
        if (wrapIntoClass)
        {
            code = WrapIntoClass(code);
        }
        return CSharpSyntaxTree.ParseText(code);
    }
    public static ClassDeclarationSyntax GetClass(SyntaxNode root)
    {
        SyntaxNode sn;
        return GetClass(root, out sn);
    }
    public static SyntaxNode FindNode(SyntaxNode parent, SyntaxNode child, bool onlyDirectSub)
    {
        int dx;
        return FindNode(parent, child, onlyDirectSub, out dx);
    }
    /// <summary>
    /// Because of searching is very unreliable
    /// Into A1 I have to insert class when I search in classes. If I insert root/ns/etc, method will be return to me whole class, because its contain method
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="child"></param>
    public static SyntaxNode FindNode(SyntaxNode parent, SyntaxNode child, bool onlyDirectSub, out int dx)
    {
        dx = -1;
        #region MyRegion
        if (false)
        {
            if (onlyDirectSub)
            {
                // toto mi vratí např. jen public, nikoliv celou stránku
                //var ss = cl.ChildThatContainsPosition(cl.GetLocation().SourceSpan.Start);
                foreach (var item in parent.ChildNodes())
                {
                    // Má tu lokaci trochu dál protože obsahuje zároveň celou třídu
                    string l1 = item.GetLocation().ToString();
                    string l2 = child.GetLocation().ToString();
                    var s = child.Span;
                    var s2 = child.FullSpan;
                    var s3 = child.GetReference();
                    if (l1 == l2)
                    {
                        return item;
                    }
                }
            }
            else
            {
                return parent.FindNode(child.FullSpan, false, true).WithoutLeadingTrivia().WithoutTrailingTrivia();
            }
            return null;
        }
        #endregion
        var childType = child.GetType().FullName;
        var parentType = parent.GetType().FullName;
        SyntaxNode result = null;
        if (child is MethodDeclarationSyntax && parent is ClassDeclarationSyntax)
        {
            ClassDeclarationSyntax cl = (ClassDeclarationSyntax)parent;
            MethodDeclarationSyntax method = (MethodDeclarationSyntax)child;
            foreach (var item in cl.Members)
            {
                dx++;
                if (item is MethodDeclarationSyntax)
                {
                    var method2 = (MethodDeclarationSyntax)item;
                    bool same = true;
                    if (method.Identifier.Text != method2.Identifier.Text)
                    {
                        same = false;
                    }
                    if (same)
                    {
                        if (!RoslynComparer.Modifiers(method.Modifiers, method2.Modifiers))
                        {
                            same = false;
                        }
                    }
                    if (same)
                    {
                        string p1 = GetParameters(method.ParameterList);
                        string p2 = GetParameters(method2.ParameterList);
                        if (p1 != p2)
                        {
                            same = false;
                        }
                    }
                    if (same)
                    {
                        result = method2;
                        break;
                    }
                }
            }
        }
        else if (child is BaseTypeDeclarationSyntax && parent is NamespaceDeclarationSyntax)
        {
            var ns = (NamespaceDeclarationSyntax)parent;
            var method = (BaseTypeDeclarationSyntax)child;
            foreach (BaseTypeDeclarationSyntax item in ns.Members)
            {
                dx++;
                if (method.Identifier.Value == item.Identifier.Value)
                {
                    result = method;
                    break;
                }
            }
        }
        else if (child is NamespaceDeclarationSyntax && parent is CompilationUnitSyntax)
        {
            var ns = (CompilationUnitSyntax)parent;
            var method = (NamespaceDeclarationSyntax)child;
            foreach (NamespaceDeclarationSyntax item in ns.Members)
            {
                dx++;
                string fs1 = method.Name.ToFullString();
                string fs2 = item.Name.ToFullString();
                if (fs1 == fs2)
                {
                    result = method;
                    break;
                }
            }
        }
        else if (child is ClassDeclarationSyntax && parent is CompilationUnitSyntax)
        {
            var ns = (CompilationUnitSyntax)parent;
            var method = (ClassDeclarationSyntax)child;
            foreach (ClassDeclarationSyntax item in ns.Members)
            {
                dx++;
                string fs1 = method.Identifier.ToFullString();
                string fs2 = item.Identifier.ToFullString();
                if (fs1 == fs2)
                {
                    result = method;
                    break;
                }
            }
        }
        else
        {
            ThrowEx.NotImplementedCase(SHJoinPairs.JoinPairs("Parent", parent.ToFullString(), "Child", child.ToFullString()));
        }
        return result;
        //return nsShared.FindNode(cl.FullSpan, false, true).WithoutLeadingTrivia().WithoutTrailingTrivia();
    }
    /// <summary>
    /// IUN
    /// </summary>
    /// <param name="cl2"></param>
    /// <param name="method"></param>
    /// <param name="keepDirectives"></param>
    public static ClassDeclarationSyntax RemoveNode(ClassDeclarationSyntax cl2, SyntaxNode method, SyntaxRemoveOptions keepDirectives)
    {
        #region MyRegion
        //var children = method.ChildNodesAndTokens().ToList();
        //for (int i = children.Count() - 1; i >= 0; i--)
        //{
        //    var t = children[i].GetType().FullName;
        //    if (!(children[i] is MethodDeclarationSyntax))
        //    {
        //        int i2 = 0;
        //    }
        //    else
        //    {
        //        children.RemoveAt(i);
        //    }
        //}
        //return null;
        //FindNode()
        //cl2.Members.
        return null;
        #endregion
    }

    /// <summary>
    /// Return null if
    /// Into A2 insert first member of A1 - Namespace/Class
    /// A1 should be rather Tree/CompilationUnitSyntax than Node because of Members - Node.ChildNodes.First is usings
    /// </summary>
    /// <param name="root"></param>
    /// <param name="ns"></param>
    public static ClassDeclarationSyntax GetClass(SyntaxNode root2, out SyntaxNode ns)
    {
        ns = null;
        ClassDeclarationSyntax helloWorldDeclaration = null;
        //(CompilationUnitSyntax)
        var root = root2;
        //var root = (CompilationUnitSyntax)tree.GetRoot();
        // Returns usings and ns
        var childNodes = root.ChildNodes();
        if (childNodes.OfType<ClassDeclarationSyntax>().Count() > 1)
        {
            return null;
        }
        SyntaxNode firstMember = null;
        firstMember = ChildNodes.NamespaceOrClass(root);
        //firstMember = (SyntaxNode)root.ChildNodes().OfType<NamespaceDeclarationSyntax>().FirstOrNull();
        //if (firstMember == null)
        //{
        //    firstMember = root.ChildNodes().OfType<ClassDeclarationSyntax>().First();
        //}
        if (firstMember is NamespaceDeclarationSyntax)
        {
            ns = (NamespaceDeclarationSyntax)firstMember;
            int i = 0;
            var fm = ((NamespaceDeclarationSyntax)ns).Members[i++];
            while (fm.GetType() != typeof(ClassDeclarationSyntax))
            {
                fm = ((NamespaceDeclarationSyntax)ns).Members[i++];
            }
            helloWorldDeclaration = (ClassDeclarationSyntax)fm;
        }
        else if (firstMember is ClassDeclarationSyntax)
        {
            helloWorldDeclaration = (ClassDeclarationSyntax)firstMember;
            // keep ns as null
            //ns = nu;
        }
        else
        {
            ThrowEx.NotImplementedCase(firstMember);
        }
        return helloWorldDeclaration;
    }
    public static List<string> HeadersOfMethod(IList<SyntaxNode> enumerable, bool alsoModifier = true)
    {
        List<string> clMethodsSharedNew = new List<string>();
        foreach (MethodDeclarationSyntax m in enumerable)
        {
            string h = GetHeaderOfMethod(m, alsoModifier);
            clMethodsSharedNew.Add(h);
        }
        return clMethodsSharedNew;
    }
    public static SyntaxNode WithoutAllTrivia(SyntaxNode sn)
    {
        return sn.WithoutLeadingTrivia().WithoutTrailingTrivia();
    }
    public static string GetHeaderOfMethod(MethodDeclarationSyntax m, bool alsoModifier = true)
    {
        m = m.WithoutTrivia();
        string addAfter = " ";
        StringBuilder sb = new();
        if (alsoModifier)
        {
            sb.AddItem(addAfter, RoslynParser.GetAccessModifiers(m.Modifiers));
        }
        bool isStatic = IsStatic(m.Modifiers);
        if (isStatic)
        {
            sb.AddItem(addAfter, "static");
        }
        sb.AddItem(addAfter, m.ReturnType.WithoutTrivia().ToFullString());
        sb.AddItem(addAfter, m.Identifier.WithoutTrivia().Text);
        // in brackets, newline
        //string parameters = m.ParameterList.ToFullString();
        // only text
        string p2 = GetParameters(m.ParameterList);
        sb.AddItem(addAfter, "(" + p2 + ")");
        string s = sb.ToString();
        return s;
    }
    /// <summary>
    /// CompilationUnitSyntax is also SyntaxNode
    /// After line must be A1 = A2 or some RoslynHelper.Get* methods
    /// </summary>
    /// <param name="cl"></param>
    /// <param name="cl2"></param>
    /// <param name="root"></param>
    public static void ReplaceNode(SyntaxNode cl, SyntaxNode cl2, out SyntaxNode root)
    {
        ReplaceNode<SyntaxNode>(cl, cl2, out root);
    }
    /// <summary>
    /// CompilationUnitSyntax is also SyntaxNode
    /// After line must be A1 = A2
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="cl"></param>
    /// <param name="cl2"></param>
    public static T ReplaceNode<T>(SyntaxNode cl, SyntaxNode cl2, out SyntaxNode root) where T : SyntaxNode
    {
        bool first = true;
        T result = default;
        while (cl is SyntaxNode)
        {
            if (cl.Parent == null)
            {
                break;
            }
            cl = cl.Parent.ReplaceNode(cl, cl2);
            if (first)
            {
                result = (T)cl2;
                first = false;
            }
            cl2 = cl;
            cl = cl.Parent;
        }
        root = cl2;
        if (result == null)
        {
        }
        return result;
    }
    private static string GetParameters(ParameterListSyntax parameterList)
    {
        var c1 = parameterList.ChildNodes();
        //var c2 = parameterList.ChildNodesAndTokens();
        StringBuilder sb = new StringBuilder();
        foreach (var item in c1)
        {
            sb.Append(item.ToFullString() + ", ");
        }
        string r = SH.RemoveLastLetters(sb.ToString(), 2);
        return r;
    }
    public static bool IsStatic(SyntaxTokenList modifiers)
    {
        return modifiers.Where(e => e.Value.ToString() == "static").Count() > 0;
    }
    public static string NameWithoutGeneric(string name)
    {
        return SHParts.RemoveAfterFirst(name, "<");
    }
}