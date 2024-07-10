namespace SunamoUriWebServices.Ads;

public class AdsHkRegion
{
    public static AdsRegionBase ci = new AdsRegionBase("50002", hyperinzerceCz, bazarCz, sBazarCz, avizoCz);

    public const string hyperinzerceCz = "https://hyperinzerce.cz/inzeraty/Index?query=%s&priceFrom=0&priceTo=99000000&distanceSearch=False&regionIds=HKK";
    public const string bazarCz = "https://www.bazar.cz/hradec-kralove/hledat/%s/?a=25";
    public const string sBazarCz = "https://www.sbazar.cz/hledej/%s/0-vsechny-kategorie/kralovehradecky";
    public const string avizoCz = "https://www.avizo.cz/inzerce/%s/?lokalita%5B%5D=0012";
}
