namespace SunamoEssential._sunamo.SunamoBts;

/// <summary>
/// Basic type conversion and parsing utilities.
/// </summary>
internal class BTS
{
    /// <summary>
    /// Converts an integer to a boolean value.
    /// </summary>
    /// <param name="value">The integer to convert.</param>
    internal static bool IntToBool(int value)
    {
        return Convert.ToBoolean(value);
    }

    /// <summary>
    /// Parses a string to an integer, returning a default value on failure.
    /// </summary>
    /// <param name="text">The text to parse.</param>
    /// <param name="defaultValue">The default value if parsing fails.</param>
    internal static int ParseInt(string text, int defaultValue)
    {
        text = text.Replace(" ", string.Empty);

        int parsedValue = 0;
        if (int.TryParse(text, out parsedValue))
        {
            return parsedValue;
        }
        return defaultValue;
    }
}
