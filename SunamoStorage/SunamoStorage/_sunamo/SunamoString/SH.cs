namespace SunamoStorage._sunamo.SunamoString;

/// <summary>
/// String helper utility methods.
/// </summary>
internal class SH
{
    /// <summary>
    /// Converts the first character of the string to uppercase (by ref).
    /// </summary>
    /// <param name="text">The string to modify.</param>
    internal static string FirstCharUpper(ref string text)
    {
        text = SH.FirstCharUpper(text);

        return text;
    }

    /// <summary>
    /// Converts the first character of the string to uppercase.
    /// </summary>
    /// <param name="text">The text to process.</param>
    /// <param name="isOnlyFirstUpper">Whether to lowercase all other characters.</param>
    internal static string FirstCharUpper(string text, bool isOnlyFirstUpper = false)
    {
        if (text != null)
        {
            var substring = text.Substring(1);
            if (isOnlyFirstUpper) substring = substring.ToLower();

            return text[0].ToString().ToUpper() + substring;
        }

        return null!;
    }

    /// <summary>
    /// Checks which characters from the list are contained in the text.
    /// </summary>
    /// <param name="text">The text to search in.</param>
    /// <param name="isCheckInCaseOnlyOneString">Whether to check when only one character exists.</param>
    /// <param name="characters">The characters to look for.</param>
    internal static List<char> ContainsAnyChar(string text, bool isCheckInCaseOnlyOneString, IList<char> characters)
    {
        List<char> found = new List<char>();
        if (characters.Count() == 1 && isCheckInCaseOnlyOneString)
        {
            text.Contains(characters.First());
        }
        else
        {
            foreach (var character in characters)
            {
                if (text.Contains(character))
                {
                    found.Add(character);
                }
            }
        }

        return found;
    }

    /// <summary>
    /// Checks whether the text contains any bracket characters.
    /// </summary>
    /// <param name="text">The text to check.</param>
    /// <param name="leftBrackets">Output: found left brackets.</param>
    /// <param name="rightBrackets">Output: found right brackets.</param>
    /// <param name="isMustBeLeftAndRight">Whether both left and right brackets must be present.</param>
    internal static bool ContainsBracket(string text, ref List<char> leftBrackets, ref List<char> rightBrackets, bool isMustBeLeftAndRight = false)
    {
        leftBrackets = SH.ContainsAnyChar(text, false, AllLists.LeftBrackets);
        rightBrackets = SH.ContainsAnyChar(text, false, AllLists.LeftBrackets);
        if (isMustBeLeftAndRight)
        {
            if (leftBrackets.Count > 0 && rightBrackets.Count > 0)
            {
                return true;
            }
        }
        else
        {
            if (leftBrackets.Count > 0 || rightBrackets.Count > 0)
            {
                return true;
            }
        }

        return false;
    }

#pragma warning disable CS0649
    protected static Dictionary<BracketsShared, char>? BracketsLeft;
    protected static Dictionary<BracketsShared, char>? BracketsRight;

    protected static List<char>? BracketsLeftList;
    protected static List<char>? BracketsRightList;
#pragma warning restore CS0649

    /// <summary>
    /// Returns the closing bracket for the given opening bracket.
    /// </summary>
    /// <param name="openingBracket">The opening bracket character.</param>
    internal static char ClosingBracketFor(char openingBracket)
    {
        foreach (var item in BracketsLeft!)
        {
            if (item.Value == openingBracket)
            {
                return BracketsRight![item.Key];
            }
        }

        ThrowEx.IsNotAllowed(openingBracket + " as bracket");
        return char.MaxValue;
    }

