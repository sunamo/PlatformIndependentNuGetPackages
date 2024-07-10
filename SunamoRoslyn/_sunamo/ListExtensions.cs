using SunamoRoslyn._sunamo;
using SunamoRoslyn._sunamo;
namespace SunamoRoslyn._sunamo;
internal static class ListExtensions
{
    internal static string ChangeFilename(string filepath, string newFilename)
    {
        // filepath = @"photo\myFolder\image.jpg";
        // newFileName = @"image-resize";
        string dir = Path.GetDirectoryName(filepath);    // @"photo\myFolder"
        string ext = Path.GetExtension(filepath);        // @".jpg"
        return Path.Combine(dir, newFilename + ext); // @"photo\myFolder\image-resize.jpg"
    }
    internal static async Task<List<T>> RemoveAllAlsoFromFile<T>(this List<T> cl, Predicate<T> match, string path) where T : BaseTypeDeclarationSyntax
    {
        var directoryName = Path.GetDirectoryName(path);
        var toRemove = cl.FindAll(match);
        BaseNamespaceDeclarationSyntax b = null;
        List<SyntaxNode> nodesToRemove = new List<SyntaxNode>();
        for (int i = 0; i < toRemove.Count; i++)
        {
            var item = toRemove[i];
            // remove class from namespace with roslyn
            //var t = item.Parent.GetType();
            b = (BaseNamespaceDeclarationSyntax)item.Parent;
            // Je nutné znát název protože až pak můžu importovat namespace
            nodesToRemove.Add(item);
            //b = (BaseNamespaceDeclarationSyntax)item.Parent.RemoveNode(item, SyntaxRemoveOptions.AddElasticMarker);
            // oba 2 dědí od BaseNamespaceDeclarationSyntax
            //FileScopedNamespaceDeclarationSyntax fileScopedNamespaceDeclarationSyntax;
            //NamespaceDeclarationSyntax namespaceDeclarationSyntax;
            var newFp = ChangeFilename(path, item.Identifier.Text);
            await TFCsFormat.WriteAllText(newFp, item.ToString());
        }
        cl.RemoveAll(match);
        DelegatesCollector dc = null;
        dc = new DelegatesCollector();
        dc.Visit(b);
#if DEBUG
        if (path.Contains("OutRef"))
        {
        }
#endif
        foreach (BaseTypeDeclarationSyntax item in nodesToRemove)
        {
            // tady je problém že 
            var t = item.GetType();
            if (t == TypesRoslyn.Class)
            {
                var first = dc.Classes.First(d => ((dynamic)d).Identifier.Text == item.Identifier.Text);
                b = b.RemoveNode(first, SyntaxRemoveOptions.AddElasticMarker);
                dc = new DelegatesCollector();
                dc.Visit(b);
            }
            else if (t == TypesRoslyn.Delegate)
            {
                var first = dc.Delegates.First(d => ((dynamic)d).Identifier.Text == item.Identifier.Text);
                b = b.RemoveNode(first, SyntaxRemoveOptions.AddElasticMarker);
                dc = new DelegatesCollector();
                dc.Visit(b);
            }
            else if (t == TypesRoslyn.Enum)
            {
                var first = dc.Enums.First(d => ((dynamic)d).Identifier.Text == item.Identifier.Text);
                b = b.RemoveNode(first, SyntaxRemoveOptions.AddElasticMarker);
                dc = new DelegatesCollector();
                dc.Visit(b);
            }
            else if (t == TypesRoslyn.Interface)
            {
                var first = dc.Interfaces.First(d => ((dynamic)d).Identifier.Text == item.Identifier.Text);
                b = b.RemoveNode(first, SyntaxRemoveOptions.AddElasticMarker);
                dc = new DelegatesCollector();
                dc.Visit(b);
            }
            else if (t == TypesRoslyn.Record)
            {
                var first = dc.Records.First(d => ((dynamic)d).Identifier.Text == item.Identifier.Text);
                b = b.RemoveNode(first, SyntaxRemoveOptions.AddElasticMarker);
                dc = new DelegatesCollector();
                dc.Visit(b);
            }
            //b = b.RemoveNode(item, SyntaxRemoveOptions.AddElasticMarker);
        }
        var identifier = cl.First().Identifier.Text;
        var newFp2 = ChangeFilename(path, identifier);
        var ts = b.ToString();
        await TFCsFormat.WriteAllText(newFp2, ts);
        return cl;
    }
    internal static async Task<List<T>> RemoveAlsoFromFile<T>(this List<T> cl, T item, string path) where T : BaseTypeDeclarationSyntax
    {
        var directoryName = Path.GetDirectoryName(path);
        var newFp = ChangeFilename(path, item.Identifier.Text);
        await TFCsFormat.WriteAllText(newFp, item.ToString());
        cl.Remove(item);
        return cl;
    }
}
