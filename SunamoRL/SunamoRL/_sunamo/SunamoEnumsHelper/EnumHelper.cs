namespace SunamoRL._sunamo.SunamoEnumsHelper;

/// <summary>
/// Helper methods for working with enum values.
/// </summary>
internal class EnumHelper
{
    /// <summary>
    /// Gets all enum values except Nope/None.
    /// </summary>
    /// <typeparam name="T">The enum type.</typeparam>
    internal static List<T> GetValues<T>()
       where T : struct
    {
        return GetValues<T>(false, true);
    }

    /// <summary>
    /// Gets enum values with options to include or exclude Nope and Shared values.
    /// </summary>
    /// <typeparam name="T">The enum type.</typeparam>
    /// <param name="isIncludingNope">Whether to include the Nope value.</param>
    /// <param name="isIncludingShared">Whether to include the Shared value.</param>
    internal static List<T> GetValues<T>(bool isIncludingNope, bool isIncludingShared)
        where T : struct
    {
        var type = typeof(T);
        var values = Enum.GetValues(type).Cast<T>().ToList();
        T nope;
        if (!isIncludingNope)
        {
            if (Enum.TryParse<T>(CodeElementsConstants.NopeValue, out nope))
            {
                values.Remove(nope);
            }
        }

        if (!isIncludingShared)
        {
            if (type.Name == "MySites")
            {
                if (Enum.TryParse<T>("Shared", out nope))
                {
                    values.Remove(nope);
                }
            }
            else
            {
                if (Enum.TryParse<T>("Sha", out nope))
                {
                    values.Remove(nope);
                }
            }
        }

        if (Enum.TryParse<T>(CodeElementsConstants.NoneValue, out nope))
        {
            values.Remove(nope);
        }

        return values;
    }
}
