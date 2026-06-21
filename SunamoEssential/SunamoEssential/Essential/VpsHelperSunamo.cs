namespace SunamoEssential.Essential;

/// <summary>
/// Provides VPS-related helper methods and constants.
/// </summary>
public class VpsHelperSunamo
{
    /// <summary>
    /// Gets a value indicating whether the current machine is the Q environment.
    /// </summary>
    public static bool IsQ
    => Environment.MachineName == "NRJANCIK";

    /// <summary>
    /// The VPS IP address.
    /// </summary>
    public const string Ip = "46.36.38.72";

    /// <summary>
    /// The MyPoda IP address.
    /// </summary>
    public const string IpMyPoda = "85.135.38.18";

    /// <summary>
    /// Returns the full path for a SQL backup file.
    /// </summary>
    /// <param name="text">The database name for the backup file.</param>
    /// <param name="mssqlServerPath">The MSSQL server base path.</param>
    public static string LocationOfSqlBackup(string text, string mssqlServerPath)
    {
        var result = mssqlServerPath += @"Backup\" + text + ".bak";
        return result;
    }

    /// <summary>
    /// Returns the path to the sunamo solution folder.
    /// </summary>
    public static string SunamoSln()
    {
        return BasePathsHelperShared.VisualStudioPath + @"sunamo\";
    }

    /// <summary>
    /// Returns the path to the sunamo.cz solution folder.
    /// </summary>
    public static string SunamoCzSln()
    {
        return BasePathsHelperShared.VisualStudioPath + @"sunamo.cz\";
    }

    /// <summary>
    /// Returns the path to the sunamo project folder.
    /// </summary>
    public static string SunamoProject()
    {
        return Path.Combine(SunamoSln(), "sunamo");
    }
}