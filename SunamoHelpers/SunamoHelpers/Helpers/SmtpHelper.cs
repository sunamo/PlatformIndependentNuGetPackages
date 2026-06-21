namespace SunamoHelpers.Helpers;

/// <summary>
/// Provides helper methods for SMTP-related operations.
/// </summary>
public class SmtpHelper
{
    /// <summary>
    /// Parses a string into an SMTP port number.
    /// </summary>
    /// <param name="text">The text to parse as port number.</param>
    public static int ParsePort(string text)
    {
        return BTS.ParseInt(text, NumConsts.DefaultPortIfCannotBeParsed);
    }
}