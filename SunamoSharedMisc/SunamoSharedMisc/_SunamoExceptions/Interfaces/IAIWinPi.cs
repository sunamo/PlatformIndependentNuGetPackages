namespace SunamoSharedMisc._SunamoExceptions.Interfaces;
/// <summary>
/// Interface for Windows platform interop actions.
/// </summary>
public interface IAIWinPi
{
    /// <summary>
    /// Gets or sets the action to run a process as a desktop user without admin privileges.
    /// </summary>
    Action<string> PHWinPiRunAsDesktopUserNoAdmin { get; set; }
}