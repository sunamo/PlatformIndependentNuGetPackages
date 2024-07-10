namespace SunamoRobotsTxt;

public class RobotsTxtBuilder
{
    const string sitemap = "Sitemap: ";
    const string disallow = "Disallow: ";
    const string allow = "Allow: ";
    const string userAgent = "User-agent: ";

    public List<string> sitemaps = new List<string>();
    public Dictionary<string, List<string>> disallows = new Dictionary<string, List<string>>();
    public Dictionary<string, List<string>> allows = new Dictionary<string, List<string>>();
    public List<string> notRecognizedLines = new List<string>();

    string actualUserAgent = string.Empty;
    public RobotsTxtBuilder(IEnumerable<string> lines)
    {
        foreach (var item in lines)
        {
            if (item.Trim() == string.Empty)
            {
                continue;
            }
            if (item.StartsWith(sitemap))
            {
                AddWithoutPrefix(sitemaps, sitemap, item);
            }
            else if (item.StartsWith(userAgent))
            {
                actualUserAgent = item.Substring(userAgent.Length);
            }
            else if (item.StartsWith(allow))
            {
                AddWithoutPrefix(allows, allow, actualUserAgent, item);
            }
            else if (item.StartsWith(disallow))
            {
                AddWithoutPrefix(disallows, disallow, actualUserAgent, item);
            }
            else
            {
                notRecognizedLines.Add(item);
            }
        }
    }

    private void AddWithoutPrefix(Dictionary<string, List<string>> allows, string allow, string actualUserAgent, string item)
    {
        item = item.Substring(allow.Length);

        AddOrCreateIfDontExists(allows, actualUserAgent, item);
    }

    private void AddWithoutPrefix(List<string> sitemaps, string sitemap, string item)
    {
        item = item.Substring(sitemap.Length);
        if (!sitemaps.Contains(item))
        {
            sitemaps.Add(item);
        }
    }

    public void Sitemap(string path)
    {
        if (!sitemaps.Contains(path))
        {
            sitemaps.Add(path);
        }
    }
    public void Disallow(string userAgent, string path)
    {
        AddOrCreateIfDontExists(disallows, userAgent, path);
    }

    public void Allow(string userAgent, string path)
    {
        AddOrCreateIfDontExists(allows, userAgent, path);
    }

    public static void AddOrCreateIfDontExists(IDictionary<string, List<string>> dict, string key, string value)
    {
        AddOrCreateIfDontExists<string, string>(dict, key, value);
    }

    public static void AddOrCreateIfDontExists<Key, Value>(IDictionary<Key, List<Value>> sl, Key key, Value value)
    {
        if (sl.ContainsKey(key))
        {
            if (!sl[key].Contains(value))
            {
                sl[key].Add(value);
            }
        }
        else
        {
            List<Value> ad = new List<Value>();
            ad.Add(value);
            sl.Add(key, ad);
        }
    }

    public void Save(string path)
    {
        StringBuilder sb = new StringBuilder();

        

        var userAgents = new List<string>();
        userAgents.AddRange(allows.Keys);
        userAgents.AddRange(disallows.Keys);
        userAgents = userAgents.Distinct().ToList();

        foreach (var item in userAgents)
        {
            sb.AppendLine(userAgent + item);
            sb.AppendLine();
            WriteAllowDisallow(sb, item, allows, allow);
            WriteAllowDisallow(sb, item, disallows, disallow);
        }

        foreach (var item in sitemaps)
        {
            sb.AppendLine(sitemap + item);
        }

        //sb.AppendLine();

        File.WriteAllText(path, sb.ToString());
    }

    private void WriteAllowDisallow(StringBuilder sb, string item, IDictionary<string, List<string>> dict, string prefix)
    {
        var allowed = GetValuesOrEmpty(dict, item);



        foreach (var item2 in allowed)
        {
            sb.AppendLine(prefix + item2);
        }

        if (allowed.Count != 0)
        {
            sb.AppendLine();
        }
    }

    public static List<U> GetValuesOrEmpty<T, U>(IDictionary<T, List<U>> dict, T t)
    {
        if (dict.ContainsKey(t))
        {
            return dict[t];
        }
        return new List<U>();
    }
}
