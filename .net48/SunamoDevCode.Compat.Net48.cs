// Net48 compat: net48 has no File.ReadAllTextAsync/WriteAllTextAsync and string.Join(char, ...), SHJoin.cs is excluded from the wrapper.
using System.Threading.Tasks;

namespace SunamoDevCode._sunamo
{
    /// <summary>Net48 replacement for SHJoin.cs (string.Join with a char separator does not exist in net48).</summary>
    internal class SHJoin
    {
        /// <summary>Joins list items with the LF character.</summary>
        internal static string JoinNL<T>(List<T> list)
        {
            return string.Join("\n", list.ConvertAll(item => item.ToString()));
        }

        /// <summary>Joins strings with the LF character.</summary>
        internal static string JoinNL(List<string> list) => string.Join("\n", list);
    }
}

namespace SunamoDevCode._sunamo.SunamoCollectionOnDrive
{
    /// <summary>Net48 shim for System.IO.File adding async methods missing in net48 (takes precedence over System.IO.File in this namespace).</summary>
    internal static class File
    {
        /// <summary>Returns whether the file exists.</summary>
        internal static bool Exists(string path) => System.IO.File.Exists(path);

        /// <summary>Reads the whole file as text (net48 replacement for File.ReadAllTextAsync).</summary>
        internal static Task<string> ReadAllTextAsync(string path) => Task.Run(() => System.IO.File.ReadAllText(path));

        /// <summary>Writes text to a file (net48 replacement for File.WriteAllTextAsync).</summary>
        internal static Task WriteAllTextAsync(string path, string contents) => Task.Run(() => System.IO.File.WriteAllText(path, contents));
    }
}
