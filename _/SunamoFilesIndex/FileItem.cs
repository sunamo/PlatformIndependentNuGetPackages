namespace SunamoFilesIndex;

public class FileItem //: IFSItem
{
    private string _name = null;
    /// <summary>
    /// File name
    /// </summary>
    public string Name
    {
        get
        {
            return _name;
        }
        set
        {
            _name = value;
        }
    }

    #region Commented - use only ID, why I was write this solution??
    //string path = null;
    ///// <summary>
    ///// Full folder path 
    ///// </summary>
    //public string Path
    //{
    //    get
    //    {
    //        return path;
    //    }
    //    set
    //    {
    //        path = value;
    //    }
    //} 
    #endregion

    #region Commented - if I want filter result by root folder, I have to create more FileIndexObjects and potentially foreach all
    //int iDParent = -1;
    ///// <summary>
    ///// folder in FileIndex.directories
    ///// </summary>
    //public int IDParent
    //{
    //    get
    //    {
    //        return iDParent;
    //    }
    //    set
    //    {
    //        iDParent = value;
    //    }
    //} 
    #endregion

    #region Commented - relative directory is succifient
    //int iDDirectory = -1;
    ///// <summary>
    ///// use to find out full path to directory
    ///// folder in FileIndex.folders
    ///// </summary>
    //public int IDDirectory
    //{
    //    get
    //    {
    //        return iDDirectory;
    //    }
    //    set
    //    {
    //        iDDirectory = value;
    //    }
    //} 
    #endregion

    //long length = -1;
    //public long Length
    //{
    //    get
    //    {
    //        return length;
    //    }
    //    set
    //    {
    //        length = value;
    //    }
    //}

    /// <summary>
    /// use with FileIndex.relativeDirectories
    /// POZOR: Počítá se od 1
    /// Relativní cesta k souboru (na začátku chybí bázová třída)
    /// </summary>
    public int IDRelativeDirectory { get; set; }
}
