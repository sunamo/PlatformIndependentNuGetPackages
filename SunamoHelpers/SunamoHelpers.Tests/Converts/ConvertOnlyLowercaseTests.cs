/// <summary>
/// Tests for converting strings to and from a lowercase-only encoding with uppercase markers.
/// </summary>
public class ConvertOnlyLowercaseTests
{
    /// <summary>
    /// Verifies that To encodes uppercase letters using the NextUpper marker character.
    /// </summary>
    [Fact]
    public void ToTest()
    {
        var input = "nY-aVdc_qu4";
        var expected = "n*y-a*vdc_qu4";

        ConvertOnlyLowercase.NextUpper = '*';

        var result = ConvertOnlyLowercase.To(input);
        Assert.Equal(expected, result);
    }

    /// <summary>
    /// Verifies that From decodes a lowercase-encoded string back to its original mixed-case form.
    /// </summary>
    [Fact]
    public void FromTest2()
    {
        var input = "n*y-a*vdc_qu4";
        var expected = "nY-aVdc_qu4";

        ConvertOnlyLowercase.NextUpper = '*';

        var result = ConvertOnlyLowercase.From(input);
        Assert.Equal(expected, result);
    }
}
