namespace SunamoGetFiles._public.SunamoArgs;


public class GetFilesMoreMascArgs : GetFilesBaseArgs
{
    public bool LoadFromFileWhenDebug = false;
    public string path;
    public string masc = "*";
    public SearchOption searchOption = SearchOption.TopDirectoryOnly;
    public bool deleteFromDriveWhenCannotBeResolved = false;
}