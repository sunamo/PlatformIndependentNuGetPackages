using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
namespace SunamoRuleset._sunamo;
internal class EnumHelper
{
    internal static T Parse<T>(string web, T _def, bool returnDefIfNull = false)
        where T : struct
    {
        if (returnDefIfNull)
        {
            return _def;
        }
        T result;
        if (Enum.TryParse<T>(web, true, out result))
        {
            return result;
        }
        return _def;
    }
}
