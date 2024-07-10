namespace SunamoGetFiles._sunamo.SunamoGetFolders.Args;


internal class GetFoldersEveryFolderArgs : GetFilesArgs
{
    ///// <summary>
    ///// Auto call WithEndSlash
    ///// </summary>
    //internal bool _trimA1AndLeadingBs = false;
    //internal List<string> excludeFromLocationsCOntains = null;
    //// nevím k čemu to je ale zdá se nesmysl, ověřovat můžu přes excludeFromLocationsCOntains != null
    ////internal bool excludeFromLocationsCOntainsBool = false;
    //internal bool writeToDebugEveryLoadedFolder = false;
    internal bool throwEx = false;
    internal GetFoldersEveryFolderArgs(GetFilesEveryFolderArgs e)
    {
        //_trimA1AndLeadingBs = e._trimA1AndLeadingBs;
        //followJunctions = e.followJunctions;
        //dIsJunctionPoint = e.dIsJunctionPoint;
        throwEx = e.throwEx;
    }
    internal GetFoldersEveryFolderArgs()
    {
    }
}