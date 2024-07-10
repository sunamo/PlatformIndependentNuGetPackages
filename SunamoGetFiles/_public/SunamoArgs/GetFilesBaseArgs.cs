namespace SunamoGetFiles._public.SunamoArgs;



public class GetFilesBaseArgs 
{
    public bool followJunctions = false;
    public Func<string, bool> dIsJunctionPoint = null;
    public bool _trimA1AndLeadingBs = false;
}