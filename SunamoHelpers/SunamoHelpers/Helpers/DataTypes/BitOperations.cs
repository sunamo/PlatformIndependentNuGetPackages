namespace SunamoHelpers.Helpers.DataTypes;

/// <summary>
/// Provides low-level bit manipulation operations for reading, writing, and copying bits within byte arrays and ulong values.
/// </summary>
public static class BitOperations
{
    /// <summary>
    /// Copies a block of bits from the source byte array starting at the specified bit offset.
    /// </summary>
    /// <param name="bytes">Source byte array.</param>
    /// <param name="offset">Bit offset to start copying from.</param>
    /// <param name="length">Number of bits to copy.</param>
    public static byte[] CopyBlock(byte[] bytes, int offset, int length)
    {
        int startByte = offset / 8;
        int endByte = (offset + length - 1) / 8;
        int shiftA = offset % 8;
        int shiftB = 8 - shiftA;
        var destination = new byte[(length + 7) / 8];

        if (shiftA == 0)
        {
            Buffer.BlockCopy(bytes, startByte, destination, 0, destination.Length);
        }

        else
        {
            int i;

            for (i = 0; i < endByte - startByte; i++)
            {
                destination[i] = (byte)(bytes[startByte + i] << shiftA | bytes[startByte + i + 1] >> shiftB);
            }

            if (i < destination.Length)
            {
                destination[i] = (byte)(bytes[startByte + i] << shiftA);
            }
        }

        destination[destination.Length - 1] &= (byte)(0xFF << destination.Length * 8 - length);

        return destination;
    }

    /// <summary>
    /// Copies source bytes into the destination byte array at the specified offset.
    /// </summary>
    /// <param name="destination">Destination byte array.</param>
    /// <param name="destinationOffset">Byte offset in the destination array.</param>
    /// <param name="source">Source byte array to copy from.</param>
    public static void CopyBytes(byte[] destination, int destinationOffset, byte[] source)
    {
        Buffer.BlockCopy(source, 0, destination, destinationOffset, source.Length);
    }

    /// <summary>
    /// Reads the specified number of bits from the high end of a ulong value and shifts the value left.
    /// </summary>
    /// <param name="bits">Reference to the ulong value to read from.</param>
    /// <param name="length">Number of bits to read.</param>
    public static int Read(ref ulong bits, int length)
    {
        int result = (int)(bits >> 64 - length);
        bits <<= length;
        return result;
    }

    /// <summary>
    /// Reads the specified number of bits from a byte array at the given bit offset.
    /// </summary>
    /// <param name="bytes">Source byte array.</param>
    /// <param name="offset">Reference to the current bit offset, updated after reading.</param>
    /// <param name="length">Number of bits to read.</param>
    public static int Read(byte[] bytes, ref int offset, int length)
    {
        int startByte = offset / 8;
        int endByte = (offset + length - 1) / 8;
        int skipBits = offset % 8;
        ulong bits = 0;

        for (int i = 0; i <= Math.Min(endByte - startByte, 7); i++)
        {
            bits |= (ulong)bytes[startByte + i] << 56 - i * 8;
        }

        if (skipBits != 0)
        {
            Read(ref bits, skipBits);
        }

        offset += length;

        return Read(ref bits, length);
    }

    /// <summary>
    /// Writes the specified number of bits to the low end of a ulong value, shifting existing bits left.
    /// </summary>
    /// <param name="bits">Reference to the ulong value to write to.</param>
    /// <param name="length">Number of bits to write.</param>
    /// <param name="value">The value to write.</param>
    public static void Write(ref ulong bits, int length, int value)
    {
        ulong mask = 0xFFFFFFFFFFFFFFFF >> 64 - length;
        bits = bits << length | (ulong)value & mask;
    }
}
