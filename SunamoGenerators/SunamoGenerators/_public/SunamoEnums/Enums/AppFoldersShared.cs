namespace SunamoGenerators._public.SunamoEnums.Enums;

/// <summary>
/// Specifies well-known application folder categories for organizing application data.
/// </summary>
public enum AppFoldersShared
{
    #region Not backuped
    /// <summary>
    /// Folder for application log files.
    /// </summary>
    Logs,
    /// <summary>
    /// Folder for application output files.
    /// </summary>
    Output,
    /// <summary>
    /// Folder for cached data.
    /// </summary>
    Cache,
    /// <summary>
    /// Folder for temporary files.
    /// </summary>
    Temp,
    #endregion
    #region Backuped
    /// <summary>
    /// Folder for input files.
    /// </summary>
    Input,
    /// <summary>
    /// Folder for application settings.
    /// </summary>
    Settings,
    /// <summary>
    /// Folder for application data files.
    /// </summary>
    Data,
    /// <summary>
    /// Folder for miscellaneous files.
    /// </summary>
    Other,
    /// <summary>
    /// Folder for UI control configurations.
    /// </summary>
    Controls,
    /// <summary>
    /// Folder for local application data.
    /// </summary>
    Local,
    /// <summary>
    /// Folder for roaming application data.
    /// </summary>
    Roaming,
    /// <summary>
    /// Folder for encrypted data files.
    /// </summary>
    Crypted,
    /// <summary>
    /// Folder for generated reports.
    /// </summary>
    Reports,
    /// <summary>
    /// Folder for backup files.
    /// </summary>
    Backup
    #endregion
}