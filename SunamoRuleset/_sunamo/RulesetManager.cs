
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
/// <summary>
/// Našel jsem ještě třídu DotXml ale ta umožňuje vytvářet jen dokumenty ke bude root ThisApp.Name
/// A nebo moje vlastní XML třídy, ale ty umí vytvářet jen třídy bez rozsáhlejšího xml vnoření.
/// Element - prvek kterému se zapisují ihned i innerObsah. Může být i prázdný.
/// Tag - prvek kterému to mohu zapsat později nebo vůbec.
/// </summary>
internal class XmlGenerator //: IXmlGenerator
{
    static Type type = typeof(XmlGenerator);
    internal StringBuilder sb = new StringBuilder();
    private bool _useStack = false;
    private Stack<string> _stack = null;
    internal int Length()
    {
        return sb.Length;
    }
    internal void WriteNonPairTagWith2Attrs(string p1, string p2, string p3, string p4, string p5)
    {
        sb.AppendFormat("<{0} {1}=\"{2}\" {3}=\"{4}\" />", p1, p2, p3, p4, p5);
    }
    internal void WriteNonPairTagWithAttr(string p1, string p2, string p3)
    {
        sb.AppendFormat("<{0} {1}=\"{2}\" />", p1, p2, p3);
    }
    internal void Insert(int index, string text)
    {
        sb.Insert(index, text);
    }
    internal void AppendLine()
    {
        sb.AppendLine();
    }
    internal XmlGenerator() : this(false)
    {
    }
    internal XmlGenerator(bool useStack)
    {
        _useStack = useStack;
        if (useStack)
        {
            _stack = new Stack<string>();
        }
    }
    internal void StartComment()
    {
        sb.Append("<!--");
    }
    internal void EndComment()
    {
        sb.Append("-->");
    }
    internal void WriteNonPairTagWithAttrs(string tag, List<string> args)
    {
        WriteNonPairTagWithAttrs(tag, args.ToArray());
    }
    internal void WriteNonPairTagWithAttrs(string tag, params string[] args)
    {
        sb.AppendFormat("<{0} ", tag);
        for (int i = 0; i < args.Length; i++)
        {
            string text = args[i];
            object hodnota = args[++i];
            sb.AppendFormat("{0}=\"{1}\" ", text, hodnota);
        }
        sb.Append(" />");
    }
    internal void WriteCData(string innerCData)
    {
        WriteRaw(/*string.Format("<![CDATA[{0}]]>", innerCData)*/ string.Format("<![CDATA[{0}]]>", innerCData));
    }
    internal void WriteTagWithAttr(string tag, string atribut, string hodnota, bool skipEmptyOrNull = false)
    {
        if (skipEmptyOrNull)
        {
            if (string.IsNullOrWhiteSpace(hodnota))
            {
                return;
            }
        }
        string r = /*string.Format*/ string.Format("<{0} {1}=\"{2}\">", tag, atribut, hodnota);
        if (_useStack)
        {
            _stack.Push(r);
        }
        sb.Append(r);
    }
    internal void WriteRaw(string p)
    {
        sb.Append(p);
    }
    internal void TerminateTag(string p)
    {
        sb.AppendFormat("</{0}>", p);
    }
    internal void WriteTag(string p)
    {
        string r = $"<{p}>";
        if (_useStack)
        {
            _stack.Push(r);
        }
        sb.Append(r);
    }
    public override string ToString()
    {
        return sb.ToString();
    }
    internal void WriteTagWithAttrs(string p, List<string> p_2)
    {
        WriteTagWithAttrs(p, p_2.ToArray());
    }
    /// <summary>
    /// if will be sth null, wont be writing
    /// </summary>
    /// <param name="p"></param>
    /// <param name="p_2"></param>
    internal void WriteTagWithAttrs(string p, params string[] p_2)
    {
        WriteTagWithAttrs(true, p, p_2);
    }
    /// <summary>
    /// Add also null
    /// </summary>
    /// <param name="nameTag"></param>
    /// <param name="p"></param>
    private void WriteTagWithAttrs(string nameTag, Dictionary<string, string> p)
    {
        WriteTagWithAttrs(true, nameTag, DictionaryHelper.GetListStringFromDictionary(p).ToArray());
    }
    /// <summary>
    /// Dont write attr with null
    /// </summary>
    /// <param name="p"></param>
    /// <param name="p_2"></param>
    internal void WriteTagWithAttrsCheckNull(string p, params string[] p_2)
    {
        WriteTagWithAttrs(false, p, p_2);
    }
    internal void WriteTagNamespaceManager(object rss, XmlNamespaceManager nsmgr, string v1, string v2)
    {
        ThrowEx.NotImplementedMethod();
    }
    bool IsNulledOrEmpty(string s)
    {
        if (string.IsNullOrEmpty(s) || s == Consts.nulled)
        {
            return true;
        }
        return false;
    }
    internal void WriteTagNamespaceManager(string nameTag, XmlNamespaceManager nsmgr, params string[] args)
    {
        //List<string> p = new List<string>(args);
        var p = XHelper.XmlNamespaces(nsmgr, true);
        for (int i = 0; i < args.Count(); i++)
        {
            p.Add(args[i], args[++i]);
        }
        WriteTagWithAttrs(nameTag, p);
    }
    internal void WriteNonPairTagWithAttrs(bool appendNull, string p, params string[] p_2)
    {
        StringBuilder sb = new StringBuilder();
        sb.AppendFormat("<{0} ", p);
        for (int i = 0; i < p_2.Length; i++)
        {
            var attr = p_2[i];
            var val = p_2[++i];
            if (string.IsNullOrEmpty(val) && appendNull || !string.IsNullOrEmpty(val))
            {
                if (!IsNulledOrEmpty(attr) && appendNull || !IsNulledOrEmpty(val))
                {
                    sb.AppendFormat("{0}=\"{1}\" ", attr, val);
                }
            }
        }
        sb.Append(" /");
        sb.Append(AllStrings.gt);
        string r = sb.ToString();
        if (_useStack)
        {
            _stack.Push(r);
        }
        this.sb.Append(r);
    }
    /// <summary>
    /// if will be sth null, wont be writing
    /// </summary>
    /// <param name="p"></param>
    /// <param name="p_2"></param>
    private void WriteTagWithAttrs(bool appendNull, string p, params string[] p_2)
    {
        StringBuilder sb = new StringBuilder();
        sb.AppendFormat("<{0} ", p);
        for (int i = 0; i < p_2.Length; i++)
        {
            var attr = p_2[i];
            var val = p_2[++i];
            if (string.IsNullOrEmpty(val) && appendNull || !string.IsNullOrEmpty(val))
            {
                if (!IsNulledOrEmpty(attr) && appendNull || !IsNulledOrEmpty(val))
                {
                    sb.AppendFormat("{0}=\"{1}\" ", attr, val);
                }
            }
        }
        sb.Append(AllStrings.gt);
        string r = sb.ToString();
        if (_useStack)
        {
            _stack.Push(r);
        }
        this.sb.Append(r);
    }
    internal void WriteElement(string nazev, string inner)
    {
        sb.AppendFormat("<{0}>{1}</{0}>", nazev, inner);
    }
    internal void WriteXmlDeclaration()
    {
        sb.Append(XmlTemplates.xml);
    }
    internal void WriteTagWith2Attrs(string p, string p_2, string p_3, string p_4, string p_5)
    {
        string r = /*string.Format*/ string.Format("<{0} {1}=\"{2}\" {3}=\"{4}\">", p, p_2, p_3, p_4, p_5);
        if (_useStack)
        {
            _stack.Push(r);
        }
        sb.Append(r);
    }
    internal void WriteNonPairTag(string p)
    {
        sb.AppendFormat("<{0} />", p);
    }
}
