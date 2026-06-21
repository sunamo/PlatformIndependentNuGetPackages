namespace sunamo.Tests.Storage;

/// <summary>
/// Tests for parsing application data from structured text files.
/// </summary>
public class ApplicationDataTextTests
{
    /// <summary>
    /// Verifies that Parse correctly reads headers and values from a structured text file.
    /// </summary>
    public
#if ASYNC
async Task
#else
void
#endif
ParseTest()
    {
        string testFile = @"D:\_Test\ConsoleApp1\ConsoleApp1\ApplicationDataText.txt";

        var headers = CA.ToListString("Copy", "Dont copy to");
        CA.AddSuffix(headers, ":");

        var expectedValues = CA.ToListString("Shared");

        var dict =
#if ASYNC
await
#endif
ApplicationDataText.Parse(testFile, headers);
        Assert.Equal<string>(expectedValues, dict[headers[0]]);
    }
}
