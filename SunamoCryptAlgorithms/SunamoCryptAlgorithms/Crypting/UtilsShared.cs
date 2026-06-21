namespace SunamoCryptAlgorithms.Crypting;

/// <summary>
/// Provides utility methods for converting between byte arrays and hex or Base64 string representations.
/// </summary>
public class Utils
{
    /// <summary>
    /// Converts a list of bytes to a hexadecimal string representation.
    /// </summary>
    /// <param name="byteList">The byte list to convert.</param>
    public static string ToHex(List<byte> byteList)
    {
        if (byteList == null || byteList.Count == 0)
        {
            return "";
        }

        const string HexFormat = "{0:X2}";
        StringBuilder stringBuilder = new StringBuilder();
        foreach (byte byteValue in byteList)
        {
            stringBuilder.Append(string.Format(HexFormat, byteValue));
        }

        return stringBuilder.ToString();
    }

    /// <summary>
    /// Converts from a string hex representation to a list of bytes.
    /// Throws if the string is not a valid hex format.
    /// </summary>
    /// <param name="hexEncoded">The hex-encoded string to convert.</param>
    public static List<byte> FromHex(string hexEncoded)
    {
        if (hexEncoded == null || hexEncoded.Length == 0)
        {
            return null!;
        }

        try
        {
            hexEncoded = hexEncoded.TrimStart('#');
            int length = Convert.ToInt32(hexEncoded.Length / 2);
            List<byte> byteList = new List<byte>(length);

            for (int i = 0; i <= length - 1; i++)
            {
                byteList.Add(Convert.ToByte(hexEncoded.Substring(i * 2, 2), 16));
            }

            return byteList;
        }
        catch (Exception ex)
        {
            throw new Exception(Translate.FromKey(XlfKeys.TheProvidedStringDoesNotAppearToBeHexEncoded) + ":" + Environment.NewLine + hexEncoded + Environment.NewLine + Exceptions.TextOfExceptions(ex));
        }
    }

    /// <summary>
    /// Converts from a string Base64 representation to an array of bytes.
    /// Throws if the string is not a valid Base64 format.
    /// </summary>
    /// <param name="base64Encoded">The Base64-encoded string to convert.</param>
    public static byte[] FromBase64(string base64Encoded)
    {
        if (base64Encoded == null || base64Encoded.Length == 0)
        {
            return null!;
        }

        try
        {
            return Convert.FromBase64String(base64Encoded);
        }
        catch (FormatException ex)
        {
            throw new Exception(Translate.FromKey(XlfKeys.TheProvidedStringDoesNotAppearToBeBase64Encoded) + ":" + Environment.NewLine + base64Encoded + Environment.NewLine + ex.Message);
        }
    }

    /// <summary>
    /// Converts from a list of bytes to a string Base64 representation.
    /// </summary>
    /// <param name="byteList">The byte list to convert.</param>
    public static string ToBase64(List<byte> byteList)
    {
        if (byteList == null || byteList.Count == 0)
        {
            return "";
        }

        return Convert.ToBase64String(byteList.ToArray());
    }
}
