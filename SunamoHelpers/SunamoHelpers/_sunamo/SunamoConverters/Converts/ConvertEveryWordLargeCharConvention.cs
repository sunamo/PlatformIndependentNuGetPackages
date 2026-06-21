namespace SunamoHelpers._sunamo.SunamoConverters.Converts;

/// <summary>
/// Converts text to a convention where every word starts with an uppercase character.
/// </summary>
internal class ConvertEveryWordLargeCharConvention
{
    private static bool IsSpecialChar(char character)
    {
        return new List<char>(['\\', '(', ')', ']', '[', '.', '\'']).Any(specialChar => specialChar == character);
    }

    /// <summary>
    /// Converts the given text to the every-word-large-char convention.
    /// </summary>
    /// <param name="text">The text to convert.</param>
    internal static string ToConvention(string text)
    {
        text = text.ToLower();
        StringBuilder stringBuilder = new StringBuilder();
        bool isNextUppercase = true;
        foreach (char item in text)
        {
            if (isNextUppercase)
            {
                if (char.IsUpper(item))
                {
                    isNextUppercase = false;
                    stringBuilder.Append(' ');
                    stringBuilder.Append(item);
                    continue;
                }
                else if (char.IsLower(item))
                {
                    isNextUppercase = false;
                    if (stringBuilder.Length != 0)
                    {
                        if (!IsSpecialChar(stringBuilder[stringBuilder.Length - 1]))
                        {
                            stringBuilder.Append(' ');
                        }
                    }
                    stringBuilder.Append(char.ToUpper(item));
                    continue;
                }
                else if (IsSpecialChar(item))
                {
                    stringBuilder.Append(item);
                    continue;
                }
                else if (char.IsDigit(item))
                {
                    stringBuilder.Append(item);
                    continue;
                }
                else
                {
                    stringBuilder.Append(' ');
                    continue;
                }
            }
            if (char.IsUpper(item))
            {
                if (!char.IsUpper(stringBuilder[stringBuilder.Length - 1]))
                {
                    stringBuilder.Append(' ');
                }
                stringBuilder.Append(item);
            }
            else if (char.IsLower(item))
            {
                stringBuilder.Append(item);
            }
            else if (char.IsDigit(item))
            {
                isNextUppercase = true;
                stringBuilder.Append(item);
                continue;
            }
            else if (IsSpecialChar(item))
            {
                stringBuilder.Append(item);
                continue;
            }
            else
            {
                stringBuilder.Append(' ');
                isNextUppercase = true;
            }
        }
        string result = stringBuilder.ToString().Trim();

        result = result.Replace("  ", " ");
        return result;
    }
}
