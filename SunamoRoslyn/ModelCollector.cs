namespace SunamoRoslyn;
public class ModelCollector : CSharpSyntaxWalker
{
    public Dictionary<string, List<string>> Models { get; } = new Dictionary<string, List<string>>();
    public override void VisitPropertyDeclaration(PropertyDeclarationSyntax node)
    {
        var classnode = node.Parent as ClassDeclarationSyntax;
        if (!Models.ContainsKey(classnode.Identifier.ValueText))
        {
            Models.Add(classnode.Identifier.ValueText, new List<string>());
        }
        Models[classnode.Identifier.ValueText].Add(node.Identifier.ValueText);
    }
}
