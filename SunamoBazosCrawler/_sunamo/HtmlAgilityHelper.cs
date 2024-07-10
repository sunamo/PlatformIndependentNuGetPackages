using HtmlAgilityPack;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using HtmlAgilityPack;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
namespace SunamoBazosCrawler._sunamo;
internal class HtmlAgilityHelper
{
    internal static bool _trimTexts = true;
    internal const string textNode = "#text";
    internal static HtmlDocument CreateHtmlDocument()
    {
        HtmlDocument hd = new HtmlDocument();
        hd.OptionOutputOriginalCase = true;
        // false - i přesto mi tag ukončený na / převede na </Page>. Musí se ještě tagy jež nechci ukončovat vymazat z HtmlAgilityPack.HtmlNode.ElementsFlags.Remove("form"); před načetním XML https://html-agility-pack.net/knowledge-base/7104652/htmlagilitypack-close-form-tag-automatically
        hd.OptionAutoCloseOnEnd = false;
        hd.OptionOutputAsXml = false;
        hd.OptionFixNestedTags = false;
        //when OptionCheckSyntax = false, raise NullReferenceException in Load/LoadHtml
        //hd.OptionCheckSyntax = false;
        return hd;
    }
    internal static HtmlNode NodeWithAttr(HtmlNode node, bool recursive, string tag, string attr, string attrValue, bool contains = false)
    {
        return NodesWithAttrWorker(node, recursive, tag, attr, attrValue, false, contains).FirstOrDefault();
    }
    internal static List<HtmlNode> NodesWithAttr(HtmlNode node, bool recursive, string tag, string attr, string attrValue, bool contains = false)
    {
        return NodesWithAttrWorker(node, recursive, tag, attr, attrValue, false, contains);
    }
    private static List<HtmlNode> NodesWithAttrWorker(HtmlNode node, bool recursive, string tag, string atribut, string hodnotaAtributu, bool isWildCard, bool enoughIsContainsAttribute, bool searchAsSingleString = true)
    {
        List<HtmlNode> vr = new List<HtmlNode>();
        RecursiveReturnTagsWithContainsAttr(vr, node, recursive, tag, atribut, hodnotaAtributu, isWildCard, enoughIsContainsAttribute, searchAsSingleString);
        if (tag != textNode)
        {
            vr = TrimTexts(vr);
        }
        return vr;
    }
    internal static List<HtmlNode> TrimTexts(List<HtmlNode> c2)
    {
        return TrimTexts(c2, true, false);
    }
    /// <summary>
    /// A2 =remove #text
    /// A3 = remove #comment
    /// </summary>
    /// <param name="c2"></param>
    /// <param name="texts"></param>
    /// <param name="comments"></param>
    internal static List<HtmlNode> TrimTexts(List<HtmlNode> c2, bool texts, bool comments = false)
    {
        if (!_trimTexts)
        {
            return c2;
        }
        List<HtmlNode> vr = new List<HtmlNode>();
        bool add = true;
        foreach (var item in c2)
        {
            add = true;
            if (texts)
            {
                if (item.Name == textNode)
                {
                    add = false;
                }
            }
            if (comments)
            {
                if (item.Name == "#comment")
                {
                    add = false;
                }
            }
            if (add)
            {
                vr.Add(item);
            }
        }
        return vr;
    }
    internal static List<HtmlNode> TrimTexts(HtmlNodeCollection htmlNodeCollection)
    {
        if (!_trimTexts)
        {
            return htmlNodeCollection.ToList();
        }
        List<HtmlNode> vr = new List<HtmlNode>();
        foreach (var item in htmlNodeCollection)
        {
            if (item.Name != textNode)
            {
                vr.Add(item);
            }
        }
        return vr;
    }
    private static bool HasTagName(HtmlNode hn, string tag)
    {
        if (tag == AllStrings.asterisk)
        {
            return true;
        }
        return hn.Name == tag;
    }
    private static bool HasTagAttr(HtmlNode item, string atribut, string hodnotaAtributu, bool isWildCard, bool enoughIsContainsAttribute, bool searchAsSingleString)
    {
        if (hodnotaAtributu == AllStrings.asterisk)
        {
            return true;
        }
        bool contains = false;
        var attrValue = HtmlHelper.GetValueOfAttribute(atribut, item);
        if (enoughIsContainsAttribute)
        {
            if (searchAsSingleString)
            {
                if (isWildCard)
                {
                    contains = SH.MatchWildcard(attrValue, hodnotaAtributu);
                }
                else
                {
                    contains = attrValue.Contains(hodnotaAtributu);
                }
                //
            }
            else
            {
                bool cont = true;
                var p = SHSplit.Split(hodnotaAtributu, AllStrings.space);
                foreach (var item2 in p)
                {
                    if (!attrValue.Contains(item2))
                    {
                        cont = false;
                        break;
                    }
                }
                contains = cont;
            }
        }
        else
        {
            contains = attrValue == hodnotaAtributu;
        }
        return contains;
    }
    internal static void RecursiveReturnTagsWithContainsAttr(List<HtmlNode> vr, HtmlNode htmlNode, bool recursively, string p, string atribut, string hodnotaAtributu, bool isWildCard, bool enoughIsContainsAttribute, bool searchAsSingleString = true)
    {
        /*
isWildCard -
         */
        p = p.ToLower();
        //atribut = atribut.ToLower();
        //hodnotaAtributu = atribut.ToLower();
        if (htmlNode == null)
        {
            return;
        }
        foreach (HtmlNode item in htmlNode.ChildNodes)
        {
            string attrValue = HtmlHelper.GetValueOfAttribute(atribut, item);
            if (HasTagName(item, p))
            {
                if (HasTagAttr(item, atribut, hodnotaAtributu, isWildCard, enoughIsContainsAttribute, searchAsSingleString))
                {
                    vr.Add(item);
                }
                if (recursively)
                {
                    RecursiveReturnTagsWithContainsAttr(vr, item, recursively, p, atribut, hodnotaAtributu, isWildCard, enoughIsContainsAttribute, searchAsSingleString);
                }
            }
            else
            {
                if (recursively)
                {
                    RecursiveReturnTagsWithContainsAttr(vr, item, recursively, p, atribut, hodnotaAtributu, isWildCard, enoughIsContainsAttribute, searchAsSingleString);
                }
            }
        }
    }
}
