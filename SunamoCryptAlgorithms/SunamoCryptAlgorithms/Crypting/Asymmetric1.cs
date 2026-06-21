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
[System.Runtime.Versioning.SupportedOSPlatform("windows")]
public partial class Asymmetric
{
    /// <summary>
    /// Represents a private encryption key. Not intended to be shared, as it
    /// contains all the elements that make up the key.
    /// </summary>
    public class PrivateKey
    {
        /// <summary>
        /// The modulus component of the key.
        /// </summary>
        public string Modulus = null!;
        /// <summary>
        /// The exponent component of the key.
        /// </summary>
        public string Exponent = null!;
        /// <summary>
        /// The first prime factor (P) of the key.
        /// </summary>
        public string PrimeP = null!;
        /// <summary>
        /// The second prime factor (Q) of the key.
        /// </summary>
        public string PrimeQ = null!;
        /// <summary>
        /// The first prime exponent (DP = D mod P-1).
        /// </summary>
        public string PrimeExponentP = null!;
        /// <summary>
        /// The second prime exponent (DQ = D mod Q-1).
        /// </summary>
        public string PrimeExponentQ = null!;
        /// <summary>
        /// The coefficient (InverseQ = Q^-1 mod P).
        /// </summary>
        public string Coefficient = null!;
        /// <summary>
        /// The private exponent (D) of the key.
        /// </summary>
        public string PrivateExponent = null!;
        /// <summary>
        /// Initializes a new instance of the <see cref="PrivateKey"/> class.
        /// </summary>
        public PrivateKey()
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="PrivateKey"/> class from an XML string containing all key elements.
        /// </summary>
        /// <param name="keyXml">The XML string containing the private key data.</param>
        public PrivateKey(string keyXml)
        {
            LoadFromXml(keyXml);
        }

        /// <summary>
        /// Loads the private key from App.config or Web.config file.
        /// </summary>
        public void LoadFromConfig()
        {
            Modulus = UtilsNonNetStandard.GetConfigString(keyModulus, true);
            Exponent = UtilsNonNetStandard.GetConfigString(keyExponent, true);
            PrimeP = UtilsNonNetStandard.GetConfigString(keyPrimeP, true);
            PrimeQ = UtilsNonNetStandard.GetConfigString(keyPrimeQ, true);
            PrimeExponentP = UtilsNonNetStandard.GetConfigString(keyPrimeExponentP, true);
            PrimeExponentQ = UtilsNonNetStandard.GetConfigString(keyPrimeExponentQ, true);
            Coefficient = UtilsNonNetStandard.GetConfigString(keyCoefficient, true);
            PrivateExponent = UtilsNonNetStandard.GetConfigString(keyPrivateExponent, true);
        }

        /// <summary>
        /// Converts this private key to an RSAParameters object.
        /// </summary>
        public RSAParameters ToParameters()
        {
            RSAParameters parameters = new RSAParameters();
            parameters.Modulus = Convert.FromBase64String(Modulus);
            parameters.Exponent = Convert.FromBase64String(Exponent);
            parameters.P = Convert.FromBase64String(PrimeP);
            parameters.Q = Convert.FromBase64String(PrimeQ);
            parameters.DP = Convert.FromBase64String(PrimeExponentP);
            parameters.DQ = Convert.FromBase64String(PrimeExponentQ);
            parameters.InverseQ = Convert.FromBase64String(Coefficient);
            parameters.D = Convert.FromBase64String(PrivateExponent);
            return parameters;
        }

        /// <summary>
        /// Returns *.config file XML section representing this private key.
        /// </summary>
        public string ToConfigSection()
        {
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.Append(UtilsNonNetStandard.WriteConfigKey(keyModulus, Modulus));
            stringBuilder.Append(UtilsNonNetStandard.WriteConfigKey(keyExponent, Exponent));
            stringBuilder.Append(UtilsNonNetStandard.WriteConfigKey(keyPrimeP, PrimeP));
            stringBuilder.Append(UtilsNonNetStandard.WriteConfigKey(keyPrimeQ, PrimeQ));
            stringBuilder.Append(UtilsNonNetStandard.WriteConfigKey(keyPrimeExponentP, PrimeExponentP));
            stringBuilder.Append(UtilsNonNetStandard.WriteConfigKey(keyPrimeExponentQ, PrimeExponentQ));
            stringBuilder.Append(UtilsNonNetStandard.WriteConfigKey(keyCoefficient, Coefficient));
            stringBuilder.Append(UtilsNonNetStandard.WriteConfigKey(keyPrivateExponent, PrivateExponent));
            return stringBuilder.ToString();
        }

