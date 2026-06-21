namespace SunamoSharedMisc;

/// <summary>
/// Wrapper that provides unified access to either a string or StringBuilder.
/// </summary>
public class StringBuilderString
{
    private readonly bool isString;
    private readonly string text = null!;
    private readonly StringBuilder stringBuilder = null!;

    /// <summary>
    /// Initializes a new instance wrapping a string value.
    /// </summary>
    /// <param name="value">The string value to wrap.</param>
    public StringBuilderString(string value)
    {
        text = value;
        isString = true;
    }

    /// <summary>
    /// Initializes a new instance wrapping a StringBuilder.
    /// </summary>
    /// <param name="value">The StringBuilder to wrap.</param>
    public StringBuilderString(StringBuilder value)
    {
        stringBuilder = value;
    }

    /// <summary>
    /// The length of the underlying string or StringBuilder.
    /// </summary>
    public int Length { get; set; }

    /// <summary>
    /// Gets or sets the character at the specified index.
    /// </summary>
    /// <param name="index">The zero-based index.</param>
    public char this[int index]
    {
        get
        {
            if (isString)
                return text[index];
            return stringBuilder[index];
        }
        set
        {
            if (isString)
                ThrowEx.NotSupported();
            else
                stringBuilder[index] = value;
        }
    }

    /// <summary>
    /// Checks whether the underlying value is null or whitespace.
    /// </summary>
    public bool IsNullOrWhiteSpace()
    {
        if (isString) return string.IsNullOrWhiteSpace(text);
        return stringBuilder != null && stringBuilder.ToString().Trim() != string.Empty;
    }
}
