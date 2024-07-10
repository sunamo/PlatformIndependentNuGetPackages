namespace SunamoWikipedia._sunamo.SunamoExceptions.InSunamoIsDerivedFrom;


internal class TFSE
{
    internal static string ReadAllTextSync(string path)
    {
        return ReadAllTextSync(path, false);
    }
    internal static string ReadAllTextSync(string path, bool createEmptyIfWasNotExists = false)
    {
        if (createEmptyIfWasNotExists)
            if (!File.Exists(path))
            {
                WriteAllTextSync(path, string.Empty);
                return string.Empty;
            }
        return File.ReadAllText(path);
    }
    internal static void WriteAllTextSync(string path, string content)
    {
        File.WriteAllText(path, content);
    }
    internal static void AppendAllTextSync(string path, string content)
    {
        File.AppendAllText(path, content);
    }
    internal static List<string> ReadAllLinesSync(string path)
    {
        return ReadAllLinesSync(path, false);
    }
    internal static List<string> ReadAllLinesSync(string path, bool createEmptyIfWasNotExists = false)
    {
        if (createEmptyIfWasNotExists)
            if (!File.Exists(path))
            {
                WriteAllTextSync(path, string.Empty);
                return new List<string>();
            }
        return SHGetLines.GetLines(File.ReadAllText(path));
    }
    internal static void WriteAllLinesSync(string path, List<string> content)
    {
        File.WriteAllLines(path, content.ToArray());
    }
    internal static void AppendAllLinesSync(string path, List<string> content)
    {
        File.AppendAllLines(path, content.ToArray());
    }
    internal static List<byte> ReadAllBytesSync(string path)
    {
        return File.ReadAllBytes(path).ToList();
    }
    internal static void WriteAllBytesSync(string path, List<byte> content)
    {
        File.WriteAllBytes(path, content.ToArray());
    }
    internal static Func<string, bool> isUsed = null;
    #region
    protected static bool LockedByBitLocker(string path)
    {
        return ThrowEx.LockedByBitLocker(path);
    }
    internal static
#if ASYNC
        async Task<string>
#else
string
#endif
        ReadAllText(string path, Encoding enc)
    {
        if (isUsed != null)
            if (isUsed.Invoke(path))
                return string.Empty;
#if ASYNC
        //TFSE.await WaitD();
#endif
        //return enc == null ? File.ReadAllText(path) : File.ReadAllText(path, enc);
#if ASYNC
        return await File.ReadAllTextAsync(path, enc);
#else
return File.ReadAllText(path, enc);
#endif
    }
    #region Array
    internal static
#if ASYNC
        async Task
#else
void
#endif
        WriteAllLinesArray(string path, string[] c)
    {
#if ASYNC
        await
#endif
            WriteAllLines(path, c.ToList());
    }
    internal static
#if ASYNC
        async Task
#else
void
#endif
        WriteAllBytesArray(string path, byte[] c)
    {
#if ASYNC
        await
#endif
            WriteAllBytes(path, c.ToList());
    }
    internal static
#if ASYNC
        async Task<byte[]>
#else
byte[]
#endif
        ReadAllBytesArray(string path)
    {
        return (
#if ASYNC
            await
#endif
                ReadAllBytes(path)).ToArray();
    }
    #endregion
    #region Bytes
    /// <summary>
    ///     Only one method where could be TFSE.ReadAllBytes
    /// </summary>
    /// <param name="file"></param>
    /// <returns></returns>
    internal static
#if ASYNC
        async Task<List<byte>>
#else
List<byte>
#endif
        ReadAllBytes(string file)
    {
        if (LockedByBitLocker(file)) return new List<byte>();
#if ASYNC
        //await WaitD();
#endif
        return
#if ASYNC
            (await File.ReadAllBytesAsync(file)).ToList();
#else
File.ReadAllBytes(file).ToList();
#endif
    }
    internal static
#if ASYNC
        async Task
#else
void
#endif
        WriteAllBytes(string file, List<byte> b)
    {
        if (LockedByBitLocker(file)) return;
#if ASYNC
        await File.WriteAllBytesAsync(file, b.ToArray());
#else
File.WriteAllBytes(file, b.ToArray());
#endif
    }
    #endregion
    #region Lines
    internal static
#if ASYNC
        async Task
#else
void
#endif
        WriteAllLines(string file, IList<string> lines)
    {
        if (LockedByBitLocker(file)) return;
#if ASYNC
        await File.WriteAllLinesAsync
#else
File.WriteAllLines
#endif
            (file, lines.ToArray());
    }
    internal static
#if ASYNC
        async Task<List<string>>
#else
List<string>
#endif
        ReadAllLines(string file, bool trim = true)
    {
        if (LockedByBitLocker(file)) return new List<string>();
#if ASYNC
        //await WaitD();
#endif
        var result = SHGetLines.GetLines(
#if ASYNC
            (await File.ReadAllTextAsync(file)).ToList();
#else
File.ReadAllText(file));
#endif
        if (trim) result = result.Where(d => !string.IsNullOrWhiteSpace(d)).ToList();
        return result;
    }
    #endregion
    #region Text
    internal static
#if ASYNC
        async Task
#else
void
#endif
        WriteAllText(string path, string content)
    {
        if (LockedByBitLocker(path)) return;
#if ASYNC
        await File.WriteAllTextAsync(path, content);
#else
File.WriteAllText(path, content);
#endif
    }
    internal static
#if ASYNC
        async Task<string>
#else
string
#endif
        ReadAllText(string f)
    {
        if (LockedByBitLocker(f)) return string.Empty;
#if ASYNC
        //await WaitD();
#endif
        try
        {
#if ASYNC
            return await File.ReadAllTextAsync(f);
#else
return File.ReadAllText(f);
#endif
        }
        catch (Exception)
        {
            return string.Empty;
        }
    }
    internal static
#if ASYNC
        async Task
#else
void
#endif
        AppendAllText(string path, string content)
    {
        if (LockedByBitLocker(path)) return;
#if ASYNC
        //await WaitD();
#endif
        try
        {
#if ASYNC
            await File.AppendAllTextAsync(path, content);
#else
File.AppendAllText(path, content);
#endif
        }
        catch (Exception)
        {
        }
    }
    #endregion
    #endregion
#if ASYNC
    internal static async Task<string> WaitD()
    {
        /*
        Vůbec nevím proč tu mám tuto metodu
        ale protože WaitD jsem volal na více místech, nechám tu metodu tu jako prázdnou
        */
        return await Task.Run(() => "");
    }
#endif
}