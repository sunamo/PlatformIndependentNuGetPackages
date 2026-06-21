namespace SunamoEntity._public.SunamoEnums.Enums;

/// <summary>
/// Specifies the type of file operation exception that occurred.
/// </summary>
public enum FileExceptions
{
    /// <summary>
    /// No exception occurred.
    /// </summary>
    None,
    /// <summary>
    /// The specified file was not found.
    /// </summary>
    FileNotFound,
    /// <summary>
    /// Access to the file was denied.
    /// </summary>
    UnauthorizedAccess,
    /// <summary>
    /// A general file operation error occurred.
    /// </summary>
    General
}