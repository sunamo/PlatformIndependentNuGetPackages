namespace SunamoSharedMisc.Args;

/// <summary>
/// Arguments for checking a method argument value.
/// </summary>
public class CheckArgumentArgs
{
    /// <summary>
    /// The string builder for collecting validation messages.
    /// </summary>
    public StringBuilder? StringBuilder { get; set; } = null;

    /// <summary>
    /// The name of the argument being checked.
    /// </summary>
    public string? ArgName { get; set; } = null;

    /// <summary>
    /// Whether to trim the argument value before checking.
    /// </summary>
    public bool IsTrim { get; set; } = false;

    /// <summary>
    /// Initializes a new instance with the argument name and string builder.
    /// </summary>
    /// <param name="argName">The name of the argument.</param>
    /// <param name="stringBuilder">The string builder for messages.</param>
    public CheckArgumentArgs(string argName, StringBuilder stringBuilder)
    {
        ArgName = argName;
        StringBuilder = stringBuilder;
    }
}
