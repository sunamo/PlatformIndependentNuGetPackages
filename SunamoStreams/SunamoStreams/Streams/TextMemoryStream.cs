namespace SunamoStreams.Streams;

/// <summary>
/// In-memory text stream backed by a file for persistence.
/// </summary>
public class TextMemoryStream
{
    /// <summary>
    /// The text content buffer.
    /// </summary>
    public StringBuilder Line { get; set; } = new StringBuilder();
    private string? filePath = null;
    private string? initialPath = null;

    /// <summary>
    /// Initializes a new instance with the specified file path.
    /// </summary>
    /// <param name="path">The file path to use for loading and saving.</param>
    public TextMemoryStream(string path)
    {
        initialPath = path;
    }

    /// <summary>
    /// Loads the file content into the buffer.
    /// </summary>
    public
#if ASYNC
    async Task
#else
    void
#endif
        Init()
    {
        filePath = initialPath;

        string content = string.Empty;
        if (File.Exists(filePath))
        {
            content =
#if ASYNC
                await FileAsync.ReadAllTextAsync(initialPath!, Encoding.UTF8);
#else
                FileAsync.ReadAllTextAsync(initialPath!, Encoding.UTF8).GetAwaiter().GetResult();
#endif
        }

        Line.Append(content);
    }

    /// <summary>
    /// Saves the buffer content to the file.
    /// </summary>
    public
#if ASYNC
    async Task
#else
    void
#endif
 Save()
    {
#if ASYNC
        await FileAsync.WriteAllTextAsync(filePath!, Line.ToString());
#else
        FileAsync.WriteAllTextAsync(filePath!, Line.ToString()).GetAwaiter().GetResult();
#endif
    }
}
