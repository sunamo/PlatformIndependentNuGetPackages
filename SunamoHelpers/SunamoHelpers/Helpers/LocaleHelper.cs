namespace SunamoHelpers.Helpers;

/// <summary>
/// Provides helper methods for locale and culture operations.
/// </summary>
public class LocaleHelper
{
    /// <summary>
    /// Initializes the locale helper by iterating available cultures.
    /// </summary>
    public static void Init()
    {
        foreach (var item in CultureInfo.GetCultures(CultureTypes.AllCultures))
        {
        }
    }

    /// <summary>
    /// Gets the country code for a given language code.
    /// Note: not reliable because for "en" it returns "AG". Use GetCountryForLang2 instead.
    /// </summary>
    /// <param name="lang">Two-letter language code.</param>
    public static string GetCountryForLang(string lang)
    {
        lang = lang.ToLower();
        foreach (var item in CultureInfo.GetCultures(CultureTypes.AllCultures))
        {
            var parts = SHSplit.Split(item.Name, "-");
            if (parts.Count > 1)
            {
                if (parts[0] == lang)
                {
                    if (parts[1].Length == 2)
                    {
                        ComplexInfoString complexInfo = new ComplexInfoString(parts[1]);
                        if (complexInfo.QuantityUpperChars == 2)
                        {
                            return parts[1];
                        }
                    }
                }
            }
        }
        return null!;
    }
}
