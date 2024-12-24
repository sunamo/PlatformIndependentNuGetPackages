namespace SunamoRoslyn._sunamo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal static class IDictionaryExtensions
{
    internal static void AddIfNotExists<T, U>(this IDictionary<T, U> d, T t, U u)
    {
        if (!d.ContainsKey(t)) d.Add(t, u);
    }
}