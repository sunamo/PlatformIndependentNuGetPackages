namespace SunamoHelpers.Helpers.Runtime;

/// <summary>
/// Provides helper methods for working with dynamic objects at runtime.
/// </summary>
public class DynamicHelper
{
    /// <summary>
    /// Attempts to convert a dynamic object into a flat list of dynamic elements.
    /// </summary>
    /// <param name="dynamicObject">The dynamic object to convert.</param>
    public static List<dynamic> ListFromDynamicObject(dynamic dynamicObject)
    {
        ThrowEx.NotImplementedMethod();

        if (dynamicObject is IList)
        {
            List<dynamic> result = new List<dynamic>();
            var outerList = (IList)dynamicObject;

            foreach (IList innerList in outerList)
            {
                foreach (var element in innerList)
                {
                    result.Add(element);
                }
            }

            return result;
        }

        List<dynamic> elements = new List<dynamic>();
        var objectType = (Type)dynamicObject.GetType();

        return null!;
    }
}
