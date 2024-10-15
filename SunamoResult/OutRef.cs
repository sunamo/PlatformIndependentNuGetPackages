namespace SunamoResult;
public class OutRef<T, U>(T t, U u)
{
    public T Item1 { get; set; } = t;
    public U Item2 { get; set; } = u;
}