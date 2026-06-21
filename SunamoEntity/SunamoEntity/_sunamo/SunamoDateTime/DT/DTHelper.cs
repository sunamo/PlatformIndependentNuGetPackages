namespace SunamoEntity._sunamo.SunamoDateTime.DT;

/// <summary>
/// DateTime formatting helper methods.
/// </summary>
internal class DTHelper
{
    /// <summary>
    /// Converts a DateTime to a file name friendly string.
    /// </summary>
    /// <param name="dateTime">The DateTime to convert.</param>
    /// <param name="isIncludingTime">Whether to include time in the output.</param>
    internal static string DateTimeToFileName(DateTime dateTime, bool isIncludingTime)
    {
        string dateDelimiter = "_";
        string spaceDelimiter = "_";
        string timeDelimiter = "_";
        string result = dateTime.Year + dateDelimiter + dateTime.Month.ToString("D2") + dateDelimiter + dateTime.Day.ToString("D2");
        if (isIncludingTime)
        {
            result += spaceDelimiter + dateTime.Hour.ToString("D2") + timeDelimiter + dateTime.Minute.ToString("D2");
        }
        return result;
    }

    /// <summary>
    /// Converts a DateTime to a date-only string in the specified language.
    /// </summary>
    /// <param name="dateTime">The DateTime to format.</param>
    /// <param name="lang">The language for formatting.</param>
    internal static string DateToString(DateTime dateTime, LangsShared lang)
    {
        return DTHelperMulti.DateToString(dateTime, lang);
    }

    /// <summary>
    /// Converts a DateTime to a full date-time string in the specified language.
    /// </summary>
    /// <param name="dateTime">The DateTime to format.</param>
    /// <param name="lang">The language for formatting.</param>
    /// <param name="minDateTime">The minimum DateTime value to check against.</param>
    internal static string DateTimeToString(DateTime dateTime, LangsShared lang, DateTime minDateTime)
    {
        if (dateTime == minDateTime)
        {
            if (lang == LangsShared.cs)
            {
                return "ItWasNotMentioned";
            }
            else
            {
                return "NotIndicated";
            }
        }

        if (lang == LangsShared.cs)
        {
            return dateTime.Day + "." + dateTime.Month + "." + dateTime.Year + " " + dateTime.Hour.ToString("D2") + ":" + dateTime.Minute.ToString("D2");
        }
        else
        {
            return dateTime.Month + "/" + dateTime.Day + "/" + dateTime.Year + " " + dateTime.Hour.ToString("D2") + ":" + dateTime.Minute.ToString("D2");
        }
    }
}
