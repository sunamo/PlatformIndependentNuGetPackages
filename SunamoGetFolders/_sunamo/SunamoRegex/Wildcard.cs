namespace SunamoGetFolders._sunamo.SunamoRegex;


/// <summary>
/// Represents a wildcard running on the
/// <see cref="System.Text.RegularExpressions"/> engine.
/// </summary>
internal class Wildcard : Regex
{
    /// <summary>
    /// Initializes a wildcard with the given search pattern.
    /// </summary>
    /// <param name="pattern">The wildcard pattern to match.</param>
    internal Wildcard(string pattern)
    : base(WildcardToRegex(pattern))
    {
    }
    /// <summary>
    /// Initializes a wildcard with the given search pattern and options.
    /// </summary>
    /// <param name="pattern">The wildcard pattern to match.</param>
    /// <param name="options">A combination of one or more
    /// <see cref="RegexOptions"/>.</param>
    internal Wildcard(string pattern, RegexOptions options)
    : base(WildcardToRegex(pattern), options)
    {
    }
    /// <summary>
    /// Converts a wildcard to a regex.
    /// </summary>
    /// <param name="pattern">The wildcard pattern to convert.</param>
    /// <returns>A regex equivalent of the given wildcard.</returns>
    internal static string WildcardToRegex(string pattern)
    {
        return "^" + Regex.Escape(pattern).Replace("\\*", ".*").Replace("\\?", AllStrings.dot) + "$";
    }
}
