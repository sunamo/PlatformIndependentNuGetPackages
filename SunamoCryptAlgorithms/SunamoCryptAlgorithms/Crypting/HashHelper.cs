namespace SunamoCryptAlgorithms.Crypting;

/// <summary>
/// Provides methods for computing SHA256 and MD5 hashes, with optional salt generation and verification.
/// </summary>
public class HashHelper
{
    /// <summary>
    /// Computes a SHA256 hash of the input string and returns it as a UTF8 string.
    /// </summary>
    /// <param name="text">The input string to hash.</param>
    public static string GetHashString(string text)
    {
        var hash = GetHash(UTF8Encoding.UTF8.GetBytes(text));
        return Encoding.UTF8.GetString(hash);
    }

    /// <summary>
    /// Computes a SHA256 hash of the password bytes combined with salt bytes.
    /// </summary>
    /// <param name="passwordBytes">The password byte array.</param>
    /// <param name="saltBytes">The salt byte array.</param>
    public static byte[] GetHash(byte[] passwordBytes, byte[] saltBytes)
    {
        List<byte> joined = CA.JoinBytesArray(passwordBytes, saltBytes);
        return GetHash(joined.ToArray());
    }

    /// <summary>
    /// Computes a SHA256 hash of the input byte array (salt must already be included if needed).
    /// </summary>
    /// <param name="input">The byte array to hash.</param>
    public static byte[] GetHash(byte[] input)
    {
        SHA256 sha = SHA256.Create();
        byte[] hashResult = sha.ComputeHash(input);
        return hashResult;
    }

    /// <summary>
    /// Generates a random 10-byte salt, combines it with the password bytes, and computes a SHA256 hash.
    /// </summary>
    /// <param name="passwordBytes">The password byte array.</param>
    /// <param name="hash">The computed hash output.</param>
    /// <param name="saltBytes">The generated salt output.</param>
    public static void GetHashAndSalt(byte[] passwordBytes, out byte[] hash, out byte[] saltBytes)
    {
        saltBytes = RandomHelper.RandomBytes(10);
        List<byte> joined = CA.JoinBytesArray(passwordBytes, saltBytes);
        hash = GetHash(joined.ToArray());
    }

    /// <summary>
    /// Generates a random salt of specified length, combines it with the password bytes, and computes a SHA256 hash.
    /// </summary>
    /// <param name="passwordBytes">The password byte array.</param>
    /// <param name="hash">The computed hash output.</param>
    /// <param name="saltBytes">The generated salt output.</param>
    /// <param name="saltByteCount">The number of random bytes for the salt.</param>
    public static void GetHashAndSalt(byte[] passwordBytes, out byte[] hash, out byte[] saltBytes, int saltByteCount)
    {
        saltBytes = RandomHelper.RandomBytes(saltByteCount);
        List<byte> joined = CA.JoinBytesArray(passwordBytes, saltBytes);
        hash = GetHash(joined.ToArray());
    }

    /// <summary>
    /// Computes an MD5 hash of the input text using UTF8 encoding.
    /// </summary>
    /// <param name="text">The input text to hash.</param>
    public static string GetMd5Hash(string text)
    {
        return GetMd5Hash(text, Encoding.UTF8);
    }

    /// <summary>
    /// Computes an MD5 hash of the input text using the specified encoding.
    /// </summary>
    /// <param name="text">The input text to hash.</param>
    /// <param name="encoding">The encoding to use for converting the text to bytes.</param>
    public static string GetMd5Hash(string text, Encoding encoding)
    {
        MD5 hash = MD5.Create();
        byte[] data = hash.ComputeHash(encoding.GetBytes(text));
        StringBuilder stringBuilder = new StringBuilder();
        for (int i = 0; i < data.Length; i++)
        {
            stringBuilder.Append(data[i].ToString("x2"));
        }

        return stringBuilder.ToString();
    }

    /// <summary>
    /// Verifies that the password matches the stored hash by combining it with the salt and comparing.
    /// </summary>
    /// <param name="hash">The stored hash to compare against.</param>
    /// <param name="saltBytes">The salt used in the original hash.</param>
    /// <param name="passwordBytes">The password bytes to verify.</param>
    public static bool PairHashAndPassword(byte[] hash, byte[] saltBytes, byte[] passwordBytes)
    {
        byte[] computedHash = GetHash(CA.JoinBytesArray(passwordBytes, saltBytes).ToArray());
        if (hash == computedHash)
        {
            return true;
        }

        return false;
    }
}
