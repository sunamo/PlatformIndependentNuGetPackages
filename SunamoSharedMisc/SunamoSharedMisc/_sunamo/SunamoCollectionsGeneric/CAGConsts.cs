namespace SunamoSharedMisc._sunamo.SunamoCollectionsGeneric;

/// <summary>
/// Generic collection constants and utilities.
/// Must be here because SunamoValues cannot inherit from SunamoCollectionGeneric (cycle detected).
/// </summary>
internal class CAGConsts
{
    /// <summary>
    /// Converts a params array to a list.
    /// </summary>
    /// <typeparam name="T">The element type.</typeparam>
    /// <param name="values">The values to convert to a list.</param>
    internal static List<T> ToList<T>(params T[] values)
    {
        return values.ToList();
    }
}
