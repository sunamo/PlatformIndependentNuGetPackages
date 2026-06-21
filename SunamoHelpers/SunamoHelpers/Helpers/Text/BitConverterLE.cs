namespace SunamoHelpers.Helpers.Text;

/// <summary>
/// Provides little-endian byte conversion methods for unsigned integer types.
/// </summary>
public static class BitConverterLE
{
    /// <summary>
    /// Converts a ulong value to a little-endian byte array.
    /// </summary>
    /// <param name="value">The value to convert.</param>
    public static byte[] GetBytes(ulong value)
    {
        var buffer = new byte[8];
        buffer[0] = (byte)value;
        buffer[1] = (byte)(value >> 8);
        buffer[2] = (byte)(value >> 16);
        buffer[3] = (byte)(value >> 24);
        buffer[4] = (byte)(value >> 32);
        buffer[5] = (byte)(value >> 40);
        buffer[6] = (byte)(value >> 48);
        buffer[7] = (byte)(value >> 56);
        return buffer;
    }

    /// <summary>
    /// Converts a uint value to a little-endian byte array.
    /// </summary>
    /// <param name="value">The value to convert.</param>
    public static byte[] GetBytes(uint value)
    {
        var buffer = new byte[4];
        buffer[0] = (byte)value;
        buffer[1] = (byte)(value >> 8);
        buffer[2] = (byte)(value >> 16);
        buffer[3] = (byte)(value >> 24);
        return buffer;
    }

    /// <summary>
    /// Converts a ushort value to a little-endian byte array.
    /// </summary>
    /// <param name="value">The value to convert.</param>
    public static byte[] GetBytes(ushort value)
    {
        var buffer = new byte[2];
        buffer[0] = (byte)value;
        buffer[1] = (byte)(value >> 8);
        return buffer;
    }
}
