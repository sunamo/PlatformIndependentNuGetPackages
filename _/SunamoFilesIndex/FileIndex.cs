namespace SunamoFilesIndex;
using SunamoFilesIndex._sunamo;
using SunamoFilesIndex.Data;

/// <summary>
/// Připomíná práci s databází - k označení složek se používají čísla int
///
/// Working with CheckBoxData
/// Use FolderItem, FileItem,
/// </summary>
public class FileIndex
{
    #region Only single static variable relativeDirectories
    /// <summary>
    /// Without base paths
    /// </summary>
    public static List<string> relativeDirectories = new List<string>();
    #endregion

    #region Variables
    /// <summary>
    ///
    /// </summary>
    public List<FileItem> files = new List<FileItem>();
    /// <summary>
    /// All folders which was processed expect root
    /// </summary>
    private List<FolderItem> _folders = new List<FolderItem>();
    private int _actualFolderID = -1;

    // TODO: Is directories somewhere used?
    /// <summary>
    /// NEOBSAHUJE VSECHNY ZPRACOVANE SLOZKY
    /// Všechny složky tak jak byly postupně přidávany do metody AddFolderRecursively
    ///
    /// </summary>
    public static List<string> directories = new List<string>();
    private string _basePath = null;

    public string BasePath
    {
        get
        {
            return _basePath;
        }
    }
    #endregion

    #region Instance method
    /// <summary>
    /// Get folders with name A2. A1 is IDParent
    /// </summary>
    /// <param name="prohledavatSlozky"></param>
    /// <param name="name"></param>
    public IList<FolderItem> GetFoldersWithName(int[] prohledavatSlozky, string name)
    {
        if (prohledavatSlozky == null)
        {
            return _folders.Where(c => c.Name == name).ToList();
        }
        return _folders.Where(c => c.Name == name).Where(d => prohledavatSlozky.Contains(d.IDParent)).ToList();
    }

    public List<FileItem> FindAllFilesWithName(string name)
    {
        return files.FindAll(d => d.Name == name);
    }

    /// <summary>
    /// Process all files including subfolders
    ///
    /// A1 musí být cesta zakončená slashem
    /// </summary>
    /// <param name="folder"></param>
    /// <param name="relativeDirectoryName"></param>
    public void AddFolderRecursively(string folder)
    {
        folder = FS.WithEndSlash(folder);
        _basePath = folder;
        _actualFolderID++;
        directories.Add(folder);

        var dirs = Directory.GetDirectories(folder, "*", SearchOption.AllDirectories);
        List<string> fils = new List<string>();

        foreach (var item in dirs)
        {
            _folders.Add(GetFolderItem(item));
            AddFilesFromFolder(folder, item);
        }

        AddFilesFromFolder(folder, FS.WithoutEndSlash(folder));
    }

    /// <summary>
    /// Index all files from A3.
    ///
    /// A1 - full path to base folder
    /// A2 - whether use relativeDirectories
    /// A3 - full path to actual folder
    /// Add with relative file path
    /// </summary>
    /// <param name="basePath"></param>
    /// <param name="relativeDirectoryName"></param>
    /// <param name="folder"></param>
    private void AddFilesFromFolder(string basePath, string folder)
    {
        var files2 = Directory.GetFiles(folder, "*.*", SearchOption.TopDirectoryOnly);
        files2.ToList().ForEach(c => files.Add(GetFileItem(c, basePath)));
    }

    private FolderItem GetFolderItem(string p)
    {
        FolderItem fi = new FolderItem();
        fi.IDParent = _actualFolderID;
        fi.Name = Path.GetFileName(p);
        fi.Path = Path.GetDirectoryName(p);
        return fi;
    }

    /// <summary>
    /// Return index of folder or -1 if cannot found
    /// </summary>
    /// <param name="folder"></param>
    public int GetRelativeFolder(string folder)
    {
        folder = FS.WithEndSlash(folder);
        return relativeDirectories.IndexOf(folder);
    }

    public string GetRelativeFolder(int folder)
    {
        return relativeDirectories[folder];
    }

