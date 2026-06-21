namespace SunamoHelpers._sunamo.SunamoFileSystem;

/// <summary>
/// File system helper utilities.
/// </summary>
internal class FS
{
    internal static List<char> InvalidFileNameChars = Path.GetInvalidFileNameChars().ToList();

#pragma warning disable CS0649
    internal static Action<string>? DeleteFileMaybeLocked;
#pragma warning restore CS0649

    /// <summary>
    /// Removes invalid characters from a file name or path.
    /// </summary>
    /// <param name="filenameOrPath">The file name or path to clean.</param>
    /// <param name="isPath">Whether the input is a path (true) or file name (false).</param>
    internal static string DeleteWrongCharsInFileName(string filenameOrPath, bool isPath)
    {
        List<char> invalidChars;

        if (isPath)
        {
            invalidChars = Path.GetInvalidPathChars().ToList();
        }
        else
        {
            invalidChars = Path.GetInvalidFileNameChars().ToList();
        }

        StringBuilder stringBuilder = new StringBuilder();
        foreach (char item in filenameOrPath)
        {
            if (!invalidChars.Contains(item))
            {
                stringBuilder.Append(item);
            }
        }

        var result = stringBuilder.ToString();
        SH.FirstCharUpper(ref result);
        return result;
    }

    /// <summary>
    /// Attempts to delete a file, returning false on failure.
    /// </summary>
    /// <param name="filePath">The file path to delete.</param>
    internal static bool TryDeleteFile(string filePath)
    {
        try
        {
            File.Delete(filePath);
            return true;
        }
        catch (Exception exception)
        {
            Console.WriteLine($"Failed to delete file {filePath}: {exception.Message}");
            return false;
        }
    }
}
