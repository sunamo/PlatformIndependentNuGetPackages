namespace SunamoEssential._sunamo.SunamoArgs;

/// <summary>
/// Arguments for PowerShell invocation.
/// </summary>
internal class PsInvokeArgs
{
    internal static readonly PsInvokeArgs Def = new PsInvokeArgs();
    internal bool IsWritingProgressBar { get; set; } = false;

    /// <summary>
    /// Earlier was false.
    /// </summary>
    internal bool IsImmediatelyToStatus { get; set; } = false;
    internal List<string> AddBeforeEveryCommand { get; set; } = null!;

    /// <summary>
    /// If the file exists, performs load to speed up execution.
    /// If it does not exist, executes commands and saves.
    /// Does not work with last modification date.
    /// </summary>
    internal string PathToSaveLoadPsOutput { get; set; } = null!;
}
