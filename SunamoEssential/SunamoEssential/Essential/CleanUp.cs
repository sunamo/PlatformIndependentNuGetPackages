namespace SunamoEssential.Essential;

/// <summary>
/// Provides methods for cleaning up and disposing resources.
/// </summary>
public static class CleanUp
{
    /// <summary>
    /// Disposes the specified stream and file stream if they are not null.
    /// </summary>
    /// <param name="stream">The stream to dispose.</param>
    /// <param name="fileStream">The file stream to dispose.</param>
    public static void Streams(Stream stream, FileStream fileStream)
    {
        if (stream != null)
        {
            stream.Dispose();
        }
        if (fileStream != null)
        {
            fileStream.Dispose();
        }
    }
}
