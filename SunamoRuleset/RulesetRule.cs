
namespace SunamoRuleset;
using SunamoRuleset._sunamo;

public class RulesetRule
{
    public string Id = null;
    public RulesetActions Action = RulesetActions.None;

    public void Parse(XElement node)
    {
        Id = XHelper.Attr(node, "Id");
        Action = EnumHelper.Parse<RulesetActions>(XHelper.Attr(node, RulesetConsts.Action), RulesetActions.None);
    }

    public string ToXml()
    {
        return "<Rule Id=\"" + Id + "\" Action=\"" + Action + "\" />";
    }
}
