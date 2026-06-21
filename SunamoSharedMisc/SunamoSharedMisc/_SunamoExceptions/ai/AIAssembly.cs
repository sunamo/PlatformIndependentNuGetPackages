namespace SunamoSharedMisc._SunamoExceptions.ai;

/// <summary>
/// Wrapper for assembly-loaded AI component of type T.
/// </summary>
/// <typeparam name="T">The interface type of the AI component.</typeparam>
public class AIAssembly<T>
{
    /// <summary>
    /// The resolved instance value.
    /// </summary>
    public object Value { get; set; } = null!;
}
