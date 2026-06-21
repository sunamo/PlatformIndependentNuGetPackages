namespace SunamoEssential._sunamo.SunamoCompare;

/// <summary>
/// Interface for comparison with both ascending and descending order.
/// </summary>
/// <typeparam name="T">The type to compare.</typeparam>
internal interface ISunamoComparer<T>
{
    /// <summary>
    /// Compares two values in descending order.
    /// </summary>
    /// <param name="first">The first value.</param>
    /// <param name="second">The second value.</param>
    int Desc(T first, T second);

    /// <summary>
    /// Compares two values in ascending order.
    /// </summary>
    /// <param name="first">The first value.</param>
    /// <param name="second">The second value.</param>
    int Asc(T first, T second);
}
