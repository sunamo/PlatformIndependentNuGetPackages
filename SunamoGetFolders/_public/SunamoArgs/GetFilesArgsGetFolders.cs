namespace SunamoGetFolders._public.SunamoArgs;



public class GetFilesArgsGetFolders : GetFilesBaseArgsGetFolders
{

    public bool _trimExt = false;
    public bool _trimA1AndLeadingBs = false;
    public List<string> excludeFromLocationsCOntains = new List<string>();
    public bool dontIncludeNewest = false;
    public bool throwEx = false;


    public Action<List<string>> excludeWithMethod = null;
    public bool byDateOfLastModifiedAsc = false;
    public Func<string, DateTime?> LastModifiedFromFn;



    public bool useMascFromExtension = false;
    public bool wildcard = false;
}