namespace SunamoHelpers._sunamo.SunamoRandom;

/// <summary>
/// Random number generation helper.
/// </summary>
internal class RandomHelper
{
    private static Random random = new Random(Guid.NewGuid().GetHashCode());

    /// <summary>
    /// Generates an array of random bytes of the specified count.
    /// </summary>
    /// <param name="count">The number of random bytes to generate.</param>
    internal static byte[] RandomBytes(int count)
    {
        byte[] bytes = new byte[count];
        for (int i = 0; i < count; i++)
        {
            bytes[i] = (byte)random.Next(0, byte.MaxValue);
        }
        return bytes;
    }
}
