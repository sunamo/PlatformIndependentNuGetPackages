namespace SunamoSerializer;

public static class SF
{
    private static SerializeContentArgs s_contentArgs = new SerializeContentArgs();
    //CASH
    public static List<string> ParseUpToRequiredElementsLine(string input, int requiredCount)
    {
        var p = SF.GetAllElementsLine(input);
        if (p.Count > requiredCount)
        {
            throw new Exception($"p have {p.Count} elements, max is {requiredCount}");
        }
        else if (p.Count < requiredCount)
        {
            for (int i = p.Count - 1; i < requiredCount; i++)
            {
                p.Add(string.Empty);
            }
        }

        return p;
    }

    static Tuple<string, string, string> t => Exc.GetStackTrace2(true);

    public static Dictionary<T1, T2> ToDictionary<T1, T2>(List<List<string>> l)
    {
        object s1 = BTS.MethodForParse<T1>();
        object s2 = BTS.MethodForParse<T2>();

        Func<string, T1> p1 = (Func<string, T1>)s1;
        Func<string, T2> p2 = (Func<string, T2>)s2;

        Dictionary<T1, T2> dict = new Dictionary<T1, T2>();

        T1 t1 = default(T1);
        T2 t2 = default(T2);

        Dictionary<int, List<string>> whereIsNotTwoEls = new Dictionary<int, List<string>>();

        int i = -1;

        foreach (List<string> item in l)
        {
            i++;

            if (item.Count != 2)
            {
                whereIsNotTwoEls.Add(i, item);
                continue;
            }

            t1 = p1.Invoke(item[0]);
            t2 = p2.Invoke(item[1]);
            dict.Add(t1, t2);
        }

        foreach (var item in whereIsNotTwoEls)
        {
            var l2 = item.Value.ToList();
            l2.Insert(0, item.Key.ToString());
            //DebugLogger.Instance.WriteListOneRow(l2, AllStrings.swd);
        }

        if (whereIsNotTwoEls.Count != 0)
        {

        }

        return dict;
    }

    public static string separatorString
    {
        get
        {
            return s_contentArgs.separatorString;
        }

        set
        {
            s_contentArgs.separatorString = value;
        }
    }

    /// <summary>
    /// Without last |
    /// </summary>
    /// <param name="o"></param>
    /// <param name="p1"></param>
    /// <returns></returns>
    public static string PrepareToSerializationExplicitString(IList o, string p1 = AllStrings.verbar)
    {
        //var o3 = new List<string>(o);
        //var o2 = CA.Trim(o3);
        string vr = string.Join(p1, o);
        return vr;
        //return vr.Substring(0, vr.Length - p1.Length);
    }

    /// <summary>
    /// Without last |
    /// If need to combine string and IList, lets use CA.Join
    /// DateTime is format with DTHelperEn.ToString
    /// </summary>
    /// <param name="p1"></param>
    /// <param name="o"></param>
    public static string PrepareToSerializationExplicit(IList o, string p1 = AllStrings.verbar)
    {

        return PrepareToSerializationExplicitString(o, p1.ToString());
    }

    /// <summary>
    /// In inner array is elements, in outer lines.
    /// </summary>
    /// <param name="file"></param>
    /// <returns></returns>
    public static List<List<string>> GetAllElementsFile(string file)
    {
        string firstLine = null;
        return GetAllElementsFile(file, ref firstLine);
    }


    public static List<string> RemoveComments(List<string> tf)
    {
        //CASH.RemoveStringsEmpty2(tf);

        tf = tf.Where(d => !string.IsNullOrWhiteSpace(d)).ToList();

        // Nevím vůbec co toto má znamenat ael nedává mi to smysl
        // Příště dopsat komentář pokud budu odkomentovávat
        //if (tf.Count > 0)
        //{
        //    if (tf[0].StartsWith(AllStrings.num))
        //    {
        //        return tf[0];
        //    }
        //}


        //CASH.RemoveStartingWith(AllStrings.num, tf);

        tf = tf.Where(d => !d.StartsWith(AllStrings.num)).ToList();
        return tf;

    }

