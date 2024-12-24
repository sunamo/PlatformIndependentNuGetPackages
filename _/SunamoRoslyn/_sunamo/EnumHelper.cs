namespace SunamoRoslyn._sunamo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal class EnumHelper
{
    internal static List<T> GetValues<T>()
      where T : struct
    {
        return GetValues<T>(false, true);
    }
    /// <summary>
    /// Get all values expect of Nope/None
    /// </summary>
    /// <typeparam name = "T"></typeparam>
    /// <param name = "type"></param>
    internal static List<T> GetValues<T>(bool IncludeNope, bool IncludeShared)
        where T : struct
    {
        var type = typeof(T);
        var values = Enum.GetValues(type).Cast<T>().ToList();
        T nope;
        if (!IncludeNope)
        {
            if (Enum.TryParse<T>(CodeElementsConstants.NopeValue, out nope))
            {
                values.Remove(nope);
            }
        }

        if (!IncludeShared)
        {
            if (type.Name == "MySites")
            {
                if (Enum.TryParse<T>("Shared", out nope))
                {
                    values.Remove(nope);
                }
            }
            else
            {
                if (Enum.TryParse<T>("Sha", out nope))
                {
                    values.Remove(nope);
                }
            }
        }

        if (Enum.TryParse<T>(CodeElementsConstants.NoneValue, out nope))
        {
            values.Remove(nope);
        }

        return values;
    }
    internal static Dictionary<T, string> EnumToString<T>(Type enumType)
    {
        return Enum.GetValues(enumType).Cast<T>().Select(t => new
        {
            Key = t,
            // Must be lower due to EveryLine and e2sNamespaceCodeElements
            Value = t.ToString().ToLower()
        }
        ).ToDictionary(r => r.Key, r => r.Value);
    }

    internal static string EnumToString<T>(T ds) where T : Enum
    {
        const string comma = ",";
        var sb = new StringBuilder();
        var v = Enum.GetValues(typeof(T));
        foreach (T item in v)
            if (ds.HasFlag(item))
            {
                var ts = item.ToString();
                if (ts != CodeElementsConstants.NopeValue) sb.Append(ts + comma);
            }

        return sb.ToString().TrimEnd(comma[0]);
    }
}