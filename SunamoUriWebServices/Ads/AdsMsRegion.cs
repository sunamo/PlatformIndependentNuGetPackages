namespace SunamoUriWebServices.Ads;
/// <summary>
/// For phones, etc. is better repas sites as mp.cz
/// </summary>
public static class AdsMsRegion
{
    public static Type type = typeof(AdsMsRegion);

    public static AdsRegionBase ci = new AdsRegionBase("70800", hyperinzerceCz, bazarCz, sBazarCz, avizoCz);

    public const string hyperinzerceCz = "https://hyperinzerce.cz/inzeraty/Index?query=%s&priceFrom=0&priceTo=99000000&distanceSearch=False&regionIds=HKK";
    public const string bazarCz = "https://www.bazar.cz/ostrava/hledat/%s/?a=25&p=%psc&pid=6934";

    public const string sBazarCz = "https://www.sbazar.cz/hledej/%s/0-vsechny-kategorie/moravskoslezsky";
    public const string avizoCz = "https://www.avizo.cz/fulltext/?beng=1&searchfor=ads&keywords=%s";

    #region Methods
    /// <summary>
    /// 70800 v okoli 25km
    /// </summary>
    /// <param name="what"></param>
    public static string BazosCz(string what)
    {
        return FromChromeReplacement(ci.bazosCz, what);
    }

    public static string FromChromeReplacement(string uri, string term)
    {
        //ThrowEx.NotImplementedMethod();
        return UriWebServices.FromChromeReplacement(uri, term);
    }

    /// <summary>
    /// MS kraj
    /// </summary>
    /// <param name="what"></param>
    public static string HyperInzerceCz(string what)
    {
        return FromChromeReplacement(hyperinzerceCz, what);
    }

    /// <summary>
    /// 70800 +25km
    /// </summary>
    /// <param name="what"></param>
    public static string BazarCz(string what)
    {
        return FromChromeReplacement(bazarCz, what);
    }
    #endregion
}
