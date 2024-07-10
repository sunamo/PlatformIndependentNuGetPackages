namespace SunamoGetFolders._sunamo.SunamoGetFiles;
internal class FSGetFiles
{
    internal static List<string> GetFiles(string item, string masc, SearchOption topDirectoryOnly)
    {
        return Directory.GetFiles(item, masc, topDirectoryOnly).ToList() ;
    }
}
