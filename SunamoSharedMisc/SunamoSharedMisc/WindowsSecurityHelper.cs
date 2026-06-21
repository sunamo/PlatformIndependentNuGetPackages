namespace SunamoSharedMisc;

/// <summary>
/// Helper for checking Windows security roles.
/// </summary>
[System.Runtime.Versioning.SupportedOSPlatform("windows")]
public class WindowsSecurityHelper
{
    /// <summary>
    /// Determines whether the current user has administrator privileges.
    /// </summary>
    public static bool IsUserAdministrator()
    {
        bool isAdmin;
        try
        {
            var user = WindowsIdentity.GetCurrent();
            var principal = new WindowsPrincipal(user);
            isAdmin = principal.IsInRole(WindowsBuiltInRole.Administrator);
        }
        catch (UnauthorizedAccessException)
        {
            isAdmin = false;
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            isAdmin = false;
        }

        return isAdmin;
    }
}
