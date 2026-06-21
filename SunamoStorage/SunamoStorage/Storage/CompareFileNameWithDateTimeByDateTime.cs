namespace SunamoStorage.Storage;

/// <summary>
/// Comparer for FileNameWithDateTimeTU by DateTime value.
/// </summary>
public class CompareFileNameWithDateTimeByDateTime<StorageFolder, StorageFile> : ISunamoComparer<FileNameWithDateTimeTU<StorageFolder, StorageFile>>
{
    /// <summary>
    /// Compares two items by DateTime in descending order.
    /// </summary>
    /// <param name="first">The first item to compare.</param>
    /// <param name="second">The second item to compare.</param>
    public int Desc(FileNameWithDateTimeTU<StorageFolder, StorageFile> first, FileNameWithDateTimeTU<StorageFolder, StorageFile> second)
    {
        return first.DateTime.CompareTo(second.DateTime) * -1;
    }

    /// <summary>
    /// Compares two items by DateTime in ascending order.
    /// </summary>
    /// <param name="first">The first item to compare.</param>
    /// <param name="second">The second item to compare.</param>
    public int Asc(FileNameWithDateTimeTU<StorageFolder, StorageFile> first, FileNameWithDateTimeTU<StorageFolder, StorageFile> second)
    {
        return first.DateTime.CompareTo(second.DateTime);
    }
}
