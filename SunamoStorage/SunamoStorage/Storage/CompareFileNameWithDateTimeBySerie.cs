namespace SunamoStorage.Storage;

/// <summary>
/// Comparer for FileNameWithDateTimeTU by serie value.
/// </summary>
public class CompareFileNameWithDateTimeBySerie<StorageFolder, StorageFile> : ISunamoComparer<FileNameWithDateTimeTU<StorageFolder, StorageFile>>
{
    /// <summary>
    /// Compares two items by SerieValue in descending order.
    /// </summary>
    /// <param name="first">The first item to compare.</param>
    /// <param name="second">The second item to compare.</param>
    public int Desc(FileNameWithDateTimeTU<StorageFolder, StorageFile> first, FileNameWithDateTimeTU<StorageFolder, StorageFile> second)
    {
        return first.SerieValue.CompareTo(second.SerieValue) * -1;
    }

    /// <summary>
    /// Compares two items by SerieValue in ascending order.
    /// </summary>
    /// <param name="first">The first item to compare.</param>
    /// <param name="second">The second item to compare.</param>
    public int Asc(FileNameWithDateTimeTU<StorageFolder, StorageFile> first, FileNameWithDateTimeTU<StorageFolder, StorageFile> second)
    {
        return first.SerieValue.CompareTo(second.SerieValue);
    }
}
