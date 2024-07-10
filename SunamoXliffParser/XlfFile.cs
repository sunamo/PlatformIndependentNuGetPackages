namespace SunamoXliffParser;
public class XlfFile
{
    public enum AddMode
    {
        SkipExisting = 0,
        UpdateExisting = 1,
        FailIfExists = 2
    }
    private const string ElementHeader = "header";
    private const string AttributeDataType = "datatype";
    private const string AttributeOriginal = "original";
    private const string AttributeSourceLanguage = "source-language";
    private const string ElementTransUnit = "trans-unit";
    private const string ElementBody = "body";
    private const string IdNone = "none";
    private const string AttributeId = "id";
    private const string AttributeResname = "resname";
    private static readonly Type type = typeof(XlfFile);
    private readonly XElement node;
    private readonly XNamespace ns;
    public XlfFile(XElement node, XNamespace ns)
    {
        this.node = node;
        this.ns = ns;
        Optional = new Optionals(node);
        if (node.Elements(ns + ElementHeader).Any())
        {
            Header = new XlfHeader(node.Element(ns + ElementHeader));
        }
    }
    public XlfFile(XElement node, XNamespace ns, string original, string dataType, string sourceLang)
        : this(node, ns)
    {
        Original = original;
        DataType = dataType;
        SourceLang = sourceLang;
    }
    // xml, html etc.
    public string DataType
    {
        get => node.Attribute(AttributeDataType).Value;
        private set => node.SetAttributeValue(AttributeDataType, value);
    }
    public XlfHeader Header { get; private set; }
    public Optionals Optional { get; }
    public string Original
    {
        get => node.Attribute(AttributeOriginal).Value;
        private set => node.SetAttributeValue(AttributeOriginal, value);
    }
    public string SourceLang
    {
        get => node.Attribute(AttributeSourceLanguage).Value;
        private set => node.SetAttributeValue(AttributeSourceLanguage, value);
    }
    public IEnumerable<XlfTransUnit> TransUnits => node.Descendants(ns + ElementTransUnit).Select(t => new XlfTransUnit(t, ns));
    // Add a new or updates an existing translation unit
    public XlfTransUnit AddOrUpdateTransUnit(string id, string source, string target, XlfDialect dialect)
    {
        return AddTransUnit(id, source, target, AddMode.UpdateExisting, dialect);
    }
    public XlfTransUnit AddTransUnit(string id, string source, string target, AddMode addMode, XlfDialect dialect)
    {
        if (TryGetTransUnit(id, dialect, out XlfTransUnit resultUnit))
        {
            switch (addMode)
            {
                case AddMode.FailIfExists:
                    throw new Exception($"There is already a trans-unit with id={id}");
                    return null;
                case AddMode.SkipExisting:
                    return resultUnit;
                default:
                case AddMode.UpdateExisting:
                    resultUnit.Source = source;
                    // only update target value if there is already a target element present
                    if (resultUnit.Target != null)
                    {
                        resultUnit.Target = target;
                    }
                    return resultUnit;
            }
        }
        XElement n = new XElement(ns + ElementTransUnit);
        List<XElement> transUnits = node.Descendants(ns + ElementTransUnit).ToList();
        if (transUnits.Any())
        {
            transUnits.Last().AddAfterSelf(n);
        }
        else
        {
            List<XElement> bodyElements = node.Descendants(ns + ElementBody).ToList();
            XElement body;
            if (bodyElements.Any())
            {
                body = bodyElements.First();
            }
            else
            {
                body = new XElement(ns + ElementBody);
                node.Add(body);
            }
            body.Add(n);
        }
        if (dialect == XlfDialect.RCWinTrans11)
        {
            XlfTransUnit unit = new XlfTransUnit(n, ns, IdNone, source, target);
            unit.Optional.Resname = id;
            return unit;
        }
        if (dialect == XlfDialect.MultilingualAppToolkit)
        {
            if (!id.StartsWith(XlfTransUnit.ResxPrefix, StringComparison.InvariantCultureIgnoreCase))
            {
                return new XlfTransUnit(n, ns, XlfTransUnit.ResxPrefix + id, source, target);
            }
        }
        return new XlfTransUnit(n, ns, id, source, target);
    }
    public XlfTransUnit GetTransUnit(string id, XlfDialect dialect)
    {
        return TransUnits.First(u => u.GetId(dialect) == id);
    }
    public bool TryGetTransUnit(string id, XlfDialect dialect, out XlfTransUnit unit)
    {
        try
        {
            unit = GetTransUnit(id, dialect);
            return true;
        }
        catch (InvalidOperationException)
        {
            unit = null;
            return false;
        }
        catch (NullReferenceException)
        {
            unit = null;
            return false;
        }
    }
    public void RemoveTransUnit(string id, XlfDialect dialect)
    {
        switch (dialect)
        {
            case XlfDialect.RCWinTrans11:
                RemoveTransUnit(AttributeResname, id);
                break;
            case XlfDialect.MultilingualAppToolkit:
                RemoveTransUnit(AttributeId, XlfTransUnit.ResxPrefix + id);
                break;
            default:
                RemoveTransUnit(AttributeId, id);
                break;
        }
    }
    public void RemoveTransUnit(string identifierName, string identifierValue)
    {
        node.Descendants(ns + ElementTransUnit).Where(u =>
        {
            XAttribute a = u.Attribute(identifierName);
            return a != null && a.Value == identifierValue;
        }).Remove();
    }
    public void Export(string outputFilePath, IXlfExporter handler, List<string> stateFilter,
        List<string> restTypeFilter, XlfDialect dialect)
    {
        IEnumerable<XlfTransUnit> units = stateFilter != null && stateFilter.Any()
            ? TransUnits.Where(u => stateFilter.Contains(u.Optional.TargetState))
            : TransUnits;
        units = restTypeFilter != null && restTypeFilter.Any()
            ? units.Where(u => restTypeFilter.Contains(u.Optional.Restype))
            : units;
        handler.ExportTranslationUnits(outputFilePath, units, Optional.TargetLang, dialect);
    }
    public class Optionals
    {
        private const string AttributeBuildNum = "build-num";
        private const string AttributeProductName = "product-name";
        private const string AttributeProductVersion = "product-version";
        private const string AttributeTargetLanguage = "target-language";
        private const string AttributeToolId = "tool-id";
        private readonly XElement node;
        public Optionals(XElement node)
        {
            this.node = node;
        }
        public string BuildNum
        {
            get => GetAttributeIfExists(AttributeBuildNum);
            set => node.SetAttributeValue(AttributeBuildNum, value);
        }
        public string ProductName
        {
            get => GetAttributeIfExists(AttributeProductName);
            set => node.SetAttributeValue(AttributeProductName, value);
        }
        public string ProductVersion
        {
            get => GetAttributeIfExists(AttributeProductVersion);
            set => node.SetAttributeValue(AttributeProductVersion, value);
        }
        public string TargetLang
        {
            get => GetAttributeIfExists(AttributeTargetLanguage);
            set => node.SetAttributeValue(AttributeTargetLanguage, value);
        }
        public string ToolId
        {
            get => GetAttributeIfExists(AttributeToolId);
            set => node.SetAttributeValue(AttributeToolId, value);
        }
        public string GetAttributeIfExists(string name)
        {
            return XmlUtil.GetAttributeIfExists(node, name);
        }
    }
}
