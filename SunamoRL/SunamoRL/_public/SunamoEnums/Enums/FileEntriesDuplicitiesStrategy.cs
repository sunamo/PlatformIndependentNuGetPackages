namespace SunamoRL._public.SunamoEnums.Enums;

/// <summary>
/// Specifies the strategy for handling duplicate file entries.
/// </summary>
public enum FileEntriesDuplicitiesStrategy
{
    /// <summary>
    /// Appends a serial number suffix to resolve duplicates.
    /// </summary>
    Serie,

    /// <summary>
    /// Appends a timestamp suffix to resolve duplicates.
    /// </summary>
    Time
}