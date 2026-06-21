namespace SunamoStorage._sunamo.SunamoCollections;

/// <summary>
/// Collection manipulation utilities for lists and arrays.
/// </summary>
internal class CA
{
    /// <summary>
    /// Trims the specified prefix from the start of each string in the list.
    /// </summary>
    /// <param name="prefix">The prefix to trim.</param>
    /// <param name="list">The list of strings to process.</param>
    internal static List<string> TrimStart(string prefix, List<string> list)
    {
        ThrowEx.IsNull("prefix", prefix);
        ThrowEx.IsNull("list", list);

        for (int i = 0; i < list.Count; i++)
        {
            if (list[i].StartsWith(prefix))
            {
                list[i] = list[i].Substring(prefix.Length);
            }
        }
        return list;
    }

    /// <summary>
    /// Trims whitespace from all strings in the list.
    /// </summary>
    /// <param name="list">The list of strings to trim.</param>
    internal static List<string> Trim(List<string> list)
    {
        for (var i = 0; i < list.Count; i++) list[i] = list[i].Trim();

        return list;
    }

    /// <summary>
    /// Replaces all occurrences of each string in the list with the specified replacement.
    /// </summary>
    /// <param name="text">The text to process.</param>
    /// <param name="what">The list of strings to replace.</param>
    /// <param name="replacement">The replacement string.</param>
    internal static string ReplaceAll(string text, List<string> what, string replacement)
    {
        foreach (var item in what)
        {
            text = text.Replace(item, replacement);
        }

        return text;
    }

    /// <summary>
    /// Removes diacritics from all strings in the list.
    /// </summary>
    /// <param name="list">The list of strings to process.</param>
    internal static List<string> WithoutDiacritic(List<string> list)
    {
        for (int i = 0; i < list.Count; i++)
        {
            list[i] = list[i].RemoveDiacritics();
        }
        return list;
    }

    /// <summary>
    /// Removes empty strings from the list.
    /// </summary>
    /// <param name="list">The list to filter.</param>
    internal static List<string> RemoveStringsEmpty(List<string> list)
    {
        for (int i = list.Count - 1; i >= 0; i--)
        {
            if (list[i] == string.Empty)
            {
                list.RemoveAt(i);
            }
        }
        return list;
    }

    /// <summary>
    /// Checks whether there is another index available in the array.
    /// </summary>
    /// <param name="array">The character array to check.</param>
    /// <param name="index">The index to verify.</param>
    internal static bool IsThereAnotherIndex(char[] array, int index)
    {
        if (array.Length >= index)
        {
            return true;
        }
        return false;
    }

    /// <summary>
    /// Checks if a matching string exists in the list.
    /// </summary>
    /// <param name="text">The text to search for.</param>
    /// <param name="list">The list to search in.</param>
    /// <param name="contained">Output: the matching string found.</param>
    internal static bool IsSomethingTheSame(string text, IList<string> list, ref string contained)
    {
        foreach (var item in list)
        {
            if (item == text)
            {
                contained = item;
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// Joins two byte arrays into a single list.
    /// </summary>
    /// <param name="firstArray">The first byte array.</param>
    /// <param name="secondArray">The second byte array.</param>
    internal static List<byte> JoinBytesArray(byte[] firstArray, byte[] secondArray)
    {
        List<byte> result = new List<byte>(firstArray.Length + secondArray.Length);
        result.AddRange(firstArray);
        result.AddRange(secondArray);
        return result;
    }
}
