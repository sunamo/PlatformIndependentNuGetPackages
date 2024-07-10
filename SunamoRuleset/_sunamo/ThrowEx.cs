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
internal class ThrowEx
{
    internal static void Custom(string v)
    {
        throw new Exception(v);
    }
    internal static void NotImplementedCase<T>(T rtype)
    {
        throw new Exception("NotImplementedCase: " + rtype);
    }
    internal static void NotImplementedMethod()
    {
        throw new Exception("NotImplementedMethod");
    }
}
