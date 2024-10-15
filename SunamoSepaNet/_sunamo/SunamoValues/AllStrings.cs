namespace SunamoSepaNet._sunamo.SunamoValues;
public class AllStrings
{
    public const string dot = ".";
    public const string comma = ",";

    /// <summary>
    ///     space wrapped equal sign
    /// </summary>
    public const string swes = " = ";

    /// <summary>
    ///     space wrapped dash
    /// </summary>
    public const string swda = " - ";

    public const string dash = "-";

    /// <summary>
    ///     Question mark
    /// </summary>
    public const string q = "?";

    /// <summary>
    ///     double dots
    /// </summary>
    public const string dd = "..";

    /// <summary>
    ///     double dots slash
    /// </summary>
    public const string dds = "../";

    public const string ds = "./";
    public const string dotSpace = ". ";
    public const string slashAsterisk = "/*";
    public const string asteriskSlash = "*/";
    public const string apostrophe = "'";
    public const string us = "_";
    public const string space = " ";
    public const string emDash = "�";

    /// <summary>
    ///     ORDINAL BRACKET
    /// </summary>
    public const string lb = "(";

    public const string rb = ")";
    public const string tab = "\t";
    public const string nl = "\n";
    public const string cr = "\r";
    public const string bs = @"\";
    public const string slash = "/";
    public const string asterisk = "*";

    /// <summary>
    ///     semicolon
    /// </summary>
    public const string sc = ";";

    /// <summary>
    ///     should be quot
    /// </summary>
    public const string qm = "\"";

    public const string doubleSpace = "  ";
    public const string bs2 = "\b";
    public const string lq = "�";
    public const string rq = "�";
    public const string la = "�";
    public const string ra = "�";
    public const string st = "\0";
    public const string euro = "�";
    public static List<string> whiteSpacesChars = null;

    /// <summary>
    ///     " - "
    /// </summary>
    public static string swd = " - ";

    /// <summary>
    ///     comma space
    /// </summary>
    public static string cs = ", ";

    /// <summary>
    ///     colon space
    /// </summary>
    public static string cs2 = ": ";

    public static string doubleSpace32160 = space + space160;
    public static string doubleSpace16032 = space160 + space;
    public static string space160 = AllChars.space160.ToString();
    public static string doubleBs = bs + bs;

    public static string DoubleSpace32160
    {
        get => doubleSpace32160;
        set => doubleSpace32160 = value;
    }

    ///// <summary>
    ///// space wrapped dash
    ///// </summary>
    //public const string swda = " - ";
    //public const string lowbar = "_";
    //public const string colon = ":";
    //public const string dash = "-";
    //public const string space = " ";
    //public const string bs = "\\";
    //public static string comma = ",";
    //public static string sc = ";";
    //public const string lcub = "{";
    //public const string rcub = "}";
    //public const string lt = "<";
    //public const string dot = ".";

    #region Generated with SunamoFramework.HtmlEntitiesForNonDigitsOrLetterChars

    public const string period = ".";
    public const string colon = ":";
    public const string excl = "!";
    public const string apos = "'";
    public const string quest = "?";
    public const string rpar = ")";
    public const string lpar = "(";
    public const string sol = "/";
    public const string lowbar = "_";
    public const string lt = "<";
    public const string equals = "=";
    public const string gt = ">";
    public const string amp = "&";
    public const string lcub = "{";
    public const string rcub = "}";
    public const string lsqb = "[";
    public const string verbar = "|";
    public const string semi = ";";
    public const string commat = "@";
    public const string ast = "*";
    public const string plus = "+";
    public const string rsqb = "]";
    public const string num = "#";
    public const string percnt = "%";
    public const string dollar = "$";
    public const string Hat = "^";
    public const string ndash = "�";
    public const string copy = "�";

    #endregion
}