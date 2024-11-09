namespace SunamoExtensions;

public static class TimeSpanExtensions
{
    public static string ToNiceString(this TimeSpan timeSpan)
    {
        var ret = timeSpan.ToString();
        var secondPostfix = ":00";
        if (ret.EndsWith(secondPostfix)) ret = ret.Substring(0, ret.Length - secondPostfix.Length);
        return ret;
    }

    #region For easy copy from TimeSpanExtensionsSunamo.cs

    public static int TotalYears(this TimeSpan timespan)
    {
        return (int)(timespan.Days / 365.2425);
    }

    public static int TotalMonths(this TimeSpan timespan)
    {
        return (int)(timespan.Days / 30.436875);
    }

    #endregion
}