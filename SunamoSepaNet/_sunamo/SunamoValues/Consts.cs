namespace SunamoSepaNet._sunamo.SunamoValues;
/// <summary>
///     Jelikož se jedná jen o tvrdé řetězce a jde mi o to furt jen nepřesouvat kód, už navždy to vše bude v .
/// </summary>
public class Consts
{
    // TODO: Distribute to other because public class name is the same as namespace
    public const string AfterCloseNonCompletedSettingsWizard =
        "Wizard of settings wasn't completed. Do you want close it?";

    public const int OneMB = 1048576;
    public const int OneMB1 = 1048577;

    /// <summary>
    ///     užitečné pro kontrolu zda jsem do params string[] nepředal list.
    /// </summary>
    public const string ListTS = @"System.Collections.Generic.List`1[System.String]";

    public const string lc = "//";
    public const string nl = "\n";
    public const string rn = "\r\n";
    public const string nl2 = rn;

    /// <summary>
    ///     hází to exception i když se jedná jen warning, viz. exceptionWarning
    ///     myslím že nejlepší bude na Exception: nekontrolovat
    ///     to tam přidává powershell jen na základě toho že to jde to error outputu
    ///     ale v případě gitu to neznamená chybu ale pouze varování.
    /// </summary>
    private const string exceptionWarning = "Exception: warning:";

    public const string Exception = "Exception: ";
    public const string stringEmpty = "";
    public const string se = "";
    public const string nulled = "(null)";
    public const string Schema = "http://schemas.microsoft.com/developer/msbuild/2003";
    public const string qMachineName = "NRJANCIK";
    public const string xmlns = "xmlns";
    public const string gitFolderName = ".git";
    public const string _3Asterisks = "***";
    public const string _5Asterisks = "*****";
    public const string Test = "Test_";
    public const string NoEntries = "No entries";
    public const string slashLocalhost = AllStrings.slash + sunamoNet;
    public const string slashScz = AllStrings.slash + Cz;
    public const string dotScz = ".sunamo.cz";
    public const string dotSczSlash = ".sunamo.cz/";
    public const string sunamoNetSlash = "sunamo.net/";
    public const string appscs = "appscs";

    public const string ChytreAplikace = "chytre-aplikace.cz";

    // public const string Nope = XlfKeys.Nope;
    public const string transformTo = "->";
    public const string fnReplacement = "{filename}";

    /// <summary>
    ///     Dot space.
    /// </summary>
    public const string ds = ": ";

    /// <summary>
    ///     "x ".
    /// </summary>
    public const string xs = "x ";

    public const string spaces4 = "    ";
    public const string HttpLocalhostSlash = "https://sunamo.net/";
    public const string HttpSunamoCzSlash = "https://sunamo.cz/";

    /// <summary>
    ///     sunamoNet.
    /// </summary>
    public const string sunamoNet = "sunamo.net";

    public const string HttpWwwCzSlash = "https://sunamo.cz/";
    public const string HttpCzSlash = "https://sunamo.cz/";
    public const string HttpWwwCz = "https://sunamo.cz";
    public const string httpLocalhost = "https://sunamo.net/";

    /// <summary>
    ///     sunamo.cz
    ///     Without slash.
    /// </summary>
    public const string Cz = "sunamo.cz";

    public const string WwwCz = "sunamo.cz";
    public const string CzSlash = "sunamo.cz/";
    public const string DotCzSlash = ".sunamo.cz/";
    public const string DotCz = ".sunamo.cz";

    /// <summary>
    ///     http://.
    /// </summary>
    public const string http = "http://";

    /// <summary>
    ///     https://.
    /// </summary>
    public const string https = "https://";

    public const string http2 = "http";
    public const string sunamo = "sunamo";

    public const string sunamocz = "sunamocz";

    // public static string dots3 = "...";
    public const string bs = AllStrings.bs;
    public const string tab = "\t";

    public const string cr = "\t";

    /// <summary>
    /// \\?\.
    /// </summary>
    // public const string UncLongPath = @"\\?\";
    /// <summary>
    ///     \\?\
    /// </summary>
    public const string UncLongPath = @"\\?\";

    /// <summary>
    ///     Here because is use in Events, AllProjectsSearch etc.
    /// </summary>
    public const int addRowsToCodeTextBoxDuringScrolling = 0;

    public const string cs = "cs ";
    public const string en = "en ";
    public const string na = "n/a";
    public const string NA = "N/A";
    public const string x = "X";
    public const string dirUp = @"..\";
    public const string dirUp3 = @"..\..\..\";
    public const string dirUp5 = @"..\..\..\..\..\";
    public const string Test_ = "Test_";
    public const int waitMsOpenInBrowser = 0;

    public static string dots3 = "...";

    // public const string Schema = "http://schemas.microsoft.com/developer/msbuild/2003";
    // public const string nulled = "(null)";
    // public static string sunamoNetIp = "127.0.0.1";
    // public static byte[] sunamoNetIpBytes = new byte[] { 127, 0, 0, 1 };
    // public const string transformTo = "->";
    // public const string se = "";
    /// <summary>
    ///     Must be also in Consts, not only in SqlServerHelper due to use in sunamo project.
    /// </summary>
    public static readonly DateTime DateTimeMinVal = new(1900, 1, 1);

    public static readonly DateTime DateTimeMaxVal = new(2079, 6, 6);
    public static string sunamoNetIpV6 = "fe80:";
    public static string sunamoNetIp = "127.0.0.1";
    public static byte[] sunamoNetIpBytes = { 127, 0, 0, 1 };
    public static DateTime nDateTimeMinVal = new(2010, 1, 1, 0, 0, 0);
    public static DateTime nDateTimeMaxVal = new(2032, 12, 31, 23, 59, 59);
    public static string isNot = "!=";
    public static string addressHavirovAntalaStaska = string.Empty;
    public static string Load = "Load";
    public static string AppendWithoutDuplicates = "AppendWithoutDuplicates";
    public static string Nope = "Nope";
    public static string HtmlDoctype = "<!DOCTYPE html>";

    /// <summary>
    ///     Must be here due to XmlAgilityDocumentTest.
    /// </summary>
    public static string Include = "Include";

    public static string OK = "OK";

    #region MyRegion

    public const string sirkaNazev = "45%";
    public const string sirkaVoteCount = "10%";
    public const string sirkaButtony = "35%";
    public static int MaxLengthColumnWordInTablesWords = 60;
    public static object dialogSize;

    #endregion
}