    public static List<List<string>> GetAllElementsFile(string file, ref string firstCommentLine, string oddelovaciZnak = AllStrings.verbar)
    {

        var (header, rows) = GetAllElementsFileAdvanced(file, oddelovaciZnak);
        if (header.Count > 0)
        {
            rows.Insert(0, header);
        }

        return rows;
    }

    public static
#if ASYNC
        async Task
#else
    void
#endif
        Dictionary<T1, T2>(string file, Dictionary<T1, T2> artists)
    {
        StringBuilder sb = new StringBuilder();
        foreach (var item in artists)
        {
            sb.AppendLine(PrepareToSerialization(item.Key.ToString(), item.Value.ToString()));
        }


#if ASYNC
        await
#endif
            File.WriteAllTextAsync(file, sb.ToString());
    }

    public static void WriteAllElementsToFile<Key, Value>(string coolPeopleShortcuts, Dictionary<Key, Value> d2)
    {
        List<List<string>> list = ListFromDictionary(d2);
        WriteAllElementsToFile(coolPeopleShortcuts, list);
    }

    public static async Task WriteAllElementsToFile(string VybranySouborLogu, List<List<string>> p)
    {
        StringBuilder sb = new StringBuilder();
        foreach (var item in p)
        {
            sb.AppendLine(PrepareToSerialization2(item));
        }

        await File.WriteAllTextAsync(VybranySouborLogu, sb.ToString());
    }

    public static List<List<string>> ListFromDictionary<Key, Value>(Dictionary<Key, Value> d2)
    {
        List<List<string>> vs = new List<List<string>>();
        foreach (var item in d2)
        {
            vs.Add([item.Key.ToString(), item.Value.ToString()]);
        }
        return vs;
    }

    /// <summary>
    /// Without last |
    /// DateTime is format with DTHelperEn.ToString
    /// </summary>
    /// <param name="o"></param>
    /// <param name="separator"></param>
    public static string PrepareToSerialization2(IList<string> o)
    {
        return PrepareToSerializationWorker(o, true, dDeli);
    }



    ///// <summary>
    ///// Return without last
    ///// DateTime is serialize always in english format
    ///// Opposite method: DTHelperEn.ToString<>DTHelperEn.ParseDateTimeUSA
    ///// </summary>
    ///// <param name="pr"></param>
    //public static string PrepareToSerialization2(params string[] pr)
    //{
    //    var ts = new List<string>(pr);
    //    return PrepareToSerializationWorker(ts, true, separatorString);
    //}

    /// <summary>
    /// Return without last
    /// If need to combine string and IList, lets use CA.Join
    /// </summary>
    /// <param name = "o"></param>
    public static string PrepareToSerializationExplicit2(IList<string> o, string separator = AllStrings.verbar)
    {
        return PrepareToSerializationWorker(o, true, separator);
    }

    public static
#if ASYNC
        async Task
#else
    void
#endif
        DictionaryAppend(string v, Dictionary<int, string> toSave)
    {
        var c = await File.ReadAllTextAsync(v);
        var s = ListFromDictionary<int, string>(toSave);
        var s2 = ToDictionary<int, string>(s);

        StringBuilder sb = new StringBuilder();
        foreach (var item in s2)
        {
            sb.AppendLine(SF.PrepareToSerialization(item.Key.ToString(), item.Value));
        }

#if ASYNC
        await
#endif
            File.AppendAllTextAsync(v, sb.ToString() + Environment.NewLine);
    }

    public static int keyCodeSeparator
    {
        get
        {
            return (int)s_contentArgs.separatorChar;
        }
    }

    /// <summary>
    /// Must be property - I can forget change value on three occurences.
    /// </summary>
    public static char separatorChar
    {
        get
        {
            return s_contentArgs.separatorChar;
        }
    }

    static SF()
    {
        s_contentArgs.separatorString = AllStrings.verbar;
    }

