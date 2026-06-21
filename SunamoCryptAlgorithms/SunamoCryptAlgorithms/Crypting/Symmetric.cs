namespace SunamoCryptAlgorithms.Crypting;

/// <summary>
/// Symmetric encryption uses a single key to encrypt and decrypt.
/// Both parties (encryptor and decryptor) must share the same secret key.
/// </summary>
public partial class Symmetric
{
    private const string defaultInitializationVector = "%1Az=-@qT";
    private const int bufferSize = 2048;

    /// <summary>
    /// Available symmetric encryption providers.
    /// </summary>
    public enum Provider
    {
        /// <summary>
        /// The DataCrypt Encryption Standard provider supports a 64 bit key only
        /// </summary>
        DES,
        /// <summary>
        /// The Rivest Cipher 2 provider supports keys ranging from 40 to 128 bits, default is 128 bits
        /// </summary>
        RC2,
        /// <summary>
        /// The Rijndael (also known as AES) provider supports keys of 128, 192, or 256 bits with a default of 256 bits
        /// </summary>
        Rijndael,
        /// <summary>
        /// The TripleDES provider (also known as 3DES) supports keys of 128 or 192 bits with a default of 192 bits
        /// </summary>
        TripleDES
    }

    private DataCrypt encryptionKey = null!;
    private DataCrypt initializationVector = null!;
    private SymmetricAlgorithm symmetricAlgorithm = null!;

    /// <summary>
    /// Initializes a new instance of the <see cref="Symmetric"/> class.
    /// </summary>
    private Symmetric()
    {
    }

    /// <summary>
    /// Instantiates a new symmetric encryption object using the specified provider.
    /// Automatically generates a random key. If useDefaultInitializationVector is true,
    /// uses the default IV; otherwise generates a random IV.
    /// </summary>
    /// <param name="provider">The symmetric encryption provider to use.</param>
    /// <param name="isUsingDefaultInitializationVector">Whether to use the default initialization vector.</param>
    public Symmetric(Provider provider, bool isUsingDefaultInitializationVector)
    {
        switch (provider)
        {
            case Provider.DES:
                symmetricAlgorithm = DES.Create();
                break;
            case Provider.RC2:
                symmetricAlgorithm = RC2.Create();
                break;
            case Provider.Rijndael:
                symmetricAlgorithm = Aes.Create();
                symmetricAlgorithm.Mode = CipherMode.CBC;
                break;
            case Provider.TripleDES:
                symmetricAlgorithm = TripleDES.Create();
                break;
        }

        Key = RandomKey();
        if (isUsingDefaultInitializationVector)
        {
            IntializationVector = new DataCrypt(defaultInitializationVector);
        }
        else
        {
            IntializationVector = RandomInitializationVector();
        }
    }

    /// <summary>
    /// Key size in bytes. Uses the default key size for any given provider; if you
    /// want to force a specific key size, set this property.
    /// </summary>
    public int KeySizeBytes
    {
        get
        {
            return symmetricAlgorithm.KeySize / 8;
        }

        set
        {
            symmetricAlgorithm.KeySize = value * 8;
            encryptionKey.MaxBytes = value;
        }
    }

    /// <summary>
    /// Key size in bits. Uses the default key size for any given provider; if you
    /// want to force a specific key size, set this property.
    /// </summary>
    public int KeySizeBits
    {
        get
        {
            return symmetricAlgorithm.KeySize;
        }

        set
        {
            symmetricAlgorithm.KeySize = value;
            encryptionKey.MaxBits = value;
        }
    }

    /// <summary>
    /// The key used to encrypt/decrypt data. Setting it also configures Min, Max and Step byte limits from the algorithm's legal key sizes.
    /// </summary>
    public DataCrypt Key
    {
        get
        {
            return encryptionKey;
        }

        set
        {
            encryptionKey = value;
            encryptionKey.MaxBytes = symmetricAlgorithm.LegalKeySizes[0].MaxSize / 8;
            encryptionKey.MinBytes = symmetricAlgorithm.LegalKeySizes[0].MinSize / 8;
            encryptionKey.StepBytes = symmetricAlgorithm.LegalKeySizes[0].SkipSize / 8;
        }
    }

