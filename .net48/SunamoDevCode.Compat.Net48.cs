// Net48 compat: net48 nema File.ReadAllTextAsync/WriteAllTextAsync a string.Join(char, ...), SHJoin.cs je z wrapperu vyloucen.
using System.Threading.Tasks;

namespace SunamoDevCode._sunamo
{
    /// <summary>Net48 nahrada SHJoin.cs (string.Join s char separatorem v net48 neexistuje).</summary>
    internal class SHJoin
    {
        /// <summary>Spoji polozky seznamu znakem LF.</summary>
        internal static string JoinNL<T>(List<T> list)
        {
            return string.Join("\n", list.ConvertAll(item => item.ToString()));
        }

        /// <summary>Spoji retezce znakem LF.</summary>
        internal static string JoinNL(List<string> list) => string.Join("\n", list);
    }
}

namespace SunamoDevCode._sunamo.SunamoCollectionOnDrive
{
    /// <summary>Net48 shim za System.IO.File doplnujici async metody chybejici v net48 (v tomto namespace ma prednost pred System.IO.File).</summary>
    internal static class File
    {
        /// <summary>Vrati, zda soubor existuje.</summary>
        internal static bool Exists(string path) => System.IO.File.Exists(path);

        /// <summary>Precte cely soubor jako text (net48 nahrada za File.ReadAllTextAsync).</summary>
        internal static Task<string> ReadAllTextAsync(string path) => Task.Run(() => System.IO.File.ReadAllText(path));

        /// <summary>Zapise text do souboru (net48 nahrada za File.WriteAllTextAsync).</summary>
        internal static Task WriteAllTextAsync(string path, string contents) => Task.Run(() => System.IO.File.WriteAllText(path, contents));
    }
}
