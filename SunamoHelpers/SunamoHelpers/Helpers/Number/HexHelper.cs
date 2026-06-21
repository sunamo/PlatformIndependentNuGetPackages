namespace SunamoHelpers.Helpers.Number;

/// <summary>
/// Provides helper methods for hexadecimal conversion and validation.
/// </summary>
public static class HexHelper
{
    /// <summary>
    /// Checks whether a string is in valid hexadecimal format (lowercase, no prefix characters like #).
    /// </summary>
    /// <param name="text">The string to validate.</param>
    public static bool IsInHexFormat(string text)
    {
        foreach (var item in text)
        {
            if (!"0123456789abcdef".Contains(item.ToString()))
            {
                return false;
            }
        }
        return true;
    }

    /// <summary>
    /// Converts a list of bytes to its hexadecimal string representation.
    /// </summary>
    /// <param name="bytes">The list of bytes to convert.</param>
    public static string ToHex(List<byte> bytes)
    {
        return Utils.ToHex(bytes);
    }

    /// <summary>
    /// Converts a hexadecimal string to a list of bytes. Throws if the format is invalid (e.g. odd number of characters).
    /// </summary>
    /// <param name="hexEncoded">The hexadecimal string to convert.</param>
    public static List<byte> FromHex(string hexEncoded)
    {
        return Utils.FromHex(hexEncoded);
    }
}
