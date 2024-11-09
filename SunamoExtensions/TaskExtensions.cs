namespace SunamoExtensions;

public static class TaskExtensions
{
    #region For easy copy from TaskExtensionsSunamo.cs

    public static ConfiguredTaskAwaitable Conf(this Task t)
    {
        return t.ConfigureAwait(true);
    }

    public static ConfiguredTaskAwaitable<T> Conf<T>(this Task<T> t)
    {
        return t.ConfigureAwait(true);
    }

    public static void LogExceptions(this Task task)
    {
        task.ContinueWith(t =>
            {
                var aggException = t.Exception.Flatten();

                StringBuilder sb = new();

                foreach (var exception in aggException.InnerExceptions) throw new Exception("");
                //sb.AppendLine(Exceptions.TextOfExceptions(exception));
                throw new Exception(sb.ToString());
            },
            TaskContinuationOptions.OnlyOnFaulted);
    }

    #endregion
}