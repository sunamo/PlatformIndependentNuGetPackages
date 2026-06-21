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
    /// RSA cryptographic service provider instance.
    /// </summary>
    private RSACryptoServiceProvider rsaCryptoProvider;
    /// <summary>
    /// Default name of the key container used for key storage.
    /// </summary>
    private string keyContainerName = "Encryption.AsymmetricEncryption.DefaultContainerName";
    /// <summary>
    /// Default key size in bits.
    /// </summary>
    private int keySize = 1024;
    private const string elementParent = "RSAKeyValue";
    private const string elementModulus = "Modulus";
    private const string elementExponent = "Exponent";
    private const string elementPrimeP = "P";
    private const string elementPrimeQ = "Q";
    private const string elementPrimeExponentP = "DP";
    private const string elementPrimeExponentQ = "DQ";
    private const string elementCoefficient = "InverseQ";
    private const string elementPrivateExponent = "D";
    private const string keyModulus = "PublicKey.Modulus";
    private const string keyExponent = "PublicKey.Exponent";
    private const string keyPrimeP = "PrivateKey.P";
    private const string keyPrimeQ = "PrivateKey.Q";
    private const string keyPrimeExponentP = "PrivateKey.DP";
    private const string keyPrimeExponentQ = "PrivateKey.DQ";
    private const string keyCoefficient = "PrivateKey.InverseQ";
    private const string keyPrivateExponent = "PrivateKey.D";
    /// <summary>
    /// Represents a public encryption key. Intended to be shared, it
    /// contains only the Modulus and Exponent.
    /// </summary>
    public class PublicKey
    {
        /// <summary>
        /// The modulus component of the public key.
        /// </summary>
        public string Modulus = null!;
        /// <summary>
        /// The exponent component of the public key.
        /// </summary>
        public string Exponent = null!;
        /// <summary>
        /// Initializes a new instance of the <see cref="PublicKey"/> class.
        /// </summary>
        public PublicKey()
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="PublicKey"/> class from an XML string containing Modulus and Exponent tags.
        /// </summary>
        /// <param name="keyXml">The XML string containing the public key data.</param>
        public PublicKey(string keyXml)
        {
            LoadFromXml(keyXml);
        }

        /// <summary>
        /// Loads the public key from App.config or Web.config file.
        /// </summary>
        public void LoadFromConfig()
        {
            Modulus = UtilsNonNetStandard.GetConfigString(keyModulus, true);
            Exponent = UtilsNonNetStandard.GetConfigString(keyExponent, true);
        }

        /// <summary>
        /// Returns *.config file XML section representing this public key.
        /// </summary>
        public string ToConfigSection()
        {
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.Append(UtilsNonNetStandard.WriteConfigKey(keyModulus, Modulus));
            stringBuilder.Append(UtilsNonNetStandard.WriteConfigKey(keyExponent, Exponent));
            return stringBuilder.ToString();
        }

        /// <summary>
        /// Writes the *.config file representation of this public key to a file.
        /// </summary>
        /// <param name="filePath">The file path to write the config section to.</param>
        public void ExportToConfigFile(string filePath)
        {
            StreamWriter streamWriter = new StreamWriter(filePath, false);
            streamWriter.Write(ToConfigSection());
            streamWriter.Close();
        }

        /// <summary>
        /// Loads the public key from its XML string.
        /// </summary>
        /// <param name="keyXml">The XML string containing the public key data.</param>
        public void LoadFromXml(string keyXml)
        {
            Modulus = UtilsNonNetStandard.GetXmlElement(keyXml, Translate.FromKey(XlfKeys.Modulus));
            Exponent = UtilsNonNetStandard.GetXmlElement(keyXml, Translate.FromKey(XlfKeys.Exponent));
        }

        /// <summary>
        /// Converts this public key to an RSAParameters object.
        /// </summary>
        public RSAParameters ToParameters()
        {
            RSAParameters parameters = new RSAParameters();
            parameters.Modulus = Convert.FromBase64String(Modulus);
            parameters.Exponent = Convert.FromBase64String(Exponent);
            return parameters;
        }

        /// <summary>
        /// Converts this public key to its XML string representation.
        /// </summary>
        public string ToXml()
        {
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlNode(elementParent, false));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlElement(elementModulus, Modulus));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlElement(elementExponent, Exponent));
            stringBuilder.Append(UtilsNonNetStandard.WriteXmlNode(elementParent, true));
            return stringBuilder.ToString();
        }

        /// <summary>
        /// Writes the XML representation of this public key to a file.
        /// </summary>
        /// <param name="filePath">The file path to write the XML to.</param>
        public void ExportToXmlFile(string filePath)
        {
            StreamWriter streamWriter = new StreamWriter(filePath, false);
            streamWriter.Write(ToXml());
            streamWriter.Close();
        }
    }
}
