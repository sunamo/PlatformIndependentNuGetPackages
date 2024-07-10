namespace SunamoXliffParser;

/// <summary>
///     The
///     <note>
///         element is used to add localization-related comments to the XLIFF document. The content of
///         <note>
///             may be instructions from developers about how to handle the
///             <source>
///                 , comments from the translator about the
///                 translation, or any comment from anyone involved in processing the XLIFF file. The optional xml:lang
///                 attribute
///                 specifies the language of the note content. The optional from attribute indicates who entered the note.
///                 The optional priority attribute allows a priority from 1 (high) to 10 (low) to be assigned to the note.
///                 The optional annotates attribute indicates if the note is a general note or, in the case of a
///                 <trans-unit>
///                     ,
///                     pertains specifically to the <source> or the <target> element.
/// </summary>
public class XlfNote
{
    private readonly XElement node;

    public XlfNote(XElement node)
    {
        this.node = node;
        Optional = new Optionals(this.node);
    }

    public Optionals Optional { get; }

    public string Value
    {
        get => node.Value;
        set => node.Value = value;
    }

    public XElement GetNode()
    {
        return node;
    }

    public class Optionals
    {
        private const string AttributeAnnotates = "annotates";
        private const string AttributeFrom = "from";
        private const string AttributePriority = "priority";
        private readonly XElement node;

        public Optionals(XElement node)
        {
            this.node = node;
        }

        /// <summary>
        ///     Indicates if the note is a general note or, in the case of a
        ///     <trans-unit>
        ///         ,
        ///         pertains specifically to the <source> or the <target> element.
        /// </summary>
        public string Annotates
        {
            get => XmlUtil.GetAttributeIfExists(node, AttributeAnnotates);
            set => node.SetAttributeValue(AttributeAnnotates, value);
        }

        /// <summary>
        ///     Indicates who entered the note.
        /// </summary>
        public string From
        {
            get => XmlUtil.GetAttributeIfExists(node, AttributeFrom);
            set => node.SetAttributeValue(AttributeFrom, value);
        }

        /// <summary>
        ///     Specifies the language of the note content.
        /// </summary>
        public string Lang
        {
            get => XmlUtil.GetAttributeIfExists(node, "xml:lang");
            set => node.SetAttributeValue("xml:lang", value);
        }

        /// <summary>
        ///     Allows a priority from 1 (high) to 10 (low) to be assigned to the note.
        /// </summary>
        public int Priority
        {
            get => XmlUtil.GetIntAttributeIfExists(node, AttributePriority);
            set => node.SetAttributeValue(AttributePriority, value);
        }
    }
}
