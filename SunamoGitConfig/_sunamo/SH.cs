using static System.Net.Mime.MediaTypeNames;
using static System.Net.Mime.MediaTypeNames;
namespace SunamoGitConfig._sunamo;
internal class SH
{
    internal static List<string> GetLines(string text)
    {
        List<string> result = new List<string>();
        using (StringReader sr = new StringReader(text))
        {
            string? line;
            while ((line = sr.ReadLine()) != null)
            {
                result.Add(line);
            }
        }
        return result;
    }
    internal static string JoinNL(List<string> lines)
    {
        return string.Join(Environment.NewLine, lines);
    }
}
