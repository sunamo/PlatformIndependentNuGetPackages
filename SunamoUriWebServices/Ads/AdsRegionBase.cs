namespace SunamoUriWebServices.Ads;
public class AdsRegionBase
{
    /// <summary>
    /// 3. největší
    /// </summary>
    public string bazosCz = null;
    public string aukroCz = null;
    /// <summary>
    /// 1. největší
    /// </summary>
    public string hyperinzerceCz = null;
    public string bazarCz = null;
    /// <summary>
    /// 2. největší
    /// </summary>
    public string sBazarCz = null;
    public string avizoCz = null;

    public AdsRegionBase(string psc, string hyperinzerceCz, string bazarCz, string sBazarCz, string avizoCz)
    {
        bazosCz = AdsByPsc.bazosCz.Replace("%psc", "50002");
        aukroCz = AdsByPsc.aukroCz.Replace("%psc", "50002");

        All = new List<string> { hyperinzerceCz,
bazarCz, sBazarCz, avizoCz, bazosCz, aukroCz };

        this.hyperinzerceCz = hyperinzerceCz;
        this.bazarCz = bazarCz;
        this.sBazarCz = sBazarCz;
        this.avizoCz = avizoCz;
    }

    public List<string> All = null;

    public void SearchInAll(string what)
    {
        UriWebServices.SearchInAll(All, what);
    }
}
