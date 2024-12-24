namespace SunamoFilesIndex;
using SunamoFilesIndex.Interfaces;

public class FolderItem : IFSItem
{
    private string _name = null;
    public string Name
    {
        get => _name;
        set => _name = value;
    }

    private string _path = null;
    public string Path
    {
        get => _path;
        set => _path = value;
    }


    private int _iDParent = -1;
    public int IDParent
    {
        get => _iDParent;
        set => _iDParent = value;
    }
    private long _length = -1;
    public long Length
    {
        get
        {
            return _length;
        }
        set
        {
            _length = value;
        }
    }
    private bool _hasFolderSubfolder = false;
    public bool HasFolderSubfolder
    {
        get
        {
            return _hasFolderSubfolder;
        }
        set
        {
            _hasFolderSubfolder = value;
        }
    }
}