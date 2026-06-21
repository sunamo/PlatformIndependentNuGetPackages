namespace SunamoSharedMisc._SunamoExceptions.Delegates;

/// <summary>
/// Delegate for checking directory existence, redirecting to FSApps or FS.
/// Returns bool? to signal unauthorized access (e.g. accessing .xlf in UWP).
/// </summary>
/// <param name="path">The directory path to check for existence.</param>
public delegate bool? ExistsDirectory(string path);