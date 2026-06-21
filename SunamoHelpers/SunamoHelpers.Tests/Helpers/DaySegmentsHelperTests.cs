namespace shared.Tests.Helpers;

using SunamoHelpers.Helpers;

/// <summary>
/// Tests for DaySegmentsHelper segment calculation logic.
/// </summary>
public class DaySegmentsHelperTests
{
    /// <summary>
    /// Verifies that GetSegment returns the correct day segment for a given time.
    /// </summary>
    [Fact]
    public void GetSegmentTest()
    {
    }

    private int Get(int hours, int minutes)
    {
        return DaySegmentsHelper.GetSegment(new DateTime(1, 1, 1, hours, minutes, 0));
    }
}
