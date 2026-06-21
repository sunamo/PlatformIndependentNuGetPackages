namespace SunamoEntity.Entity;

/// <summary>
/// Analyzes a string and provides character complexity information.
/// </summary>
public class ComplexInfoString
{
    private int quantityNumbers = 0;
    private int quantityUpperChars = 0;
    private int quantityLowerChars = 0;
    private int quantitySpecialChars = 0;
    private Dictionary<char, int> characterCounts = new Dictionary<char, int>();

    /// <summary>
    /// Gets the count of a specific character in the analyzed string.
    /// </summary>
    /// <param name="character">The character to look up.</param>
    public int this[char character]
    {
        get
        {
            if (characterCounts.ContainsKey(character))
            {
                return characterCounts[character];
            }
            return 0;
        }
    }

    /// <summary>
    /// Gets the quantity of numeric characters found.
    /// </summary>
    public int QuantityNumbers
    {
        get
        {
            return quantityNumbers;
        }
    }

    /// <summary>
    /// Gets the quantity of lowercase characters found.
    /// </summary>
    public int QuantityLowerChars
    {
        get
        {
            return quantityLowerChars;
        }
    }

    /// <summary>
    /// Gets the quantity of special characters found.
    /// </summary>
    public int QuantitySpecialChars
    {
        get
        {
            return quantitySpecialChars;
        }
    }

    /// <summary>
    /// Gets the quantity of uppercase characters found.
    /// </summary>
    public int QuantityUpperChars
    {
        get
        {
            return quantityUpperChars;
        }
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="ComplexInfoString"/> class by analyzing the given text.
    /// </summary>
    /// <param name="text">The text to analyze for character complexity.</param>
    public ComplexInfoString(string text)
    {
        foreach (char item in text)
        {
            int keyCode = item;
            LetterAndDigitKeyCodeService letterAndDigitKeyCodeService = new();
            SpecialKeyCodeServices specialKeyCodeService = new();
            if (letterAndDigitKeyCodeService.LowerKeyCodes.Contains(keyCode))
            {
                quantityLowerChars++;
                NumberLettersOrDigit++;
            }
            else if (letterAndDigitKeyCodeService.UpperKeyCodes.Contains(keyCode))
            {
                quantityUpperChars++;
                NumberLettersOrDigit++;
            }
            else if (letterAndDigitKeyCodeService.NumericKeyCodes.Contains(keyCode))
            {
                quantityNumbers++;
                NumberLettersOrDigit++;
            }
            else if (specialKeyCodeService.SpecialKeyCodes.Contains(keyCode))
            {
                quantitySpecialChars++;
            }
            if (characterCounts.ContainsKey(item))
            {
                characterCounts[item]++;
            }
            else
            {
                characterCounts.Add(item, 1);
            }
            if (CountOfNeededLettersOrDigit != int.MaxValue)
            {
                if (NumberLettersOrDigit > CountOfNeededLettersOrDigit)
                {
                    break;
                }
            }
        }
    }

    /// <summary>
    /// Gets or sets the count of needed letters or digits before stopping analysis.
    /// </summary>
    public int CountOfNeededLettersOrDigit { get; set; } = int.MaxValue;

    /// <summary>
    /// Gets or sets the number of letters or digits found so far.
    /// </summary>
    public int NumberLettersOrDigit { get; set; } = 0;
}
