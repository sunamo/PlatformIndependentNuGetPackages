namespace SunamoHelpers.Helpers;

/// <summary>
/// Provides helper methods for generating grid layout proportional size definitions.
/// </summary>
public class GridHelperSunamo
{
    /// <summary>
    /// Generates a list of equal proportional sizes for the specified number of columns.
    /// Can be used with XamlGeneratorDesktop.Write*Definitions.
    /// </summary>
    /// <param name="count">Number of columns to generate equal sizes for.</param>
    public static List<string> ForAllTheSame(int count)
    {
        List<string> result = new List<string>(count);
        var proportion = 100d / count;
        for (int i = 0; i < count; i++)
        {
            result.Add(proportion + "*");
        }

        return result;
    }
}
