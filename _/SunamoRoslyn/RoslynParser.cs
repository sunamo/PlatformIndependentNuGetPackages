namespace SunamoRoslyn;
using SunamoRoslyn._public;

/// <summary>
/// RoslynParser - use roslyn classes
/// RoslynParserText - no use roslyn classes, only text or indexer
/// </summary>
public class RoslynParser
{
    // TODO: take also usings

    static Type type = null;

    public static bool IsCSharpCode(string input)
    {
        SyntaxTree d = null;
        try
        {
            d = CSharpSyntaxTree.ParseText(input);
        }
        catch (Exception ex)
        {
            // throwed Method not found: 'Boolean Microsoft.CodeAnalysis.StackGuard.IsInsufficientExecutionStackException(System.Exception)'.' for non cs code

        }
        var s = d.GetText().ToString();
        return d != null;
    }

    public static MethodDeclarationSyntax Method(string item)
    {
        item = item + "{}";
        //StringReader sr = new StringReader(item);
        //CSharpSyntaxNode.DeserializeFrom();
        var tree = CSharpSyntaxTree.ParseText(item);
        var root = tree.GetRoot();
        //return (MethodDeclarationSyntax)root.DescendantNodesAndTokensAndSelf().OfType<MethodDeclarationSyntax>().FirstOrNull();

        // Only root I cannot cast -> cannot cast CSU to MethodDeclSyntax

        var childNodes = root.ChildNodes();
        return (MethodDeclarationSyntax)childNodes.First();
    }





    /// <summary>
    /// Úplně nevím k čemu toto mělo sloužit.
    /// Read comments inside
    /// </summary>
    /// <param name="folderFrom"></param>
    /// <param name="folderTo"></param>
    public
#if ASYNC
async Task<List<string>>
#else
List<string>
#endif
GetCodeOfElementsClass(string folderFrom, string folderTo)
    {
        FS.WithEndSlash(ref folderFrom);
        FS.WithEndSlash(ref folderTo);

        var files = Directory.GetFiles(folderFrom, "*.aspx.cs", SearchOption.TopDirectoryOnly);
        foreach (var file in files)
        {
            SyntaxTree tree = CSharpSyntaxTree.ParseText(
#if ASYNC
await
#endif
File.ReadAllTextAsync(file));

            List<string> result = new List<string>();
            // Here probable it mean SpaceName, ale když není namespace, uloží třídu
            SyntaxNode sn;
            var cl = RoslynHelper.GetClass(tree.GetRoot(), out sn);

            SyntaxAnnotation saSn = new SyntaxAnnotation();
            sn = sn.WithAdditionalAnnotations(saSn);

            SyntaxAnnotation saCl = new SyntaxAnnotation();
            cl = cl.WithAdditionalAnnotations(saCl);
            //ClassDeclarationSyntax cl2 = cl.Parent.)

            var root = tree.GetRoot();

            int count = cl.Members.Count;
            for (int i = count - 1; i >= 0; i--)
            {
                var item = cl.Members[i];
                //cl.Members.RemoveAt(i);
                //cl.Members.Remove(item);
                cl = cl.RemoveNode(item, SyntaxRemoveOptions.KeepEndOfLine);
            }
            // záměna namespace za class pak dělá problémy tady
            sn = sn.TrackNodes(cl);
            root = root.TrackNodes(sn);

            var d = sn.SyntaxTree.ToString();
            var fileTo = file.Replace(folderFrom, folderTo);
            await File.WriteAllTextAsync(fileTo, d);
        }

        return null;
    }
    private SyntaxNode FindTopParent(SyntaxNode cl)
    {
        var result = cl;
        while (result.Parent != null)
        {
            result = result.Parent;
        }
        return result;
    }

    ///// <summary>
    /////
    ///// </summary>
    ///// <param name="root"></param>
    ///// <param name="wrapIntoClass"></param>
    //public static ABCRoslyn GetVariablesInCsharp(SyntaxNode root)
    //{
    //    List<string> lines = new List<string>();
    //    List<string> usings;

    //    return GetVariablesInCsharp(root);
    //}

