namespace SunamoEssential.Essential;

/// <summary>
/// Provides shared web application state and configuration.
/// </summary>
public class WebApp
{
    /// <summary>
    /// Gets or sets the current application language.
    /// </summary>
    public static LangsShared Lang { get; set; } = LangsShared.en;

    /// <summary>
    /// Gets or sets the shared resources instance.
    /// </summary>
    public static ResourcesShared Resources { get; set; } = null!;

    /// <summary>
    /// Gets or sets the application name.
    /// </summary>
    public static string Name { get; set; } = null!;

    /// <summary>
    /// Gets a value indicating whether the application has been initialized.
    /// </summary>
    public static bool Initialized { get; } = false;

    /// <summary>
    /// Gets or sets the application namespace.
    /// </summary>
    public static string Namespace { get; set; } = "";

    /// <summary>
    /// Occurs when the application status is set.
    /// </summary>
    public static event Action<TypeOfMessageShared, string>? StatusSetted;

    /// <summary>
    /// Sets the application status with formatted arguments.
    /// </summary>
    /// <param name="messageType">The type of the status message.</param>
    /// <param name="status">The status format string.</param>
    /// <param name="args">The format arguments.</param>
    public static void SetStatus(TypeOfMessageShared messageType, string status, params string[] args)
    {
        StatusSetted?.Invoke(messageType, string.Format(status, args));
    }
}
