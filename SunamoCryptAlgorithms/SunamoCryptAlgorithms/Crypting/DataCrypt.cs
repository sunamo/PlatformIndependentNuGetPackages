namespace SunamoCryptAlgorithms.Crypting;

/// <summary>
/// Represents Hex, Byte, Base64, or String data to encrypt/decrypt.
/// Use the .Text property to set/get a string representation.
/// Use the .Hex property to set/get a string-based Hexadecimal representation.
/// Use the .Base64 to set/get a string-based Base64 representation.
/// Used in classes Asymmetric, Symmetric, Hash.
/// </summary>
public class DataCrypt
{
    private byte[] bytes = null!;
    private int maxBytes = 0;
    private int minBytes = 0;
    private int stepBytes = 0;
    /// <summary>
    /// Determines the default text encoding across ALL DataCrypt instances.
    /// </summary>
    public static Encoding DefaultEncoding = Encoding.GetEncoding(Translate.FromKey(XlfKeys.Windows1252));
    /// <summary>
    /// Determines the default text encoding for this DataCrypt instance.
    /// </summary>
    public Encoding Encoding = DefaultEncoding;

    /// <summary>
    /// Initializes a new empty instance of the <see cref="DataCrypt"/> class.
    /// </summary>
    public DataCrypt()
    {
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="DataCrypt"/> class from a byte array.
    /// </summary>
    /// <param name="data">The byte array data.</param>
    public DataCrypt(byte[] data)
    {
        bytes = data;
    }

    /// <summary>
    /// Creates new encryption data with the specified string;
    /// will be converted to byte array using default encoding.
    /// </summary>
    /// <param name="text">The string to convert to encryption data.</param>
    public DataCrypt(string text)
    {
        Text = text;
    }

    /// <summary>
    /// Creates new encryption data using the specified string and encoding
    /// to convert the string to a byte array.
    /// </summary>
    /// <param name="text">The string to convert to encryption data.</param>
    /// <param name="encoding">The encoding to use for conversion.</param>
    public DataCrypt(string text, Encoding encoding)
    {
        Encoding = encoding;
        Text = text;
    }

    /// <summary>
    /// Returns true if no data is present.
    /// </summary>
    public bool IsEmpty
    {
        get
        {
            if (bytes == null)
            {
                return true;
            }
            if (bytes.Length == 0)
            {
                return true;
            }
            return false;
        }
    }

    /// <summary>
    /// Allowed step interval, in bytes, for this data; if 0, no limit.
    /// </summary>
    public int StepBytes
    {
        get { return stepBytes; }
        set { stepBytes = value; }
    }

    /// <summary>
    /// Allowed step interval, in bits, for this data; if 0, no limit.
    /// </summary>
    public int StepBits
    {
        get { return stepBytes * 8; }
        set { stepBytes = value / 8; }
    }

    /// <summary>
    /// Minimum number of bytes allowed for this data; if 0, no limit.
    /// </summary>
    public int MinBytes
    {
        get { return minBytes; }
        set { minBytes = value; }
    }

    /// <summary>
    /// Minimum number of bits allowed for this data; if 0, no limit.
    /// </summary>
    public int MinBits
    {
        get { return minBytes * 8; }
        set { minBytes = value / 8; }
    }

    /// <summary>
    /// Maximum number of bytes allowed for this data; if 0, no limit.
    /// </summary>
    public int MaxBytes
    {
        get { return maxBytes; }
        set { maxBytes = value; }
    }

    /// <summary>
    /// Maximum number of bits allowed for this data; if 0, no limit.
    /// </summary>
    public int MaxBits
    {
        get { return maxBytes * 8; }
        set { maxBytes = value / 8; }
    }

    /// <summary>
    /// Returns the byte representation of the data.
    /// This will be padded to MinBytes and trimmed to MaxBytes as necessary.
    /// </summary>
    public byte[] Bytes
    {
        get
        {
            if (maxBytes > 0)
            {
                if (bytes.Length > maxBytes)
                {
                    byte[] trimmed = new byte[maxBytes];
                    Array.Copy(bytes, trimmed, trimmed.Length);
                    bytes = trimmed;
                }
            }
            if (minBytes > 0)
            {
                if (bytes.Length < minBytes)
                {
                    byte[] padded = new byte[minBytes];
                    Array.Copy(bytes, padded, bytes.Length);
                    bytes = padded;
                }
            }
            return bytes;
        }
        set { bytes = value; }
    }

    /// <summary>
    /// Sets or returns text representation of bytes using the default text encoding.
    /// </summary>
    public string Text
    {
        get
        {
            if (bytes == null)
            {
                return "";
            }
            else
            {
                int nullIndex = Array.IndexOf(bytes, Convert.ToByte(0));
                if (nullIndex >= 0)
                {
                    return Encoding.GetString(bytes, 0, nullIndex);
                }
                else
                {
                    return Encoding.GetString(bytes);
                }
            }
        }
        set { bytes = Encoding.GetBytes(value); }
    }

    /// <summary>
    /// Sets or returns Hex string representation of this data.
    /// </summary>
    public string Hex
    {
        get { return Utils.ToHex(bytes.ToList()); }
        set { bytes = Utils.FromHex(value).ToArray(); }
    }

    /// <summary>
    /// Sets or returns Base64 string representation of this data.
    /// </summary>
    public string Base64
    {
        get { return Utils.ToBase64(bytes.ToList()); }
        set { bytes = Utils.FromBase64(value); }
    }

    /// <summary>
    /// Returns text representation of bytes using the default text encoding.
    /// </summary>
    public new string ToString()
    {
        return Text;
    }

    /// <summary>
    /// Returns Base64 string representation of this data.
    /// </summary>
    public string ToBase64()
    {
        return Base64;
    }

    /// <summary>
    /// Returns Hex string representation of this data.
    /// </summary>
    public string ToHex()
    {
        return Hex;
    }

    /// <summary>
    /// Creates a new DataCrypt instance from the contents of a file.
    /// </summary>
    /// <param name="filePath">The path to the file to read.</param>
    public static
#if ASYNC
async Task<DataCrypt>
#else
  DataCrypt
#endif
FromFile(string filePath)
    {
        DataCrypt dataCrypt = new DataCrypt();
        dataCrypt.Text =
#if ASYNC
            await FileAsync.ReadAllTextAsync(filePath);
#else
            FileAsync.ReadAllTextAsync(filePath).GetAwaiter().GetResult();
#endif
        return dataCrypt;
    }
}
