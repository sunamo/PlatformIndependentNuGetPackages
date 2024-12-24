namespace SunamoThreading;

public class ThreadPoolWithoutWaiting
{
    object o = new object();

    List<Thread> threads = new List<Thread>();

    public ThreadPoolWithoutWaiting(int size, ParameterizedThreadStart start, params string[] args)
    {
        foreach (var item in args)
        {
            Thread thread = new Thread(start);

        }
    }
}
