namespace SunamoGeo.Value;

/// <summary>
/// Provides a lazily-initialized list of all Czech administrative regions.
/// </summary>
public static class GeoCzechRegions
{
    private static List<GeoCzechRegion>? s_czechRegions;

    private static void Init()
    {
        s_czechRegions = new List<GeoCzechRegion>();
        s_czechRegions.Add(new GeoCzechRegion("A", "Hlavn\u00ED m\u011Bsto Praha", "PHA", Translate.FromKey(XlfKeys.Prague)));
        s_czechRegions.Add(new GeoCzechRegion("S", "St\u0159edo\u010Desk\u00FD", "ST\u010C", Translate.FromKey(XlfKeys.Prague)));
        s_czechRegions.Add(new GeoCzechRegion("C", "Jiho\u010Desk\u00FD", "JH\u010C", "\u010Cesk\u00E9 Bud\u011Bjovice"));
        s_czechRegions.Add(new GeoCzechRegion("P", "Plze\u0148sk\u00FD", "PLK", "Plze\u0148"));
        s_czechRegions.Add(new GeoCzechRegion("K", "Karlovarsk\u00FD", "KVK", Translate.FromKey(XlfKeys.Carlsbad)));
        s_czechRegions.Add(new GeoCzechRegion("U", "\u00DAsteck\u00FD", "ULK", "\u00DAst\u00ED nad Labem"));
        s_czechRegions.Add(new GeoCzechRegion("L", "Libereck\u00FD", "LBK", Translate.FromKey(XlfKeys.Liberec)));
        s_czechRegions.Add(new GeoCzechRegion("H", "Kr\u00E1lov\u00E9hradeck\u00FD", "HKK", "Hradec Kr\u00E1lov\u00E9"));
        s_czechRegions.Add(new GeoCzechRegion("E", "Pardubick\u00FD", "PAK", Translate.FromKey(XlfKeys.Pardubice)));
        s_czechRegions.Add(new GeoCzechRegion("M", "Olomouck\u00FD", "OLK", Translate.FromKey(XlfKeys.Olomouc)));
        s_czechRegions.Add(new GeoCzechRegion("T", "Moravskoslezsk\u00FD", "MSK", Translate.FromKey(XlfKeys.Ostrava)));
        s_czechRegions.Add(new GeoCzechRegion("B", "Jihomoravsk\u00FD", "JHM", Translate.FromKey(XlfKeys.Brno)));
        s_czechRegions.Add(new GeoCzechRegion("Z", "Zl\u00EDnsk\u00FD", "ZLK", "Zl\u00EDn"));
        s_czechRegions.Add(new GeoCzechRegion("J", "Kraj Vyso\u010Dina", "VYS", Translate.FromKey(XlfKeys.Jihlava)));
    }

    /// <summary>
    /// Gets the list of all 14 Czech administrative regions, initializing on first access.
    /// </summary>
    public static List<GeoCzechRegion> CzechRegions
    {
        get
        {
            if (s_czechRegions == null)
            {
                Init();
            }
            return s_czechRegions!;
        }
    }
}