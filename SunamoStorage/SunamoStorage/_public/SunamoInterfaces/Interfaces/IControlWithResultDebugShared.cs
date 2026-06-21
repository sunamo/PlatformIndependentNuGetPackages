namespace SunamoStorage._public.SunamoInterfaces.Interfaces;

/// <summary>
/// Debug extension of IControlWithResult providing handler inspection and attachment.
/// </summary>
[ComVisible(true)]
[InterfaceType(ComInterfaceType.InterfaceIsDual)]
public interface IControlWithResultDebugShared : IControlWithResult
{
    /// <summary>
    /// Returns the count of handlers attached to the ChangeDialogResult event.
    /// </summary>
    int CountOfHandlersChangeDialogResult();

    /// <summary>
    /// Attaches a handler to the ChangeDialogResult event.
    /// </summary>
    /// <param name="handler">The handler to attach.</param>
    /// <param name="isThrowingException">Whether to throw an exception if attachment fails.</param>
    void AttachChangeDialogResult(Action<bool> handler, bool isThrowingException = true);
}