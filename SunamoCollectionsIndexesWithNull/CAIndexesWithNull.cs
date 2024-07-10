namespace SunamoCollectionsIndexesWithNull;

public class CAIndexesWithNull
{
    /// <summary>
    /// Dont trim
    /// </summary>
    /// <param name="times"></param>
    public static List<int> IndexesWithNullOrEmpty(IList times)
    {
        List<int> nulled = new List<int>();
        int i = 0;
        foreach (var item in times)
        {
            if (item == null)
            {
                nulled.Add(i);
            }
            else if (item.ToString() == string.Empty)
            {
                nulled.Add(i);
            }
            i++;
        }

        return nulled;
    }

    /// <summary>
    /// For all types
    /// </summary>
    /// <param name="times"></param>
    public static List<int> IndexesWithNull(IList times)
    {
        List<int> nulled = new List<int>();
        int i = 0;
        foreach (var item in times)
        {
            if (item == null)
            {
                nulled.Add(i);
            }
            i++;
        }

        return nulled;
    }


}
