namespace SunamoHttp._sunamo.SunamoFileExtensions.Attributes;


internal class TypeOfExtensionAttribute : Attribute
{
    internal TypeOfExtension Type { get; set; }
    internal TypeOfExtensionAttribute(TypeOfExtension toe)
    {
        Type = toe;
    }
}