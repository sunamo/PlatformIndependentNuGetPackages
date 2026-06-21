namespace SunamoStorage._sunamo.SunamoInterfaces.Interfaces;


/// <summary>
/// File system operations for Windows with locked file handling.
/// </summary>
internal interface IFSWin
{
    /// <summary>
    /// Deletes a file that may be locked by another process.
    /// </summary>
    /// <param name="filePath">The path to the file.</param>
    void DeleteFileMaybeLocked(string filePath);

    /// <summary>
    /// Deletes a file or folder that may be locked by another process.
    /// </summary>
    /// <param name="path">The path to the file or folder.</param>
    void DeleteFileOrFolderMaybeLocked(string path);
}