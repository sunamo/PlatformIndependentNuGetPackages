/// <summary>
/// Tests for camelCase convention detection and conversion.
/// </summary>
public class ConvertCamelConventionTests
{
    /// <summary>
    /// Verifies that IsCamel correctly rejects non-camelCase strings.
    /// </summary>
    [Fact]
    public void IsCamelTest()
    {
        var pascalCaseWithNumber = @"HelloWorld 3";
        var camelCaseWithSpace = @"hello World";

        Assert.False(ConvertCamelConvention.IsCamel(pascalCaseWithNumber));
        Assert.False(ConvertCamelConvention.IsCamel(camelCaseWithSpace));
    }
}
