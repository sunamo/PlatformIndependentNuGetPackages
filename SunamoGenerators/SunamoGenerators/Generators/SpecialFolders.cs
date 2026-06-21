namespace SunamoGenerators.Generators;

/// <summary>
/// Provides helper methods for constructing paths under special document folders.
/// </summary>
public static class SpecialFolders
{
    /// <summary>
    /// Returns a path under D:\Documents\ with the given relative path appended.
    /// </summary>
    /// <param name="path">Relative path to append.</param>
    public static string MyDocuments(string path)
    {
        return @"D:\Documents\" + path.TrimStart('\\');
    }

    /// <summary>
    /// Returns a path under E:\Documents\ with the given relative path appended.
    /// </summary>
    /// <param name="path">Relative path to append.</param>
    public static string eMyDocuments(string path)
    {
        return @"E:\Documents\" + path.TrimStart('\\');
    }
}
