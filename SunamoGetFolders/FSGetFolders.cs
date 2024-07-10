using WildcardMatch;

namespace SunamoGetFolders;

public class FSGetFolders
{
    public static List<string> GetFolders(string folder, SearchOption so)
    {
        return GetFolders(folder, AllStrings.asterisk, so);
    }
    public static List<string> GetFolders(string v, string contains)
    {
        var folders = GetFolders(v);
        for (int i = 0; i < folders.Count; i++)
        {
            folders[i] = folders[i].TrimEnd(AllChars.bs);
        }
        //CA.TrimEnd(folders, new char[] { AllChars.bs });
        for (int i = folders.Count - 1; i >= 0; i--)
        {
            if (!Wildcard.IsMatch(Path.GetFileName(folders[i]), contains))
            {
                folders.RemoveAt(i);
            }
        }
        return folders;
    }
    public static List<string> GetFolders(string folder)
    {
        return GetFolders(folder, SearchOption.TopDirectoryOnly);
    }
    /// <summary>
    /// Return only subfolder if A3, a1 not include
    /// Must have backslash on end - is folder
    ///
    ///
    /// </summary>
    /// <param name="folder"></param>
    /// <param name="masc"></param>
    /// <param name="so"></param>
    /// <param name="_trimA1"></param>
    public static List<string> GetFolders(string folder, string masc, SearchOption so, bool _trimA1AndLeadingBs = false)
    {
        List<string> dirs = null;
        try
        {
            dirs = Directory.GetDirectories(folder, masc, so).ToList();
        }
        catch (Exception ex)
        {
            ThrowEx.CustomWithStackTrace(ex);
        }
        if (dirs == null)
        {
            return new List<string>();
        }
        //CAChangeContent.ChangeContent0(null, dirs, d => );
        for (int i = 0; i < dirs.Count; i++)
        {
            dirs[i] = SH.FirstCharUpper(dirs[i]);
        }
        if (_trimA1AndLeadingBs)
        {
            for (int i = 0; i < dirs.Count; i++)
            {
                dirs[i] = SH.FirstCharUpper(dirs[i]);
            }
            //CA.Replace(dirs, folder, string.Empty);
            //CA.TrimEnd(dirs, new Char[] { AllChars.bs });
            for (int i = 0; i < dirs.Count; i++)
            {
                dirs[i] = dirs[i].Replace(folder, string.Empty);
            }
            for (int i = 0; i < dirs.Count; i++)
            {
                dirs[i] = dirs[i].TrimEnd('\\');
            }
        }
        else
        {
            for (int i = 0; i < dirs.Count; i++)
            {
                dirs[i] = dirs[i].TrimEnd('\\') + "\\";
            }
            // Must have backslash on end - is folder
            //if (CA.PostfixIfNotEnding != null)
            //{
            //    CA.PostfixIfNotEnding(@"\", dirs);
            //}
        }
        return dirs;
    }
    /// <summary>
    /// A3 must be GetFilesArgs, not GetFoldersEveryFolder because is calling from GetFiles
    /// </summary>
    /// <param name="folder"></param>
    /// <param name="list"></param>
    /// <param name="e"></param>
    private static void GetFoldersEveryFolder(string folder, List<string> list, GetFilesArgsGetFolders e = null)
    {
        List<string> folders = null;
#if DEBUG
        if (folder == @"E:\vs\Projects\AllProjectsSearch\Aps.Projs\")
        {
        }
#endif
        try
        {
            folders = Directory.GetDirectories(folder).ToList();
            folders = CAChangeContent.ChangeContent0(null, folders, FSND.WithEndSlash);
            //#if DEBUG
            //            if (e.writeToDebugEveryLoadedFolder)
            //            {
            //                DebugLogger.Instance.WriteLine("GetFoldersEveryFolder: " + folder);
            //            }
            //#endif
        }
        catch (Exception ex)
        {
            if (e.throwEx)
            {
                ThrowEx.DummyNotThrow(ex);
            }

            // Not throw exception, it's probably Access denied  on Documents and Settings etc
            //throw new Exception("GetFoldersEveryFolder with path: " + folder, ex);
        }
        if (folders != null)
        {
            CA.RemoveWhichContainsList(folders, e.excludeFromLocationsCOntains, e.wildcard);
            list.AddRange(folders);
            for (int i = 0; i < folders.Count; i++)
            {
                GetFoldersEveryFolder(folders[i], list, e);
            }
        }
    }
    private static void GetFoldersEveryFolder(string folder, string mask, List<string> list)
    {
        try
        {
            var folders = Directory.GetDirectories(folder, mask, SearchOption.TopDirectoryOnly);
            list.AddRange(folders);
            foreach (var item in folders)
            {
                GetFoldersEveryFolder(item, mask, list);
            }
        }
        catch (Exception ex)
        {
            ThrowEx.DummyNotThrow(ex);
            // Not throw exception, it's probably Access denied  on Documents and Settings etc
            //throw new Exception("GetFoldersEveryFolder with path: " + folder, ex);
        }
    }
    /// <summary>
    /// It's always recursive
    /// </summary>
    /// <param name="folder"></param>
    /// <param name="mask"></param>
    public static List<string> GetFoldersEveryFolder(string folder, string masc, GetFoldersEveryFolderArgs e = null)
    {
        if (e == null)
        {
            e = new GetFoldersEveryFolderArgs();
        }
        List<string> list = new List<string>();
        // zde progress bar nedává smysl. načítám to rekurzivně, tedy nevím na začátku kolik těch složek bude
        //IProgressBarHelper pbh = null;
        //if (a.progressBarHelper != null)
        //{
        //    pbh = a.progressBarHelper.CreateInstance(a.pb, files.Count, this);
        //}
        GetFoldersEveryFolder(folder, list, e);

        if (masc != "*")
        {
            for (int i = list.Count - 1; i >= 0; i--)
            {
                var fn = Path.GetFileName(list[i].TrimEnd(Path.DirectorySeparatorChar));
                if (!masc.WildcardMatch(fn))
                {
                    list.RemoveAt(i);
                }
            }
        }

        if (e._trimA1AndLeadingBs)
        {
            //list = CAChangeContent.ChangeContent0(null, list, d => d = d.Replace(folder, "").TrimStart(AllChars.bs));
            for (int i = 0; i < list.Count; i++)
            {
                list[i] = list[i].Replace(folder, "").TrimStart(AllChars.bs);
            }
        }
        if (e.excludeFromLocationsCOntains != null)
        {
            // I want to find files recursively
            foreach (var item in e.excludeFromLocationsCOntains)
            {
                CA.RemoveWhichContains(list, item, e.wildcard, Wildcard.IsMatch);
            }
        }
        return list;
    }
    public static List<string> GetFoldersWhichContainsFiles(string d, string masc, SearchOption topDirectoryOnly)
    {
        var f = GetFolders(d);
        List<string> result = new List<string>();
        foreach (var item in f)
        {
            var files = FSGetFiles.GetFiles(item, masc, topDirectoryOnly);
            if (files.Count != 0)
            {
                result.Add(item);
            }
        }
        return result;
    }
}
