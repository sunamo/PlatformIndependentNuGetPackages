namespace SunamoSharedMisc._SunamoExceptions.ai;

/// <summary>
/// Initialization arguments for AI subsystem.
/// </summary>
public class AIInitArgs
{
    /// <summary>
    /// Windows platform interop assembly wrapper.
    /// </summary>
    public AIAssembly<IAIWinPi> WinPi { get; set; } = null!;
}
