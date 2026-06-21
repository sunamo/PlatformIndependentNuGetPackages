
/// <summary>
/// Tests for shared cryptographic utility methods.
/// </summary>
public class UtilsSharedTests
{
    /// <summary>
    /// Verifies that Base64 encoding and decoding round-trips correctly.
    /// </summary>
    [Fact]
    public void Base64Test()
    {
        byte[] inputBuffer = [101,
224,
213,
172,
187,
31,
40,
224,
29,
94];
        var base64Encoded = Utils.ToBase64(inputBuffer.ToList());
        var decodedBytes = Utils.FromBase64(base64Encoded);
        Assert.Equal<byte>(inputBuffer, decodedBytes);
    }
}
