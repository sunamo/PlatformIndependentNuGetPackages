namespace SunamoHelpers._sunamo;

/// <summary>
/// Converts DateTime values to file name postfixes using a standard convention.
/// </summary>
internal class ConvertDateTimeToFileNamePostfix
{
    private static char delimiter = '_';

    /// <summary>
    /// Converts a postfix and DateTime to a file name convention string.
    /// </summary>
    /// <param name="postfix">The postfix to append after the date.</param>
    /// <param name="dateTime">The DateTime to convert to file name format.</param>
    /// <param name="isIncludingTime">Whether to include time in the file name.</param>
    internal static string ToConvention(string postfix, DateTime dateTime, bool isIncludingTime)
    {
        return DTHelper.DateTimeToFileName(dateTime, isIncludingTime) + delimiter + postfix;
    }
}