    /// <summary>
    /// A1 by mohl být SyntaxNode kdybych nepotřeboval získávat globální usingy
    /// Prop Usings je pouze ve CompilationUnitSyntax
    /// </summary>
    /// <param name="root"></param>
    /// <param name="lines"></param>
    /// <param name="usings"></param>
    public static ABCRoslyn GetVariablesInCsharp(CompilationUnitSyntax root, out List<string> usings)
    {
        ABCRoslyn result = new ABCRoslyn();
        usings = CSharpHelper.Usings(root);

        ClassDeclarationSyntax helloWorldDeclaration = null;
        helloWorldDeclaration = RoslynHelper.GetClass(root);

        var variableDeclarations = helloWorldDeclaration.DescendantNodes().OfType<FieldDeclarationSyntax>();

        foreach (var variableDeclaration in variableDeclarations)
        {
            //CL.WriteLine(variableDeclaration.Variables.First().Identifier.);
            //CL.WriteLine(variableDeclaration.Variables.First().Identifier.Value);
            string variableName = variableDeclaration.Declaration.Type.ToString();
            variableName = SHReplace.ReplaceOnce(variableName, "global::", "");
            int lastIndex = variableName.LastIndexOf('.');
            string ns, cn;
            SH.GetPartsByLocation(out ns, out cn, variableName, lastIndex);
            usings.Add(ns);
            // in key type, in value name
            result.Add(ABRoslyn.Get(cn, variableDeclaration.Declaration.Variables.First().Identifier.Text));

        }

        usings = usings.Distinct().ToList();

        return result;
    }



    public static string GetAccessModifiers(SyntaxTokenList modifiers)
    {
        foreach (var item in modifiers)
        {
            switch (item.Kind())
            {
                case SyntaxKind.PublicKeyword:

                case SyntaxKind.PrivateKeyword:

                case SyntaxKind.InternalKeyword:

                case SyntaxKind.ProtectedKeyword:
                    return item.WithoutTrivia().ToFullString();
            }

        }
        return string.Empty;
    }

    /// <summary>
    /// return declaredVariables, assignedVariables
    /// A1 can be string or CompilationUnitSyntax
    /// </summary>
    /// <param name="code"></param>
    /// <returns></returns>
    public static Tuple<List<string>, List<string>> ParseVariables(object code)
    {
        SyntaxNode root = null;
        string code2 = null;

        //MethodDeclarationSyntax;

        root = SyntaxNodeFromObjectOrString(code);

        var variableDeclarations = root.DescendantNodes().OfType<VariableDeclarationSyntax>();
        var variableAssignments = root.DescendantNodes().OfType<AssignmentExpressionSyntax>();

        List<string> declaredVariables = new List<string>(variableDeclarations.Count());
        List<string> assignedVariables = new List<string>(variableAssignments.Count());

        foreach (var variableDeclaration in variableDeclarations)
            declaredVariables.Add(variableDeclaration.Variables.First().Identifier.Value.ToString());

        foreach (var variableAssignment in variableAssignments)
            assignedVariables.Add(variableAssignment.Left.ToString());

        return new Tuple<List<string>, List<string>>(declaredVariables, assignedVariables);
    }

    public static SyntaxNode SyntaxNodeFromObjectOrString(object code)
    {
        SyntaxNode root = null;

        if (code is SyntaxNode)
        {
            root = (SyntaxNode)code;
        }
        else if (code is string)
        {
            SyntaxTree tree = CSharpSyntaxTree.ParseText(code.ToString());
            root = tree.GetRoot();
        }
        else
        {
            ThrowEx.NotImplementedCase("else");
        }

        return root;
    }

    public static Dictionary<string, List<string>> GetVariablesInEveryMethod(string s)
    {
        Dictionary<string, List<string>> m = new Dictionary<string, List<string>>();

        var tree = CSharpSyntaxTree.ParseText(s);
        var root = tree.GetRoot();

        IList<MethodDeclarationSyntax> methods = root
          .DescendantNodes()
          .OfType<MethodDeclarationSyntax>().ToList();

        foreach (var method in methods)
        {
            var v = ParseVariables(method);
            m.Add(method.Identifier.Text, v.Item2);
        }

        return m;
    }
}