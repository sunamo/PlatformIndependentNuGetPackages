namespace SunamoEntity._sunamo.SunamoArgs;

/// <summary>
/// Base arguments for file retrieval operations.
/// </summary>
internal class GetFilesBaseArgsShared
{
    internal bool FollowJunctions { get; set; } = false;
    internal Func<string, bool> IsJunctionPoint { get; set; } = null!;
    internal bool IsTrimPathAndLeadingBackslashes { get; set; } = false;
}
