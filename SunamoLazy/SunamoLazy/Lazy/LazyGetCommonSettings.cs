namespace SunamoLazy.Lazy;

/// <summary>
/// Lazy-loaded common settings value retrieved by key.
/// </summary>
public class LazyGetCommonSettings : LazyString
{
    /// <summary>
    /// Initializes a new instance with the settings key and retrieval function.
    /// </summary>
    /// <param name="key">The settings key.</param>
    /// <param name="appDataGetCommonSettings">The function to retrieve settings.</param>
    public LazyGetCommonSettings(string key, Func<string, bool, string> appDataGetCommonSettings) : base(appDataGetCommonSettings, key)
    {
    }
}
