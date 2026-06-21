namespace SunamoStorage.Storage;

/// <summary>
/// Manages a date-time based file index for organizing and retrieving stored files.
/// </summary>
/// <typeparam name="StorageFolder">The type representing a storage folder.</typeparam>
/// <typeparam name="StorageFile">The type representing a storage file.</typeparam>
public class DateTimeFileIndexT<StorageFolder, StorageFile>
{
    /// <summary>
    /// The abstract catalog used for storage operations.
    /// </summary>
    public AbstractCatalogShared<StorageFolder, StorageFile> Catalog { get; set; } = null!;

    /// <summary>
    /// Raised when initialization of the file list is complete.
    /// </summary>
    public event Action<List<FileNameWithDateTimeTU<StorageFolder, StorageFile>>>? InitComplete;

    private string? extension = null;
    /// <summary>
    /// The list of file entries with associated date-time metadata.
    /// </summary>
    public List<FileNameWithDateTimeTU<StorageFolder, StorageFile>> Files { get; set; } = new List<FileNameWithDateTimeTU<StorageFolder, StorageFile>>();
    private FileEntriesDuplicitiesStrategy duplicityStrategy = FileEntriesDuplicitiesStrategy.Time;
    private LangsShared lang = LangsShared.cs;

#pragma warning disable
    /// <summary>
    /// Returns the full path of the specified file entry.
    /// </summary>
    /// <param name="fileEntry">The file entry to resolve.</param>
    /// <returns>The full path string, or null if not resolved.</returns>
    public string GetFullPath(FileNameWithDateTimeTU<StorageFolder, StorageFile> fileEntry)
    {
        return null;
    }
#pragma warning restore

    /// <summary>
    /// Initializes a new empty instance of the file index.
    /// </summary>
    public DateTimeFileIndexT()
    {
    }

    /// <summary>
    /// Initializes the file index with the given extension, duplicity strategy, and catalog.
    /// A4 was nowhere used, deleted
    /// </summary>
    /// <param name="ext">The file extension to filter by.</param>
    /// <param name="ds">The duplicity strategy for file entries.</param>
    /// <param name="catalog">The abstract catalog for storage operations.</param>
    public void Initialize(string ext, FileEntriesDuplicitiesStrategy ds, AbstractCatalogShared<StorageFolder, StorageFile> catalog)
    {
        this.Catalog = catalog;
        duplicityStrategy = ds;
        extension = ext;
        string mask = "????_??_??_";
        if (ds == FileEntriesDuplicitiesStrategy.Serie)
        {
            mask += "S_?*_";
        }
        else if (ds == FileEntriesDuplicitiesStrategy.Time)
        {
            mask += "??_??_";
        }
        else
        {
            throw new Exception(Translate.FromKey(XlfKeys.NotSupportedStrategyOfSavingFiles) + ".");
        }
        mask += "*" + ext;
        List<StorageFile>? storageFiles = null;
        foreach (var item in storageFiles!)
        {
        }
        if (ds == FileEntriesDuplicitiesStrategy.Serie)
        {
            Files.Sort(new CompareFileNameWithDateTimeBySerie<StorageFolder, StorageFile>().Desc);
        }
        Files.Sort(new CompareFileNameWithDateTimeByDateTime<StorageFolder, StorageFile>().Desc);
        if (InitComplete != null)
        {
            InitComplete(Files);
        }
    }

    private FileEntriesDuplicitiesStrategy GetFileEntriesDuplicitiesStrategy(string fileNameWithoutExtension, out int? serie, out int hour, out int minute, out string postfix)
    {
        serie = null;
        minute = hour = 0;
        if (fileNameWithoutExtension[11] == 'S')
        {
            var parts = SHSplit.Split(fileNameWithoutExtension, "_");
            serie = int.Parse(parts[4]);
            postfix = SHJoin.JoinFromIndex(5, "_", parts);
            return FileEntriesDuplicitiesStrategy.Serie;
        }
        else
        {
            string filePath = fileNameWithoutExtension.Substring(11, 5);
            var parts = SHSplit.Split(filePath, "_");
            hour = int.Parse(parts[0]);
            minute = int.Parse(parts[1]);
            postfix = SHJoin.JoinFromIndex(5, "_", parts);
            return FileEntriesDuplicitiesStrategy.Time;
        }
    }

