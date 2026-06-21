namespace SunamoSharedMisc._SunamoExceptions.ai;


/// <summary>
/// Implementation of Windows platform interop actions.
/// </summary>
public class AIWinPi : IAIWinPi
{
    /// <summary>
    /// Gets or sets the action to run a process as a desktop user without admin privileges.
    /// </summary>
    public Action<string> PHWinPiRunAsDesktopUserNoAdmin { get; set; } = null!;
}