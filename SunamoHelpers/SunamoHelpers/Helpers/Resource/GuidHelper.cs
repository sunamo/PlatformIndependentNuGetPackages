namespace SunamoHelpers.Helpers.Resource;

/// <summary>
/// Provides helper methods for GUID string formatting and manipulation.
/// </summary>
public class GuidHelper
{
    /// <summary>
    /// Removes all dash characters from a GUID string.
    /// </summary>
    /// <param name="guid">The GUID string to process.</param>
    public static string RemoveDashes(string guid)
    {
        return guid.Replace("-", "");
    }

    /// <summary>
    /// Adds dashes to a 32-character GUID string in the standard 8-4-4-4-12 format.
    /// Returns the input unchanged if it already contains dashes.
    /// </summary>
    /// <param name="guid">The GUID string to format.</param>
    public static string AddDashes(string guid)
    {
        if (guid.Contains("-"))
        {
            return guid;
        }
        guid = guid.Insert(8, "-");
        guid = guid.Insert(13, "-");
        guid = guid.Insert(18, "-");
        guid = guid.Insert(23, "-");
        return guid;
    }

    /// <summary>
    /// Generates a newline-separated list of GUIDs where each GUID consists of a single repeated character (0-9, a-f).
    /// </summary>
    public static string GuidsOnlySingleLetter()
    {
        List<string> list = new List<string>();
        for (int i = 0; i < 10; i++)
        {
            var text = i.ToString();
            text = text.PadLeft(32, text[0]);

            list.Add(AddDashes(text));
        }

        for (char i = 'a'; i < 'g'; i++)
        {
            var text = i.ToString();
            text = text.PadLeft(32, text[0]);

            list.Add(AddDashes(text));
        }

        return string.Join(Environment.NewLine, list);
    }
}
