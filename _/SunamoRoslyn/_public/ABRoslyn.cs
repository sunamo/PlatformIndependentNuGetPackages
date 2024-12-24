namespace SunamoRoslyn._public;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

public class ABRoslyn
{
    public static Type type = typeof(ABRoslyn);
    public string A;
    public object B;

    public ABRoslyn(string a, object b)
    {
        A = a;
        B = b;
    }

    public static ABRoslyn Get(Type a, object b)
    {
        return new ABRoslyn(a.FullName, b);
    }

    /// <param name="a"></param>
    /// <param name="b"></param>
    public static ABRoslyn Get(string a, object b)
    {
        return new ABRoslyn(a, b);
    }

    public override string ToString()
    {
        return A + ":" + B;
    }
}