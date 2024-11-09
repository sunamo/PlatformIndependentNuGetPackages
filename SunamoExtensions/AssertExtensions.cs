namespace SunamoExtensions;

public class AssertExtensions /*: TranslateAble - pryč kvůli přerodu k nuget packages*/
{
    public static string xCountInAAndBIsNotEqual = "CountInAAndBIsNotEqual";
    private static Type type = typeof(AssertExtensions);

    public static void EqualTuple<T, U>(List<Tuple<T, U>> a, List<Tuple<T, U>> b)
    {
        if (a.Count != b.Count) throw new Exception(xCountInAAndBIsNotEqual);

        for (var i = 0; i < a.Count; i++)
            if (!EqualityComparer<T>.Default.Equals(a[i].Item1, b[i].Item1) ||
                !EqualityComparer<U>.Default.Equals(a[i].Item2, b[i].Item2))
                throw new Exception("a and b is not equal");
    }
}