namespace SunamoEntity._sunamo.SunamoValues.Constants;

/// <summary>
/// Numeric constants used across the application.
/// </summary>
internal class NumConsts
{
    #region For easy copy
    internal const int MinusOne = -1;
    #endregion
    internal const int DefaultPortIfCannotBeParsed = 587;
    /// <summary>
    /// Min age is 18 due to GDPR - below 18 is needed parent agreement of child
    /// </summary>
    internal const int MinAge = 18;
    internal static short DateTimeMinNumericValue = 10101;
    internal static short DateTimeMaxNumericValue = 32271;
    /// <summary>
    /// One thousand
    /// </summary>
    internal static int OneThousand = 1000;
    internal const long KiloByte = 1024;
    internal const double ZeroDouble = 0;
    internal const float ZeroFloat = 0;
    /// <summary>
    /// Integer value one (no postfix needed for int)
    /// </summary>
    internal const int One = 1;
    internal const int ZeroInt = 0;
}
