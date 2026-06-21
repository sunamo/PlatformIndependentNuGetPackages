namespace SunamoEntity.Entity;

/// <summary>
/// Provides methods for parsing and managing artist-dash-title formatted strings.
/// </summary>
public class ManageArtistDashTitle
{
    /// <summary>
    /// Extracts artist, song title, and remix information from the given text into out parameters.
    /// </summary>
    /// <param name="text">The formatted text to parse (e.g. "Artist - Title [Remix]").</param>
    /// <param name="artist">The extracted artist name.</param>
    /// <param name="song">The extracted song title.</param>
    /// <param name="remix">The extracted remix information.</param>
    public static void GetArtistTitleRemix(string text, out string artist, out string song, out string remix)
    {
        var result = GetArtistTitleRemix(text);
        artist = result.Item1;
        song = result.Item2;
        remix = result.Item3;
    }

    /// <summary>
    /// Checks whether the given text contains bracket characters.
    /// </summary>
    /// <param name="text">The text to check for brackets.</param>
    /// <param name="left">List of left bracket characters found.</param>
    /// <param name="right">List of right bracket characters found.</param>
    /// <param name="isMustBeLeftAndRight">If true, both left and right brackets must be present.</param>
    public static bool ContainsBracket(string text, ref List<char> left, ref List<char> right, bool isMustBeLeftAndRight = false)
    {
        left = SH.ContainsAnyChar(text, false, AllLists.LeftBrackets);
        right = SH.ContainsAnyChar(text, false, AllLists.LeftBrackets);
        if (isMustBeLeftAndRight)
        {
            if (left.Count > 0 && right.Count > 0)
            {
                return true;
            }
        }
        else
        {
            if (left.Count > 0 || right.Count > 0)
            {
                return true;
            }
        }

        return false;
    }

