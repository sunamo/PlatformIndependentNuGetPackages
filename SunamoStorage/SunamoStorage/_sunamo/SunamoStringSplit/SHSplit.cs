namespace SunamoStorage._sunamo.SunamoStringSplit;

/// <summary>
/// String splitting utility methods.
/// </summary>
internal class SHSplit
{
    /// <summary>
    /// Splits the text by character delimiters.
    /// </summary>
    /// <param name="text">The text to split.</param>
    /// <param name="delimiters">The character delimiters.</param>
    internal static List<string> SplitChar(string text, params char[] delimiters)
    {
        return text.Split(delimiters).ToList();
    }

    /// <summary>
    /// Splits the text by string delimiters, removing empty entries.
    /// </summary>
    /// <param name="text">The text to split.</param>
    /// <param name="delimiters">The string delimiters.</param>
    internal static List<string> Split(string text, params string[] delimiters)
    {
        return text.Split(delimiters, StringSplitOptions.RemoveEmptyEntries).ToList();
    }
}
