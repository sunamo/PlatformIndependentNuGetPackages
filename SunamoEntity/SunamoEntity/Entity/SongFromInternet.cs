namespace SunamoEntity.Entity;

/// <summary>
/// Represents a song parsed from the internet, with artist, title, and remix information.
/// Supports similarity comparison between songs.
/// </summary>
public partial class SongFromInternet : IEquatable<SongFromInternet>
{
    private List<string> artistWords = new List<string>();
    private List<string> titleWords = new List<string>();
    private List<string> remixWords = new List<string>();
    private List<string> artistWordsWithoutDiacritic = new List<string>();
    private List<string> titleWordsWithoutDiacritic = new List<string>();
    private List<string> remixWordsWithoutDiacritic = new List<string>();

    /// <summary>
    /// Gets or sets the YouTube video code associated with this song.
    /// </summary>
    public string? YtCode { get; set; } = null;

    /// <summary>
    /// Gets or sets the database ID for this song.
    /// </summary>
    public int IdInDb { get; set; } = int.MaxValue;

    private string? artistConvention = null;
    private string? titleConvention = null;
    private string? remixConvention = null;

    /// <summary>
    /// Gets or sets the artist name in convention format.
    /// </summary>
    public string ArtistC
    {
        get
        {
            return artistConvention!;
        }

        set
        {
            artistConvention = value;
        }
    }

    /// <summary>
    /// Gets or sets the title in convention format.
    /// </summary>
    public string TitleC
    {
        get
        {
            return titleConvention!;
        }

        set
        {
            titleConvention = value;
        }
    }

    /// <summary>
    /// Gets or sets the remix info in convention format.
    /// </summary>
    public string RemixC
    {
        get
        {
            return remixConvention!;
        }

        set
        {
            remixConvention = value;
        }
    }

    /// <summary>
    /// Sets the artist name by splitting and normalizing the given text.
    /// </summary>
    /// <param name="text">The artist name text to parse.</param>
    public void SetArtist(string text)
    {
        artistWords.Clear();
        artistWordsWithoutDiacritic.Clear();
        artistWords.AddRange(SplitArtistTitle(text));
        artistWordsWithoutDiacritic = CA.WithoutDiacritic(artistWords);
        artistConvention = ArtistInConvention();
    }

    /// <summary>
    /// Initializes a new empty instance of the <see cref="SongFromInternet"/> class.
    /// </summary>
    public SongFromInternet()
    {
    }

    /// <summary>
    /// Initializes a new instance by parsing a song string into artist, title, and remix.
    /// </summary>
    /// <param name="song">The formatted song string to parse.</param>
    /// <param name="ytCode">Optional YouTube video code.</param>
    public SongFromInternet(string song, string? ytCode = null)
    {
        string artist, title, remix;
        ManageArtistDashTitle.GetArtistTitleRemix(song, out artist, out title, out remix);
        Init(artist, title, remix);
        this.YtCode = ytCode;
    }

    /// <summary>
    /// Initializes a new instance by copying data from another SongFromInternet instance.
    /// </summary>
    /// <param name="other">The source instance to copy from.</param>
    public SongFromInternet(SongFromInternet other)
    {
        artistWords = new List<string>(other.artistWords);
        titleWords = new List<string>(other.titleWords);
        remixWords = new List<string>(other.remixWords);
        SetInConvention();
    }

    /// <summary>
    /// Initializes the song data from a tuple of artist, title, and remix strings.
    /// </summary>
    /// <param name="tuple">A tuple containing artist, title, and remix.</param>
    public SongFromInternet Init(Tuple<string, string, string> tuple)
    {
        return Init(tuple.Item1, tuple.Item2, tuple.Item3);
    }

    /// <summary>
    /// Initializes the song data from separate artist, title, and remix strings.
    /// </summary>
    /// <param name="artist">The artist name.</param>
    /// <param name="title">The song title.</param>
    /// <param name="remix">The remix information.</param>
    public SongFromInternet Init(string artist, string title, string remix)
    {
        SetArtist(artist);
        var splittedTitle = SplitArtistTitle(title);
        var splittedRemix = SplitRemix(remix);
        titleWords.AddRange(splittedTitle);
        remixWords.AddRange(splittedRemix);
        titleWordsWithoutDiacritic = CA.WithoutDiacritic(new List<string>(titleWords));
        remixWordsWithoutDiacritic = CA.WithoutDiacritic(new List<string>(remixWords));
        SetInConvention();
        return this;
    }

