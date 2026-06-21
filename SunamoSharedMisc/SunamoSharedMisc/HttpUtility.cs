namespace SunamoSharedMisc;

/// <summary>
/// HTTP utility methods to avoid importing System.Web for methods not in WebUtility.
/// </summary>
public class HttpUtility
{
    /// <summary>
    /// Parses a query string into a name-value collection.
    /// </summary>
    /// <param name="queryString">The query string to parse.</param>
    public static NameValueCollection ParseQueryString(string queryString)
    {
        NameValueCollection queryParameters = new();
        var querySegments = queryString.Split('&');
        foreach (var segment in querySegments)
        {
            var parts = segment.Split('=');
            if (parts.Length > 0)
            {
                var key = parts[0].Trim('?', ' ');
                var value = parts[1].Trim();
                queryParameters.Add(key, value);
            }
        }

        return queryParameters;
    }

    /// <summary>
    /// Decodes an HTML-encoded string.
    /// </summary>
    /// <param name="text">The HTML-encoded text to decode.</param>
    public static string HtmlDecode(string text)
    {
        return WebUtility.HtmlDecode(text);
    }

    /// <summary>
    /// Encodes a string for safe HTML output.
    /// </summary>
    /// <param name="html">The HTML text to encode.</param>
    public static string HtmlEncode(string html)
    {
        return HtmlEncodeWithCompatibility(html);
    }

    /// <summary>
    /// Encodes a string for safe HTML output with optional backward compatibility.
    /// </summary>
    /// <param name="html">The HTML text to encode.</param>
    /// <param name="isBackwardCompatibility">Whether to use backward-compatible encoding.</param>
    public static string HtmlEncodeWithCompatibility(string html, bool isBackwardCompatibility = true)
    {
        if (html == null) throw new Exception("html");
        var regex = isBackwardCompatibility
            ? new Regex("&(?!(amp;)|(lt;)|(gt;)|(quot;))", RegexOptions.IgnoreCase)
            : new Regex("&(?!(amp;)|(lt;)|(gt;)|(quot;)|(nbsp;)|(reg;))", RegexOptions.IgnoreCase);
        return regex.Replace(html, "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;");
    }

    /// <summary>
    /// URL-encodes the specified text.
    /// </summary>
    /// <param name="text">The text to URL-encode.</param>
    public static string UrlEncode(string text)
    {
        return WebUtility.UrlEncode(text);
    }

    /// <summary>
    /// URL-decodes the specified text.
    /// </summary>
    /// <param name="text">The URL-encoded text to decode.</param>
    public static string UrlDecode(string text)
    {
        return WebUtility.UrlDecode(text);
    }
}