        /// <summary>
        /// Writes the *.config file representation of this private key to a file.
        /// </summary>
        /// <param name="filePath">The file path to write the config section to.</param>
        public void ExportToConfigFile(string filePath)
        {
            StreamWriter streamWriter = new StreamWriter(filePath, false);
            streamWriter.Write(ToConfigSection());
            streamWriter.Close();
        }

        /// <summary>
        /// Loads the private key from its XML string.
        /// </summary>
        /// <param name="keyXml">The XML string containing the private key data.</param>
        public void LoadFromXml(string keyXml)
        {
            Modulus = UtilsNonNetStandard.GetXmlElement(keyXml, Translate.FromKey(XlfKeys.Modulus));
            Exponent = UtilsNonNetStandard.GetXmlElement(keyXml, Translate.FromKey(XlfKeys.Exponent));
            PrimeP = UtilsNonNetStandard.GetXmlElement(keyXml, "P");
            PrimeQ = UtilsNonNetStandard.GetXmlElement(keyXml, "Q");
            PrimeExponentP = UtilsNonNetStandard.GetXmlElement(keyXml, "DP");
            PrimeExponentQ = UtilsNonNetStandard.GetXmlElement(keyXml, "DQ");
            Coefficient = UtilsNonNetStandard.GetXmlElement(keyXml, "InverseQ");
            PrivateExponent = UtilsNonNetStandard.GetXmlElement(keyXml, "D");
        }

        /// <summary>
        /// Converts this private key to its XML string representation.
        /// </summary>
        public string ToXml()
        {
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlNode(elementParent, false));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlElement(elementModulus, Modulus));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlElement(elementExponent, Exponent));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlElement(elementPrimeP, PrimeP));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlElement(elementPrimeQ, PrimeQ));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlElement(elementPrimeExponentP, PrimeExponentP));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlElement(elementPrimeExponentQ, PrimeExponentQ));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlElement(elementCoefficient, Coefficient));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlElement(elementPrivateExponent, PrivateExponent));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlNode(elementParent, true));
            return stringBuilder.ToString();
        }

        /// <summary>
        /// Writes the XML representation of this private key to a file.
        /// </summary>
        /// <param name="filePath">The file path to write the XML to.</param>
        public void ExportToXmlFile(string filePath)
        {
            StreamWriter streamWriter = new StreamWriter(filePath, false);
            streamWriter.Write(ToXml());
            streamWriter.Close();
        }
    }

    /// <summary>
    /// Instantiates a new asymmetric encryption session using the default key size (usually 1024 bits).
    /// </summary>
    public Asymmetric()
    {
        rsaCryptoProvider = GetRSAProvider();
    }

    /// <summary>
    /// Instantiates a new asymmetric encryption session using a specific key size.
    /// </summary>
    /// <param name="keySize">The key size in bits.</param>
    public Asymmetric(int keySize)
    {
        this.keySize = keySize;
        rsaCryptoProvider = GetRSAProvider();
    }

    /// <summary>
    /// Sets the name of the key container used to store this key on disk;
    /// this is an unavoidable side effect of the underlying Microsoft CryptoAPI.
    /// </summary>
    /// <remarks>
    /// http://support.microsoft.com/default.aspx?scid=http://support.microsoft.com:80/support/kb/articles/q322/3/71.asp&amp;NoWebContent=1
    /// </remarks>
    public string KeyContainerName
    {
        get
        {
            return keyContainerName;
        }

        set
        {
            keyContainerName = value;
        }
    }

    /// <summary>
    /// Returns the current key size, in bits.
    /// </summary>
    public int KeySizeBits
    {
        get
        {
            return rsaCryptoProvider.KeySize;
        }
    }

    /// <summary>
    /// Returns the maximum supported key size, in bits.
    /// </summary>
    public int KeySizeMaxBits
    {
        get
        {
            return rsaCryptoProvider.LegalKeySizes[0].MaxSize;
        }
    }

    /// <summary>
    /// Returns the minimum supported key size, in bits.
    /// </summary>
    public int KeySizeMinBits
    {
        get
        {
            return rsaCryptoProvider.LegalKeySizes[0].MinSize;
        }
    }

    /// <summary>
    /// Returns valid key step sizes, in bits.
    /// </summary>
    public int KeySizeStepBits
    {
        get
        {
            return rsaCryptoProvider.LegalKeySizes[0].SkipSize;
        }
    }

    /// <summary>
    /// Returns the default public key as stored in the *.config file.
    /// </summary>
    public PublicKey DefaultPublicKey
    {
        get
        {
            PublicKey publicKey = new PublicKey();
            publicKey.LoadFromConfig();
            return publicKey;
        }
    }
}
