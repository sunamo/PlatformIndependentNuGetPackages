namespace SunamoCryptAlgorithms.Crypting;

/// <summary>
/// Asymmetric encryption uses a pair of keys to encrypt and decrypt.
/// There is a "public" key which is used to encrypt. Decrypting, on the other hand,
/// requires both the "public" key and an additional "private" key. The advantage is
/// that people can send you encrypted messages without being able to decrypt them.
/// </summary>
/// <remarks>
/// The only provider supported is the <see cref = "RSACryptoServiceProvider"/>
/// </remarks>
public partial class Asymmetric
{
    /// <summary>
    /// Returns the default private key as stored in the *.config file.
    /// </summary>
    public PrivateKey DefaultPrivateKey
    {
        get
        {
            PrivateKey privateKey = new PrivateKey();
            privateKey.LoadFromConfig();
            return privateKey;
        }
    }

    /// <summary>
    /// Generates a new public/private key pair as objects.
    /// </summary>
    /// <param name="publicKey">The generated public key object.</param>
    /// <param name="privateKey">The generated private key object.</param>
    public void GenerateNewKeyset(ref PublicKey publicKey, ref PrivateKey privateKey)
    {
        string? publicKeyXml = null;
        string? privateKeyXml = null;
        GenerateNewKeyset(ref publicKeyXml!, ref privateKeyXml!);
        publicKey = new PublicKey(publicKeyXml!);
        privateKey = new PrivateKey(privateKeyXml!);
    }

    /// <summary>
    /// Generates a new public/private key pair as XML strings.
    /// </summary>
    /// <param name="publicKeyXml">The generated public key XML string.</param>
    /// <param name="privateKeyXml">The generated private key XML string.</param>
    public void GenerateNewKeyset(ref string publicKeyXml, ref string privateKeyXml)
    {
        RSA rsa = RSA.Create();
        publicKeyXml = rsa.ToXmlString(false);
        privateKeyXml = rsa.ToXmlString(true);
    }

    /// <summary>
    /// Encrypts data using the default public key.
    /// </summary>
    /// <param name="dataCrypt">The data to encrypt.</param>
    public DataCrypt Encrypt(DataCrypt dataCrypt)
    {
        PublicKey publicKey = DefaultPublicKey;
        return Encrypt(dataCrypt, publicKey);
    }
}
