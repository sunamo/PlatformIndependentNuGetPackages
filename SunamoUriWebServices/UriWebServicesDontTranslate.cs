namespace SunamoUriWebServices;



public partial class UriWebServices
{
    public static class UriWebServicesDontTranslate
    {
        private static List<string> s_list = null;

        public static void SearchInAll(string spicyName)
        {
            if (s_list == null)
            {
                s_list = new List<string>(new List<string>(["kotanyi", "avok\u00E1do", "nadir", "Orient", "Drago", "v\u00EDtana", "sv\u011Bt bylinek"]));
            }

            foreach (var item in s_list)
            {
                Process.Start(UriWebServices.GoogleSearch($"{item} koření {spicyName}"));
            }
        }
    }

    public static bool IsToOpen(string item)
    {
        return new List<string>([Consts.NA, Consts.na]).Contains(item);
    }
}