    /// <param name = "element"></param>
    /// <param name = "line"></param>
    /// <param name = "elements"></param>
    private static string GetElementAtIndex(List<List<string>> elements, int element, int line)
    {
        if (elements.Count > line)
        {
            var lineElements = elements[line];
            if (lineElements.Count > element)
            {
                return lineElements[element];
            }
        }

        return null;
    }



    public static
#if ASYNC
        async Task<List<List<string>>>
#else
 List<List<string>>
#endif
        AppendAllText(string path, string line)
    {
        var content = SHGetLines.GetLines(
#if ASYNC
            await
#endif
                File.ReadAllTextAsync(path)).ToList();
        CASE.Trim(content);
        //content += Environment.NewLine + line + Environment.NewLine;
        content.Add(line);

        var vr = GetAllElementsLines(content);


#if ASYNC
        await
#endif
            File.WriteAllLinesAsync(path, content);

        return vr;
    }

    private static List<List<string>> GetAllElementsLines(List<string> lines)
    {
        string firstLine = null;
        return GetAllElementsLines(lines, ref firstLine);
    }

    private static List<List<string>> GetAllElementsLines(List<string> lines, ref string firstLIne)
    {
        lines = SF.RemoveComments(lines);

        List<List<string>> vr = new List<List<string>>();
        foreach (string var in lines)
        {
            if (!string.IsNullOrWhiteSpace(var))
            {
                vr.Add(SF.GetAllElementsLine(var));
            }
        }
        return vr;
    }

    /// <summary>
    /// If index won't founded, return null.
    /// </summary>
    /// <param name = "element"></param>
    /// <param name = "line"></param>
    public static string GetElementAtIndexFile(string file, int element, int line)
    {
        List<List<string>> elements = GetAllElementsFile(file);
        return GetElementAtIndex(elements, element, line);
    }

    /// <summary>
    /// G null if first element on any lines A2 dont exists
    /// </summary>
    /// <param name = "file"></param>
    /// <param name = "element"></param>
    public static List<string> GetFirstWhereIsFirstElement(string file, string element)
    {
        List<List<string>> elementsLines = SF.GetAllElementsFile(file);
        for (int i = 0; i < elementsLines.Count; i++)
        {
            if (elementsLines[i][0] == element)
            {
                return elementsLines[i];
            }
        }

        return null;
    }

    /// <summary>
    /// G null if first element on any lines A2 dont exists
    /// </summary>
    /// <param name = "file"></param>
    /// <param name = "element"></param>
    public static List<string> GetLastWhereIsFirstElement(string file, string element)
    {
        List<List<string>> elementsLines = SF.GetAllElementsFile(file);
        for (int i = elementsLines.Count - 1; i >= 0; i--)
        {
            if (elementsLines[i][0] == element)
            {
                return elementsLines[i];
            }
        }

        return null;
    }





    /// <summary>
    /// Read text with first delimitech which automatically delimite
    /// </summary>
    /// <param name="fileNameOrPath"></param>
    public static void ReadFileOfSettingsOther(string fileNameOrPath)
    {
        // COmmented, app data not should be in *.web. pass directly as arg
        List<string> lines = null;
        //SHGetLines.GetLines(AppData.ci.ReadFileOfSettingsOther(fileNameOrPath));
        if (lines.Count > 1)
        {
            int delimiterInt;
            if (int.TryParse(lines[0], out delimiterInt))
            {
                separatorString = ((char)delimiterInt).ToString();
            }
        }
    }

    public static async Task WriteAllElementsToFile(string VybranySouborLogu, List<string>[] p)
    {
        StringBuilder sb = new StringBuilder();
        foreach (List<string> item in p)
        {
            sb.AppendLine(PrepareToSerialization2(item));
        }

        await File.WriteAllTextAsync(VybranySouborLogu, sb.ToString());
    }

    static Type type = typeof(SF);

    public const string replaceForSeparatorString = AllStrings.lowbar;
    public static readonly char replaceForSeparatorChar = AllChars.lowbar;
    public static string dDeli = "|";


