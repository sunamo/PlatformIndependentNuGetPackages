namespace SunamoExtensions;

public static class XmlNodeListExtensions
{
    #region For easy copy from XmlNodeListExtensions.cs

    public static bool Contains(this XmlNodeList e, XmlNode n)
    {
        foreach (var item in e)
            if (item == n)
                return true;
        return false;
    }

    public static XmlNode First(this XmlNodeList e, string n)
    {
        foreach (XmlNode item in e)
            if (item.Name == n)
                return item;
        return null;
    }

    public static List<XmlNode> WithName(this XmlNodeList e, string n)
    {
        var result = new List<XmlNode>();
        foreach (XmlNode item in e)
            if (item.Name == n)
                result.Add(item);
        return result;
    }

    #endregion
}