    /// <summary>
    /// Using the default Cipher Block Chaining (CBC) mode, all data blocks are processed using
    /// the value derived from the previous block; the first data block has no previous data block
    /// to use, so it needs an InitializationVector to feed the first block.
    /// </summary>
    public DataCrypt IntializationVector
    {
        get
        {
            return initializationVector;
        }

        set
        {
            initializationVector = value;
            initializationVector.MaxBytes = symmetricAlgorithm.BlockSize / 8;
            initializationVector.MinBytes = symmetricAlgorithm.BlockSize / 8;
        }
    }

    /// <summary>
    /// Generates a random Initialization Vector if one was not provided.
    /// </summary>
    public DataCrypt RandomInitializationVector()
    {
        symmetricAlgorithm.GenerateIV();
        DataCrypt dataCrypt = new DataCrypt(symmetricAlgorithm.IV);
        return dataCrypt;
    }

    /// <summary>
    /// Generates a random key if one was not provided.
    /// </summary>
    public DataCrypt RandomKey()
    {
        symmetricAlgorithm.GenerateKey();
        DataCrypt dataCrypt = new DataCrypt(symmetricAlgorithm.Key);
        return dataCrypt;
    }

    /// <summary>
    /// Ensures that the symmetric algorithm has valid Key and IV
    /// prior to any attempt to encrypt/decrypt anything.
    /// </summary>
    /// <param name="isEncrypting">Whether this is an encryption operation (generates missing keys) or decryption (throws if missing).</param>
    private void ValidateKeyAndIv(bool isEncrypting)
    {
        if (encryptionKey.IsEmpty)
        {
            if (isEncrypting)
            {
                encryptionKey = RandomKey();
            }
            else
            {
                throw new Exception(Translate.FromKey(XlfKeys.NoKeyWasProvidedForTheDecryptionOperation) + "!");
            }
        }

        if (initializationVector.IsEmpty)
        {
            if (isEncrypting)
            {
                initializationVector = RandomInitializationVector();
            }
            else
            {
                throw new Exception(Translate.FromKey(XlfKeys.NoInitializationVectorWasProvidedForTheDecryptionOperation) + "!");
            }
        }

        symmetricAlgorithm.Key = encryptionKey.Bytes;
        symmetricAlgorithm.IV = initializationVector.Bytes;
    }

    /// <summary>
    /// Encrypts the specified DataCrypt using provided key.
    /// </summary>
    /// <param name="dataCrypt">The data to encrypt.</param>
    /// <param name="key">The encryption key to use.</param>
    public DataCrypt Encrypt(DataCrypt dataCrypt, DataCrypt key)
    {
        Key = key;
        return Encrypt(dataCrypt);
    }

    /// <summary>
    /// Encrypts the specified DataCrypt using preset key and preset initialization vector.
    /// </summary>
    /// <param name="dataCrypt">The data to encrypt.</param>
    public DataCrypt Encrypt(DataCrypt dataCrypt)
    {
        MemoryStream memoryStream = new MemoryStream();
        ValidateKeyAndIv(true);
        CryptoStream cryptoStream = new CryptoStream(memoryStream, symmetricAlgorithm.CreateEncryptor(), CryptoStreamMode.Write);
        cryptoStream.Write(dataCrypt.Bytes, 0, dataCrypt.Bytes.Length);
        cryptoStream.Close();
        memoryStream.Close();
        return new DataCrypt(memoryStream.ToArray());
    }

    /// <summary>
    /// Encrypts the stream to memory using provided key and provided initialization vector.
    /// </summary>
    /// <param name="stream">The stream to encrypt.</param>
    /// <param name="key">The encryption key to use.</param>
    /// <param name="initVector">The initialization vector to use.</param>
    public DataCrypt Encrypt(Stream stream, DataCrypt key, DataCrypt initVector)
    {
        IntializationVector = initVector;
        Key = key;
        return Encrypt(stream);
    }

    /// <summary>
    /// Encrypts the stream to memory using specified key.
    /// </summary>
    /// <param name="stream">The stream to encrypt.</param>
    /// <param name="key">The encryption key to use.</param>
    public DataCrypt Encrypt(Stream stream, DataCrypt key)
    {
        Key = key;
        return Encrypt(stream);
    }
}
