namespace SunamoEntity._sunamo.SunamoInterfaces.Interfaces;

/// <summary>
/// Windows process helper interface.
/// Implemented as a class with Init pattern (similar to PowerShell helper)
/// to avoid excessive dependency injection.
/// </summary>
internal interface IPHWin
{
    /// <summary>
    /// Opens the specified path in a code editor.
    /// </summary>
    /// <param name="path">The file or folder path to open.</param>
    void Code(string path);
}
