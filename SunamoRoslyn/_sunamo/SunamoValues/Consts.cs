namespace SunamoRoslyn._sunamo.SunamoValues;
/// <summary>
///     Jelikož se jedná jen o tvrdé řetězce a jde mi o to furt jen nepřesouvat kód, už navždy to vše bude v SE.
/// </summary>
internal class Consts
{
    // TODO: Distribute to other because internal class name is the same as namespace
    internal const string AfterCloseNonCompletedSettingsWizard = "Wizard of settings wasn't completed. Do you want close it?";
    internal const int OneMB = 1048576;
    internal const int OneMB1 = 1048577;
    #region MyRegion
    internal const string sirkaNazev = "45%";
    internal const string sirkaVoteCount = "10%";
    internal const string sirkaButtony = "35%";
    internal static int MaxLengthColumnWordInTablesWords = 60;
    internal static object dialogSize;
    #endregion
    /// <summary>
    ///     užitečné pro kontrolu zda jsem do params string[] nepředal list.
    /// </summary>
    internal const string ListTS = @"System.Collections.Generic.List`1[System.String]";
    internal const string lc = "//";
    internal const string nl = "\n";
    internal const string rn = "\r\n";
    internal const string nl2 = rn;
    /// <summary>
    ///     hází to exception i když se jedná jen warning, viz. exceptionWarning
    ///     myslím že nejlepší bude na Exception: nekontrolovat
    ///     to tam přidává powershell jen na základě toho že to jde to error outputu
    ///     ale v případě gitu to neznamená chybu ale pouze varování.
    /// </summary>
    private const string exceptionWarning = "Exception: warning:";
    internal const string Exception = "Exception: ";
    internal const string stringEmpty = "";
    internal const string se = "";
    internal const string nulled = "(null)";
    internal const string Schema = "http://schemas.microsoft.com/developer/msbuild/2003";
    internal const string qMachineName = "NRJANCIK";
    internal const string xmlns = "xmlns";
    internal const string gitFolderName = ".git";
    internal const string _3Asterisks = "***";
    internal const string _5Asterisks = "*****";
    internal const string Test = "Test_";
    internal const string NoEntries = "No entries";
    internal const string slashLocalhost = AllStrings.slash + sunamoNet;
    internal const string slashScz = AllStrings.slash + Cz;
    internal const string dotScz = ".sunamo.cz";
    internal const string dotSczSlash = ".sunamo.cz/";
    internal const string sunamoNetSlash = "sunamo.net/";
    internal const string appscs = "appscs";
    internal const string ChytreAplikace = "chytre-aplikace.cz";
    // internal const string Nope = XlfKeys.Nope;
    internal const string transformTo = "->";
    internal const string fnReplacement = "{filename}";
    /// <summary>
    ///     Dot space.
    /// </summary>
    internal const string ds = ": ";
    /// <summary>
    ///     "x ".
    /// </summary>
    internal const string xs = "x ";
    internal const string spaces4 = "    ";
    internal const string HttpLocalhostSlash = "https://sunamo.net/";
    internal const string HttpSunamoCzSlash = "https://sunamo.cz/";
    /// <summary>
    ///     sunamoNet.
    /// </summary>
    internal const string sunamoNet = "sunamo.net";
    internal const string HttpWwwCzSlash = "https://sunamo.cz/";
    internal const string HttpCzSlash = "https://sunamo.cz/";
    internal const string HttpWwwCz = "https://sunamo.cz";
    internal const string httpLocalhost = "https://sunamo.net/";
    /// <summary>
    ///     sunamo.cz
    ///     Without slash.
    /// </summary>
    internal const string Cz = "sunamo.cz";
    internal const string WwwCz = "sunamo.cz";
    internal const string CzSlash = "sunamo.cz/";
    internal const string DotCzSlash = ".sunamo.cz/";
    internal const string DotCz = ".sunamo.cz";
    /// <summary>
    ///     http://.
    /// </summary>
    internal const string http = "http://";
    /// <summary>
    ///     https://.
    /// </summary>
    internal const string https = "https://";
    internal const string http2 = "http";
    internal const string sunamo = "sunamo";
    internal const string sunamocz = "sunamocz";
    // internal static string dots3 = "...";
    internal const string bs = AllStrings.bs;
    internal const string tab = "\t";
    internal const string cr = "\t";
    /// <summary>
    /// \\?\.
    /// </summary>
    // internal const string UncLongPath = @"\\?\";
    /// <summary>
    ///     \\?\
    /// </summary>
    internal const string UncLongPath = @"\\?\";
    /// <summary>
    ///     Here because is use in Events, AllProjectsSearch etc.
    /// </summary>
    internal const int addRowsToCodeTextBoxDuringScrolling = 0;
    internal const string cs = "cs ";
    internal const string en = "en ";
    internal const string na = "n/a";
    internal const string NA = "N/A";
    internal const string x = "X";
    internal const string dirUp = @"..\";
    internal const string dirUp3 = @"..\..\..\";
    internal const string dirUp5 = @"..\..\..\..\..\";
    internal const string Test_ = "Test_";
    internal const int waitMsOpenInBrowser = 0;
    internal static string dots3 = "...";
    // internal const string Schema = "http://schemas.microsoft.com/developer/msbuild/2003";
    // internal const string nulled = "(null)";
    // internal static string sunamoNetIp = "127.0.0.1";
    // internal static byte[] sunamoNetIpBytes = new byte[] { 127, 0, 0, 1 };
    // internal const string transformTo = "->";
    // internal const string se = "";
    /// <summary>
    ///     Must be also in Consts, not only in SqlServerHelper due to use in sunamo project.
    /// </summary>
    internal static readonly DateTime DateTimeMinVal = new(1900, 1, 1);
    internal static readonly DateTime DateTimeMaxVal = new(2079, 6, 6);
    internal static string sunamoNetIpV6 = "fe80:";
    internal static string sunamoNetIp = "127.0.0.1";
    internal static byte[] sunamoNetIpBytes = { 127, 0, 0, 1 };
    internal static DateTime nDateTimeMinVal = new(2010, 1, 1, 0, 0, 0);
    internal static DateTime nDateTimeMaxVal = new(2032, 12, 31, 23, 59, 59);
    internal static string isNot = "!=";
    internal static string addressHavirovAntalaStaska = string.Empty;
    internal static string Load = "Load";
    internal static string AppendWithoutDuplicates = "AppendWithoutDuplicates";
    internal static string Nope = "Nope";
    internal static string HtmlDoctype = "<!DOCTYPE html>";
    /// <summary>
    ///     Must be here due to XmlAgilityDocumentTest.
    /// </summary>
    internal static string Include = "Include";
    internal static string OK = "OK";
}
