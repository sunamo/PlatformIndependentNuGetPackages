namespace SunamoEntity.Entity;

public partial class SongFromInternet : IEquatable<SongFromInternet>
{
    /// <summary>
    /// Calculates similarity score based on same/different word counts and two word lists.
    /// Returns a value between 0 and 1 where 1 means identical.
    /// </summary>
    /// <param name="sameCount">The count of matching words.</param>
    /// <param name="differentCount">The count of non-matching words (sum from both collections).</param>
    /// <param name="newWords">The new word list to compare.</param>
    /// <param name="originalWords">The original word list to compare against.</param>
    public static float CalculateSimilarity(int sameCount, int differentCount, List<string> newWords, List<string> originalWords)
    {
        if (sameCount == differentCount && sameCount == 0)
        {
            return 1.0f;
        }

        if (sameCount > differentCount)
        {
            if (differentCount == 0)
            {
                int matchCount = 0;
                for (int i = 0; i < newWords.Count; i++)
                {
                    if (originalWords.Contains(newWords[i]))
                    {
                        matchCount++;
                    }
                }

                if (matchCount == newWords.Count)
                {
                    return 1.0f;
                }

                return 1f / 3f * 2f;
            }

            if (differentCount != 0)
            {
                if (differentCount != 1)
                {
                    return sameCount / differentCount;
                }

                if (sameCount > 3)
                {
                    float similarity = (sameCount - differentCount) / 2f;
                    while (similarity > 1f)
                    {
                        similarity /= 2f;
                    }

                    return similarity;
                }
                else
                {
                    float similarity = (sameCount - sameCount / (sameCount - 1f)) / 2;
                    int matchCount = 0;
                    for (int i = 0; i < newWords.Count; i++)
                    {
                        if (originalWords.Contains(newWords[i]))
                        {
                            matchCount++;
                        }
                    }

                    if (matchCount > 0)
                    {
                        similarity = matchCount / (float)differentCount / 2f;
                    }

                    if (similarity > 0.99f)
                    {
                        similarity = similarity / 2f;
                    }

                    return similarity;
                }
            }

            return 0f;
        }

        if (sameCount + 1 > differentCount && sameCount < 3)
        {
            return 0.5f;
        }

        return 0f;
    }

    /// <summary>
    /// Calculates overall similarity considering alternate artists from featuring annotations.
    /// </summary>
    /// <param name="other">The other song to compare against.</param>
    /// <param name="isWithoutDiacritic">Whether to compare without diacritics.</param>
    /// <param name="minimal">The minimum similarity threshold to stop searching.</param>
    public float CalculateSimilarityAll(SongFromInternet other, bool isWithoutDiacritic, float minimal)
    {
        var result = CalculateSimilarity(other, isWithoutDiacritic);
        float alternateResult = 0;
        bool shouldContinue = true;
        if (minimal <= result)
        {
            shouldContinue = false;
        }

        List<string>? feats = null;
        if (shouldContinue)
        {
            var song = other.TitleC;
            feats = other.AlternateArtists();
            foreach (var item in feats)
            {
                other = new SongFromInternet(item + "-" + song);
                alternateResult = CalculateSimilarity(other, true);
                if (IsBreakInCalculateSimilarity)
                {
                    System.Diagnostics.Debugger.Break();
                }

                if (alternateResult > result)
                {
                    result = alternateResult;
                }

                if (minimal <= result)
                {
                    break;
                }
            }
        }

        if (IsBreakInCalculateSimilarity)
        {
            System.Diagnostics.Debugger.Break();
        }

        return result;
    }

    /// <summary>
    /// Gets or sets whether to break in debugger during similarity calculation (for debugging purposes).
    /// </summary>
    public static bool IsBreakInCalculateSimilarity { get; set; } = false;

    /// <summary>
    /// Returns the artist name as a space-joined string of artist words.
    /// </summary>
    public string Artist()
    {
        return string.Join(" ", artistWords);
    }

    /// <summary>
    /// Returns the artist name formatted in convention (each word capitalized).
    /// </summary>
    public string ArtistInConvention()
    {
        return ConvertEveryWordLargeCharConvention.ToConvention(Artist());
    }

    /// <summary>
    /// Returns the title as a space-joined string of title words.
    /// </summary>
    public string Title()
    {
        return string.Join(" ", titleWords);
    }

    /// <summary>
    /// Returns the title formatted in convention (each word capitalized).
    /// </summary>
    public string TitleInConvention()
    {
        return ConvertEveryWordLargeCharConvention.ToConvention(Title());
    }

    /// <summary>
    /// Returns the remix as a space-joined string of remix words.
    /// </summary>
    public string Remix()
    {
        return string.Join(" ", remixWords);
    }

    /// <summary>
    /// Returns the remix formatted in convention (each word capitalized).
    /// </summary>
    public string RemixInConvention()
    {
        return ConvertEveryWordLargeCharConvention.ToConvention(Remix());
    }

    /// <summary>
    /// Returns the title and remix formatted in convention, with remix in square brackets.
    /// </summary>
    public string TitleAndRemixInConvention()
    {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.Append(TitleInConvention());
        if (remixWords.Count != 0)
        {
            stringBuilder.Append("[" + RemixInConvention() + "]");
        }

        return stringBuilder.ToString();
    }

    /// <summary>
    /// Counts matching and non-matching words between two lists.
    /// Matching words are removed from both working copies; the remaining counts are summed as different.
    /// </summary>
    /// <param name="firstList">The first word list to compare.</param>
    /// <param name="secondList">The second word list to compare.</param>
    /// <param name="sameCount">The count of words found in both lists.</param>
    /// <param name="differentCount">The sum of remaining words in both lists after removing matches.</param>
    public static void CountSameAndDifferent(List<string> firstList, List<string> secondList, out int sameCount, out int differentCount)
    {
        List<string> firstCopy = new List<string>(firstList.ToArray());
        List<string> secondCopy = new List<string>(secondList.ToArray());
        sameCount = 0;
        for (int i = firstCopy.Count - 1; i >= 0; i--)
        {
            int foundIndex = secondCopy.IndexOf(firstCopy[i]);
            if (foundIndex != -1)
            {
                firstCopy.RemoveAt(i);
                secondCopy.RemoveAt(foundIndex);
                sameCount++;
            }
        }

        differentCount = firstCopy.Count + secondCopy.Count;
    }

    /// <summary>
    /// Returns a string representation of artist, title, and optionally remix.
    /// </summary>
    public override string ToString()
    {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.Append(Artist() + "-" + Title());
        if (remixWords.Count != 0)
        {
            stringBuilder.Append(" [" + Remix() + "]");
        }

        return stringBuilder.ToString();
    }

    /// <summary>
    /// Returns a convention-formatted string of artist, title, and optionally remix.
    /// </summary>
    public string ToConventionString()
    {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.Append(ArtistInConvention() + "-" + TitleInConvention());
        if (remixWords.Count != 0)
        {
            stringBuilder.Append(" [" + RemixInConvention() + "]");
        }

        return stringBuilder.ToString();
    }

    private IList<string> SplitRemix(string text)
    {
        List<string> words = SHSplit.Split(text, "&", " ", ",", "-", "[", "]", "(", ")");
        for (int i = 0; i < words.Count; i++)
        {
            words[i] = words[i].ToLower();
        }

        return words;
    }

    private IList<string> SplitArtistTitle(string text)
    {
        List<string> words = SHSplit.Split(text, "&", " ", ",", "-");
        for (int i = 0; i < words.Count; i++)
        {
            words[i] = words[i].ToLower();
        }

        return words;
    }
}
