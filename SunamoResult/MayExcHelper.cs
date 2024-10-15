namespace SunamoResult;
public class MayExcHelper
{
    public static bool MayExc(string exc)
    {
        if (exc != null)
        {
            Console.WriteLine(exc);
            //ThisApp.Error( result.exc);
            return true;
        }

        return false;
    }
}