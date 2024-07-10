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
internal class HtmlHelper
{
    internal static string GetValueOfAttribute(string p, HtmlNode divMain, bool _trim = false)
    {
        object o = divMain.Attributes[p]; // divMain.GetAttributeValue(p, null);//
        if (o != null)
        {
            string st = ((HtmlAttribute)o).Value;
            if (_trim)
            {
                st = st.Trim();
            }
            if (st == string.Empty)
            {
                return Consts.nulled;
            }
            return st;
        }
        return string.Empty;
    }
}
