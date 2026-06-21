namespace SunamoEntity._sunamo.SunamoInterfaces.Interfaces;


/// <summary>
/// Dialog window interface for folder selection.
/// </summary>
internal interface IDW
{
    /// <summary>
    /// Opens a folder selection dialog starting from the specified root folder path.
    /// </summary>
    /// <param name="rootFolder">The root folder path.</param>
    string SelectOfFolder(string rootFolder);

    /// <summary>
    /// Opens a folder selection dialog starting from the specified special folder.
    /// </summary>
    /// <param name="rootFolder">The special folder to start from.</param>
    string SelectOfFolder(Environment.SpecialFolder rootFolder);
}