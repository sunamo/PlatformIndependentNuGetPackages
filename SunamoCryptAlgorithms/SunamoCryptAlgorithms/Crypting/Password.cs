namespace SunamoCryptAlgorithms.Crypting;

/// <summary>
/// Provides methods for password generation, salting, and hashing.
/// </summary>
public class Password
{
    /// <summary>
    /// Creates a random strong password with mixed character types.
    /// </summary>
    public static string CreateRandomStrongPassword()
    {
        int countCharsLower = 3;
        int countCharsUpper = 3;
        int countCharsNumbers = 3;
        int countCharsSpecial = 1;
        int passwordLength = countCharsLower + countCharsUpper + countCharsNumbers + countCharsSpecial;
        LetterAndDigitCharService letterAndDigitCharService = new LetterAndDigitCharService();
        SpecialCharsService specialCharsService = new();
        List<char> allowedCharsLower = letterAndDigitCharService.LowerChars;
        List<char> allowedCharsUpper = letterAndDigitCharService.UpperChars;
        List<char> allowedCharsNumbers = letterAndDigitCharService.NumericChars;
        List<char> allowedCharsSpecial = specialCharsService.SpecialChars;
        Byte[] randomBytes = new Byte[3];
        var rng = RandomNumberGenerator.Create();
        StringBuilder result = new StringBuilder(passwordLength);
        rng.GetBytes(randomBytes);
        Random random = new Random();
        for (int i = 0; i < countCharsLower; i++)
        {
            result.Insert(random.Next(0, result.Length - 1), allowedCharsLower[(int)randomBytes[i] % allowedCharsLower.Count]);
        }
        rng.GetBytes(randomBytes);
        for (int i = 0; i < countCharsUpper; i++)
        {
            result.Insert(random.Next(0, result.Length - 1), allowedCharsUpper[(int)randomBytes[i] % allowedCharsUpper.Count]);
        }
        rng.GetBytes(randomBytes);
        for (int i = 0; i < countCharsNumbers; i++)
        {
            result.Insert(random.Next(0, result.Length - 1), allowedCharsNumbers[(int)randomBytes[i] % allowedCharsNumbers.Count]);
        }
        rng.GetBytes(randomBytes);
        for (int i = 0; i < countCharsSpecial; i++)
        {
            result.Insert(random.Next(0, result.Length - 1), allowedCharsSpecial[(int)randomBytes[i] % allowedCharsSpecial.Count]);
        }
        return result.ToString();
    }

    private string password;
    private int salt;

    /// <summary>
    /// Initializes a new instance of the <see cref="Password"/> class.
    /// </summary>
    /// <param name="password">The password string.</param>
    /// <param name="saltValue">The salt value for hashing.</param>
    public Password(string password, int saltValue)
    {
        this.password = password;
        salt = saltValue;
    }

    /// <summary>
    /// Creates a random password of the specified length.
    /// </summary>
    /// <param name="passwordLength">The desired password length.</param>
    public static string CreateRandomPassword(int passwordLength)
    {
        String allowedChars = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789";
        Byte[] randomBytes = new Byte[passwordLength];
        var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomBytes);
        char[] chars = new char[passwordLength];
        int allowedCharCount = allowedChars.Length;
        for (int i = 0; i < passwordLength; i++)
        {
            chars[i] = allowedChars[(int)randomBytes[i] % allowedCharCount];
        }
        return new string(chars);
    }

    /// <summary>
    /// Creates a random salt value for password hashing.
    /// </summary>
    public static int CreateRandomSalt()
    {
        Byte[] saltBytes = new Byte[4];
        var rng = RandomNumberGenerator.Create();
        rng.GetBytes(saltBytes);
        return ((((int)saltBytes[0]) << 24) + (((int)saltBytes[1]) << 16) + (((int)saltBytes[2]) << 8) + ((int)saltBytes[3]));
    }

    /// <summary>
    /// Computes the salted hash of the password.
    /// </summary>
    public string ComputeSaltedHash()
    {
        ASCIIEncoding encoder = new ASCIIEncoding();
        Byte[] secretBytes = encoder.GetBytes((string)password);
        Byte[] saltBytes = new Byte[4];
        saltBytes[0] = (byte)(salt >> 24);
        saltBytes[1] = (byte)(salt >> 16);
        saltBytes[2] = (byte)(salt >> 8);
        saltBytes[3] = (byte)(salt);
        Byte[] toHash = new Byte[secretBytes.Length + saltBytes.Length];
        Array.Copy(secretBytes, 0, toHash, 0, secretBytes.Length);
        Array.Copy(saltBytes, 0, toHash, secretBytes.Length, saltBytes.Length);
        SHA1 sha1 = SHA1.Create();
        Byte[] computedHash = sha1.ComputeHash(toHash);
        return encoder.GetString(computedHash);
    }
}
