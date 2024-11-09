namespace SunamoExtensions;

public static class ListExtensions
{
    public static void RemoveMany<T>(this IList<T> list, List<T> l)
    {
        foreach (var item in l) list.Remove(item);
    }

    public static void RemoveMany(this IList<string> list, List<string> l)
    {
        foreach (var item in l) list.Remove(item);
    }

    /// <summary>
    ///     Nepoužívat toto na přidávání js, vloží se v špatném pořadí, pak to dělá function is not defined!
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="list"></param>
    /// <param name="item"></param>
    private static List<T> Add2<T>(this IList<T> list, T item)
    {
        list.Add(item);
        return (List<T>)list;
    }

    public static void AddRangeIfNotContain<T>(this IList<T> list, List<T> l)
    {
        foreach (var item in l)
            if (!list.Contains(item))
                list.Add(item);
    }

    /// <summary>
    ///     Direct edit
    /// </summary>
    /// <param name="list"></param>
    /// <param name="items"></param>
    /// <returns></returns>
    public static List<string> LeadingRange(this List<string> list, IList<string> items)
    {
        for (var i = items.Count() - 1; i >= 0; i--) list.Insert(0, items[i]);
        return list;
    }

    public static List<T> Insert<T>(this IList<T> list, int dx, T item)
    {
        list.Insert(dx, item);
        return (List<T>)list;
    }

    #region For easy copy from ListExtensionsSunamo.cs

    /// <summary>
    ///     Must be List due to working with indexes.
    ///     Partitions the given list around a pivot element such that all elements on left of pivot are <= pivot
    ///     and the ones at thr right are > pivot. This method can be used for sorting, N-order statistics such as
    ///     as median finding algorithms.
    ///     Pivot is selected ranodmly if random number generator is supplied else its selected as last element in the list.
    ///     Reference: Introduction to Algorithms 3rd Edition, Corman et al, pp 171
    /// </summary>
    public static int Partition<T>(this IList<T> list, int start, int end, Random rnd = null) where T : IComparable<T>
    {
        if (rnd != null)
            list.Swap(end, rnd.Next(start, end + 1));
        var pivot = list[end];
        var lastLow = start - 1;
        for (var i = start; i < end; i++)
            if (list[i].CompareTo(pivot) <= 0)
                list.Swap(i, ++lastLow);
        list.Swap(end, ++lastLow);
        return lastLow;
    }

    /// <summary>
    ///     Returns Nth smallest element from the list. Here n starts from 0 so that n=0 returns minimum, n=1 returns 2nd
    ///     smallest element etc.
    ///     Note: specified list would be mutated in the process.
    ///     Reference: Introduction to Algorithms 3rd Edition, Corman et al, pp 216
    /// </summary>
    public static T NthOrderStatistic<T>(this IList<T> list, int n, Random rnd = null) where T : IComparable<T>
    {
        return NthOrderStatistic(list, n, 0, list.Count - 1, rnd);
    }

    private static T NthOrderStatistic<T>(this IList<T> list, int n, int start, int end, Random rnd)
        where T : IComparable<T>
    {
        while (true)
        {
            var pivotIndex = list.Partition(start, end, rnd);
            if (pivotIndex == n)
                return list[pivotIndex];
            if (n < pivotIndex)
                end = pivotIndex - 1;
            else
                start = pivotIndex + 1;
        }
    }

    /// <summary>
    ///     Js() With Leading should be always the last in code
    ///     Js() With Add should be first in code
    /// </summary>
    /// <param name="list"></param>
    /// <param name="item"></param>
    public static List<string> Leading(this List<string> list, string item)
    {
        list.Insert(0, item);
        return list;
    }

    public static List<T> AddOrSet<T>(this IList<T> list, int dx, T item)
    {
        if (list.Count > dx)
            list[dx] = item;
        else
            list.Add(item);
        return list.ToList();
    }

    #endregion
}