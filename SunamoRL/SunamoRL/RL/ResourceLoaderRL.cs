namespace SunamoRL.RL;

/// <summary>
/// Simple resource loader that delegates to the translation system.
/// </summary>
public class ResourceLoaderRL
{
    /// <summary>
    /// Gets a localized string by key.
    /// </summary>
    /// <param name="key">The localization key.</param>
    public string GetString(string key)
    {
        return Translate.FromKey(key);
    }
}
