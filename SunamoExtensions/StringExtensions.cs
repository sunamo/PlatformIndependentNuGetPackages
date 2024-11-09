namespace SunamoExtensions;

public static class StringExtensions
{
    public static string RemoveInvisibleChars(this string input)
    {
        int[] charsToRemove = [8205];
        return new string(input.ToCharArray()
            .Where(c => !charsToRemove.Contains((int)c))
            .ToArray());
    }

    public static string RemoveWhitespaceChars(this string input)
    {
        // https://g.co/gemini/share/b47b0b16b54f
        int[] charsToRemove = [9, 10, 11, 12, 13, 32, 160, 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202, 8239, 8287, 12288];
        return new string(input.ToCharArray()
            .Where(c => !charsToRemove.Contains((int)c))
            .ToArray());
    }

    public static IList<string> SplitAndKeep(this string s, List<string> delims)
    {
        //    // delims allow only char[], not List<string>
        //    //int start = 0, index;
        //    //string selectedSeperator = null;
        //    //while ((index = s.IndexOfAny(delims, start, out selectedSeperator)) != -1)
        //    //{
        //    //    if (selectedSeperator == null)
        //    //        continue;
        //    //    if (index - start > 0)
        //    //        yield return s.Substring(start, index - start);
        //    //    yield return s.Substring(index, selectedSeperator.Length);
        //    //    start = index + selectedSeperator.Length;
        //    //}
        //    //if (start < s.Length)
        //    //{
        //    //    yield return s.Substring(start);
        //    //}
        return null;
    }
}