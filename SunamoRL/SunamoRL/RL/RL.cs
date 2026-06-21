namespace SunamoRL.RL;

using SunamoRL.Interfaces;

/// <summary>
/// Resource loader class for using RL in any type of application.
/// </summary>
public class RL
{
    /// <summary>
    /// Requires calling RL.Initialize() before using this class.
    /// </summary>
    private static class Xaml
    {
        public static byte LanguageId { get; set; } = 1;

        public static void Initialize(LangsShared lang)
        {
            LanguageId = (byte)lang;
        }
    }

    /// <summary>
    /// Gets or sets the global language setting for the entire application.
    /// Must be an enum because the application can have multiple languages.
    /// </summary>
    public static LangsShared Lang
    {
        set
        {
            ThisApp.Lang = value;
        }
        get
        {
            return ThisApp.Lang;
        }
    }

    /// <summary>
    /// Gets or sets the resource helper loader instance.
    /// </summary>
    public static IResourceHelper Loader { get; set; } = null!;

    private static int langsLength = 0;

    static RL()
    {
        langsLength = Enum.GetValues(typeof(LangsShared)).Length;
    }

    /// <summary>
    /// Initializes the resource loader with the specified language.
    /// </summary>
    /// <param name="lang">The language to initialize with.</param>
    public static void Initialize(LangsShared lang)
    {
        RL.Lang = lang;
        AppLangHelperShared.CurrentCulture = new CultureInfo(lang.ToString());
        AppLangHelperShared.CurrentUICulture = new CultureInfo(lang.ToString());
    }
}