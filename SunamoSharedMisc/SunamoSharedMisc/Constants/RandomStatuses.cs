namespace SunamoSharedMisc.Constants;

/// <summary>
/// Helper for setting random status messages of various types.
/// </summary>
public class RandomStatuses
{
    /// <summary>
    /// Sets the application status to the specified message type.
    /// </summary>
    /// <param name="type">The type of message to set as status.</param>
    public void SetStatusOfType(TypeOfMessageShared type)
    {
        ThisApp.SetStatus(type, type.ToString());
    }

    /// <summary>
    /// Sets the application status for all message types sequentially.
    /// </summary>
    public void SetAllTypes()
    {
        foreach (var item in EnumHelper.GetValues<TypeOfMessageShared>())
        {
            SetStatusOfType(item);
        }
    }
}
