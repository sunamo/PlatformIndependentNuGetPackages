namespace SunamoSepaNet._sunamo.SunamoValues;
public class AllChars
{
    public const char comma = ',';
    public const char bs = '\\';
    public const char dot = '.';
    public const char la = '‘';
    public const char ra = '’';
    public const char st = '\0';
    public const char euro = '€';
    public static List<char> vsZnakyWithoutSpecial;
    public static List<char> vsZnaky;

    public static readonly List<int> specialKeyCodes =
        new(new[] { 33, 64, 35, 36, 37, 94, 38, 42, 63, 95, 126 });

    public static readonly List<char> specialCharsWhite = new(new[] { space });
    public static readonly List<char> specialCharsNotEnigma = new(new[] { nbsp, space160, copy });

    /// <summary>
    ///     Used in enigma
    /// </summary>
    public static readonly List<char> specialCharsAll;

    public static readonly List<int> numericKeyCodes = new(new[] { 49, 50, 51, 52, 53, 54, 55, 56, 57, 48 });

    public static readonly List<char> numericChars =
        new(new[] { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' });

    public static readonly List<int> lowerKeyCodes = new(new[]
    {
        97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
        120, 121, 122
    });

    public static readonly List<char> lowerChars = new(new[]
    {
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z'
    });

    public static readonly List<int> upperKeyCodes = new(new[]
        { 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90 });

    public static readonly List<char> upperChars = new(new[]
    {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
        'W', 'X', 'Y', 'Z'
    });

    public static readonly List<char> specialChars = new(new[]
        { excl, commat, num, dollar, percnt, Hat, amp, ast, quest, lowbar, tilda });

    private static readonly Type type = typeof(AllChars);

    // my extension
    public static readonly List<char> generalChars;

    // IsWhiteSpace
    // , 55296 mi taky vrátila metoda IsWhiteSpace vrátila, ale při znovu vytvoření pomocí tohoto kódu to vyhazovalo výjimku
    /// <summary>
    ///     160 is space, is used for example in Uctenkovka
    /// </summary>
    public static readonly List<int> whiteSpacesCodes = new(new[]
    {
        9, 10, 11, 12, 13, 32, 133, 160, 5760, 6158, 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202,
        8232, 8233, 8239, 8287, 12288
    });

    public static List<char> whiteSpacesChars;
    public static char space160 = (char)160;
    public static readonly char notNumber;

    /// <summary>
    ///     2020-07-4 added slash
    /// </summary>
    public static readonly List<char> specialChars2 = new(new[]
    {
        lq, rq, dash, la, ra,
        comma, period, colon, apos, rpar, sol, lt, gt, lcub, rcub, lsqb, verbar, semi, plus, rsqb,
        ndash, slash
    });

    static AllChars()
    {
        ConvertWhiteSpaceCodesToChars();
        notNumber = (char)whiteSpacesCodes[0];
        generalChars = new List<char>(new[] { notNumber });
        specialCharsAll = new List<char>(specialChars.Count + specialChars2.Count + specialCharsWhite.Count);
        specialCharsAll.AddRange(specialChars);
        specialCharsAll.AddRange(specialChars2);
        specialCharsAll.AddRange(specialCharsWhite);
        vsZnaky = new List<char>(lowerChars.Count + numericChars.Count + specialChars.Count + upperChars.Count);
        vsZnaky.AddRange(lowerChars);
        vsZnaky.AddRange(numericChars);
        vsZnaky.AddRange(specialChars);
        vsZnaky.AddRange(upperChars);
        vsZnakyWithoutSpecial = new List<char>(lowerChars.Count + numericChars.Count + upperChars.Count);
        vsZnakyWithoutSpecial.AddRange(lowerChars);
        vsZnakyWithoutSpecial.AddRange(numericChars);
        vsZnakyWithoutSpecial.AddRange(upperChars);
    }

    public static Predicate<char> ReturnRightPredicate(char genericChar)
    {
        Predicate<char> predicate = null;
        if (genericChar == notNumber)
            predicate = char.IsNumber;
        else
            ThrowEx.NotImplementedCase(generalChars);
        return predicate;
    }

    public static void ConvertWhiteSpaceCodesToChars()
    {
        AllStrings.whiteSpacesChars = new List<string>(whiteSpacesCodes.Count);
        whiteSpacesChars = new List<char>(whiteSpacesCodes.Count);
        foreach (var item in whiteSpacesCodes)
        {
            var s = char.ConvertFromUtf32(item);
            var ch = Convert.ToChar(s);
            whiteSpacesChars.Add(ch);
            AllStrings.whiteSpacesChars.Add(ch.ToString());
        }
    }

    #region from AllCharsConsts.cs

    ///// <summary>
    ///// char code 32
    ///// </summary>
    //public const char space = ' ';
    ///// <summary>
    ///// Look similar as 32 space
    ///// </summary>
    //public const char nbsp = (char)160;
    //#region Generated with SunamoFramework.HtmlEntitiesForNonDigitsOrLetterChars
    //public const char dollar = '$';
    //public const char Hat = '^';
    //public const char ast = '*';
    //public const char quest = '?';
    //public const char tilda = '~';
    //public const char comma = ',';
    //public const char period = '.';
    //public const char colon = ':';
    //public const char excl = '!';
    //public const char apos = '\'';
    //public const char rpar = ')';
    //public const char lpar = '(';
    //public const char sol = '/';
    //public const char lowbar = '_';
    //public const char lt = '<';
    ///// <summary>
    ///// skip in specialChars2 - already as equal
    ///// </summary>
    //public const char equals = '=';
    //public const char gt = '>';
    //public const char amp = '&';
    //public const char lcub = '{';
    //public const char rcub = '}';
    //public const char lsqb = '[';
    //public const char verbar = '|';
    //public const char semi = ';';
    //public const char commat = '@';
    //public const char plus = '+';
    //public const char rsqb = ']';
    //public const char num = '#';
    //public const char percnt = '%';
    //public const char ndash = '–';
    //public const char copy = '©';
    //#endregion
    //public static readonly List<char> specialChars = new List<char>(new char[] { excl, commat, num, dollar, percnt, Hat, amp, ast, quest, lowbar, tilda });

    #endregion

    #region For easy copy from AllChars.cs

    // my extension
    /*
    equal->equals
    *
    * Ascii - 128 chars - 7B
    * ASCII + code page (e.g. ISO 8859-1) - 256 chars - 8B
    *
    * Unicode 11.0:
    * * Basic Multilingual Plane - 65536 letters - table 16*16, in every cell 256 letters, all others (SMP, SIP, TIP) are part of this
    * Supplementary Multilingual Plane (SMP) - Doplňková multilinguální rovina - 14000 chars -
    * Supplementary Ideographic Plane (SIP) - 53424 chars -
    * Tertiary Ideographic Plane (TIP) - 16672 chars
    * Supplementary Special-purpose Plane (SSP) - 368 chars
    * 15 PUA-A 65536
    * 16 PUA-B 65536
    *
    * =  overall 264256 letters
    *
    * Surrogates - replacement, by two surrogates is coded one letter above BMP (surrogate pair). Is in UTF16. Benefit is less space (some letters have two bytes, others 4B). In UTF32 is every char 4bytes.
    * char.IsSurrogatePair(low, right) - pair is formed by low and high
    * *
    */
    // IsControl
    //public const List<int> controlKeyCodes =
    // IsDigit - IsNumber + superset atd.
    // IsHighSurrogate -
    // IsLower
    // IsLowSurrogate
    // IsNumber - 0..9
    // IsPunctuation
    // IsSeparatorw
    // IsSurrogate
    // IsSurrogatePair
    // IsSymbol
    // IsUpper

    #endregion

    #region For easy copy from AllCharsConsts.cs

    /// <summary>
    ///     char code 32
    /// </summary>
    public const char space = ' ';

    /// <summary>
    ///     Look similar as 32 space
    /// </summary>
    public const char nbsp = (char)160;

    #region Generated with SunamoFramework.HtmlEntitiesForNonDigitsOrLetterChars

    public const char dollar = '$';
    public const char Hat = '^';
    public const char ast = '*';
    public const char quest = '?';
    public const char tilda = '~';
    public const char period = '.';
    public const char colon = ':';
    public const char excl = '!';
    public const char apos = '\'';
    public const char rpar = ')';
    public const char lpar = '(';
    public const char sol = '/';
    public const char lowbar = '_';
    public const char lt = '<';

    /// <summary>
    ///     skip in specialChars2 - already as equal
    /// </summary>
    public const char equals = '=';

    public const char gt = '>';
    public const char amp = '&';
    public const char lcub = '{';
    public const char rcub = '}';
    public const char lsqb = '[';
    public const char verbar = '|';
    public const char semi = ';';
    public const char commat = '@';
    public const char plus = '+';
    public const char rsqb = ']';
    public const char num = '#';
    public const char percnt = '%';
    public const char ndash = '–';
    public const char copy = '©';

    #endregion

    #endregion

    #region MyRegion

    public const char lq = '“';
    public const char rq = '”';

    #region Generic chars

    public const char zero = '0';

    #endregion

    #region Names here must be the same as in Consts

    public const char modulo = '%';
    public const char dash = '-';

    #endregion

    public const char tab = '\t';
    public const char nl = '\n';
    public const char cr = '\r';
    public const char asterisk = '*';
    public const char apostrophe = '\'';
    public const char sc = ';';

    /// <summary>
    ///     quotation marks
    /// </summary>
    public const char qm = '"';

    /// <summary>
    ///     Question
    /// </summary>
    public const char q = '?';

    /// <summary>
    ///     Left bracket
    /// </summary>
    public const char lb = '(';

    public const char rb = ')';
    public const char slash = '/';

    /// <summary>
    ///     backspace
    /// </summary>
    public const char bs2 = '\b';

    #endregion
}