namespace SunamoHttp._sunamo.SunamoFileSystem;
internal class FS
{
    internal static void CreateUpfoldersPsysicallyUnlessThere(string nad)
    {
        CreateFoldersPsysicallyUnlessThere(Path.GetDirectoryName(nad));
    }

    internal static void CreateFoldersPsysicallyUnlessThere(string nad)
    {
        ThrowEx.IsNullOrEmpty("nad", nad);
        ThrowEx.IsNotWindowsPathFormat("nad", nad);


        if (Directory.Exists(nad))
        {
            return;
        }

        List<string> slozkyKVytvoreni = new List<string>
{
nad
};

        while (true)
        {
            nad = Path.GetDirectoryName(nad);

            // TODO: Tady to nefunguje pro UWP/UAP apps protoze nemaji pristup k celemu disku. Zjistit co to je UWP/UAP/... a jak v nem ziskat/overit jakoukoliv slozku na disku
            if (Directory.Exists(nad))
            {
                break;
            }

            string kopia = nad;
            slozkyKVytvoreni.Add(kopia);
        }

        slozkyKVytvoreni.Reverse();
        foreach (string item in slozkyKVytvoreni)
        {
            string folder = item;
            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }
        }
    }

    internal static string Combine(params string[] folder2)
    {
        return Path.Combine(folder2);
    }

    internal static bool ExistsFile(string path)
    {
        return FS.ExistsFile(path);
    }

    internal static long GetFileSize(string item)
    {
        FileInfo fi = null;
        try
        {
            fi = new FileInfo(item);
        }
        catch (Exception ex)
        {
            // Například příliš dlouhý název souboru
            return 0;
        }
        if (fi.Exists)
        {
            return fi.Length;
        }
        return 0;
    }

    internal static string GetExtension(string href)
    {
        return Path.GetExtension(href);
    }

    internal static void GetPathAndFileNameWithoutExtension(string fn, out string path, out string file, out string ext)
    {
        path = Path.GetDirectoryName(fn) + AllChars.bs;
        file = Path.GetFileNameWithoutExtension(fn);
        ext = Path.GetExtension(fn);
    }

    internal static string GetTempFilePath()
    {
        return Path.Combine(System.IO.Path.GetTempPath(), System.IO.Path.GetTempFileName());
    }

    //internal static void MoveFile(string item, string fileTo, FileMoveCollisionOption co)
    //{
    //    if (CopyMoveFilePrepare(ref item, ref fileTo, co))
    //    {
    //        try
    //        {
    //            item = FS.MakeUncLongPath(item);
    //            fileTo = FS.MakeUncLongPath(fileTo);

    //            if (co == FileMoveCollisionOption.DontManipulate && File.Exists(fileTo))
    //            {
    //                return;
    //            }
    //            File.Move(item, fileTo);
    //        }
    //        catch (Exception ex)
    //        {
    //            //ThisApp.Error(item + " : " + ex.Message);
    //        }
    //    }
    //    else
    //    {
    //    }
    //}

    internal static string ReplaceInvalidFileNameChars(string v)
    {
        return string.Concat(v.Split(Path.GetInvalidFileNameChars()));
    }
}
