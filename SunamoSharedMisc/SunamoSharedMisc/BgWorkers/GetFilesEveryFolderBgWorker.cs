namespace SunamoSharedMisc.BgWorkers;

/// <summary>
/// Background worker for retrieving files from every subfolder.
/// </summary>
public class GetFilesEveryFolderBgWorker
{
    private BackgroundWorker? backgroundWorker = null;
    /// <summary>
    /// Occurs when the background file retrieval operation has completed.
    /// </summary>
    public event RunWorkerCompletedEventHandler? RunWorkerCompleted;

    /// <summary>
    /// Initializes a new instance of the <see cref="GetFilesEveryFolderBgWorker"/> class and sets up the background worker.
    /// </summary>
    public GetFilesEveryFolderBgWorker()
    {
        backgroundWorker = new BackgroundWorker();
        backgroundWorker.DoWork += BackgroundWorker_DoWork;
        backgroundWorker.RunWorkerCompleted += BackgroundWorker_RunWorkerCompleted;
    }

    private void BackgroundWorker_RunWorkerCompleted(object? sender, RunWorkerCompletedEventArgs eventArgs)
    {
        RunWorkerCompleted?.Invoke(sender, eventArgs);
    }

    /// <summary>
    /// The result list of file paths.
    /// </summary>
    public List<string>? Result { get; set; } = null;

    private void BackgroundWorker_DoWork(object? sender, DoWorkEventArgs eventArgs)
    {
    }
}
