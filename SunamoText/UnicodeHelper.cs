namespace SunamoText;

public class UnicodeHelper
{
    public static StringBuilder sb = new StringBuilder();

    public static StringBuilder DeescapeDecodeUnicode(string str)
    {
        sb.Clear();
        // var splitted = Regex.Split(str, @"\\u([a-fA-F\d]{4})");
        //  
        // foreach (var s in splitted)
        // {
        //     try
        //     {
        //         if (s.Length == 4)
        //         {
        //             var decoded = ((char)Convert.ToUInt16(s, 16)).ToString();
        //             sb.Append(decoded);
        //         }
        //         else
        //         {
        //             sb.Append(s);
        //         }
        //     }
        //     catch (Exception e)
        //     {
        //         sb.Append(s);
        //     }
        // }
        //
        // return sb;

        sb.Append(Regex.Replace(
            str,
            @"\\[Uu]([0-9A-Fa-f]{4})",
            m => char.ToString(
                (char)ushort.Parse(m.Groups[1].Value, NumberStyles.AllowHexSpecifier))));
        return sb;
    }
}
