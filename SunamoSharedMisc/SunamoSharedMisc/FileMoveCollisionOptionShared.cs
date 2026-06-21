namespace SunamoSharedMisc;

/// <summary>
/// Specifies the action to take when a file move operation encounters a naming collision.
/// </summary>
public enum FileMoveCollisionOptionShared
{
    /// <summary>
    /// Append a sequential number to the file name to avoid collision.
    /// </summary>
    AddSerie,
    /// <summary>
    /// Append the file size to the file name to avoid collision.
    /// </summary>
    AddFileSize,
    /// <summary>
    /// Overwrite the existing file at the destination.
    /// </summary>
    Overwrite,
    /// <summary>
    /// Discard the source file and keep the existing destination file.
    /// </summary>
    DiscardFrom,
    /// <summary>
    /// Keep the larger file and discard the smaller one.
    /// </summary>
    LeaveLarger,
    /// <summary>
    /// Do not move or modify either file.
    /// </summary>
    DontManipulate
}