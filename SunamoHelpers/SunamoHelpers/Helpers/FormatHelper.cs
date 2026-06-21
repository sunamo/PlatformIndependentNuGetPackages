namespace SunamoHelpers.Helpers;

/// <summary>
/// Provides methods for formatting email addresses from names and domain postfixes, with diacritic removal.
/// </summary>
public class FormatHelper
{
    /// <summary>
    /// Gets or sets the parsed first name from the last FormatEmail call.
    /// </summary>
    public static string? ParsedName { get; set; } = null;

    /// <summary>
    /// Gets or sets the parsed surname from the last FormatEmail call.
    /// </summary>
    public static string? ParsedSurname { get; set; } = null;

    /// <summary>
    /// Formats an email address from a full name and domain postfix.
    /// </summary>
    /// <param name="nameSurname">Full name in "FirstName LastName" format.</param>
    /// <param name="postfix">Email domain postfix.</param>
    public static string FormatEmail(string nameSurname, string postfix)
    {
        var parts = SHSplit.Split(nameSurname, " ");
        if (parts.Count != 2)
        {
            ThrowEx.WrongNumberOfElements(2, "parts", parts);
        }
        ParsedName = parts[0];
        ParsedSurname = parts[1];
        return FormatEmail(parts[0], parts[1], postfix);
    }

    /// <summary>
    /// Formats an email address from a first name, surname, and domain postfix.
    /// </summary>
    /// <param name="name">First name.</param>
    /// <param name="surname">Last name.</param>
    /// <param name="postfix">Email domain postfix.</param>
    public static string FormatEmail(string name, string surname, string postfix)
    {
        return SH.TextWithoutDiacritic(name.ToLower()) + "." + SH.TextWithoutDiacritic(surname.ToLower()) + "@" + postfix.TrimStart('@');
    }
}