    /// <summary>
    /// Determines whether a title array is similar to a given name.
    /// All strings in both collections must be lowercase for correct comparison.
    /// </summary>
    /// <param name="titleArray">The title words array to compare.</param>
    /// <param name="name">The name to compare against.</param>
    public static bool IsSimilar(string[] titleArray, string name)
    {
        return IsSimilar(new List<string>(titleArray), name);
    }

    /// <summary>
    /// Determines whether a title word list is similar to a given name.
    /// All strings in both collections must be lowercase for correct comparison.
    /// </summary>
    /// <param name="titleArray">The title words to compare.</param>
    /// <param name="name">The name to compare against.</param>
    public static bool IsSimilar(List<string> titleArray, string name)
    {
        int sameCount, differentCount;
        var nameArray = SHSplit.Split(name, " ", ",", "-", "&", ".", ";", "(", ")", "[", "]");
        SongFromInternet.CountSameAndDifferent(titleArray, nameArray, out sameCount, out differentCount);
        if (CalculateSimilarity(sameCount, differentCount, titleArray, new List<string>(nameArray)) > 0.49f)
        {
            return true;
        }

        return false;
    }

    private void SetInConvention()
    {
        artistConvention = ArtistInConvention();
        titleConvention = TitleInConvention();
        remixConvention = RemixInConvention();
    }

    /// <summary>
    /// Returns the remix content without featuring annotations.
    /// </summary>
    public string RemixOnlyContent()
    {
        var result = Remix();
        result = CA.ReplaceAll(result, AllLists.FeatLower, string.Empty);
        result = CA.ReplaceAll(result, AllLists.FeatUpper, string.Empty);
        return result;
    }

    /// <summary>
    /// Calculates the similarity score between this song and a song parsed from the given text.
    /// Comparison is diacritic-sensitive.
    /// </summary>
    /// <param name="text">The song text to compare against.</param>
    public float CalculateSimilarity(string text)
    {
        SongFromInternet other = new SongFromInternet(text);
        return CalculateSimilarity(other, false);
    }

    /// <summary>
    /// Calculates the similarity score between this song and another SongFromInternet instance.
    /// </summary>
    /// <param name="other">The other song to compare against.</param>
    /// <param name="isWithoutDiacritic">If true, comparison ignores diacritics.</param>
    public float CalculateSimilarity(SongFromInternet other, bool isWithoutDiacritic)
    {
        float artistSimilarity, titleSimilarity, remixSimilarity;
        if (isWithoutDiacritic)
        {
            int sameArtist, diffArtist, sameTitle, diffTitle, sameRemix, diffRemix;
            CountSameAndDifferent(other.artistWordsWithoutDiacritic, artistWordsWithoutDiacritic, out sameArtist, out diffArtist);
            CountSameAndDifferent(other.titleWordsWithoutDiacritic, titleWordsWithoutDiacritic, out sameTitle, out diffTitle);
            CountSameAndDifferent(other.remixWordsWithoutDiacritic, remixWordsWithoutDiacritic, out sameRemix, out diffRemix);
            artistSimilarity = CalculateSimilarity(sameArtist, diffArtist, other.artistWords, artistWordsWithoutDiacritic);
            titleSimilarity = CalculateSimilarity(sameTitle, diffTitle, other.titleWords, titleWordsWithoutDiacritic);
            remixSimilarity = CalculateSimilarity(sameRemix, diffRemix, other.remixWords, remixWordsWithoutDiacritic);
        }
        else
        {
            int sameArtist, diffArtist, sameTitle, diffTitle, sameRemix, diffRemix;
            CountSameAndDifferent(other.artistWords, artistWords, out sameArtist, out diffArtist);
            CountSameAndDifferent(other.titleWords, titleWords, out sameTitle, out diffTitle);
            CountSameAndDifferent(other.remixWords, remixWords, out sameRemix, out diffRemix);
            artistSimilarity = CalculateSimilarity(sameArtist, diffArtist, other.artistWords, artistWords);
            titleSimilarity = CalculateSimilarity(sameTitle, diffTitle, other.titleWords, titleWords);
            remixSimilarity = CalculateSimilarity(sameRemix, diffRemix, other.remixWords, remixWords);
        }

        float result = (artistSimilarity + titleSimilarity) / 2;
        if (result == 1)
        {
            result = (artistSimilarity + titleSimilarity + remixSimilarity) / 3;
        }

        return result;
    }
}
