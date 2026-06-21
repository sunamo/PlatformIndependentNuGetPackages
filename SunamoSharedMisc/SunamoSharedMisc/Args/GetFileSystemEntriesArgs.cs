namespace SunamoSharedMisc.Args;

/// <summary>
/// Arguments for getting file system entries with progress tracking.
/// </summary>
public class GetFileSystemEntriesArgs
{
    /// <summary>
    /// The progress bar helper for tracking progress.
    /// </summary>
    public IProgressBarHelperShared? ProgressBarHelper { get; set; } = null;

    /// <summary>
    /// The progress bar instance.
    /// </summary>
    public ProgressBar? ProgressBarInstance { get; set; } = null;
}
