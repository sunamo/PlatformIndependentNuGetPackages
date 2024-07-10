
namespace SunamoRuleset;
using SunamoRuleset._sunamo;

using System.IO;

public class RulesetManager
{
    private static Type type = typeof(RulesetManager);
    private readonly string Description;
    private readonly string Name;

    private readonly string pathRuleset;
    public Dictionary<RulesetTypes, List<RulesetRule>> rules = new Dictionary<RulesetTypes, List<RulesetRule>>();
    private readonly string ToolsVersion;

    public RulesetManager(string pathRuleset)
    {
        this.pathRuleset = pathRuleset;

        var c = File.ReadAllText(pathRuleset);
        var xd = XDocument.Parse(c);
        var root = xd.Root;
        var rules2 = xd.Root.Descendants().Where(e => e.Name == "Rules");
        var type = RulesetTypes.None;

        Name = XHelper.Attr(root, "Name");
        Description = XHelper.Attr(root, "Description");
        ToolsVersion = XHelper.Attr(root, "ToolsVersion");

        var cantBeAdded = new List<string>();

        foreach (var item in rules2)
        {
            var analyzerId = AttrRules(item, "AnalyzerId");

            type = EnumHelper.Parse(analyzerId, RulesetTypes.None);

            if (type == RulesetTypes.None)
            {
                var ruleNamespace = AttrRules(item, "RuleNamespace");
                type = EnumHelper.Parse(ruleNamespace, RulesetTypes.None);
            }

            if (type == RulesetTypes.None)
            {
                cantBeAdded.Add(item.ToString());
                continue;
            }

            var rules3 = item.Descendants().Where(d => d.Name == "Rule");
            foreach (var item2 in rules3)
            {
                var rulesetRule = new RulesetRule();
                rulesetRule.Parse(item2);
                DictionaryHelper.AddOrCreate(rules, type, rulesetRule);
            }
        }
    }

    private string AttrRules(XElement item, string v)
    {
        return XHelper.Attr(item, v).Replace(AllStrings.dot, string.Empty);
    }

    public static RulesetTypes Type(string rule)
    {
        if (rule.StartsWith("CS")) return RulesetTypes.MicrosoftCodeAnalysisCSharp;

        if (RulesetValues.rulesMicrosoftNetCoreAnalyzers.Contains(rule))
            return RulesetTypes.MicrosoftNetCoreAnalyzers;
        if (RulesetValues.rulesMicrosoftCodeQuality.Contains(rule)) return RulesetTypes.MicrosoftCodeQualityAnalyzers;
        return RulesetTypes.None;
    }

    public string ConvertToDotSyntax(RulesetTypes rtype)
    {
        switch (rtype)
        {
            case RulesetTypes.MicrosoftCodeQualityAnalyzers:
                return "Microsoft.CodeQuality.Analyzers";
            case RulesetTypes.MicrosoftNetCoreAnalyzers:
                return "Microsoft.NetCore.Analyzers";
            case RulesetTypes.MicrosoftCodeAnalysisCSharp:
                return "Microsoft.CodeAnalysis.CSharp";
            case RulesetTypes.None:
                // Is calling only in save, return null
                return null;
            default:
                ThrowEx.NotImplementedCase(rtype);
                break;
        }

        return null;
    }

    public void Save()
    {
        XmlGenerator xg = new XmlGenerator();

        xg.WriteXmlDeclaration();

        xg.WriteTagWithAttrs(RulesetConsts.RuleSet, RulesetConsts.Name, Name, RulesetConsts.Description, Description,
            RulesetConsts.ToolsVersion, ToolsVersion);
        foreach (var item in rules)
        {
            var dotSyntax = ConvertToDotSyntax(item.Key);

            xg.WriteTagWithAttrs(RulesetConsts.Rules, RulesetConsts.AnalyzerId, dotSyntax, RulesetConsts.RuleNamespace,
                dotSyntax);
            foreach (var rule in item.Value) xg.WriteRaw(rule.ToXml());

            xg.TerminateTag(RulesetConsts.Rules);
        }

        xg.TerminateTag(RulesetConsts.RuleSet);

        File.WriteAllText(pathRuleset, xg.ToString());
    }
}
