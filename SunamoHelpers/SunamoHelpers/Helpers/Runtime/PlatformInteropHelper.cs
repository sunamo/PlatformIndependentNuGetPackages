namespace SunamoHelpers.Helpers.Runtime;

/// <summary>
/// Provides helper methods for detecting the current platform and runtime environment.
/// </summary>
public class PlatformInteropHelper
{
    /// <summary>
    /// Checks whether the application is a selling app.
    /// </summary>
    public static bool IsSellingApp()
    {
        return false;
    }

    private static bool? isUwp = null;

    /// <summary>
    /// Determines whether the application is running as a UWP Windows Store app.
    /// </summary>
    public static bool IsUwpWindowsStoreApp()
    {
        if (isUwp.HasValue)
        {
            return isUwp.Value;
        }

        var assemblies = AppDomain.CurrentDomain.GetAssemblies();
        foreach (var item in assemblies)
        {
            Type[]? types = null;
            try
            {
                types = item.GetTypes();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.GetType().Name + ": " + ex.Message);
                ThrowEx.Custom(ex);
            }

            if (types != null)
            {
                foreach (var currentType in types)
                {
                    if (currentType.Namespace != null)
                    {
                        if (currentType.Namespace.StartsWith("Windows.UI"))
                        {
                            isUwp = true;
                            break;
                        }
                    }
                }

                if (isUwp.HasValue)
                {
                    break;
                }
            }
        }

        if (!isUwp.HasValue)
        {
            isUwp = false;
        }

        return isUwp.Value;
    }

    /// <summary>
    /// Gets the type of the resources class. Currently not implemented.
    /// </summary>
    public static Type GetTypeOfResources()
    {
        throw new Exception();
    }

    /// <summary>
    /// Determines whether the application uses a .NET Standard/Core project.
    /// </summary>
    public static bool IsUseStandardProject()
    {
        var result = RuntimeInformation.FrameworkDescription;
        if (result.StartsWith(RuntimeFrameworks.NetCore))
        {
            return true;
        }

        return false;
    }
}
