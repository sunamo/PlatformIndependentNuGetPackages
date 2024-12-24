namespace SunamoRoslyn;
public class RoslynParents
{
    Dictionary<string, SyntaxNode> n = new Dictionary<string, SyntaxNode>();

    public void Add(string where, SyntaxNode n)
    {
        //this.n.Add(where, n);
        if (n != null)
        {
            //////DebugLogger.Instance.WriteLine(where + SH.NullToStringOrDefault(n.Parent, ("not null")));
        }

    }
}