namespace SunamoXliffParser;
public class XlfDocument
{
    [Flags]
    public enum ResXSaveOption
    {
        None = 0,
        SortEntries = 1,
        IncludeComments = 2
    }
    private const string AttributeOriginal = "original";
    private const string ElementFile = "file";
    private const string AttributeVersion = "version";
    public static Type type = typeof(XlfDocument);
    private XDocument doc;
    public string FileName { get; }
    public IEnumerable<XlfFile> Files
    {
        get
        {
            XNamespace ns = doc.Root.Name.Namespace;
            return doc.Descendants(ns + ElementFile).Select(f => new XlfFile(f, ns));
        }
    }
    public string Version
    {
        get => doc.Root.Attribute(AttributeVersion).Value;
        set => doc.Root.SetAttributeValue(AttributeVersion, value);
    }
    public XlfDialect Dialect { get; set; }
    public XlfFile AddFile(string original, string dataType, string sourceLang)
    {
        XNamespace ns = doc.Root.Name.Namespace;
        XElement f = new XElement(ns + ElementFile);
        doc.Descendants(ns + ElementFile).Last().AddAfterSelf(f);
        return new XlfFile(f, ns, original, dataType, sourceLang);
    }
    public void RemoveFile(string original)
    {
        XNamespace ns = doc.Root.Name.Namespace;
        doc.Descendants(ns + ElementFile).Where(u =>
        {
            XAttribute a = u.Attribute(AttributeOriginal);
            return a != null && a.Value == original;
        }).Remove();
    }
    public void SaveAsResX(string fileName)
    {
        SaveAsResX(fileName, ResXSaveOption.None);
    }
    public void SaveAsResX(string fileName, ResXSaveOption options)
    {
        List<ResXEntry> entries = new List<ResXEntry>();
        foreach (XlfFile f in Files)
        {
            foreach (XlfTransUnit u in f.TransUnits)
            {
                ResXEntry entry = new ResXEntry { Id = u.GetId(Dialect), Value = u.Target };
                if (options.HasFlag(ResXSaveOption.IncludeComments) && u.Optional.Notes.Count() > 0)
                {
                    entry.Comment = u.Optional.Notes.First().Value;
                }
                entries.Add(entry);
            }
        }
        if (options.HasFlag(ResXSaveOption.SortEntries))
        {
            entries.Sort();
        }
        ResXFile.Write(fileName, entries,
            options.HasFlag(ResXSaveOption.IncludeComments) ? ResXOption.None : ResXOption.SkipComments);
    }
    public UpdateResult UpdateFromSource()
    {
        switch (Version)
        {
            default:
            case "1.1":
            case "1.2":
                return UpdateFromSource("new", "new");
            case "2.0":
                return UpdateFromSource("initial", "initial");
        }
    }
    public UpdateResult UpdateFromSource(string updatedResourceStateString, string addedResourceStateString)
    {
        string sourceFile = Path.Combine(Path.GetDirectoryName(FileName), Files.Single().Original);
        return Update(sourceFile, updatedResourceStateString, addedResourceStateString);
    }
    /// <summary>
    ///     Updates the xlf data from the provided resx source file.
    /// </summary>
    /// <param name="sourceFile">The source file to be processed.</param>
    /// <param name="updatedResourceStateString">The state string that should be used for updated items.</param>
    /// <param name="addedResourceStateString">The state string that should be used for added items.</param>
    /// <returns>Return the ids of the updated/added/removed items in separate lists.</returns>
    public UpdateResult Update(string sourceFile, string updatedResourceStateString,
        string addedResourceStateString)
    {
        Dictionary<string, ResXEntry> resxData = new Dictionary<string, ResXEntry>(); // id, value, comment
        foreach (ResXEntry entry in ResXFile.Read(sourceFile))
        {
            resxData.Add(entry.Id, entry);
        }
        List<string> updatedItems = new List<string>();
        List<string> addedItems = new List<string>();
        List<string> removedItems = new List<string>();
        foreach (XlfFile f in Files)
        {
            foreach (XlfTransUnit u in f.TransUnits)
            {
                string key = u.GetId(Dialect);
                if (resxData.ContainsKey(key))
                {
                    if (XmlUtil.NormalizeLineBreaks(u.Source) != XmlUtil.NormalizeLineBreaks(resxData[key].Value))
                    {
                        // source text changed
                        u.Source = resxData[key].Value;
                        u.Optional.TargetState = updatedResourceStateString;
                        u.Optional.SetCommentFromResx(resxData[key].Comment);
                        updatedItems.Add(key);
                    }
                }
                else
                {
                    removedItems.Add(key);
                }
                resxData.Remove(key);
            }
            foreach (string id in removedItems)
            {
                f.RemoveTransUnit(id, Dialect);
            }
            foreach (KeyValuePair<string, ResXEntry> d in resxData)
            {
                XlfTransUnit unit = f.AddTransUnit(d.Key, d.Value.Value, d.Value.Value, XlfFile.AddMode.FailIfExists,
                    Dialect);
                unit.Optional.TargetState = addedResourceStateString;
                unit.Optional.SetCommentFromResx(d.Value.Comment);
                addedItems.Add(d.Key);
            }
        }
        return new UpdateResult(addedItems, removedItems, updatedItems);
    }
    private XlfDialect DetermineDialect()
    {
        return Files.First().Optional.ToolId == "MultilingualAppToolkit"
            ? XlfDialect.MultilingualAppToolkit
            : doc.Root.GetNamespaceOfPrefix("rwt") == "http://www.schaudin.com/xmlns/rwt11" ? XlfDialect.RCWinTrans11 : XlfDialect.Standard;
    }
    #region Changed to load also from Embedded Resources
    /// <summary>
    ///     A1 can be null but then is need to call LoadXml
    /// </summary>
    /// <param name="fileName"></param>
    public XlfDocument(string fileName)
    {
        FileName = fileName;
        if (FileName != null)
        {
            doc = XDocument.Load(FileName);
            Dialect = DetermineDialect();
        }
    }
    public XlfDocument()
    {
    }
    public void LoadXml(string xml)
    {
        byte[] b = Encoding.UTF8.GetBytes(xml);
        LoadXml(b);
    }
    public void LoadXml(byte[] xml)
    {
        using (MemoryStream xmlStream = new MemoryStream(xml))
        {
            doc = XDocument.Load(xmlStream);
        }
        Dialect = DetermineDialect();
    }
    public void Save()
    {
        if (FileName != null)
        {
            doc.Save(FileName);
        }
        else
        {
            ThrowEx.IsNull("FileName");
        }
    }
    #endregion
}
