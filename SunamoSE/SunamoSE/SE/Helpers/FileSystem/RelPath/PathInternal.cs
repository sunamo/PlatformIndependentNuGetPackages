namespace SunamoSE.SE.Helpers.FileSystem.RelPath;

/// <summary>
/// Provides internal path manipulation utilities for relative path resolution.
/// </summary>
public partial class PathInternal
{
    /// <summary>
    /// The primary directory separator character (backslash on Windows).
    /// </summary>
    public const char DirectorySeparatorChar = '\\';

    /// <summary>
    /// The alternative directory separator character (forward slash).
    /// </summary>
    public const char AltDirectorySeparatorChar = '/';

    /// <summary>
    /// Length of the UNC prefix (\\).
    /// </summary>
    // \\
    public const int UncPrefixLength = 2;

    /// <summary>
    /// Length of the extended UNC prefix (\\?\UNC\ or \\.\UNC\).
    /// </summary>
    // \\?\UNC\, \\.\UNC\
    public const int UncExtendedPrefixLength = 8;

    /// <summary>
    /// The volume separator character (colon on Windows).
    /// </summary>
    public const char VolumeSeparatorChar = ':';

    /// <summary>
    /// Length of the device prefix (\\?\ or \\.\).
    /// </summary>
    public const int DevicePrefixLength = 4;

    /// <summary>
    /// Returns true if the path ends in a directory separator character.
    /// </summary>
    /// <param name="path">The path to check.</param>
    public static bool EndsInDirectorySeparator(ReadOnlySpan<char> path)
    {
        return EndsInDirectorySeparator2(path);
    }

    /// <summary>
    /// Returns true if the path ends in a directory separator character.
    /// </summary>
    /// <param name="path">The path to check.</param>
    public static bool EndsInDirectorySeparator2(ReadOnlySpan<char> path)
    {
        return path.Length > 0 && IsDirectorySeparator(path[path.Length - 1]);
    }

    /// <summary>
    ///     Get the common path length from the start of the string.
    /// </summary>
    /// <param name="first">The first path to compare.</param>
    /// <param name="second">The second path to compare.</param>
    /// <param name="ignoreCase">Whether to ignore character casing during comparison.</param>
    public static int GetCommonPathLength(string first, string second, bool ignoreCase)
    {
        int commonChars = EqualStartingCharacterCount(first, second, ignoreCase);

        // If nothing matches
        if (commonChars == 0)
        {
            return commonChars;
        }

        // Or we're a full string and equal length or match to a separator
        if (commonChars == first.Length
            && (commonChars == second.Length || IsDirectorySeparator(second[commonChars])))
        {
            return commonChars;
        }

        if (commonChars == second.Length && IsDirectorySeparator(first[commonChars]))
        {
            return commonChars;
        }

        // It's possible we matched somewhere in the middle of a segment e.g. C:\Foodie and C:\Foobar.
        while (commonChars > 0 && !IsDirectorySeparator(first[commonChars - 1]))
        {
            commonChars--;
        }

        return commonChars;
    }

    /// <summary>
    /// Returns the number of characters that match at the start of two strings.
    /// </summary>
    /// <param name="first">The first string to compare.</param>
    /// <param name="second">The second string to compare.</param>
    /// <param name="ignoreCase">Whether to ignore character casing during comparison.</param>
    public static int EqualStartingCharacterCount(string first, string second, bool ignoreCase)
    {
        if (ignoreCase)
        {
            first = first.ToLower();
            second = second.ToLower();
        }

        int maxLength = Math.Min(first.Length, second.Length);
        for (int i = 0; i < maxLength; i++)
        {
            if (first[i] != second[i])
            {
                return i;
            }
        }

        return 0;
    }

    /// <summary>
    ///     Returns true if the two paths have the same root.
    /// </summary>
    /// <param name="first">The first path to compare.</param>
    /// <param name="second">The second path to compare.</param>
    /// <param name="comparisonType">The string comparison type to use.</param>
    public static bool AreRootsEqual(string first, string second, StringComparison comparisonType)
    {
        int firstRootLength = GetRootLength(first.AsSpan());
        int secondRootLength = GetRootLength(second.AsSpan());

        return firstRootLength == secondRootLength
               && string.Compare(
                   first,
                   0,
                   second,
                   0,
                   firstRootLength,
                   comparisonType) == 0;
    }

