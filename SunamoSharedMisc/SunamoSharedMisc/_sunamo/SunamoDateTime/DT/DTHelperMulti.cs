namespace SunamoSharedMisc._sunamo.SunamoDateTime.DT;

/// <summary>
/// Multi-language DateTime formatting helper.
/// </summary>
internal class DTHelperMulti
{
    /// <summary>
    /// Converts a DateTime to a date-only string in the specified language.
    /// </summary>
    /// <param name="dateTime">The DateTime to format.</param>
    /// <param name="lang">The language for formatting.</param>
    internal static string DateToString(DateTime dateTime, LangsShared lang)
    {
        if (lang == LangsShared.cs)
        {
            return dateTime.Day + "." + dateTime.Month + "." + dateTime.Year;
        }
        return dateTime.Month + "/" + dateTime.Day + "/" + dateTime.Year;
    }
}
