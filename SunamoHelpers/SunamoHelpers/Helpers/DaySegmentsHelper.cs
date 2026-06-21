namespace SunamoHelpers.Helpers;

/// <summary>
/// Divides a day into 288 five-minute segments and provides methods to determine the current segment.
/// </summary>
public class DaySegmentsHelper
{
    private const int SecondsInOneSegment = 300;
    private const int CountOfSegments = 288;
    private static readonly DateTime MinDateTime = new DateTime(1, 1, 1, 0, 0, 0, 0);

    /// <summary>
    /// Gets the current time segment of the day based on the current time.
    /// </summary>
    public static int GetSegment()
    {
        var dateTime = DateTime.Now;
        return GetSegment(dateTime);
    }

    /// <summary>
    /// Gets the time segment of the day for the specified date and time.
    /// </summary>
    /// <param name="dateTime">The date and time to calculate the segment for.</param>
    public static int GetSegment(DateTime dateTime)
    {
        var timeOnly = new DateTime(1, 1, 1, dateTime.Hour, dateTime.Minute, dateTime.Second);

        var totalSeconds = (timeOnly - MinDateTime).TotalSeconds;
        var segmentIndex = totalSeconds / SecondsInOneSegment;
        return (int)segmentIndex;
    }
}