    /// <summary>
    ///     Returns true if the path uses the canonical form of extended syntax (@"\\?\" or "\??\"). If the
    ///     path matches exactly (cannot use alternate directory separators) Windows will skip normalization
    ///     and path length checks.
    /// </summary>
    /// <param name="path">The path to check.</param>
    public static bool IsExtended(ReadOnlySpan<char> path)
    {
        // While paths like "//?/C:/" will work, they're treated the same as "\\.\" paths.
        // Skipping of normalization will *only* occur if back slashes ('\'') are used.
        return path.Length >= DevicePrefixLength
               && path[0] == '\\'
               && (path[1] == '\\' || path[1] == '?')
               && path[2] == '?'
               && path[3] == '\\';
    }

    /// <summary>
    ///     Returns true if the path uses any of the DOS device path syntaxes. ("\\.\", @"\\?\", or "\??\")
    /// </summary>
    /// <param name="path">The path to check.</param>
    public static bool IsDevice(ReadOnlySpan<char> path)
    {
        // If the path begins with any two separators is will be recognized and normalized and prepped with
        // "\??\" for public usage correctly. "\??\" is recognized and handled, "/??/" is not.
        return IsExtended(path)
               ||
               (
                   path.Length >= DevicePrefixLength
                   && IsDirectorySeparator(path[0])
                   && IsDirectorySeparator(path[1])
                   && (path[2] == '.' || path[2] == '?')
                   && IsDirectorySeparator(path[3])
               );
    }

    /// <summary>
    ///     Returns true if the path is a device UNC (\\?\UNC\, \\.\UNC\)
    /// </summary>
    /// <param name="path">The path to check.</param>
    public static bool IsDeviceUNC(ReadOnlySpan<char> path)
    {
        return path.Length >= UncExtendedPrefixLength
               && IsDevice(path)
               && IsDirectorySeparator(path[7])
               && path[4] == 'U'
               && path[5] == 'N'
               && path[6] == 'C';
    }

    /// <summary>
    ///     True if the given character is a directory separator.
    /// </summary>
    /// <param name="c">The character to check.</param>
    //[MethodImpl(MethodImplOptions.AggressiveInlining)]
    public static bool IsDirectorySeparator(char c)
    {
        return c == DirectorySeparatorChar || c == AltDirectorySeparatorChar;
    }

    /// <summary>
    ///     Gets the length of the root of the path (drive, share, etc.).
    /// </summary>
    /// <param name="path">The path to analyze.</param>
    public static int GetRootLength(ReadOnlySpan<char> path)
    {
        int pathLength = path.Length;
        int i = 0;

        bool deviceSyntax = IsDevice(path);
        bool deviceUnc = deviceSyntax && IsDeviceUNC(path);

        if ((!deviceSyntax || deviceUnc) && pathLength > 0 && IsDirectorySeparator(path[0]))
        {
            // UNC or simple rooted path (e.g. "\foo", NOT "\\?\C:\foo")
            if (deviceUnc || (pathLength > 1 && IsDirectorySeparator(path[1])))
            {
                // UNC (\\?\UNC\ or \\), scan past server\share

                // Start past the prefix ("\\" or "\\?\UNC\")
                i = deviceUnc ? UncExtendedPrefixLength : UncPrefixLength;

                // Skip two separators at most
                int n = 2;
                while (i < pathLength && (!IsDirectorySeparator(path[i]) || --n > 0))
                {
                    i++;
                }
            }
            else
            {
                // Current drive rooted (e.g. "\foo")
                i = 1;
            }
        }
        else if (deviceSyntax)
        {
            // Device path (e.g. "\\?\.", "\\.\")
            // Skip any characters following the prefix that aren't a separator
            i = DevicePrefixLength;
            while (i < pathLength && !IsDirectorySeparator(path[i]))
            {
                i++;
            }

            // If there is another separator take it, as long as we have had at least one
            // non-separator after the prefix (e.g. don't take "\\?\\", but take "\\?\a\")
            if (i < pathLength && i > DevicePrefixLength && IsDirectorySeparator(path[i]))
            {
                i++;
            }
        }
        else if (pathLength >= 2
                 && path[1] == VolumeSeparatorChar
                 && IsValidDriveChar(path[0]))
        {
            // Valid drive specified path ("C:", "D:", etc.)
            i = 2;

            // If the colon is followed by a directory separator, move past it (e.g "C:\")
            if (pathLength > 2 && IsDirectorySeparator(path[2]))
            {
                i++;
            }
        }

        return i;
    }

    /// <summary>
    ///     Returns true if the given character is a valid drive letter
    /// </summary>
    /// <param name="value">The character to check.</param>
    public static bool IsValidDriveChar(char value)
    {
        return (value >= 'A' && value <= 'Z') || (value >= 'a' && value <= 'z');
    }
}