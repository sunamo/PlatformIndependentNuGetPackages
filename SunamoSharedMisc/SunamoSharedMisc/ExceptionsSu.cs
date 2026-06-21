namespace SunamoSharedMisc;

/// <summary>
/// Utility for parsing exception output lines.
/// </summary>
public class ExceptionsSu
{
    /// <summary>
    /// Filters and trims exception lines from a list of log lines.
    /// </summary>
    /// <param name="lines">The log lines to filter.</param>
    /// <param name="trimIfStartWith">Prefixes to trim from matching lines.</param>
    public static List<string> ParseExceptions(List<string> lines, params string[] trimIfStartWith)
    {
        lines = lines.Where(line => line.StartsWith("Exception:")).ToList();
        CA.TrimStart("Exception:", lines);
        foreach (var item in trimIfStartWith) CA.TrimStart(item, lines);
        return lines;
    }
}
