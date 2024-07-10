namespace SunamoHttp._sunamo.SunamoFileIO;
internal class TF
{
    internal static string ReadAllText(string path)
    {
        return File.ReadAllText(path);
    }

    internal static void WriteAllBytes(string path, byte[] c)
    {
        File.WriteAllBytes(path, c);
    }
}
