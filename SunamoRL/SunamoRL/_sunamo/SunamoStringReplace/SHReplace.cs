namespace SunamoRL._sunamo.SunamoStringReplace;

/// <summary>
/// String replacement utility methods.
/// </summary>
internal class SHReplace
{
    /// <summary>
    /// Replaces the first occurrence of a pattern in the text.
    /// </summary>
    /// <param name="text">The input text.</param>
    /// <param name="what">The pattern to search for.</param>
    /// <param name="replacement">The replacement string.</param>
    internal static string ReplaceOnce(string text, string what, string replacement)
    {
        return new Regex(what).Replace(text, replacement, 1);
    }

    /// <summary>
    /// Replaces all specified strings in the text with the replacement.
    /// </summary>
    /// <param name="text">The input text.</param>
    /// <param name="replacement">The replacement string.</param>
    /// <param name="what">The strings to replace.</param>
    internal static string ReplaceAll(string text, string replacement, params string[] what)
    {
        foreach (var item in what)
        {
            if (string.IsNullOrEmpty(item))
            {
                return text;
            }
        }

        foreach (var item in what)
        {
            text = text.Replace(item, replacement);
        }
        return text;
    }
}
