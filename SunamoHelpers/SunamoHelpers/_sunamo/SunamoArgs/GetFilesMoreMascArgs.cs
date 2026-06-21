namespace SunamoHelpers._sunamo.SunamoArgs;

/// <summary>
/// Extended arguments for file retrieval with mask and search options.
/// </summary>
internal class GetFilesMoreMascArgs : GetFilesBaseArgsShared
{
    internal bool IsLoadFromFileWhenDebug { get; set; } = false;
    internal string Path { get; set; } = null!;
    internal string Mask { get; set; } = "*";
    internal SearchOption FileSearchOption { get; set; } = SearchOption.TopDirectoryOnly;
    internal bool IsDeleteFromDriveWhenCannotBeResolved { get; set; } = false;
}
