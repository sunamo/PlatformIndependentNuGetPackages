namespace SunamoStorage.Storage;

/// <summary>
/// File name with associated DateTime, serie number, and display text.
/// </summary>
/// <typeparam name="StorageFolder">The type representing a storage folder.</typeparam>
/// <typeparam name="StorageFile">The type representing a storage file.</typeparam>
public class FileNameWithDateTimeTU<StorageFolder, StorageFile>
{
    private AbstractCatalogShared<StorageFolder, StorageFile> catalog;

    /// <summary>
    /// The date and time associated with the file.
    /// </summary>
    public DateTime DateTime { get; set; } = DateTime.MinValue;

    /// <summary>
    /// The display name or postfix of the file.
    /// </summary>
    public string Name { get; set; } = "";

    /// <summary>
    /// The serie number. If set, time is not used for identification.
    /// </summary>
    public int? Serie { get; set; } = null;

    /// <summary>
    /// The file name without extension.
    /// </summary>
    public string FileNameWithoutExtension { get; set; } = "";

    /// <summary>
    /// Gets the serie value (throws if null).
    /// </summary>
    public int SerieValue
    {
        get
        {
            return Serie!.Value;
        }
    }

    private string? displayText = null;
    private string row1 = string.Empty;
    private string row2 = string.Empty;

    /// <summary>
    /// Creates a new instance with display row values and catalog reference.
    /// </summary>
    /// <param name="row1">The first display row text.</param>
    /// <param name="row2">The second display row text.</param>
    /// <param name="catalog">The abstract catalog reference.</param>
    public FileNameWithDateTimeTU(string row1, string row2, AbstractCatalogShared<StorageFolder, StorageFile> catalog)
    {
        displayText = row1 + " " + row2;
        this.row1 = row1;
        this.row2 = row2;
        this.catalog = catalog;
    }

    /// <summary>
    /// First row in SelectorHelperListViewUC.
    /// </summary>
    public string Row1 { get { return row1; } set { row1 = value; } }

    /// <summary>
    /// Second row in SelectorHelperListViewUC.
    /// </summary>
    public string Row2 { get { return row2; } set { row2 = value; } }

    /// <summary>
    /// Returns the combined display text of this file entry.
    /// </summary>
    public override string ToString()
    {
        return displayText!;
    }
}
