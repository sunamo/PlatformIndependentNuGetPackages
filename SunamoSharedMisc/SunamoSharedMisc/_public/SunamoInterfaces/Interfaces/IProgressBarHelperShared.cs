namespace SunamoSharedMisc._public.SunamoInterfaces.Interfaces;

/// <summary>
/// Provides progress bar helper functionality for tracking operation progress.
/// </summary>
public interface IProgressBarHelperShared
{
    /// <summary>
    /// Marks the operation as fully completed.
    /// </summary>
    void Done();

    /// <summary>
    /// Marks the operation as partially completed.
    /// </summary>
    void DonePartially();

    /// <summary>
    /// Creates a new progress bar helper instance.
    /// </summary>
    /// <param name="progressBar">The progress bar control to update.</param>
    /// <param name="overall">The total value representing 100% progress.</param>
    /// <param name="dispatcher">The UI dispatcher for thread-safe updates.</param>
    IProgressBarHelperShared CreateInstance(object progressBar, double overall, object dispatcher);
}