    /// <summary>
    /// Return object FIleItem.
    /// Add to relativeDirectories, if A3.
    ///
    /// A3 - whether save to relativeDirectories and can use indexes for directory
    /// </summary>
    /// <param name="p"></param>
    /// <param name="basePath"></param>
    /// <param name="relativeDirectoryName"></param>
    private FileItem GetFileItem(string p, string basePath)
    {
        FileItem fi = new FileItem();
        //fi.IDDirectory = folders.Count;
        //fi.IDParent = actualFolderID;
        fi.Name = Path.GetFileName(p);
        //fi.Path = Path.GetDirectoryName(p);

        //if (relativeDirectoryName)
        //{
        string relDirName = Path.GetDirectoryName(p).Replace(basePath, "");
        if (!relativeDirectories.Contains(relDirName))
        {
            relativeDirectories.Add(relDirName);
            // Počítá se od 1
            fi.IDRelativeDirectory = relativeDirectories.Count;
        }
        else
        {
            fi.IDRelativeDirectory = relativeDirectories.IndexOf(relDirName) + 1;
        }
        //}
        return fi;
    }

    /// <summary>
    /// Clear folders and files collection
    /// </summary>
    public void Nuke()
    {
        _folders.Clear();
        files.Clear();
    }

    public int GetIndexOfFolder(FolderItem item)
    {
        return _folders.IndexOf(item);
    }

    public IList<FileItem> GetFilesInRelativeFolder(int p)
    {
        return files.Where(c => c.IDRelativeDirectory == p).ToList();
    }
    #endregion

    #region Has FileIndex as input or output parameter
    /// <summary>
    /// Process recursively A1 - for every folder one object FileIndex in output
    ///
    /// </summary>
    /// <param name="folders"></param>
    public static Dictionary<string, FileIndex> IndexFolders(IList<string> folders)
    {
        Dictionary<string, FileIndex> vr = new Dictionary<string, FileIndex>();
        foreach (var item in folders)
        {
            FileIndex fi = new FileIndex();
            fi.AddFolderRecursively(item);
            vr.Add(item, fi);
        }
        return vr;
    }

    /// <summary>
    /// Prida do A3 soubor s relativni cestou pokud neexistuje
    /// Use relative path to file to find relative id directory and insert with file path to ID to A3
    ///
    /// A1 - base path, will be discard, used to make relative file paths from A2
    /// A2 -
    /// A3 - key is relative file path, value is index of relative directory
    /// A4 - relative paths to files which is used to fill A3. no change
    /// </summary>
    /// <param name="folderOfSolution"></param>
    /// <param name="fi"></param>
    /// <param name="relativeFilePathForEveryColumn"></param>
    /// <param name="filesFromAllFoldersUniqueRelative"></param>
    public static void AggregateFilesFromAllFolders(string folderOfSolution, FileIndex fi, Dictionary<string, int> relativeFilePathForEveryColumn, List<string> filesFromAllFoldersUniqueRelative)
    {
        foreach (var item2 in fi.files)
        {
            string relativeFilePath = (relativeDirectories[item2.IDRelativeDirectory] + item2.Name).Replace(folderOfSolution, "");

            if (!relativeFilePathForEveryColumn.ContainsKey(relativeFilePath))
            {
                int relativeDirectoryId = filesFromAllFoldersUniqueRelative.IndexOf(relativeFilePath);
                relativeFilePathForEveryColumn.Add(relativeFilePath, relativeDirectoryId);
            }
        }
    }

    /// <summary>
    /// Tato metoda má za úkol vytvořit matici ze souborů v A1, kde každý soubor bude v daném sloupci dle A2
    /// Kdyz soubor nebude existovat bude null
    ///
    /// Load size of files from disc
    /// In key of A2 - relativeFilePath, value - index of column.
    /// </summary>
    /// <param name="files"></param>
    /// <param name="relativeFilePathForEveryColumn"></param>
    public static CheckBoxDataShared<TWithSize<string>>[,] ExistsFilesOnDrive(Dictionary<string, FileIndex> files, Dictionary<string, int> relativeFilePathForEveryColumn)
    {
        int columns = relativeFilePathForEveryColumn.Count;
        CheckBoxDataShared<TWithSize<string>>[,] vr = new CheckBoxDataShared<TWithSize<string>>[files.Count, columns];
        int r = -1;

        // Process all rows
        foreach (var item in files)
        {
            r++;
            var fi = item.Value;
            //List<long> fileSize = new List<long>(columns);
            //List<int> added = new List<int>();

            for (int c = 0; c < fi.files.Count; c++)
            {
                // get files in column c
                var file = fi.files[c];

                string relativeFilePath = (relativeDirectories[file.IDRelativeDirectory] + file.Name).Replace(item.Key, "");
                int columnToInsert = relativeFilePathForEveryColumn[relativeFilePath];
                string fullFilePath = relativeDirectories[file.IDRelativeDirectory] + file.Name;

                if (File.Exists(fullFilePath))
                {
                    long l2 = new FileInfo(fullFilePath).Length;
                    // To result set CheckBoxData - full path and size
                    vr[r, columnToInsert] = new CheckBoxDataShared<TWithSize<string>> { t = new TWithSize<string> { t = fullFilePath, size = l2 } };
                }
                else
                {
                    vr[r, columnToInsert] = null;
                }
            }
        }

        return vr;
    }
    #endregion

