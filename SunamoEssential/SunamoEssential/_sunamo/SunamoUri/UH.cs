namespace SunamoEssential._sunamo.SunamoUri;

/// <summary>
/// URI helper utility methods.
/// </summary>
internal class UH
{
    /// <summary>
    /// URL-encodes the given text after trimming whitespace.
    /// </summary>
    /// <param name="text">The text to encode.</param>
    internal static string UrlEncode(string text)
    {
        return WebUtility.UrlEncode(text.Trim());
    }
}
