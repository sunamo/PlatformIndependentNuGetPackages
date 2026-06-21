namespace SunamoHelpers.Helpers.DataTypes;

/// <summary>
/// Provides helper methods for byte array comparison operations.
/// </summary>
public class BitHelper
{
    /// <summary>
    /// Checks whether the byte array starts with the specified byte sequence.
    /// </summary>
    /// <param name="source">The byte array to check.</param>
    /// <param name="prefix">The byte sequence to match at the start.</param>
    public static bool StartsWith(byte[] source, params byte[] prefix)
    {
        for (int i = 0; i < prefix.Length; i++)
        {
            if (prefix[i] != source[i])
            {
                return false;
            }
        }
        return true;
    }
}