    /// <summary>
    /// Creates a file entry object from display rows and the current catalog.
    /// </summary>
    /// <param name="row1">The first display row text.</param>
    /// <param name="row2">The second display row text.</param>
    /// <param name="catalog">The abstract catalog for storage operations.</param>
    /// <returns>A new file entry with parsed date-time and metadata.</returns>
    public FileNameWithDateTimeTU<StorageFolder, StorageFile> CreateObjectFileNameWithDateTime(string row1, string row2, AbstractCatalogShared<StorageFolder, StorageFile> catalog)
    {
        FileNameWithDateTimeTU<StorageFolder, StorageFile> entry = new FileNameWithDateTimeTU<StorageFolder, StorageFile>(row1, row2, catalog);
        string? fileNameWithoutExtension = null;
        string dateS = fileNameWithoutExtension!.Substring(0, 10);
        entry.DateTime = DateTime.ParseExact(dateS, "yyyy_MM_dd", null);
        int? serie;
        int hour;
        int minute;
        string postfix;
        var strategy = GetFileEntriesDuplicitiesStrategy(fileNameWithoutExtension, out serie, out hour, out minute, out postfix);
        entry.Serie = serie;
        entry.DateTime.AddMinutes(minute);
        entry.DateTime.AddHours(hour);
        entry.Name = postfix;
        entry.FileNameWithoutExtension = DeleteWrongCharsInFileName(fileNameWithoutExtension);
        entry.Row1 = postfix;
        entry.Row2 = entry.DateTime.ToShortDateString();
        return entry;
    }

    private static string GetDisplayText(DateTime date, int? serie, LangsShared lang)
    {
        string displayText;
        if (serie == null)
        {
            displayText = DTHelper.DateTimeToString(date, lang, new(1900, 1, 1));
        }
        else
        {
            int serieValue = serie.Value;
            string serieSuffix = "";
            if (serieValue != 0)
            {
                serieSuffix = " (" + serieValue + ")";
            }
            displayText = DTHelper.DateToString(date, lang) + serieSuffix;
        }
        return displayText;
    }

    private FileNameWithDateTimeTU<StorageFolder, StorageFile> CreateObjectFileNameWithDateTime(string row1, string row2, DateTime date, int? serie, string postfix, string fileNameWithoutExtension)
    {
        FileNameWithDateTimeTU<StorageFolder, StorageFile> entry = new FileNameWithDateTimeTU<StorageFolder, StorageFile>(row1, row2, Catalog);
        entry.DateTime = date;
        entry.Serie = serie;
        entry.Name = postfix;
        entry.FileNameWithoutExtension = DeleteWrongCharsInFileName(fileNameWithoutExtension);
        return entry;
    }

    private string DeleteWrongCharsInFileName(string fileNameWithoutExtension)
    {
        return SHReplace.ReplaceAll(FS.DeleteWrongCharsInFileName(fileNameWithoutExtension, false), "_", "");
    }

    /// <summary>
    /// Deletes the specified file entry from storage and removes it from the file list.
    /// </summary>
    /// <param name="fileEntry">The file entry to delete.</param>
    public void DeleteFile(FileNameWithDateTimeTU<StorageFolder, StorageFile> fileEntry)
    {
        try
        {
            string filePath = GetStorageFile(fileEntry);
            FS.TryDeleteFile(filePath);
            Files.Remove(fileEntry);
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
    }

#pragma warning disable
    /// <summary>
    /// Gets the storage file path for the specified file entry.
    /// </summary>
    /// <param name="fileEntry">The file entry to resolve.</param>
    /// <returns>The storage file path, or null if not resolved.</returns>
    public string GetStorageFile(FileNameWithDateTimeTU<StorageFolder, StorageFile> fileEntry)
    {
        return null;
    }
#pragma warning restore

    /// <summary>
    /// Saves a file with a date-time based name using the duplicity strategy specified during initialization.
    /// Does not add to the files collection directly; returns the created entry.
    /// </summary>
    /// <param name="name">The display name or postfix for the file.</param>
    /// <param name="content">The file content to write.</param>
    /// <returns>The created file entry with date-time metadata.</returns>
    public async Task<FileNameWithDateTimeTU<StorageFolder, StorageFile>> SaveFileWithDate(string name, string content)
    {
        DateTime dateTime = DateTime.Now;
        DateTime today = DateTime.Today;
        string fileNameWithoutExtension = "";
        int? max = null;
        if (duplicityStrategy == FileEntriesDuplicitiesStrategy.Time)
        {
            fileNameWithoutExtension = ConvertDateTimeToFileNamePostfix.ToConvention(name, dateTime, true);
        }
        else if (duplicityStrategy == FileEntriesDuplicitiesStrategy.Serie)
        {
            IList<int?> serieValues = Files.Where(fileEntry => fileEntry.DateTime == today).Select(fileEntry => fileEntry.Serie).ToList();
            max = serieValues.Count();
            if (max != 0)
            {
                max = serieValues.Max() + 1;
            }
            if (!max.HasValue)
            {
                max = 1;
            }
            fileNameWithoutExtension = DTHelper.DateTimeToFileName(dateTime, false) + "_S_" + max.Value + "_" + name;
        }
        else
        {
            // Unnecessary, already checked in constructor
        }
#if DEBUG
#endif
        var fileEntry = CreateObjectFileNameWithDateTime(GetDisplayText(dateTime, max, lang), name, dateTime, max, name, fileNameWithoutExtension);
        Files.Add(fileEntry);
        return fileEntry;
    }
}
