namespace SunamoSharedMisc._public.SunamoEnums.Enums;

/// <summary>
/// Specifies the type of a user-facing message.
/// </summary>
public enum TypeOfMessageShared
{
    /// <summary>
    /// An error message indicating a failure.
    /// </summary>
    Error,

    /// <summary>
    /// A warning message indicating a potential issue.
    /// </summary>
    Warning,
    /// <summary>
    /// An informational message.
    /// </summary>
    Information,

    /// <summary>
    /// An ordinary message with no special severity.
    /// </summary>
    Ordinal,
    /// <summary>
    /// A message that appeals for user attention or action.
    /// </summary>
    Appeal,
    /// <summary>
    /// A success message indicating a completed operation.
    /// </summary>
    Success
}