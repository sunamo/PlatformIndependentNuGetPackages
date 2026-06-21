namespace SunamoCryptAlgorithms._sunamo;

/// <summary>
/// Provides lists of special characters for classification and filtering.
/// </summary>
internal class SpecialCharsService
{
    internal readonly List<char> SpecialChars = new(new[]
        { exclamation, atSign, hash, dollar, percent, hat, ampersand, asteriskChar, question, underscore, tilde });
    internal readonly List<char> SpecialCharsExtended = new(new[]
    {
        leftQuote, rightQuote, dash, leftApostrophe, rightApostrophe,
        comma, period, colon, apostrophe, rightParenthesis, solidus, lessThan, greaterThan, leftCurlyBracket, rightCurlyBracket, leftSquareBracket, verticalBar, semicolon, plus, rightSquareBracket,
        enDash, forwardSlash
    });
    /// <summary>
    /// Used in enigma.
    /// </summary>
#pragma warning disable CS0649
    internal readonly List<char>? SpecialCharsAll;
#pragma warning restore CS0649
    internal readonly List<char> SpecialCharsWhite = new(new[] { space });
    internal readonly List<char> SpecialCharsNotEnigma = new(new[] { nonBreakingSpace, copyright });
    private const char leftApostrophe = '\u2018';
    private const char rightApostrophe = '\u2019';
    private const char comma = ',';
    private const char space = ' ';
    private static char nonBreakingSpace = (char)160;
    private const char dollar = '$';
    private const char hat = '^';
    private const char asteriskChar = '*';
    private const char question = '?';
    private const char tilde = '~';
    private const char period = '.';
    private const char colon = ':';
    private const char exclamation = '!';
    private const char apostrophe = '\'';
    private const char rightParenthesis = ')';
    private const char leftParenthesis = '(';
    private const char solidus = '/';
    private const char underscore = '_';
    private const char lessThan = '<';
    /// <summary>
    /// Skipped in SpecialCharsExtended - already used as equals.
    /// </summary>
    private const char equalsSign = '=';
    private const char greaterThan = '>';
    private const char ampersand = '&';
    private const char leftCurlyBracket = '{';
    private const char rightCurlyBracket = '}';
    private const char leftSquareBracket = '[';
    private const char verticalBar = '|';
    private const char semicolon = ';';
    private const char atSign = '@';
    private const char plus = '+';
    private const char rightSquareBracket = ']';
    private const char hash = '#';
    private const char percent = '%';
    private const char enDash = '\u2013';
    private const char copyright = '\u00A9';
    private const char leftQuote = '\u201C';
    private const char rightQuote = '\u201D';
    private const char zero = '0';
    private const char modulo = '%';
    private const char dash = '-';
    private const char tab = '\t';
    private const char newLine = '\n';
    private const char carriageReturn = '\r';
    private const char quotationMark = '"';
    private const char leftBracket = '(';
    private const char rightBracket = ')';
    private const char forwardSlash = '/';
    /// <summary>
    /// Backspace character.
    /// </summary>
    private const char backspace = '\b';
}
