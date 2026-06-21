namespace SunamoStorage.Storage;

/// <summary>
/// Parser for text files with section-based grouping (e.g. "Copy:", "Shared", "[Header]").
/// </summary>
public class ApplicationDataText
{
    /// <summary>
    /// Parses a text file into sections, returning a dictionary of section names to their content lines.
    /// </summary>
    /// <param name="file">The file path to parse.</param>
    /// <param name="sections">The section header names to look for.</param>
    public static
#if ASYNC
async Task<Dictionary<string, List<string>>>
#else
  Dictionary<string, List<string>>
#endif
Parse(string file, List<string> sections)
    {
        Dictionary<string, List<string>> result = new Dictionary<string, List<string>>();

        List<string> lines = (
#if ASYNC
            await FileAsync.ReadAllLinesAsync(file)
#else
            FileAsync.ReadAllLinesAsync(file).GetAwaiter().GetResult()
#endif
            ).ToList();
        CA.Trim(lines);
        List<string> currentLines = new List<string>();

        string? currentSection = null;

        foreach (var item in lines)
        {
            string? previousSection = currentSection;
            if (CA.IsSomethingTheSame(item, sections, ref currentSection!))
            {
                CA.RemoveStringsEmpty(currentLines);
                if (previousSection != null)
                {
                    result.Add(previousSection, currentLines);
                }

                currentLines = new List<string>();

                continue;
            }

            currentLines.Add(item);
        }
        CA.RemoveStringsEmpty(currentLines);
        result.Add(currentSection!, currentLines);

        ThrowEx.DifferentCountInLists("sections", sections.Count, "result", result.Count);
        return result;
    }
}
