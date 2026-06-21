namespace SunamoLazy.Lazy;

/// <summary>
/// Generic lazy-loaded value using a settings retrieval function.
/// </summary>
/// <typeparam name="T">The type of the lazy value.</typeparam>
public class LazyT<T>
{
    private Func<string, bool, T> getCommonSettings;
    private string argument;
    T? value = default;

    /// <summary>
    /// Gets the lazily-loaded value, retrieving it on first access.
    /// </summary>
    public T Value
    {
        get
        {
            if (EqualityComparer<T>.Default.Equals(value, default))
            {
                value = getCommonSettings(argument, true);
            }
            return value!;
        }
    }

    /// <summary>
    /// Initializes a new instance with the retrieval function and key.
    /// </summary>
    /// <param name="getCommonSettings">The function to retrieve settings.</param>
    /// <param name="key">The settings key.</param>
    public LazyT(Func<string, bool, T> getCommonSettings, string key)
    {
        this.getCommonSettings = getCommonSettings;
        argument = key;
    }
}
