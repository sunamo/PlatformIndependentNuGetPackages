namespace SunamoPaths;
using System;
using System.Collections.Generic;

public partial class DefaultPaths
{
    public const string eVs2 = @"E:\vs2\";
    public const string eVs = @"E:\vs\";
    private static readonly Dictionary<string, bool> exists = [];
    public static string ActualPlatform => eVs;

    //public static Platforms platform = Platforms.Mb;

    /// <summary>
    ///     Ended with backslash
    /// </summary>
    public static readonly string sczRootPath = Path.Combine(eVs, @"Projects\sunamo.cz\");

    public const string bpBb = @"D:\Documents\BitBucket\";

    /// <summary>
    ///     For all is here sczRootPath
    ///     edn with bs
    /// </summary>
    public static readonly string sczPath =
        Path.Combine(eVs, @"Projects\sunamo.cz\sunamo.cz\");

    public static readonly string sczOldPath =
        Path.Combine(eVs, @"Projects\sunamo.cz\sunamo.cz-old\");

    public static readonly string sczNsnPath =
        Path.Combine(eVs, @"Projects\sunamo.cz\sunamo.cz-nsn\");


    public static readonly string vsDocuments = Path.Combine(eDocuments, @"vs\");


    //public static readonly string vs17 = @"E:\vs17\";


    //public static readonly string vs17Documents = Path.Combine(eDocuments, @"vs17\");

    public static readonly string NormalizePathToFolder = Path.Combine(eVs, @"Projects\");

    public static readonly string Test_MoveClassElementIntoSharedFileUC =
        "D:\\_Test\\AllProjectsSearch\\AllProjectsSearch\\MoveClassElementIntoSharedFileUC\\";

    public const string SyncArchived = @"E:\SyncArchived\";
    public const string SyncArchivedText = @"E:\SyncArchived\Text\";
    public const string SyncArchivedDrive = @"E:\SyncArchived\Drive\";

    public static readonly List<string> All = [Documents, Docs, Downloads, Music2];
    public static readonly string XnConvert = @"D:\Pictures\XnConvert\";
    public const string PhotosScz = @"D:\Pictures\photos.sunamo.cz\";

    //[Obsolete("Vůbec nechápu k čemu to má být")]
    //public static List<string> AllPathsToProjects;

    /// <summary>
    ///     Solution, not project
    /// </summary>
    //public static readonly string sunamo;

    //[Obsolete("There is none sunamo\\sunamo")]
    ///// <summary>
    /////     Cant be used also VpsHelperSunamo.SunamoProject()
    ///// </summary>
    //public static readonly string sunamoProject;

    /// <summary>
    ///     E:\Documents\vs\Projects\
    /// </summary>
    public static readonly string eVsProjects = @"E:\vs\Projects\";

    public const string eVsProjectsPinp = @"E:\vs\Projects\PlatformIndependentNuGetPackages\";

    /// <summary>
    ///     E:\Documents\vs\Projects\
    /// </summary>
    //public static readonly string vs;

    //public static readonly string KeysXlf;
    //public static readonly string DllSunamo;
    //public static readonly string VisualStudio2017;
    //public static readonly string VisualStudio2017WoSlash;

    public const string BackupSunamosAppData = @"E:\Sync\Develop of Future\Backups\";
    public const string pathPa = @"D:\pa\";
    public const string pathPaSync = @"D:\paSync\";

    //public const string capturedUris =
    //    @"C:\Users\Administrator\AppData\Roaming\sunamo\SunamoCzAdmin\Data\SubsSignalR\CapturedUris.txt";

    //public const string capturedUris_backup =
    //    @"C:\Users\Administrator\AppData\Roaming\sunamo\SunamoCzAdmin\Data\SubsSignalR\CapturedUris_backup.txt";

    //public const string rootVideos0Kb = @"D:\Documents\Videos0kb\";
    public static readonly string Documents = @"D:\Documents\";
    public static readonly string eDocuments = @"E:\Documents\";
    public static readonly string Docs = @"D:\Docs\";
    public static readonly string Downloads = @"D:\Downloads\";
    public static readonly string Music2 = @"D:\Music2\";
    public static readonly string Backup = @"D:\Documents\Backup\";
    public static readonly string Streamline = @"D:\Pictures\Streamline_All_Icons_PNG\PNG Icons\";
}