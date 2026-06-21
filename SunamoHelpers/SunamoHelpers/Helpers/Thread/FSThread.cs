namespace SunamoHelpers.Helpers.Thread;

/// <summary>
/// Provides file system operations that avoid initialization dependencies.
/// </summary>
public class FSThread
{
    /// <summary>
    /// Gets the file name from the specified path.
    /// </summary>
    /// <param name="path">The full file path.</param>
    public static string GetFileName(string path)
    {
        return Path.GetFileName(path);
    }
}
