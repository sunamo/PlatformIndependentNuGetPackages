namespace SunamoSharedMisc;

/// <summary>
/// Extension for converting objects to dynamic ExpandoObject, skipping null/empty values.
/// </summary>
public static class ReClasser
{
    /// <summary>
    /// Converts an object to a dynamic ExpandoObject, excluding null and whitespace-only string properties.
    /// Must be here because it is used in JsonSystemTextJson etc.
    /// </summary>
    /// <param name="fixMe">The object to convert.</param>
    public static dynamic FixMeUp(this object fixMe)
    {
        var objectType = fixMe.GetType();
        var result = new ExpandoObject() as IDictionary<string, object>;
        var properties = objectType.GetProperties();
        foreach (var property in properties)
        {
            var propertyValue = property.GetValue(fixMe);
            if (propertyValue is string && string.IsNullOrWhiteSpace(propertyValue.ToString()))
            {
                continue;
            }

            if (propertyValue == null)
            {
                continue;
            }

            result.Add(property.Name, propertyValue);
        }

        return result;
    }
}
