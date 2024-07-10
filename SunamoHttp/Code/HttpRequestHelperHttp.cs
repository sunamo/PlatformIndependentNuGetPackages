namespace SunamoHttp.Code;

public static class HttpRequestHelperHttp
{
    /// <summary>
    /// In earlier time return ext
    /// Now return whether was downloaded
    /// </summary>
    /// <param name="path"></param>
    /// <param name="uri"></param>
    /// <returns></returns>
    public static string DownloadOrReadWorker(string path, string uri)
    {
        string html = null;

        if (!FS.ExistsFile(path))
        {
            Download(uri, null, path);
        }

        html = TF.ReadAllText(path);

        return html;
    }

    /// <summary>
    /// As folder is use Cache
    /// </summary>
    /// <param name="cache"></param>
    /// <param name="uri"></param>
    public static string DownloadOrRead(string uri, string appDataCachePath)
    {
        var v = UH.GetFileName(uri);
        var fn = FS.ReplaceInvalidFileNameChars(v);
        fn = FS.Combine(appDataCachePath, SH.AppendIfDontEndingWith(fn, AllExtensions.html));
        return DownloadOrReadWorker(fn, uri);
    }

    public static bool ExistsPage(string url)
    {
        try
        {
            //Creating the HttpWebRequest
            HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest;
            //Setting the Request method HEAD, you can also use GET too.
            request.Method = "HEAD";
            //Getting the Web Response.
            HttpWebResponse response = request.GetResponse() as HttpWebResponse;
            //Returns TRUE if the Status code == 200
            response.Close();
            return (response.StatusCode == HttpStatusCode.OK);
        }
        catch
        {
            //Any exception will returns false.
            return false;
        }
    }

    /// <summary>
    /// Is not async coz t.Result
    /// </summary>
    /// <param name="address"></param>
    public async static Task<string> GetResponseTextAsync(string address)
    {
        var request = (HttpWebRequest)WebRequest.CreateHttp(address);
        request.Timeout = int.MaxValue;
        request.UserAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11";
        var t = request.GetResponseAsync();
        using (var response = (HttpWebResponse)t.Result)
        {
            Encoding encoding = null;

            if (response.CharacterSet == "")
            {
                //encoding = Encoding.UTF8;
            }
            else
            {
                encoding = Encoding.GetEncoding(response.CharacterSet);
            }

            using (var responseStream = response.GetResponseStream())
            {
                StreamReader reader = null;
                if (encoding == null)
                {
                    reader = new StreamReader(responseStream, true);
                }
                else
                {
                    reader = new StreamReader(responseStream, encoding);
                }
                string vr = reader.ReadToEnd();
                return vr;
            }
        }
    }

