namespace SunamoEntity.Entity;

public partial class SongFromInternet : IEquatable<SongFromInternet>
{
    /// <summary>
    /// Returns a list of alternate artist names extracted from featuring annotations in the remix.
    /// </summary>
    public List<string> AlternateArtists()
    {
        var remixText = Remix();
        remixText = SHReplace.ReplaceAll(remixText, "Ft", "ft", Translate.FromKey(XlfKeys.Feat), "feat");
        remixText = remixText.Trim('.');
        remixText = remixText.Trim();
        var artists = SHSplit.Split(remixText, "&", " and ");
        return artists;
    }

    /// <summary>
    /// Compares two SongFromInternet instances by their similarity score.
    /// Returns 1 if similar (above threshold), 0 otherwise.
    /// </summary>
    /// <param name="first">The first object to compare (must be SongFromInternet).</param>
    /// <param name="second">The second object to compare (must be SongFromInternet).</param>
    public int Compare(object first, object second)
    {
        var firstSong = (SongFromInternet)first;
        var secondSong = (SongFromInternet)second;
        const float min = 0.5f;
        var similarity = secondSong.CalculateSimilarityAll(firstSong, false, min);
        if (min <= similarity)
        {
            return 1;
        }

        return 0;
    }

    /// <summary>
    /// Determines whether this instance equals the specified object.
    /// </summary>
    /// <param name="obj">The object to compare with.</param>
    public override bool Equals(object? obj)
    {
        return Equals((SongFromInternet)obj!);
    }

    /// <summary>
    /// Determines whether this instance equals another SongFromInternet.
    /// </summary>
    /// <param name="other">The other song to compare with.</param>
    public bool Equals(SongFromInternet? other)
    {
        return BTS.IntToBool(Compare(this, other!));
    }

    private readonly StringComparer comparer = StringComparer.OrdinalIgnoreCase;

    /// <summary>
    /// Returns a hash code based on the string representation of this song.
    /// </summary>
    public override int GetHashCode()
    {
        return ToString().GetHashCode();
    }
}
