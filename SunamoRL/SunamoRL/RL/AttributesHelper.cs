namespace SunamoRL.RL;

/// <summary>
/// Helper for extracting data member values from objects using reflection.
/// </summary>
public class AttributesHelper
{
    /// <summary>
    /// Gets values of specified fields from an object, with optional field name translation.
    /// Empty string entries in the basic list produce empty string results.
    /// </summary>
    /// <param name="source">The source object to extract values from.</param>
    /// <param name="fields">The list of available field infos.</param>
    /// <param name="basic">The list of field names to extract (can contain empty string as separator).</param>
    /// <param name="nameMapping">Optional dictionary mapping field names to alternate names. Can be null.</param>
    public static List<object> DataMember(object source, List<FieldInfo> fields, List<string> basic, Dictionary<string, string> nameMapping)
    {
        List<object> result = new List<object>();
        foreach (var item in basic)
        {
            if (item == string.Empty)
            {
                result.Add(string.Empty);
            }
            else
            {
                var fieldName = item;
                if (nameMapping != null)
                {
                    fieldName = nameMapping[item];
                }
                result.Add(fields.Where(field => field.Name == fieldName).First().GetValue(source)!);
            }
        }
        return result;
    }
}
