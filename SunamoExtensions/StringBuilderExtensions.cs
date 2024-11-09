namespace SunamoExtensions;

public static class StringBuilderExtensions
{
    #region For easy copy

    public static void TrimEnd(this StringBuilder sb)
    {
        var length = sb.Length;
        for (var i = length - 1; i >= 0; i--)
            if (char.IsWhiteSpace(sb[i]))
                sb.Remove(i, 1);
            else
                break;
    }

    #endregion

    public static void AppendFormatLine(this StringBuilder sb, string test, params string[] args)
    {
        sb.AppendFormat(test, args);
        sb.AppendLine();
    }

    public static bool EndsWith(this StringBuilder sb, string test)
    {
        if (sb.Length < test.Length)
            return false;

        var end = sb.ToString(sb.Length - test.Length, test.Length);
        return end.Equals(test);
    }

    public static bool StartWith(this StringBuilder sb, string test)
    {
        if (sb.Length < test.Length)
            return false;

        var start = sb.ToString(0, test.Length);
        return start.Equals(test);
    }

    public static StringBuilder TrimEnd(this StringBuilder name, string ext)
    {
        while (name.EndsWith(ext)) return name.Substring(0, name.Length - ext.Length);
        return name;
    }


    public static StringBuilder TrimStart(this StringBuilder name, string ext)
    {
        while (name.StartWith(ext)) return name.Substring(ext.Length, name.Length - ext.Length);
        return name;
    }

    public static StringBuilder Substring(this StringBuilder input, int indexFrom)
    {
        return input.Substring(1, input.Length - 1);
    }

    public static StringBuilder Substring(this StringBuilder input, int index, int length)
    {
        var subString = new StringBuilder();
        if (index + length - 1 >= input.Length || index < 0)
            throw new ArgumentOutOfRangeException("Index out of range!");
        var endIndex = index + length;
        for (var i = index; i < endIndex; i++) subString.Append(input[i]);
        return subString;
    }


    public static void TrimStart(this StringBuilder sb)
    {
        var length = sb.Length;
        for (var i = 0; i < length; i++)
            if (char.IsWhiteSpace(sb[i]))
                sb.Remove(i, 1);
            else
                break;
    }

    public static void Trim(this StringBuilder sb)
    {
        TrimEnd(sb);
        TrimStart(sb);
    }

    #region For easy copy from StringBuilderExtensions.cs

    public static bool Contains(this StringBuilder haystack, string needle)
    {
        return haystack.IndexOf(needle) != -1;
    }

    public static int IndexOf(this StringBuilder haystack, string needle)
    {
        if (haystack == null || needle == null)
            throw new ArgumentNullException();
        if (needle.Length == 0)
            return 0; //empty strings are everywhere!
        if (needle.Length == 1) //can't beat just spinning through for it
        {
            var c = needle[0];
            for (var idx = 0; idx != haystack.Length; ++idx)
                if (haystack[idx] == c)
                    return idx;
            return -1;
        }

        var m = 0;
        var i = 0;
        var T = KMPTable(needle);
        while (m + i < haystack.Length)
            if (needle[i] == haystack[m + i])
            {
                if (i == needle.Length - 1)
                    return m == needle.Length ? -1 : m; //match -1 = failure to find conventional in .NET
                ++i;
            }
            else
            {
                m = m + i - T[i];
                i = T[i] > -1 ? T[i] : 0;
            }

        return -1;
    }

    private static int[] KMPTable(string sought)
    {
        var table = new int[sought.Length];
        var pos = 2;
        var cnd = 0;
        table[0] = -1;
        table[1] = 0;
        while (pos < table.Length)
            if (sought[pos - 1] == sought[cnd])
                table[pos++] = ++cnd;
            else if (cnd > 0)
                cnd = table[cnd];
            else
                table[pos++] = 0;
        return table;
    }

    #endregion
}