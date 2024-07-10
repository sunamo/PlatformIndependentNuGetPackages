namespace SunamoXliffParser;




public static class XmlUtil
{
    private static readonly Type type = typeof(XmlUtil);

    public static string GetAttributeIfExists(XElement node, string name)
    {
        if (node == null)
        {
            ThrowEx.IsNull(nameof(node));
        }

        XAttribute a = node.Attribute(name);
        return a != null ? a.Value : string.Empty;
    }

    public static int GetIntAttributeIfExists(XElement node, string name)
    {
        if (node == null)
        {
            ThrowEx.IsNull(nameof(node));
        }

        XAttribute a = node.Attribute(name);
        return a != null ? int.Parse(a.Value) : 0;
    }

    public static string NormalizeLineBreaks(string s)
    {
        return string.IsNullOrWhiteSpace(s) ? string.Empty : s.Replace("\r", string.Empty);
    }

    public static string DeNormalizeLineBreaks(string s)
    {
        return string.IsNullOrWhiteSpace(s) ? string.Empty : NormalizeLineBreaks(s).Replace("\r", "\r\n");
    }
}
