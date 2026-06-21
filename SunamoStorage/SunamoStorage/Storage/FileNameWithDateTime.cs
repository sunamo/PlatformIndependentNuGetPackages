namespace SunamoStorage.Storage;

/// <summary>
/// File name with DateTime using string-based storage types.
/// </summary>
public class FileNameWithDateTime : FileNameWithDateTimeTU<string, string>
{
    /// <summary>
    /// Initializes a new instance with display row values.
    /// </summary>
    /// <param name="row1">The first display row text.</param>
    /// <param name="row2">The second display row text.</param>
    public FileNameWithDateTime(string row1, string row2) : base(row1, row2, null!)
    {
    }
}
