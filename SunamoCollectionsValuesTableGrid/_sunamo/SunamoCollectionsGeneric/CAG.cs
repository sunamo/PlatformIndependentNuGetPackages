namespace SunamoCollectionsValuesTableGrid._sunamo.SunamoCollectionsGeneric;
internal class CAG
{
    internal static int MinElementsItemsInnerList<T>(List<List<T>> exists)
    {
        int min = int.MaxValue;

        foreach (var item in exists)
        {
            if (item.Count < min)
            {
                min = item.Count;
            }
        }

        return min;
    }
    internal static int MaxElementsItemsInnerList<T>(List<List<T>> exists)
    {
        int max = 0;

        foreach (var item in exists)
        {
            if (item.Count > max)
            {
                max = item.Count;
            }
        }

        return max;
    }
    internal static int LowestCount<T>(List<List<T>> exists)
    {
        var min = int.MaxValue;

        foreach (var item in exists)
        {
            if (min > item.Count)
            {
                min = item.Count;
            }
        }

        return min;
    }
    internal static List<List<T>> TrimInnersToCount<T>(List<List<T>> exists, int lowest)
    {
        for (int i = 0; i < exists.Count; i++)
        {
            exists[i] = exists[i].Take(lowest).ToList();
        }

        return exists;
    }
}
