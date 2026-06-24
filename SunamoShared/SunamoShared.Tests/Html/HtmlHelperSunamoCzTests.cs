public class HtmlHelperSunamoCzTests
{
    /*

     */

    [Fact]
    public void ConvertTextToHtmlWithAnchorsTest()
    {
        //Užitečný nástroj který stahuje auta ze 
        var input = @"https://sauto.cz a vytváří tabulku v *Google Sheets* pro snadné _porovnání_ dostupných dat pro -zvolení- auta jež je nejblíže Vašemu snu o nové mobilitě.";
        var error = string.Empty;
        var actual = HtmlHelperSunamoCz.ConvertTextToHtmlWithAnchors(input, ref error);
        int s = 0;
    }
}
