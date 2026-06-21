namespace SunamoHelpers.Helpers;

/// <summary>
/// Provides helper methods for casting and converting objects to specific types.
/// </summary>
public class CastHelper
{
    /// <summary>
    /// Converts an object to its string representation, supporting string and List of string types.
    /// </summary>
    /// <param name="value">The object to convert to string.</param>
    public static string ToString(object value)
    {
        var objectType = value.GetType();
        if (objectType == typeof(string))
        {
            return value.ToString()!;
        }
        else if (objectType == typeof(List<string>))
        {
            return string.Join(Environment.NewLine, (List<string>)value);
        }
        else
        {
            ThrowEx.DoesntHaveRequiredType(nameof(value));
        }

        return null!;
    }
}
