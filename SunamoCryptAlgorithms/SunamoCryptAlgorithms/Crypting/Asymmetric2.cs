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
    /// Encrypts data using the provided public key.
    /// </summary>
    /// <param name="dataCrypt">The data to encrypt.</param>
    /// <param name="publicKey">The public key to use for encryption.</param>
    public DataCrypt Encrypt(DataCrypt dataCrypt, PublicKey publicKey)
    {
        rsaCryptoProvider.ImportParameters(publicKey.ToParameters());
        return EncryptPrivate(dataCrypt);
    }

    /// <summary>
    /// Encrypts data using the provided public key as XML.
    /// </summary>
    /// <param name="dataCrypt">The data to encrypt.</param>
    /// <param name="publicKeyXml">The public key XML string.</param>
    public DataCrypt Encrypt(DataCrypt dataCrypt, string publicKeyXml)
    {
        LoadKeyXml(publicKeyXml, false);
        return EncryptPrivate(dataCrypt);
    }

    /// <summary>
    /// Encrypts data using the RSA provider. Throws if data is too large for RSA encryption.
    /// </summary>
    /// <param name="dataCrypt">The data to encrypt.</param>
    private DataCrypt EncryptPrivate(DataCrypt dataCrypt)
    {
        try
        {
            return new DataCrypt(rsaCryptoProvider.Encrypt(dataCrypt.Bytes, false));
        }
        catch (CryptographicException ex)
        {
            if (ex.Message.ToLower().IndexOf("bad length") > -1)
            {
                throw new Exception(Translate.FromKey(XlfKeys.YourDataIsTooLargeRSAEncryptionIsDesignedToEncryptRelativelySmallAmountsOfDataTheExactByteLimitDependsOnTheKeySizeToEncryptMoreDataUseSymmetricEncryptionAndThenEncryptThatSymmetricKeyWithAsymmetricRSAEncryption) + ".");
            }
            else
            {
                throw;
            }
        }
    }

    /// <summary>
    /// Decrypts data using the default private key from the config file.
    /// </summary>
    /// <param name="encryptedDataCrypt">The encrypted data to decrypt.</param>
    public DataCrypt Decrypt(DataCrypt encryptedDataCrypt)
    {
        PrivateKey privateKey = new PrivateKey();
        privateKey.LoadFromConfig();
        return Decrypt(encryptedDataCrypt, privateKey);
    }

    /// <summary>
    /// Decrypts data using the provided private key.
    /// </summary>
    /// <param name="encryptedDataCrypt">The encrypted data to decrypt.</param>
    /// <param name="privateKey">The private key to use for decryption.</param>
    public DataCrypt Decrypt(DataCrypt encryptedDataCrypt, PrivateKey privateKey)
    {
        rsaCryptoProvider.ImportParameters(privateKey.ToParameters());
        return DecryptPrivate(encryptedDataCrypt);
    }

    /// <summary>
    /// Decrypts data using the provided private key as XML.
    /// </summary>
    /// <param name="encryptedDataCrypt">The encrypted data to decrypt.</param>
    /// <param name="privateKeyXml">The private key XML string.</param>
    public DataCrypt Decrypt(DataCrypt encryptedDataCrypt, string privateKeyXml)
    {
        LoadKeyXml(privateKeyXml, true);
        return DecryptPrivate(encryptedDataCrypt);
    }

    /// <summary>
    /// Loads RSA key from XML string into the crypto provider.
    /// </summary>
    /// <param name="keyXml">The XML string containing the key data.</param>
    /// <param name="isPrivate">Whether the key is a private key (used for error messages).</param>
    private void LoadKeyXml(string keyXml, bool isPrivate)
    {
        try
        {
            rsaCryptoProvider.FromXmlString(keyXml);
        }
        catch (Exception)
        {
            string? keyType = null;
            if (isPrivate)
            {
                keyType = "private";
            }
            else
            {
                keyType = "public";
            }

            throw new Exception(string.Format(Translate.FromKey(XlfKeys.TheProvided0EncryptionKeyXMLDoesNotAppearToBeValid) + ".", keyType));
        }
    }

    /// <summary>
    /// Decrypts data using the RSA provider.
    /// </summary>
    /// <param name="encryptedDataCrypt">The encrypted data to decrypt.</param>
    private DataCrypt DecryptPrivate(DataCrypt encryptedDataCrypt)
    {
        return new DataCrypt(rsaCryptoProvider.Decrypt(encryptedDataCrypt.Bytes, false));
    }

    /// <summary>
    /// Gets the default RSA provider using the specified key size.
    /// Note that Microsoft's CryptoAPI has an underlying file system dependency that is unavoidable.
    /// The key will be stored in the machine key store, not in the user profile.
    /// </summary>
    /// <remarks>
    /// http://support.microsoft.com/default.aspx?scid=http://support.microsoft.com:80/support/kb/articles/q322/3/71.asp&amp;NoWebContent=1
    /// </remarks>
    [System.Runtime.Versioning.SupportedOSPlatform("windows")]
    private RSACryptoServiceProvider GetRSAProvider()
    {
        RSACryptoServiceProvider? rsa = null;
        CspParameters? csp = null;
        try
        {
            csp = new CspParameters();
            csp.KeyContainerName = keyContainerName;
            rsa = new RSACryptoServiceProvider(keySize, csp);
            rsa.PersistKeyInCsp = false;
            RSACryptoServiceProvider.UseMachineKeyStore = true;
            return rsa;
        }
        catch (CryptographicException ex)
        {
            if (ex.Message.ToLower().IndexOf("csp for this implementation could not be acquired") > -1)
            {
                throw new Exception(Translate.FromKey(XlfKeys.UnableToObtainCryptographicServiceProvider) + ". " + Translate.FromKey(XlfKeys.EitherThePermissionsAreIncorrectOnThe) + " 'C:\\Documents and Settings\\All Users\\Application DataCrypt\\Microsoft\\Crypto\\RSA\\MachineKeys' folder, or the current security context '" + WindowsIdentity.GetCurrent().Name + "' does not have access to this folder.");
            }
            else
            {
                throw;
            }
        }
        finally
        {
            if (rsa != null)
            {
                rsa = null;
            }

            if (csp != null)
            {
                csp = null;
            }
        }
#pragma warning disable CS0162
        return null!;
#pragma warning restore CS0162
    }
}
