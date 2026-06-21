namespace SunamoEssential._sunamo.SunamoInterfaces.Interfaces.SunamoPS;

/// <summary>
/// PowerShell helper interface for executing commands and detecting file languages.
/// </summary>
internal interface IPowershellHelper
{
    /// <summary>
    /// Executes a command using cmd /c.
    /// </summary>
    /// <param name="command">The command to execute.</param>
#if ASYNC
    Task
#else
    void
#endif
    CmdC(string command);

    /// <summary>
    /// Detects the programming language of a file using GitHub Linguist.
    /// </summary>
    /// <param name="windowsPath">The Windows file path to analyze.</param>
#if ASYNC
    Task<string>
#else
    string
#endif
    DetectLanguageForFileGithubLinguist(string windowsPath);

    /// <summary>
    /// Returns a list of running process names.
    /// </summary>
    List<string> ProcessNames();
}
