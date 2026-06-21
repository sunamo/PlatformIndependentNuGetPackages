namespace SunamoSharedMisc.Control;

/// <summary>
/// Helper for calculating column widths in grid layouts.
/// </summary>
public class ColumnSizeHelper
{
    /// <summary>
    /// Redistributes a width change evenly across all non-zero columns.
    /// </summary>
    /// <param name="columnWidths">The list of column widths.</param>
    /// <param name="widthChange">The total width change to distribute.</param>
    public static List<double> CalculateWidthOfColumnsAgain(List<double> columnWidths, double widthChange)
    {
        if (widthChange == 0)
        {
            throw new Exception(Translate.FromKey(XlfKeys.ParameterZmenaOOfMethodColumnSizeHelperCalculateWidthOfColumnsAgainHasValue) + " ");
        }

        widthChange /= columnWidths.Count;
        for (int i = 0; i < columnWidths.Count; i++)
        {
            if (columnWidths[i] != 0)
            {
                columnWidths[i] += widthChange;
            }
        }

        return columnWidths;
    }
}