    /// <summary>
    /// Without last |
    /// DateTime is format with DTHelperEn.ToString
    /// </summary>
    /// <param name="o"></param>
    public static string PrepareToSerialization(params string[] o)
    {
        return PrepareToSerializationWorker(o.ToList(), true, dDeli);
    }

    ///// <summary>
    ///// Return without last
    ///// DateTime is serialize always in english format
    ///// Opposite method: DTHelperEn.ToString<>DTHelperEn.ParseDateTimeUSA
    ///// </summary>
    ///// <param name="pr"></param>
    //public static string PrepareToSerialization2(params string[] pr)
    //{
    //    var ts = new List<string>(pr);
    //    return PrepareToSerializationWorker(ts, true, separatorString);
    //}

    /// <summary>
    ///
    /// DateTime is format with DTHelperEn.ToString
    /// </summary>
    /// <param name="o"></param>
    /// <param name="removeLast"></param>
    /// <param name="separator"></param>
    private static string PrepareToSerializationWorker(IList<string> o, bool removeLast, string separator)
    {
        var list = o.ToList();
        if (separator == replaceForSeparatorString)
        {
            throw new Exception("replaceForSeparatorString is the same as separator");
        }
        CASH.Replace(list, separator, replaceForSeparatorString);
        CASH.Replace(list, Environment.NewLine, AllStrings.space);
        CASE.Trim(list);
        string vr = string.Join(separator.ToString(), list);

        if (removeLast)
        {
            if (vr.Length > 0)
            {
                return vr.Substring(0, vr.Length - 1);
            }
        }

        return vr;
    }

    /// <summary>
    ///     Get all elements from A1
    ///     A2 byl object ale dal jsem ho jako string
    ///     nemůžu to dávat jako object protože SHSplit.Split musí být typový. Např. když mám allWhiteChars který je List
    ///     <object> a po přenesení do params string[] mi vytvoří new string[]{}
    /// </summary>
    /// <param name="var"></param>
    public static List<string> GetAllElementsLine(string var, string oddelovaciZnak = null)
    {
        if (oddelovaciZnak == null)
        {
            oddelovaciZnak = AllStrings.verbar;
        }
        // Musí tu být none, protože pak když někde nic nebylo, tak mi to je nevrátilo a progran vyhodil IndexOutOfRangeException
        return SHSplit.Split(var, oddelovaciZnak);
    }



    /// <summary>
    ///     In result A1 is not
    /// </summary>
    /// <param name="file"></param>
    /// <param name="hlavicka"></param>
    /// <param name="oddelovaciZnak"></param>
    public static (List<string> header, List<List<string>> rows)
        GetAllElementsFileAdvanced(string file,
            string oddelovaciZnak = "|")
    {
        if (oddelovaciZnak == null)
        {
            oddelovaciZnak = "|";
        }

        var hlavicka = new List<string>();
        string oz = oddelovaciZnak.ToString();
        List<List<string>> vr = new List<List<string>>();
        // Sync protože mám v deklaraci out
        List<string> lines = SHGetLines.GetLines(File.ReadAllText(file));
        CASE.Trim(lines);
        if (lines.Count > 0)
        {
            hlavicka = GetAllElementsLine(lines[0], oddelovaciZnak);
            int musiByt = lines[0].Split(new string[] { oz }, StringSplitOptions.None).Length - 1;
            //int nalezeno = 0;
            StringBuilder jedenRadek = new StringBuilder();

            for (int i = 1; i < lines.Count; i++)
            {
                if (lines[i].Trim().Length == 0)
                {
                    continue;
                }
                //nalezeno += SH.OccurencesOfStringIn(lines[i], oz);
                jedenRadek.AppendLine(lines[i]);
                //if (nalezeno == musiByt)
                //{
                //nalezeno = 0;
                List<string> columns = GetAllElementsLine(jedenRadek.ToString(), oddelovaciZnak);
                CASE.Trim(columns);
                jedenRadek.Clear();

                vr.Add(columns);
                //}
            }
        }

        return (hlavicka, vr);
    }
}
