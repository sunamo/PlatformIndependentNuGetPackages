namespace SunamoStorage._sunamo;

/// <summary>
/// Provides lists of letter and digit characters for classification.
/// </summary>
internal class LetterAndDigitCharService
{
#pragma warning disable CS0649
    internal List<char>? AllCharsWithoutSpecial;
    internal List<char>? AllChars;
#pragma warning restore CS0649
    internal readonly List<char> NumericChars =
        new(new[] { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' });
    internal readonly List<char> LowerChars = new(new[]
    {
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z'
    });
    internal readonly List<char> UpperChars = new(new[]
    {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
        'W', 'X', 'Y', 'Z'
    });
}