    /// <summary>
    /// Gets the text between two delimiter characters.
    /// </summary>
    /// <param name="text">The text to search in.</param>
    /// <param name="afterChar">The opening delimiter character.</param>
    /// <param name="beforeChar">The closing delimiter character.</param>
    /// <param name="isThrowingExceptionIfNotContains">Whether to throw if delimiters are not found.</param>
    /// <param name="notAllowedInRanges">Ranges where end delimiter should not be matched.</param>
    /// <param name="isEndLastIndexOf">Whether to use LastIndexOf for the end delimiter.</param>
    internal static string GetTextBetween(string text, char afterChar, char beforeChar, bool isThrowingExceptionIfNotContains = true, object? notAllowedInRanges = null, bool isEndLastIndexOf = false)
    {
        return GetTextBetweenTwoChars(text, afterChar, beforeChar, isThrowingExceptionIfNotContains, notAllowedInRanges, isEndLastIndexOf);
    }

    /// <summary>
    /// Checks if the index is within a not-allowed range.
    /// </summary>
    /// <param name="rangeChecker">The range checker object.</param>
    /// <param name="index">The index to check.</param>
    internal static bool NotAllowedInRanges(object rangeChecker, int index)
    {
        if (rangeChecker is Func<int, bool>)
        {
            var predicate = (Func<int, bool>)rangeChecker;
            return predicate(index);
        }

        ThrowEx.NotImplementedCase("NotAllowedInRanges: " + rangeChecker);
        return false;
    }

    /// <summary>
    /// Gets the text between two delimiter characters.
    /// </summary>
    /// <param name="text">The text to search in.</param>
    /// <param name="beginChar">The opening delimiter.</param>
    /// <param name="endChar">The closing delimiter.</param>
    /// <param name="isThrowingExceptionIfNotContains">Whether to throw if delimiters are not found.</param>
    /// <param name="notAllowedInRanges">Ranges where end delimiter should not be matched.</param>
    /// <param name="isEndLastIndexOf">Whether to use LastIndexOf for the end delimiter.</param>
    internal static string GetTextBetweenTwoChars(string text, char beginChar, char endChar, bool isThrowingExceptionIfNotContains = true, object? notAllowedInRanges = null, bool isEndLastIndexOf = false)
    {
        int beginIndex = text.IndexOf(beginChar);
        int endIndex = -1;
        if (isEndLastIndexOf)
        {
            endIndex = text.LastIndexOf(endChar);
        }
        else
        {
            endIndex = text.IndexOf(endChar, beginIndex + 1);
            if (notAllowedInRanges != null)
            {
                while (endIndex != -1 && NotAllowedInRanges(notAllowedInRanges, endIndex))
                {
                    endIndex = text.IndexOf(endChar, endIndex + 1);
                }
            }
        }

        if (beginIndex == -1 || endIndex == -1)
        {
            if (isThrowingExceptionIfNotContains)
            {
                ThrowEx.NotContains(text, beginChar.ToString(), endChar.ToString());
            }
            else if (endIndex == -1)
            {
                return null!;
            }

            return text;
        }

        return GetTextBetweenTwoCharsInts(text, beginIndex, endIndex);
    }

    /// <summary>
    /// Extracts a substring between two index positions.
    /// </summary>
    /// <param name="text">The source text.</param>
    /// <param name="beginIndex">The start index (exclusive).</param>
    /// <param name="endIndex">The end index (exclusive).</param>
    internal static string GetTextBetweenTwoCharsInts(string text, int beginIndex, int endIndex)
    {
        if (endIndex > beginIndex)
            return text.Substring(beginIndex + 1, endIndex - beginIndex - 1);
        return text;
    }

    /// <summary>
    /// Wraps a value with the specified wrapper string on both sides.
    /// </summary>
    /// <param name="text">The text to wrap.</param>
    /// <param name="wrapper">The wrapper string.</param>
    internal static string WrapWith(string text, string wrapper)
    {
        return wrapper + text + wrapper;
    }

    /// <summary>
    /// Removes diacritics from the text.
    /// </summary>
    /// <param name="text">The text to process.</param>
    internal static string TextWithoutDiacritic(string text)
    {
        return text.RemoveDiacritics();
    }
}
