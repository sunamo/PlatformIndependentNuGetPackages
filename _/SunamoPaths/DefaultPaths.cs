namespace SunamoPaths;

public partial class DefaultPaths
{
    //public static string actualPlatformParent
    //{
    //    get
    //    {
    //        if (eVs == @"C:\repos\_\") return @"C:\repos\";
    //        return eVs;
    //    }
    //}

    public static bool IsIgnored(string p)
    {
        if (p.StartsWith(bpBb)) return true;
        return false;
    }

    private static void Add(string bpMb)
    {
        exists.Add(bpMb, Directory.Exists(bpMb));
    }

    //public static void InitAllPathsToProjects()
    //{
    //    if (AllPathsToProjects == null)
    //        AllPathsToProjects = new[]
    //        {
    //            Test_MoveClassElementIntoSharedFileUC, vs, vsDocuments, vs17 + ProjectsFolderNameSlash,
    //            vs17Documents + ProjectsFolderNameSlash, NormalizePathToFolder
    //        }.ToList();
    //}


    static DefaultPaths()
    {

        //bp = eVs;

        //sunamo = bp + @"Projects\PlatformIndependentNuGetPackages\";
        //sunamoProject = bp + @"Projects\PlatformIndependentNuGetPackages\sunamo\";
        //vsProjects = bp + @"Projects\";
        //vs = bp + @"Projects\";
        //KeysXlf = bp + @"Projects\PlatformIndependentNuGetPackages\sunamo\Enums\KeysXlf.cs";
        //DllSunamo = bp + @"Projects\PlatformIndependentNuGetPackages\dll\";
        //VisualStudio2017 = bp;
        //VisualStudio2017WoSlash = bp.Substring(0, bp.Length - 1);

        //AllPathsToProjects = new[]
        //{
        //    Test_MoveClassElementIntoSharedFileUC, vs, vsDocuments, vs17 + ProjectsFolderNameSlash,
        //    vs17Documents + ProjectsFolderNameSlash, NormalizePathToFolder
        //}.ToList();
    }
}