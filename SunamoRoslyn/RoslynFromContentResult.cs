namespace SunamoRoslyn;
/// <summary>
/// Tato třída byla vytvořena abych mohl vrátit všechny elementy kódu v jednom (např. interfacy a třídy). 
/// Asi je to nepřekonatelný problém, protože pak bych musel zrušit  where T : BaseTypeDeclarationSyntax
/// A odvodit this od BaseTypeDeclarationSyntax taky nejde, implementuje mi to metody u kterých potom hlásí 'RoslynFromContentResult' does not implement inherited abstract member 'BaseTypeDeclarationSyntax.WithOpenBraceTokenCore(SyntaxToken)'
/// 
/// To dále znamená že 
/// 1/ musím poté všude dodat NS
/// 2/ musím zkontrolovat zda není více klíčových slov. teď můžu podle walkeru získat jen 1 typ elementu (třídu, rekord, atd.)
/// </summary>
public class RoslynFromContentResult //: BaseTypeDeclarationSyntax
{
    //public RoslynFromContentResult() 
    //{
    //}
    public /*BaseTypeDeclarationSyntax*/ object RoslynObject { get; set; } = null;
    public SyntaxToken Identifier => ((dynamic)RoslynObject).Identifier;
    public string IdentifierText => Identifier.Text;
}
