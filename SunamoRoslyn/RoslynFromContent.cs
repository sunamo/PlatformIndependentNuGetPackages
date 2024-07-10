namespace SunamoRoslyn;


public class RoslynFromContent
{
    public static async Task<List<ClassDeclarationSyntax>> AttributesClasses(string code, SelectiveArgs a = null)
    {
        var d = await ArgsClasses(code);
        List<ClassDeclarationSyntax> result = new List<ClassDeclarationSyntax>();
        d = d.Where(d => d.Identifier.ToString().EndsWith("Attributte")).ToList();
        return d;
    }
    public static async Task<List<ClassDeclarationSyntax>> ArgsClasses(string code, SelectiveArgs a = null)
    {
        return await Classes(code);
    }
    public static async Task<List<ClassDeclarationSyntax>> Classes(string code, SelectiveArgs a = null)
    {
        var c = new DelegatesCollector();
        await VisitWithCollector(code, c);
        return c.Classes;
    }
    public static async Task<List<RoslynFromContentResult>> Selective(string code, SelectiveArgs a)
    {
        var c = new DelegatesCollector();
        await VisitWithCollector(code, c);
        List<RoslynFromContentResult> result = new List<RoslynFromContentResult>();
        if (a.Classes)
        {
            result.AddRange(WrapMany(c.Classes));
        }
        else if (a.Interfaces)
        {
            result.AddRange(WrapMany(c.Interfaces));
        }
        else if (a.Records)
        {
            result.AddRange(WrapMany(c.Records));
        }
        else if (a.Structs)
        {
            result.AddRange(WrapMany(c.Structs));
        }
        else if (a.Delegates)
        {
            result.AddRange(WrapMany(c.Delegates));
        }
        return result;
    }
    private static IEnumerable<RoslynFromContentResult> WrapMany<T>(List<T> classes)
    {
        foreach (var item in classes)
        {
            yield return new RoslynFromContentResult { RoslynObject = item };
        }
    }
    public static async Task<List<InterfaceDeclarationSyntax>> Interfaces(string code, SelectiveArgs a = null)
    {
        var c = new DelegatesCollector();
        await VisitWithCollector(code, c);
        return c.Interfaces;
    }
    public static async Task<List<DelegateDeclarationSyntax>> Delegates(string code, SelectiveArgs a = null)
    {
        var c = new DelegatesCollector();
        await VisitWithCollector(code, c);
        var s = c.Delegates.Count;
        return c.Delegates;
    }
    private static async Task VisitWithCollector(string code, DelegatesCollector c)
    {
        var tree = CSharpSyntaxTree.ParseText(code);
        var root = (CompilationUnitSyntax)tree.GetRoot();
        //var m = root.Members[0].DescendantNodes();
        c.Visit(root);
    }
}
