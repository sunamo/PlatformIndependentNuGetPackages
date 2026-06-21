namespace SunamoCryptAlgorithms.Crypting;

/// <summary>
/// Hash functions are fundamental to modern cryptography. These functions map binary
/// strings of an arbitrary length to small binary strings of a fixed length, known as
/// hash values. A cryptographic hash function has the property that it is computationally
/// infeasible to find two distinct inputs that hash to the same value. Hash functions
/// are commonly used with digital signatures and for data integrity.
/// </summary>
public partial class Hash
{
    /// <summary>
    /// Type of hash; some are security oriented, others are fast and simple.
    /// </summary>
    public enum Provider
    {
        /// <summary>
        /// Cyclic Redundancy Check provider, 32-bit
        /// </summary>
        CRC32,
        /// <summary>
        /// Secure Hashing Algorithm provider, SHA-1 variant, 160-bit
        /// </summary>
        SHA1,
        /// <summary>
        /// Secure Hashing Algorithm provider, SHA-2 variant, 256-bit
        /// </summary>
        SHA256,
        /// <summary>
        /// Secure Hashing Algorithm provider, SHA-2 variant, 384-bit
        /// </summary>
        SHA384,
        /// <summary>
        /// Secure Hashing Algorithm provider, SHA-2 variant, 512-bit
        /// </summary>
        SHA512,
        /// <summary>
        /// Message Digest algorithm 5, 128-bit
        /// </summary>
        MD5
    }

    /// <summary>
    /// The hash algorithm used for computing hashes.
    /// </summary>
    private HashAlgorithm hashAlgorithm = null!;
    /// <summary>
    /// The last computed hash value.
    /// </summary>
    private DataCrypt hashValue = new DataCrypt();

    /// <summary>
    /// Initializes a new instance of the <see cref="Hash"/> class.
    /// </summary>
    private Hash()
    {
    }

    /// <summary>
    /// Instantiates a new hash of the specified type.
    /// </summary>
    /// <param name="provider">The hash algorithm provider to use.</param>
    public Hash(Provider provider)
    {
        switch (provider)
        {
            case Provider.CRC32:
                hashAlgorithm = new CRC32();
                break;
            case Provider.MD5:
                hashAlgorithm = MD5.Create();
                break;
            case Provider.SHA1:
                hashAlgorithm = SHA1.Create();
                break;
            case Provider.SHA256:
                hashAlgorithm = SHA256.Create();
                break;
            case Provider.SHA384:
                hashAlgorithm = SHA384.Create();
                break;
            case Provider.SHA512:
                hashAlgorithm = SHA512.Create();
                break;
        }
    }

    /// <summary>
    /// Returns the previously calculated hash.
    /// </summary>
    public DataCrypt Value
    {
        get
        {
            return hashValue;
        }
    }

    /// <summary>
    /// Calculates hash on a stream of arbitrary length.
    /// </summary>
    /// <param name="stream">The stream to compute hash from.</param>
    public DataCrypt Calculate(ref Stream stream)
    {
        hashValue.Bytes = hashAlgorithm.ComputeHash(stream);
        return hashValue;
    }

    /// <summary>
    /// Calculates hash for fixed length <see cref="DataCrypt"/>.
    /// </summary>
    /// <param name="dataCrypt">The data to compute hash from.</param>
    public DataCrypt Calculate(DataCrypt dataCrypt)
    {
        return CalculatePrivate(dataCrypt.Bytes);
    }

    /// <summary>
    /// Calculates hash for a string with a prefixed salt value.
    /// A "salt" is random data prefixed to every hashed value to prevent
    /// common dictionary attacks.
    /// </summary>
    /// <param name="dataCrypt">The data to compute hash from.</param>
    /// <param name="salt">The salt data to prefix before hashing.</param>
    public DataCrypt Calculate(DataCrypt dataCrypt, DataCrypt salt)
    {
        byte[] combined = new byte[dataCrypt.Bytes.Length + salt.Bytes.Length];
        salt.Bytes.CopyTo(combined, 0);
        dataCrypt.Bytes.CopyTo(combined, salt.Bytes.Length);
        return CalculatePrivate(combined);
    }

    /// <summary>
    /// Calculates hash for an array of bytes and stores it in the hash value.
    /// </summary>
    /// <param name="data">The byte array to compute hash from.</param>
    private DataCrypt CalculatePrivate(byte[] data)
    {
        hashValue.Bytes = hashAlgorithm.ComputeHash(data);
        return hashValue;
    }
}
