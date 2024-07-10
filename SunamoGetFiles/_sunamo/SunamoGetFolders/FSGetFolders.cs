namespace SunamoGetFiles._sunamo.SunamoGetFolders;
internal class FSGetFolders
{
    internal static void GetFoldersEveryFolder(List<string> folders, string folder, string v, GetFoldersEveryFolderArgs e)
    {
        try
        {
            var d = Directory.GetDirectories(folder, v, SearchOption.TopDirectoryOnly);
            folders.AddRange(d);
            foreach (var item in d)
            {
                GetFoldersEveryFolder(folders, item, v, e);
            }
        }
        catch (Exception ex)
        {
            if (e.throwEx)
            {
                throw ex;
            }
            else
            {
                // do nothing
                //return new List<string>();
            }
        }

    }
}
