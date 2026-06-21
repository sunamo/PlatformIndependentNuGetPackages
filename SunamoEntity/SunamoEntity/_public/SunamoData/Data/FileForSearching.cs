namespace SunamoEntity._public.SunamoData.Data;

/// <summary>
/// Represents a file loaded for content searching with lowercased line cache.
/// </summary>
public class FileForSearching
{
    /// <summary>
    /// Gets or sets a value indicating whether this file is surely not a match.
    /// </summary>
    public bool IsSurelyNo { get; set; } = false;

    /// <summary>
    /// Gets or sets the list of line indices where matches were found.
    /// </summary>
    public List<int> FoundedLines { get; set; } = new List<int>();

    /// <summary>
    /// Gets or sets the lowercased version of all lines for case-insensitive searching.
    /// </summary>
    public List<string> LinesLower { get; set; } = null!;

    /// <summary>
    /// Gets or sets the original lines of the file.
    /// </summary>
    public List<string> Lines { get; set; } = null!;

    private string path;

    /// <summary>
    /// Initializes a new instance of the <see cref="FileForSearching"/> class.
    /// </summary>
    /// <param name="path">The file path to load for searching.</param>
    public FileForSearching(string path)
    {
        this.path = path;
    }

    /// <summary>
    /// Loads the file content and creates a lowercased line cache.
    /// </summary>
    public
#if ASYNC
    async Task
#else
    void
#endif
        Init()
    {
        Lines = (
#if ASYNC
            await FileAsync.ReadAllLinesAsync(path)
#else
            FileAsync.ReadAllLinesAsync(path).GetAwaiter().GetResult()
#endif
            ).ToList();
        LinesLower = new List<string>(Lines.Count);
        foreach (var item in Lines)
        {
            LinesLower.Add(item.ToLower());
        }
    }
}