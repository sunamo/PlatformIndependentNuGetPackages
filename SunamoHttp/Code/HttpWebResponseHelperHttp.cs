namespace SunamoHttp.Code;
/// <summary>
/// Can be only in shared coz is not available in standard
/// </summary>
public class HttpWebResponseHelperHttp
{


    public static bool SomeError(HttpWebResponse r)
    {
        if (r == null)
        {
            return true;
        }

        // 400 errors for Bojánci and other which doesn't exists on lfm
        // 429 Too many errors (mainly for 
        switch (r.StatusCode)
        {
            case HttpStatusCode.OK:
                return false;
        }
        return true;
    }

    public static bool IsNotFound(HttpWebResponse r)
    {
        if (r == null)
        {
            return true;
        }

        switch (r.StatusCode)
        {
            case HttpStatusCode.NotFound:
                return true;
        }
        return false;
    }
}
