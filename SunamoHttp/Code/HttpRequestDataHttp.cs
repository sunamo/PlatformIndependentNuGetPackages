namespace SunamoHttp.Code;
/// Here it cant be, is already in SunamoHttp.standard and even if I not directly reference SunamoHttp.standard, VS see it
public class HttpRequestDataHttp
{
    public Dictionary<string, string> headers = new Dictionary<string, string>();
    public string contentType = null;
    public string accept = null;
    public Encoding encodingPostData;
    //public int? timeout = null; // Není v třídě HttpKnownHeaderNames
    public bool? keepAlive = null;
    /// <summary>
    /// Assign: StreamContent,ByteArrayContent,FormUrlEncodedContent,StringContent,MultipartContent,MultipartFormDataContent
    /// </summary>
    public HttpContent content = null;
}
