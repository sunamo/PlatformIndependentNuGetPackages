namespace SunamoRoslyn._sunamo;
internal class SHGetLines
{
    internal static List<string> GetLines(string p)
    {
        var parts = p.Split(new[] { "\r\n", "\n\r" }, StringSplitOptions.None).ToList();
        SplitByUnixNewline(parts);
        return parts;
    }

    private static void SplitByUnixNewline(List<string> d)
    {
        SplitBy(d, "\r");
        SplitBy(d, "\n");
    }

    private static void SplitBy(List<string> d, string v)
    {
        for (var i = d.Count - 1; i >= 0; i--)
        {
            if (v == "\r")
            {
                var rn = d[i].Split(new[] { "\r\n" }, StringSplitOptions.None);
                var nr = d[i].Split(new[] { "\n\r" }, StringSplitOptions.None);

                if (rn.Length > 1)
                    ThrowEx.Custom("cannot contain any \r\n, pass already split by this pattern");
                else if (nr.Length > 1) ThrowEx.Custom("cannot contain any \n\r, pass already split by this pattern");
            }

            var n = d[i].Split(new[] { v }, StringSplitOptions.None);

            if (n.Length > 1) InsertOnIndex(d, n.ToList(), i);
        }
    }

    private static void InsertOnIndex(List<string> d, List<string> r, int i)
    {
        r.Reverse();

        d.RemoveAt(i);

        foreach (var item in r) d.Insert(i, item);
    }
}