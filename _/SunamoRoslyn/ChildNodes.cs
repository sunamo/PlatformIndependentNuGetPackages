namespace SunamoRoslyn;

public class ChildNodes
{
    /// <summary>
    /// If will not working, try MethodsDescendant()
    /// </summary>
    /// <param name="n"></param>
    /// <returns></returns>
    public static IList<MethodDeclarationSyntax> Methods(SyntaxNode n)
    {
        return n.ChildNodes().OfType<MethodDeclarationSyntax>().ToList();
    }

    /// <summary>
    /// If will not working, try Methods()
    /// </summary>
    /// <param name="n"></param>
    /// <returns></returns>
    public static IList<MethodDeclarationSyntax> MethodsDescendant(SyntaxNode n)
    {
        return n.DescendantNodes().OfType<MethodDeclarationSyntax>().ToList();
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="n"></param>
    /// <returns></returns>
    public static IList<FieldDeclarationSyntax> FieldsDescendant(SyntaxNode n)
    {
        return n.DescendantNodes().OfType<FieldDeclarationSyntax>().ToList();
    }

    /// <summary>
    /// VariablesDescendant - only int a1.
    /// FieldsDescendant - whole public int a1. when I want to add xml comment like to have be
    /// </summary>
    /// <param name="n"></param>
    /// <returns></returns>
    public static IList<VariableDeclarationSyntax> VariablesDescendant(SyntaxNode n)
    {
        return n.DescendantNodes().OfType<VariableDeclarationSyntax>().ToList();
    }

    public static MethodDeclarationSyntax Method(ClassDeclarationSyntax cl, string item)
    {
        var methodToFind = RoslynParser.Method(item);

        var founded = RoslynHelper.FindNode(cl, methodToFind, true);
        //var methods =  Methods(cl);
        return (MethodDeclarationSyntax)founded;
    }

    public static NamespaceDeclarationSyntax Namespace(SyntaxNode n)
    {
        if (n is NamespaceDeclarationSyntax)
        {
            return (NamespaceDeclarationSyntax)n;
        }
        return (NamespaceDeclarationSyntax)n.ChildNodes().OfType<NamespaceDeclarationSyntax>().ToList().FirstOrDefault();
    }

    public static ClassDeclarationSyntax Class(SyntaxNode n)
    {
        if (n is ClassDeclarationSyntax)
        {
            return (ClassDeclarationSyntax)n;
        }
        var r = n.ChildNodes().OfType<ClassDeclarationSyntax>();
        return (ClassDeclarationSyntax)r.ToList().FirstOrDefault();
    }

    public static SyntaxNode NamespaceOrClass(SyntaxNode root)
    {
        var ns = Namespace(root);
        if (ns != null)
        {
            return ns;
        }
        return Class(root);
    }
}
