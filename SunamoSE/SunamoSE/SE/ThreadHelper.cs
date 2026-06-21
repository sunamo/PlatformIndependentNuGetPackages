namespace SunamoSE.SE;

/// <summary>
/// Helper for thread-related operations including dispatcher checks and async sleep.
/// </summary>
public class ThreadHelper
{
    /// <summary>
    /// Determines whether the given type name requires a UI dispatcher for access.
    /// </summary>
    /// <param name="typeName">The name of the collection type to check.</param>
    public static bool NeedDispatcher(string typeName)
    {
        return typeName == "UIElementCollection";
    }

    /// <summary>
    /// Pauses execution for the specified number of milliseconds.
    /// Uses Task.Delay in async mode, Thread.Sleep otherwise.
    /// </summary>
    /// <param name="milliseconds">The number of milliseconds to sleep.</param>
    public static
#if ASYNC
    async Task
#else
    void
#endif
 Sleep(int milliseconds)
    {
#if ASYNC
        await Task.Delay(milliseconds);
#else
        Thread.Sleep(milliseconds);
#endif
    }
}
