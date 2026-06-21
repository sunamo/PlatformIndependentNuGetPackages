namespace SunamoSharedMisc;

/// <summary>
/// Demo progress bar for testing song download simulation.
/// </summary>
public class ProgressBar
{
    private static readonly int totalSongs = 10;
    /// <summary>
    /// Raised when the next song download begins.
    /// </summary>
    public static event Action? AnotherSong;

    /// <summary>
    /// Raised at the start of the download process with the total number of songs.
    /// </summary>
    public static event Action<int>? OverallSongs;

    /// <summary>
    /// Raised when all song downloads are complete and the progress bar should close.
    /// </summary>
    public static event Action? WriteProgressBarEnd;

    /// <summary>
    /// Simulates downloading all songs with progress tracking.
    /// </summary>
    public static List<int> GetAllSongFromInternet()
    {
        OverallSongs?.Invoke(totalSongs);

        return GetAllSongFromInternet(totalSongs);
    }

    private static List<int> GetAllSongFromInternet(int songCount)
    {
        for (var i = 0; i < songCount; i++)
        {
            AnotherSong?.Invoke();
            Thread.Sleep(100);
        }

        WriteProgressBarEnd?.Invoke();

        return null!;
    }
}
