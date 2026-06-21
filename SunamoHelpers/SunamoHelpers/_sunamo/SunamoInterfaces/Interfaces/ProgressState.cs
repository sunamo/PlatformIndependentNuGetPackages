namespace SunamoHelpers._sunamo.SunamoInterfaces.Interfaces;

/// <summary>
/// Tracks progress state for song processing operations.
/// </summary>
internal class ProgressState
{
    internal bool IsRegistered { get; set; } = false;
    internal int CurrentIndex { get; set; } = 0;
}
