namespace SunamoEssential.Essential;

/// <summary>
/// Provides shared algorithmic utility methods.
/// </summary>
public class SharedAlgorithms
{
    /// <summary>
    /// Gets or sets the last HTTP error code encountered, or -1 if none.
    /// </summary>
    public static int LastError { get; set; } = -1;

    /// <summary>
    /// Repeats the specified operation up to the given number of times with a timeout between attempts.
    /// </summary>
    /// <typeparam name="TResult">The return type of the operation.</typeparam>
    /// <param name="times">The maximum number of retry attempts.</param>
    /// <param name="timeoutMs">The timeout in milliseconds between retries.</param>
    /// <param name="operation">The operation to execute.</param>
    public static TResult RepeatAfterTimeXTimes<TResult>(int times, int timeoutMs, Func<TResult> operation)
    {
        LastError = -1;
        TResult? result = default;
        bool isSuccessful = false;
        for (int i = 0; i < times; i++)
        {
            try
            {
                result = operation();
                isSuccessful = true;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                var message = ex.Message;
                if (message.StartsWith("The remote server returned an error: "))
                {
                    var parts = SHSplit.Split(SHReplace.ReplaceOnce(message, "The remote server returned an error: ", string.Empty), " ");
                    var errorCode = parts[0].TrimEnd(')').TrimStart('(');
                    LastError = int.Parse(errorCode);
                }
                if (LastError == 404)
                {
                    return result!;
                }
                Thread.Sleep(timeoutMs);
            }
            if (isSuccessful)
            {
                break;
            }
        }
        return result!;
    }
}
