namespace SunamoHelpers._sunamo.SunamoStringJoin;

/// <summary>
/// String join utility methods.
/// </summary>
internal class SHJoin
{
    /// <summary>
    /// Joins parts from the specified index using the given delimiter.
    /// </summary>
    /// <param name="startIndex">The index to start joining from.</param>
    /// <param name="delimiter">The delimiter to use between parts.</param>
    /// <param name="parts">The list of parts to join.</param>
    internal static string JoinFromIndex(int startIndex, object delimiter, IList parts)
    {
        string delimiterText = delimiter.ToString()!;
        StringBuilder stringBuilder = new StringBuilder();
        int index = 0;
        foreach (var item in parts)
        {
            if (index >= startIndex)
            {
                stringBuilder.Append(item + delimiterText);
            }
            index++;
        }
        string result = stringBuilder.ToString();
        return result.Substring(0, result.Length - 1);
    }
}
