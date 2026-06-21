namespace SunamoRL._public.SunamoInterfaces.Interfaces;

/// <summary>
/// Represents a control that produces a dialog result.
/// </summary>
[ComVisible(true)]
[InterfaceType(ComInterfaceType.InterfaceIsDual)]
public interface IControlWithResult
{
    /// <summary>
    /// Occurs when the dialog result changes.
    /// </summary>
    event Action<bool?> ChangeDialogResult;

    /// <summary>
    /// Sets the dialog result value.
    /// </summary>
    bool? DialogResult { set; }

    /// <summary>
    /// Accepts the input and processes it.
    /// </summary>
    /// <param name="value">The input value to accept.</param>
    void Accept(object value);

    /// <summary>
    /// Sets focus on the main interactive element.
    /// </summary>
    void FocusOnMainElement();
}