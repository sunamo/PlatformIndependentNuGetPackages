namespace SunamoHelpers.Crypting;

/// <summary>
/// Shared utility methods used by multiple encryption classes.
/// </summary>
public class UtilsNonNetStandard
{
    /// <summary>
    /// Retrieves the content of a named element from an XML string.
    /// </summary>
    /// <param name="xml">The XML string to search in.</param>
    /// <param name="element">The element name to find.</param>
    public static string GetXmlElement(string xml, string element)
    {
        Match? match = null;
        match = Regex.Match(xml, "<" + element + ">(?<Element>[^>]*)</" + element + ">", RegexOptions.IgnoreCase);
        if (match == null)
        {
            throw new Exception(Translate.FromKey(XlfKeys.CouldNotFind) + " " + element + "></" + element + "  " + Translate.FromKey(XlfKeys.inProvidedPublicKeyXML) + ".");
        }
        return match.Groups["Element"].ToString();
    }

    /// <summary>
    /// Returns the specified string value from the application .config file.
    /// </summary>
    /// <param name="key">The config key to retrieve.</param>
    /// <param name="isRequired">Whether the key is required (throws if missing).</param>
    public static string GetConfigString(string key, bool isRequired)
    {
        string? configValue = null;
        if (configValue == null)
        {
            if (isRequired)
            {
                throw new Exception("key " + key + "  is missing from .config file");
            }
            else
            {
                return "";
            }
        }
        else
        {
            return configValue;
        }
    }

    /// <summary>
    /// Returns an XML config key element string in the format: &lt;add key="..." value="..." /&gt;
    /// </summary>
    /// <param name="key">The config key name.</param>
    /// <param name="value">The config key value.</param>
    public static string WriteConfigKey(string key, string value)
    {
        string format = "<add key=\"{0}\" value=\"{1}\" />" + Environment.NewLine;
        return string.Format(format, key, value);
    }

    /// <summary>
    /// Returns an XML element string with the specified name and value.
    /// </summary>
    /// <param name="element">The element name.</param>
    /// <param name="value">The element value.</param>
    public static string WriteXmlElement(string element, string value)
    {
        string format = "<{0}>{1}</{0}>" + Environment.NewLine;
        return string.Format(format, element, value);
    }

    /// <summary>
    /// Returns an opening or closing XML tag for the specified element.
    /// </summary>
    /// <param name="element">The element name.</param>
    /// <param name="isClosing">Whether to return a closing tag.</param>
    public static string WriteXmlNode(string element, bool isClosing)
    {
        string? format = null;
        if (isClosing)
        {
            format = "</{0}>" + Environment.NewLine;
        }
        else
        {
            format = "<{0}>" + Environment.NewLine;
        }
        return string.Format(format, element);
    }
}
