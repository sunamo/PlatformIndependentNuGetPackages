namespace SunamoThreading;
public class ThreadPoolEvent
{
    int n = 0;
    int finished = 0;
    public event Action Done;

    public ThreadPoolEvent(int n)
    {
        this.n = n;
    }

    public void PartiallyDone()
    {
        finished++;
        if (finished == n)
        {
            Done();
        }
    }
}
