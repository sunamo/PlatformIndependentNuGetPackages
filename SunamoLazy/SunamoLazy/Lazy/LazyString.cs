namespace SunamoLazy.Lazy;

/// <summary>
/// Lazy-loaded string value using common settings retrieval.
/// </summary>
public class LazyString : LazyT<string>
{
    /// <summary>
    /// Initializes a new instance with the retrieval function and key.
    /// </summary>
    /// <param name="getCommonSettings">The function to retrieve common settings.</param>
    /// <param name="key">The settings key.</param>
    public LazyString(Func<string, bool, string> getCommonSettings, string key) : base(getCommonSettings, key)
    {
    }
}
