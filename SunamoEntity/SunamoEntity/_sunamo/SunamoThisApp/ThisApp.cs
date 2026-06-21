namespace SunamoEntity._sunamo.SunamoThisApp;

/// <summary>
/// Provides shared application-level settings and status management.
/// </summary>
internal class ThisApp
{
    internal static string EventLogName { get; set; } = null!;
    internal static string Name { get; set; } = null!;
    internal static LangsShared Lang { get; set; }




    internal static void SetStatus(TypeOfMessageShared st, string status, params string[] args)
    {
        var format = /*string.Format*/ string.Format(status, args);
        if (format.Trim() != string.Empty)
        {
            if (StatusSetted == null)
            {
                // For unit tests
                //////////DebugLogger.Instance.WriteLine(st + ": " + format);
            }
            else
            {
                StatusSetted(st, format);
            }
        }
    }

    internal static event Action<TypeOfMessageShared, string>? StatusSetted;
}