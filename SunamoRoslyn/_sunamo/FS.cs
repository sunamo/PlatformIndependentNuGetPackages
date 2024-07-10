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
namespace SunamoRoslyn._sunamo;
internal class FS
{
    internal static string ChangeFilename(string item, string newFileNameWithoutPath, bool physically)
    {
        string cesta = Path.GetDirectoryName(item);
        string nova = Path.Combine(cesta, newFileNameWithoutPath);
        if (physically)
        {
            try
            {
                if (File.Exists(nova))
                {
                    File.Delete(nova);
                }
                File.Move(item, nova);
            }
            catch
            {
            }
        }
        return nova;
    }
}
