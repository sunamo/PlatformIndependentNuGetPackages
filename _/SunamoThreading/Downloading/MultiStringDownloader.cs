namespace SunamoThreading.Downloading;
using System.Net;

/// <summary>
/// 
/// </summary>
/// <typeparam name="T">Typ vstupu, měl by začínat slovem Input</typeparam>
/// <typeparam name="U">Vždy Object---Typ vrácení, měl by začínat slovem Output</typeparam>
/// <typeparam name="X">Funkce která vrací U </typeparam>
public class MultiStringDownloader<T> //: IMultiThreaded<T>
    where T : IInputDownload
{
    TimeThreadPool mtp = null;
    //Dictionary<T, Exception> exceptions = new Dictionary<T, Exception>();
    Action<T, object> evaluationMethod = null;
    Action<T, Exception> passExceptionMethod = null;

    /// <summary>
    /// A3 nemůže být params
    /// </summary>
    /// <param name="evaluationMethod"></param>
    /// <param name="passExceptionMethod"></param>
    /// <param name="toDownload"></param>
    public MultiStringDownloader(Action<T, object> evaluationMethod, Action<T, Exception> passExceptionMethod, string[] toDownload)
    {
        mtp = new TimeThreadPool(Download, 5, toDownload);
        this.evaluationMethod = evaluationMethod;
        this.passExceptionMethod = passExceptionMethod;
    }

    void Download(object o)
    {
        T t = (T)o;
        WebClient wc = new WebClient();
        try
        {
            evaluationMethod.Invoke(t, wc.DownloadString(t.Uri));
        }
        catch (Exception ex)
        {
            passExceptionMethod.Invoke(t, ex);
        }
    }
}