namespace SunamoRL._sunamo;

/// <summary>
/// Provides lists of whitespace characters and their codes.
/// </summary>
internal class WhitespaceCharService
{
#pragma warning disable CS0649
    internal List<char>? WhiteSpaceChars;
#pragma warning restore CS0649
    internal readonly List<int> WhiteSpacesCodes = new(new[]
{
9, 10, 11, 12, 13, 32, 133, 160, 5760, 6158, 8192, 8193, 8194, 8195, 8196, 8197, 8198, 8199, 8200, 8201, 8202,
8232, 8233, 8239, 8287, 12288
});
}