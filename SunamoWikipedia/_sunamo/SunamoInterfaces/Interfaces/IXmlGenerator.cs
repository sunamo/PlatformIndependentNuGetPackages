namespace SunamoWikipedia._sunamo.SunamoInterfaces.Interfaces;


internal interface IXmlGenerator
{
    void AppendLine();
    void EndComment();
    void Insert(int index, string text);
    int Length();
    void StartComment();
    void TerminateTag(string p);
    string ToString();
    void WriteCData(string innerCData);
    void WriteElement(string nazev, string inner);
    void WriteNonPairTag(string p);
    void WriteNonPairTagWith2Attrs(string p1, string p2, string p3, string p4, string p5);
    void WriteNonPairTagWithAttr(string p1, string p2, string p3);
    void WriteNonPairTagWithAttrs(bool appendNull, string p, params string[] p_2);
    void WriteNonPairTagWithAttrs(string tag, List<string> args);
    void WriteNonPairTagWithAttrs(string tag, params string[] args);
    void WriteRaw(string p);
    void WriteTag(string p);
    void WriteTagNamespaceManager(object rss, XmlNamespaceManager nsmgr, string v1, string v2);
    void WriteTagNamespaceManager(string nameTag, XmlNamespaceManager nsmgr, params string[] args);
    void WriteTagWith2Attrs(string p, string p_2, string p_3, string p_4, string p_5);
    void WriteTagWithAttr(string tag, string atribut, string hodnota, bool skipEmptyOrNull = false);
    void WriteTagWithAttrs(string p, List<string> p_2);
    void WriteTagWithAttrs(string p, params string[] p_2);
    void WriteTagWithAttrsCheckNull(string p, params string[] p_2);
    void WriteXmlDeclaration();
}
