namespace SunamoCryptAlgorithms.Crypting;

/// <summary>
/// Symmetric encryption uses a single key to encrypt and decrypt.
/// Both parties (encryptor and decryptor) must share the same secret key.
/// </summary>
public partial class Symmetric
{
    /// <summary>
    /// Encrypts the specified stream to memory using preset key and preset initialization vector.
    /// </summary>
    /// <param name="stream">The stream to encrypt.</param>
    public DataCrypt Encrypt(Stream stream)
    {
        MemoryStream memoryStream = new MemoryStream();
        byte[] buffer = new byte[bufferSize + 1];
        int bytesRead = 0;
        ValidateKeyAndIv(true);
        CryptoStream cryptoStream = new CryptoStream(memoryStream, symmetricAlgorithm.CreateEncryptor(), CryptoStreamMode.Write);
        bytesRead = stream.Read(buffer, 0, bufferSize);
        while (bytesRead > 0)
        {
            cryptoStream.Write(buffer, 0, bytesRead);
            bytesRead = stream.Read(buffer, 0, bufferSize);
        }

        cryptoStream.Close();
        memoryStream.Close();
        return new DataCrypt(memoryStream.ToArray());
    }

    /// <summary>
    /// Decrypts the specified data using provided key and preset initialization vector.
    /// </summary>
    /// <param name="encryptedDataCrypt">The encrypted data to decrypt.</param>
    /// <param name="key">The decryption key to use.</param>
    public DataCrypt Decrypt(DataCrypt encryptedDataCrypt, DataCrypt key)
    {
        Key = key;
        return Decrypt(encryptedDataCrypt);
    }

    /// <summary>
    /// Decrypts the specified stream using provided key and preset initialization vector.
    /// </summary>
    /// <param name="encryptedStream">The encrypted stream to decrypt.</param>
    /// <param name="key">The decryption key to use.</param>
    public DataCrypt Decrypt(Stream encryptedStream, DataCrypt key)
    {
        Key = key;
        return Decrypt(encryptedStream);
    }

    /// <summary>
    /// Decrypts the specified stream using preset key and preset initialization vector.
    /// </summary>
    /// <param name="encryptedStream">The encrypted stream to decrypt.</param>
    public DataCrypt Decrypt(Stream encryptedStream)
    {
        MemoryStream memoryStream = new MemoryStream();
        byte[] buffer = new byte[bufferSize + 1];
        ValidateKeyAndIv(false);
        CryptoStream cryptoStream = new CryptoStream(encryptedStream, symmetricAlgorithm.CreateDecryptor(), CryptoStreamMode.Read);
        int bytesRead = 0;
        bytesRead = cryptoStream.Read(buffer, 0, bufferSize);
        while (bytesRead > 0)
        {
            memoryStream.Write(buffer, 0, bytesRead);
            bytesRead = cryptoStream.Read(buffer, 0, bufferSize);
        }

        cryptoStream.Close();
        memoryStream.Close();
        return new DataCrypt(memoryStream.ToArray());
    }

    /// <summary>
    /// Decrypts the specified data using preset key and preset initialization vector.
    /// Key and IV must be set before calling this method.
    /// </summary>
    /// <param name="encryptedDataCrypt">The encrypted data to decrypt.</param>
    public DataCrypt Decrypt(DataCrypt encryptedDataCrypt)
    {
        MemoryStream memoryStream = new MemoryStream(encryptedDataCrypt.Bytes, 0, encryptedDataCrypt.Bytes.Length);
        byte[] buffer = new byte[encryptedDataCrypt.Bytes.Length];
        ValidateKeyAndIv(false);
        CryptoStream cryptoStream = new CryptoStream(memoryStream, symmetricAlgorithm.CreateDecryptor(), CryptoStreamMode.Read);
        try
        {
            cryptoStream.ReadExactly(buffer, 0, encryptedDataCrypt.Bytes.Length - 1);
        }
        catch (CryptographicException ex)
        {
            throw new Exception(Translate.FromKey(XlfKeys.UnableToDecryptDataTheProvidedKeyMayBeInvalid) + "." + Exceptions.TextOfExceptions(ex));
        }
        finally
        {
            cryptoStream.Close();
        }

        return new DataCrypt(buffer);
    }
}