    #region Not use FileIndex
    // TODO: Not use FileIndex, move to other locations
    /// <summary>
    /// Check (or uncheck) all in columns by filesize
    /// </summary>
    /// <param name="allRows"></param>
    public static CheckBoxDataShared<TWithSize<string>>[,] CheckVertically(CheckBoxDataShared<TWithSize<string>>[,] allRows)
    {
        int columns = allRows.GetLength(1);
        int rows = allRows.GetLength(0);

        // List all files
        for (int c = 0; c < columns; c++)
        {
            // Create collections for all rows
            // key - row, value - size
            Dictionary<int, long> fileSize = new Dictionary<int, long>();
            // For easy compare of size and find out any difference
            List<long> fileSize2 = new List<long>();

            for (int r = 0; r < rows; r++)
            {
                CheckBoxDataShared<TWithSize<string>> cbd = allRows[r, c];
                if (cbd != null)
                {
                    fileSize.Add(r, cbd.t.size);
                    fileSize2.Add(cbd.t.size);
                }
            }

            #region Get min and max size
            fileSize2.Sort();

            long min = fileSize2[0];
            long max = fileSize2[fileSize2.Count - 1];
            #endregion

            #region Tick potencially unecesary files
            if (fileSize.Count > 1)
            {
                if (min == max)
                {
                    TickIfItIsForDelete(allRows, 0, c, fileSize, min, max, false);
                    for (int r = 1; r < rows; r++)
                    {
                        TickIfItIsForDelete(allRows, r, c, fileSize, min, max, true);
                    }
                }
                else
                {
                    for (int r = 0; r < rows; r++)
                    {
                        TickIfItIsForDelete(allRows, r, c, fileSize, min, max, null);
                    }
                }
            }
            else
            {
                // Maybe leave file with zero size?
                TickIfItIsForDelete(allRows, 0, c, fileSize, min, max, false);
            }
            #endregion
        }
        return allRows;
    }

    /// <summary>
    /// Check CheckBox in condition of size and A7 in location specified parameter row A2 and column A3
    ///
    /// A4 to find size of file. In keys are indexes.
    /// If size is A5 min, check.
    /// If A6 max, uncheck.
    /// Or none of this, set null. This behaviour can be changed setted A7 forceToAll
    /// </summary>
    /// <param name="allRows"></param>
    /// <param name="row"></param>
    /// <param name="column"></param>
    /// <param name="fileSize"></param>
    /// <param name="min"></param>
    /// <param name="max"></param>
    /// <param name="forceToAll"></param>
    private static void TickIfItIsForDelete(CheckBoxDataShared<TWithSize<string>>[,] allRows, int row, int column, Dictionary<int, long> fileSize, long min, long max, bool? forceToAll)
    {
        CheckBoxDataShared<TWithSize<string>> cbd = allRows[row, column];
        if (cbd != null)
        {
            long filSiz = fileSize[row];
            if (filSiz == -1)
            {
            }
            else if (filSiz == max)
            {
                if (forceToAll.HasValue)
                {
                    cbd.tick = forceToAll.Value;
                }
                else
                {
                    cbd.tick = false;
                }
            }
            else if (filSiz == min)
            {
                if (forceToAll.HasValue)
                {
                    cbd.tick = forceToAll.Value;
                }
                else
                {
                    cbd.tick = true;
                }
            }
            else
            {
                if (forceToAll.HasValue)
                {
                    cbd.tick = forceToAll.Value;
                }
                else
                {
                    cbd.tick = null;
                }
            }
        }
    }
    #endregion
}