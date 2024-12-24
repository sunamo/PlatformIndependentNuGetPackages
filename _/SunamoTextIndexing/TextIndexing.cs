namespace SunamoTextIndexing;
using SunamoTextIndexing.Data;

public class TextIndexing
{
    /// <summary>
    /// In key is full path to file
    /// </summary>
    public Dictionary<string, FileForSearching> files = null;
    private bool _v1;
    private bool _v2;
    private bool _v3;

    public TextIndexing(bool v1, bool v2, bool v3)
    {
        _v1 = v1;
        _v2 = v2;
        _v3 = v3;
    }

    public void ReloadFiles(List<string> list)
    {
        files.Clear();

        foreach (var item in list)
        {
            files.Add(item, new FileForSearching(item));
        }
    }
}