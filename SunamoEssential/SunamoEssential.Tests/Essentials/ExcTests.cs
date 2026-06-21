using SunamoExceptions;

/// <summary>
/// Tests for exception parsing and formatting utilities.
/// </summary>
public class ExcTests
{
    /// <summary>
    /// Verifies that TypeAndMethodName correctly extracts the type and method from a stack trace line.
    /// </summary>
    [Fact]
    public void TypeAndMethodNameTest()
    {
        var stackTraceLine = @"   at EveryLine.SearchCodeElementsUC.SearchCodeElementsUC_Loaded(Object sender, RoutedEventArgs e) in E:\vs\Projects\_Selling\EveryLine\EveryLine\UC\EveryLineUC.xaml.cs:line 362";

        string typeName, methodName;
        Exceptions.TypeAndMethodName(stackTraceLine, out typeName, out methodName);

        Assert.Equal("EveryLine.SearchCodeElementsUC", typeName);
        Assert.Equal("SearchCodeElementsUC_Loaded", methodName);
    }
}
