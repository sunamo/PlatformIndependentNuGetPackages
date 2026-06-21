namespace SunamoSharedMisc._public;

/// <summary>
/// Provides shared application language culture settings.
/// </summary>
public class AppLangHelperShared
{
    /// <summary>
    /// Gets or sets the current culture used for formatting.
    /// </summary>
    public static CultureInfo CurrentCulture { get; set; } = null!;

    /// <summary>
    /// Gets or sets the current UI culture used for resource localization.
    /// </summary>
    public static CultureInfo CurrentUICulture { get; set; } = null!;
}