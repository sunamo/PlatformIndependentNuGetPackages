namespace SunamoThreading.Downloading;
/// <summary>
/// Obsahuje URI ke stažení - každá URI má jedinečné identifikační číslo
/// </summary>
public class InputDownload : IInputDownload
{
    public InputDownload(string uri, int id)
    {
        Uri = uri;
        ID = id;
    }

    public int ID = 0;

    public string Uri
    {
        get;
        set;
    }
}
