namespace SunamoGeo.Value;

/// <summary>
/// Represents a Czech administrative region with its abbreviations and main city.
/// </summary>
public class GeoCzechRegion
{
    /// <summary>
    /// Creates a new Czech region instance.
    /// </summary>
    /// <param name="shortcutRZ">The vehicle registration plate abbreviation.</param>
    /// <param name="name">The full name of the region.</param>
    /// <param name="shortcutCSU">The Czech Statistical Office abbreviation.</param>
    /// <param name="mainCity">The main city (capital) of the region.</param>
    public GeoCzechRegion(string shortcutRZ, string name, string shortcutCSU, string mainCity)
    {
        ShortcutRZ = shortcutRZ;
        ShortcutCSU = shortcutCSU;
        Name = name;
        MainCity = mainCity;
    }

    /// <summary>
    /// The vehicle registration plate abbreviation for the region.
    /// </summary>
    public string ShortcutRZ { get; set; }

    /// <summary>
    /// The Czech Statistical Office (CSU) abbreviation for the region.
    /// </summary>
    public string ShortcutCSU { get; set; }

    /// <summary>
    /// The full name of the region.
    /// </summary>
    public string Name { get; set; }

    /// <summary>
    /// The main city (capital) of the region.
    /// </summary>
    public string MainCity { get; set; }
}