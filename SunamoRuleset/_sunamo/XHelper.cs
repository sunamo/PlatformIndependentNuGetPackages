using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
namespace SunamoRuleset._sunamo;
internal class XHelper
{
    internal static Dictionary<string, string> XmlNamespaces(XmlNamespaceManager nsmgr, bool withPrexixedXmlnsColon)
    {
        Dictionary<string, string> ns = new Dictionary<string, string>();
        foreach (string item2 in nsmgr)
        {
            var item = item2;
            if (withPrexixedXmlnsColon)
            {
                if (item == string.Empty || item == Consts.xmlns)
                {
                    item = Consts.xmlns;
                }
                else
                {
                    item = "xmlns:" + item;
                }
            }
            // Jak� je typ item, at nemus�m pou��vat slovn�k
            var v = nsmgr.LookupNamespace(item2);
            if (!ns.ContainsKey(item))
            {
                ns.Add(item, v);
            }
        }
        return ns;
    }
    internal static string Attr(XElement item, string attr)
    {
        XAttribute xa = item.Attribute(XName.Get(attr));
        if (xa != null)
        {
            return xa.Value;
        }
        return null;
    }
}
