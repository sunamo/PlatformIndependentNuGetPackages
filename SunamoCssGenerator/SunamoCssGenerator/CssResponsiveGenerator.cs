public class CssResponsiveGenerator : CssGenerator
{
    public override string ToString()
    {
        return base.ToString();
    }

    #region From https://en.wikipedia.org/wiki/List_of_common_resolutions
    public const int _768 = 768;
    public const int _1024 = 1024;
    public const int _1280 = 1280;
    public const int _1366 = 1366;
    public const int _1440 = 1440;
    public const int _1536 = 1536;
    public const int _1600 = 1600;
    public const int _1792 = 1792;
    public const int _1920 = 1920;
    public const int _2048 = 2048;

    public const int _2160 = 2160;
    public const int _2280 = 2280;
    public const int _2304 = 2304;
    public const int _2436 = 2436;
    public const int _2560 = 2560;
    public const int _2732 = 2732;
    public const int _2880 = 2880;
    public const int _2960 = 2960;
    public const int _3200 = 3200;
    public const int _3440 = 3440;
    public const int _3840 = 3840;
    public const int _4096 = 4096;
    public const int _4480 = 4480;
    public const int _5120 = 5120;
    public const int _6016 = 6016;
    public const int _6040 = 6040;
    public const int _7680 = 7680;
    public const int _8192 = 8192;
    public const int _10240 = 10240;
    public const int _15360 = 15360;
    public const int _20000 = 20000; 
    #endregion



    public static List<int> sizes = new List<int>(new int[]{ _768,
_1024,
_1280,
_1366,
_1440,
_1536,
_1600,
_1920,
_2160 ,
_2280 ,
_2304 ,
_2436 ,
_2560 ,
_2732 ,
_2880 ,
_2960 ,
_3200 ,
_3440 ,
_3840 ,
_4096 ,
_4480 ,
_5120 ,
_6016 ,
_6040 ,
_7680 ,
_8192 ,
_10240 ,
_15360 ,
_20000 
    });


    /// <summary>
    /// In value is in every element name of element and their width when is max-width key in outer dict
    /// </summary>
    /// <param name="id"></param>
    public void Generate(Dictionary<int, Dictionary<string, int>> id)
    {
        foreach (var item3 in sizes.Skip(2))
        {
            AddMediaMinMaxWidth(0, item3, GetMinFromMax);
            foreach (var item2 in id[item3])
            {
                AddId(1, item2.Key, CssProps.Width(item2.Value + AllStrings.px));
            }
            End(0);
        }
    }

    private int GetMinFromMax(int maxWidth)
    {
        var dx = sizes.IndexOf(maxWidth);
        return sizes[dx - 1] + 1;
    }
}
