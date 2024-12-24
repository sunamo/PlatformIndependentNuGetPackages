namespace SunamoRoslyn._sunamo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal class UnindexableFiles
{
    internal static UnindexableFiles uf = new UnindexableFiles();

    private UnindexableFiles()
    {
    }

    internal List<string> unindexablePathPartsFiles = new List<string>();
    internal List<string> unindexableFileNamesFiles = new List<string>();
    internal List<string> unindexableFileNamesExactlyFiles = new List<string>();
    internal List<string> unindexablePathEndsFiles = new List<string>();
    internal List<string> unindexablePathStartsFiles = new List<string>();
}
