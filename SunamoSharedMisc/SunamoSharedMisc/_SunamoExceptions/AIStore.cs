namespace SunamoSharedMisc._SunamoExceptions;

/// <summary>
/// Static store for AI subsystem instances.
/// </summary>
public class AIStore
{
    /// <summary>
    /// Windows platform interop instance.
    /// </summary>
    public static IAIWinPi WinPi { get; set; } = null!;
}