    /// <summary>
    /// A3 can be null
    /// </summary>
    /// <param name="address"></param>
    /// <param name="method"></param>
    /// <param name="hrd"></param>
    public static string GetResponseText(string address, HttpMethod method, HttpRequestDataHttp hrd)
    {
        HttpWebResponse response;
        return GetResponseText(address, method, hrd, out response);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name = "address"></param>
    public static Stream GetResponseStream(string address, HttpMethod method)
    {
        var request = (HttpWebRequest)WebRequest.Create(address);
        request.Method = method.Method;
        HttpWebResponse response = null;
        try
        {
            response = (HttpWebResponse)request.GetResponse();
        }
        catch (System.Exception ex)
        {
            return null;
        }

        return response.GetResponseStream();
    }

    public static string GetResponseText(string address, HttpMethod method, HttpRequestDataHttp hrd, out HttpWebResponse response)
    {
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(address);
        return GetResponseText(request, method, hrd, out response);
    }

    /// <summary>
    /// A3 can be null
    /// Dont forger Dispose on A4
    /// </summary>
    /// <param name = "address"></param>
    /// <param name = "method"></param>
    /// <param name = "hrd"></param>
    public static string GetResponseText(HttpWebRequest request, HttpMethod method, HttpRequestDataHttp hrd, out HttpWebResponse response)
    {
        response = null;

        if (hrd == null)
        {
            hrd = new HttpRequestDataHttp();
        }

        var address = request.Address.ToString();

        int dex = address.IndexOf(AllChars.q);
        string adressCopy = address;
        if (method.Method.ToUpper() == "POST")
        {
            if (dex != -1)
            {
                address = address.Substring(0, dex);
            }
        }

        // Cant create new instance, in A1 can be setted up property which is not allowed in Headers
        //request.Address = address;

        string result = null;

        request.Method = method.Method;

        if (method == HttpMethod.Post)
        {
            string query = adressCopy.Substring(dex + 1);
            Encoding encoder = null;
            if (hrd.encodingPostData == null)
            {
                encoder = new ASCIIEncoding();
            }
            else
            {
                encoder = hrd.encodingPostData;
            }

            byte[] data = encoder.GetBytes(query);
            request.ContentType = "application/x-www-urlencoded";
            request.ContentLength = data.Length;
            request.GetRequestStream().Write(data, 0, data.Length);
        }

        //request.UserAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11";
        request.UserAgent = "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36";
        if (hrd.contentType != null)
        {
            request.ContentType = hrd.contentType;
        }

        if (hrd.accept != null)
        {
            request.Accept = hrd.accept;
        }

        if (hrd != null)
        {
            foreach (var item in hrd.headers)
            {
                request.Headers.Add(item.Key, item.Value);
            }
        }

        try
        {
            response = (HttpWebResponse)request.GetResponse();

            Encoding encoding = null;
            if (response.CharacterSet == "")
            {
                //encoding = Encoding.UTF8;
            }
            else
            {
                encoding = Encoding.GetEncoding(response.CharacterSet);
            }

            using (var responseStream = response.GetResponseStream())
            {
                StreamReader reader = null;
                if (encoding == null)
                {
                    reader = new StreamReader(responseStream, true);
                }
                else
                {
                    reader = new StreamReader(responseStream, encoding);
                }

                result = reader.ReadToEnd();
            }

        }
        catch (System.Exception ex)
        {
            result = Exceptions.TextOfExceptions(ex);
        }

        return result;
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name = "address"></param>
    public static byte[] GetResponseBytes(string address, HttpMethod method)
    {
        var request = (HttpWebRequest)WebRequest.Create(address);
        request.Method = method.Method;
        request.UserAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11";
        using (var response = (HttpWebResponse)request.GetResponse())
        {
            Encoding encoding = null;
            if (response.CharacterSet == "")
            {
                encoding = Encoding.UTF8;
            }
            else
            {
                encoding = Encoding.GetEncoding(response.CharacterSet);
            }

            using (var responseStream = response.GetResponseStream())
            {
                using (MemoryStream ms = new MemoryStream())
                {
                    responseStream.CopyTo(ms);
                    ms.Seek(0, SeekOrigin.Begin);
                    using (var reader = new StreamReader(ms, encoding))
                    {
                        using (BinaryReader br = new BinaryReader(reader.BaseStream))
                        {
                            return br.ReadBytes((int)ms.Length);
                        }
                    }
                }
            }
        }
    }

    public static bool IsNotFound(object uri)
    {
        HttpWebResponse r;
        var test = GetResponseText(uri.ToString(), HttpMethod.Get, null, out r);

        return HttpResponseHelperHttp.IsNotFound(r);
    }

    public static bool SomeError(object uri)
    {
        HttpWebResponse r;
        var test = GetResponseText(uri.ToString(), HttpMethod.Get, null, out r);

        return HttpResponseHelperHttp.SomeError(r);
    }

    /// <summary>
    /// A2 can be null (if dont have duplicated extension, set null)
    /// </summary>
    /// <param name="hrefs"></param>
    /// <param name="DontHaveAllowedExtension"></param>
    /// <param name="folder2"></param>
    /// <param name="co"></param>
    /// <param name="ext"></param>
    public static void DownloadAll(List<string> hrefs, Func<string, bool> DontHaveAllowedExtension, string folder2, FileMoveCollisionOptionHttp co, string ext = null)
    {
        if (co != FileMoveCollisionOptionHttp.Overwrite)
        {
            ThrowEx.Custom("Is allowed only Overwrite. Due to deps FS.MoveFile is not possible to use.");
        }

        foreach (var item in hrefs)
        {
            var tempPath = FS.GetTempFilePath();

            Download(item, DontHaveAllowedExtension, tempPath);
            var to = FS.Combine(folder2, Path.GetFileName(item) + ext);

            File.Move(tempPath, to, true);
        }
    }



    /// <summary>
    /// A2 can be null (if dont have duplicated extension, set null)
    /// In earlier time return ext
    /// Now return whether was downloaded
    /// </summary>
    /// <param name = "href"></param>
    /// <param name = "DontHaveAllowedExtension"></param>
    /// <param name = "folder2"></param>
    /// <param name = "fn"></param>
    /// <param name = "ext"></param>
    public static bool Download(string href, Func<string, bool> DontHaveAllowedExtension, string folder2, string fn, string ext = null)
    {
        if (DontHaveAllowedExtension != null)
        {
            if (DontHaveAllowedExtension(ext))
            {
                ext += ".jpeg";
            }
        }

        if (string.IsNullOrWhiteSpace(ext))
        {
            ext = FS.GetExtension(href);
            ext = SHParts.RemoveAfterFirst(ext, AllStrings.q);
        }

        fn = SHParts.RemoveAfterFirst(fn, AllStrings.q);
        string path = FS.Combine(folder2, fn + ext);
        FS.CreateFoldersPsysicallyUnlessThere(folder2);

        if (!FS.ExistsFile(path) || FS.GetFileSize(path) == 0)
        {
            var c = HttpRequestHelperHttp.GetResponseBytes(href, HttpMethod.Get);

            TF.WriteAllBytes(path, c);
            return true;
        }

        return false;
    }

    /// <summary>
    /// In earlier time return ext
    /// Now return whether was downloaded
    /// </summary>
    /// <param name="uri"></param>
    /// <param name="DontHaveAllowedExtension"></param>
    /// <param name="path"></param>
    /// <returns></returns>
    public static bool Download(string uri, Func<string, bool> DontHaveAllowedExtension, string path)
    {
        string p, fn, ext;
        FS.GetPathAndFileNameWithoutExtension(path, out p, out fn, out ext);
        return Download(uri, null, p, fn, FS.GetExtension(path));
    }
}