    /// <summary>
    /// Parses a formatted string into artist, title, and remix components.
    /// </summary>
    /// <param name="text">The formatted text to parse (e.g. "Artist - Title [Remix]").</param>
    public static Tuple<string, string, string> GetArtistTitleRemix(string text)
    {
        string artist; string song; string remix;
        string delimiter = SH.WrapWith("-", " ");

        if (!text.Contains(delimiter))
        {
            delimiter = "-";
        }

        List<string> parts = SHSplit.Split(text, delimiter);
        artist = song = "";
        if (parts.Count == 0)
        {
            artist = song = remix = "";
        }
        else if (parts.Count == 1)
        {
            artist = "";
            ExtractTitleRemix(parts[0], out song, out remix);
        }
        else
        {

            artist = parts[0];

            List<char>? left, right;
            left = right = null;

            if (SH.ContainsBracket(artist, ref left!, ref right!))
            {
                if (left.Count - 1 == right.Count)
                {
                    var closingBracket = SH.ClosingBracketFor(left[0]);
                    right.Add(closingBracket);
                    artist += closingBracket;
                }
                if (left.Count > 0 && right.Count > 0)
                {
                    var between = SH.GetTextBetween(artist, left[0], right[0]);
                    between = left[0] + between + right[0];
                    text = text.Replace(between, string.Empty);
                    text += " " + between;
                    parts = SHSplit.Split(text, delimiter);
                    if (parts.Count > 0)
                    {
                        artist = parts[0].Trim();
                    }
                }
            }

            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 1; i < parts.Count; i++)
            {
                stringBuilder.Append(parts[i]);
            }

            ExtractTitleRemix(stringBuilder.ToString().TrimEnd('-'), out song, out remix);
        }
        return new Tuple<string, string, string>(artist, song, remix);
    }

    /// <summary>
    /// Extracts title and remix parts from a song title string that may contain brackets.
    /// </summary>
    /// <param name="text">The text to split into title and remix.</param>
    /// <param name="title">The extracted title portion.</param>
    /// <param name="remix">The extracted remix portion (bracket content).</param>
    private static void ExtractTitleRemix(string text, out string title, out string remix)
    {
        title = text;
        remix = "";
        int firstSquareBracketIndex = text.IndexOf(']');
        int firstParenthesisIndex = text.IndexOf('(');
        if (firstSquareBracketIndex == -1 && firstParenthesisIndex != -1)
        {
            SplitAtIndexInclusive(text, firstParenthesisIndex, out title, out remix);
        }
        else if (firstSquareBracketIndex != -1 && firstParenthesisIndex == -1)
        {
            SplitAtIndexInclusive(text, firstSquareBracketIndex, out title, out remix);
        }
        else if (firstSquareBracketIndex != -1 && firstParenthesisIndex != -1)
        {
            if (firstSquareBracketIndex < firstParenthesisIndex)
            {
                SplitAtIndexInclusive(text, firstParenthesisIndex, out title, out remix);
            }
            else
            {
                SplitAtIndexInclusive(text, firstSquareBracketIndex, out title, out remix);
            }
        }
    }

    /// <summary>
    /// Splits text at the given index, including the character at that index in the second part.
    /// </summary>
    /// <param name="text">The text to split.</param>
    /// <param name="splitIndex">The index at which to split.</param>
    /// <param name="title">The text before the split index.</param>
    /// <param name="remix">The text from the split index onward.</param>
    private static void SplitAtIndexInclusive(string text, int splitIndex, out string title, out string remix)
    {
        title = text.Substring(0, splitIndex);
        remix = text.Substring(splitIndex);
    }

    /// <summary>
    /// Extracts the artist name from a formatted text string.
    /// </summary>
    /// <param name="text">The formatted text to extract the artist from.</param>
    public static string GetArtist(string text)
    {
        string artist;
        string? title = null;
        GetArtistTitle(text, out artist, out title!);
        return artist;
    }

    /// <summary>
    /// Extracts artist and title from a formatted text string, using the file name without extension.
    /// </summary>
    /// <param name="text">The formatted text to parse.</param>
    /// <param name="artist">The extracted artist name.</param>
    /// <param name="title">The extracted title.</param>
    public static void GetArtistTitle(string text, out string artist, out string title)
    {
        var fileNameWithoutExtension = Path.GetFileNameWithoutExtension(text);
        List<string> parts = SHSplit.Split(fileNameWithoutExtension, "-");
        artist = title = "";
        if (parts.Count == 0)
        {
            artist = title = "";
        }
        else if (parts.Count == 1)
        {
            artist = "";
            title = parts[0];
        }
        else
        {
            artist = parts[0];
            StringBuilder stringBuilder = new StringBuilder();
            for (int i = 1; i < parts.Count; i++)
            {
                stringBuilder.Append(parts[i] + "-");
            }

            title = stringBuilder.ToString().TrimEnd('-');
        }
    }

    /// <summary>
    /// Capitalizes the first letter, and letters after spaces, hyphens, closing brackets, and opening parentheses.
    /// </summary>
    /// <param name="text">The text to capitalize.</param>
    /// <param name="separator">The separator character sequence used between artist and title.</param>
    public static string ArtistAndTitleToUpper(string text, string separator)
    {
        char[] characters = text.ToCharArray();
        characters[0] = char.ToUpper(text[0]);
        int separatorIndex = text.IndexOf(separator);
        characters[separatorIndex + 1] = char.ToUpper(characters[separatorIndex + 1]);
        for (int i = 1; i < characters.Length; i++)
        {
            if (characters[i] == ' ')
            {
                if (CA.IsThereAnotherIndex(characters, i))
                {
                    characters[i + 1] = char.ToUpper(characters[i + 1]);
                }
            }
            else if (characters[i] == '-')
            {
                if (CA.IsThereAnotherIndex(characters, i))
                {
                    characters[i + 1] = char.ToUpper(characters[i + 1]);
                }
            }
            else if (characters[i] == ']')
            {
                if (CA.IsThereAnotherIndex(characters, i))
                {
                    characters[i + 1] = char.ToUpper(characters[i + 1]);
                }
            }
            else if (characters[i] == '(')
            {
                if (CA.IsThereAnotherIndex(characters, i))
                {
                    characters[i + 1] = char.ToUpper(characters[i + 1]);
                }
            }
        }

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.Append(characters);
        return stringBuilder.ToString();
    }

    /// <summary>
    /// Replaces all hyphens except the first one with the specified replacement string.
    /// </summary>
    /// <param name="text">The text to process.</param>
    /// <param name="replacement">The string to replace hyphens with (default is a space).</param>
    public static string ReplaceAllHyphensExceptTheFirst(string text, string replacement = " ")
    {
        int firstHyphenIndex = text.IndexOf('-');
        text = text.Replace("-", replacement);
        char[] characters = text.ToCharArray();
        characters[firstHyphenIndex] = '-';
        return new string(characters);
    }

    /// <summary>
    /// Extracts the song title from a formatted text string.
    /// </summary>
    /// <param name="text">The formatted text to extract the title from.</param>
    public string GetTitle(string text)
    {
        string artist;
        string? title = null;
        GetArtistTitle(text, out artist, out title!);
        return title!;
    }

    /// <summary>
    /// Reverses the order of hyphen-separated parts in the text, swapping the first and last segments.
    /// </summary>
    /// <param name="text">The hyphen-separated text to reverse.</param>
    public static string Reverse(string text)
    {
        List<string> parts = SHSplit.SplitChar(text, '-');
        string firstPart = parts[0];
        parts[0] = parts[parts.Count - 1];
        parts[parts.Count - 1] = firstPart;
        StringBuilder stringBuilder = new StringBuilder();
        foreach (string item in parts)
        {
            stringBuilder.Append(item + "-");
        }

        return stringBuilder.ToString().TrimEnd('-');
    }
}
