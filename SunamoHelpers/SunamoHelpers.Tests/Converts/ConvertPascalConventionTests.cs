/// <summary>
/// Tests for PascalCase convention detection and conversion.
/// </summary>
public class ConvertPascalConventionTests
{
    string[] testInputs = {
           "AutomaticTrackingSystem",
           "XMLEditor",
           "AnXMLAndXSLT2.0Tool",
        };

    Regex pascalCaseSplitRegex = new Regex(
        @"(?<=[A-Z])(?=[A-Z][a-z])|(?<=[^A-Z])(?=[A-Z])|(?<=[A-Za-z])(?=[^A-Za-z])"
      );

    /// <summary>
    /// Verifies that IsPascal correctly handles strings containing numbers.
    /// </summary>
    [Fact]
    public void IsPascalWithNumberTest()
    {
        var validPascalCase = @"HelloWorld";
        var pascalCaseWithNumber = @"HelloWorld2";
        var pascalCaseWithSpace = @"Hello World3";

        Assert.True(ConvertPascalConvention.IsPascal(validPascalCase));
        Assert.False(ConvertPascalConvention.IsPascal(pascalCaseWithNumber));
        Assert.False(ConvertPascalConvention.IsPascal(pascalCaseWithSpace));
    }

    /// <summary>
    /// Verifies that converting to PascalCase and back produces the original string.
    /// </summary>
    [Fact]
    public void FromToPascalWithNumbersTest()
    {
        var input = "hello world";
        var convertedToPascal = ConvertPascalConvention.ToConvention(input);
        var convertedBack = ConvertPascalConvention.FromConvention(convertedToPascal);

        input = SH.FirstCharUpper(input);

        Assert.Equal(input, convertedBack);
    }

    /// <summary>
    /// Verifies that IsPascal correctly identifies valid PascalCase and rejects other formats.
    /// </summary>
    [Fact]
    public void IsPascalTest()
    {
        var validPascalCase = @"HelloWorld";
        var camelCase = @"helloWorld";
        var pascalCaseWithSpace = @"Hello World";

        Assert.True(ConvertPascalConvention.IsPascal(validPascalCase));
        Assert.False(ConvertPascalConvention.IsPascal(camelCase));
        Assert.False(ConvertPascalConvention.IsPascal(pascalCaseWithSpace));
    }

    /// <summary>
    /// Verifies that ToConvention converts a space-separated string to PascalCase.
    /// </summary>
    [Fact]
    public void ToConventionTest()
    {
        var input = @"custom Field 2 - Value";
        var expected = "CustomField2Value";

        var result = ConvertPascalConvention.ToConvention(input);

        Assert.Equal(expected, result);
    }
}
