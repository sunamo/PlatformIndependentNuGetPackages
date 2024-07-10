using HtmlAgilityPack;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using HtmlAgilityPack;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
namespace SunamoBazosCrawler._sunamo;
internal class HtmlAssistant
{
    internal static string InnerText(HtmlNode node, bool recursive, string tag, string attr, string attrValue, bool contains = false)
    {
        return InnerContentWithAttr(node, recursive, tag, attr, attrValue, false, contains);
    }
    internal static string InnerHtmlWithAttr(HtmlNode node, bool recursive, string tag, string attr, string attrValue, bool contains = false)
    {
        return InnerContentWithAttr(node, recursive, tag, attr, attrValue, true, contains);
    }
    internal static string HtmlDecode(string v)
    {
        return WebUtility.HtmlDecode(v);
    }
    internal static string InnerContentWithAttr(HtmlNode node, bool recursive, string tag, string attr, string attrValue, bool html, bool contains = false)
    {
        HtmlNode node2 = HtmlAgilityHelper.NodeWithAttr(node, true, tag, attr, attrValue, contains);
        if (node2 != null)
        {
            var c = string.Empty;
            if (html)
            {
                c = node2.InnerHtml;
            }
            else
            {
                c = node2.InnerText;
            }
            return HtmlAssistant.HtmlDecode(c.Trim());
        }
        return string.Empty;
    }
}
