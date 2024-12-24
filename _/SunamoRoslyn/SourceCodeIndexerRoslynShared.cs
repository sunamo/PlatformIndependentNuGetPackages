namespace SunamoRoslyn;
using SunamoRoslyn._public;
using SunamoRoslyn._sunamo;
using static CsFileFilterRoslyn;

public partial class SourceCodeIndexerRoslyn
{


    /// <summary>
    /// used only in FileSystemWatcher
    /// </summary>
    /// <param name="file"></param>
    /// <param name="fromFileSystemWatcher"></param>
    public
#if ASYNC
            async Task ProcessFileAsync
#else
        void ProcessFile
#endif
            (string file, bool fromFileSystemWatcher)
    {
#if ASYNC
        await
#endif
                ProcessFile(file, NamespaceCodeElementsType.All, ClassCodeElementsType.All, false, fromFileSystemWatcher);
    }

    public bool IsToIndexedFolder(string pathFile, bool alsoEnds)
    {
        var uf = UnindexableFiles.uf;
        bool end2 = false;

        if (!CsFileFilterRoslyn.AllowOnly(pathFile, endArgs, containsArgs, ref end2, alsoEnds))
        {
            if (end2)
            {
                uf.unindexablePathEndsFiles.Add(pathFile);
            }
            else
            {
                uf.unindexablePathPartsFiles.Add(pathFile);
            }

            return false;
        }

        if (CA.StartWith(pathStarts, pathFile) != null)
        {
            uf.unindexablePathStartsFiles.Add(pathFile);

            return false;
        }

        return true;
    }

    public bool IsToIndexed(string pathFile)
    {
        #region All 4 for which is checked
        if (CA.ReturnWhichContainsIndexes(endsOther, pathFile, SearchStrategyRoslyn.FixedSpace).Count > 0)
        {
            return false;
        }

        var uf = UnindexableFiles.uf;

        var fn = Path.GetFileName(pathFile);
        if (CA.ReturnWhichContainsIndexes(fileNames, fn, SearchStrategyRoslyn.FixedSpace).Count > 0)
        {
            uf.unindexableFileNamesFiles.Add(pathFile);

            return false;
        }

        #endregion

        return IsToIndexedFolder(pathFile, true);
    }

    public bool isCallingIsToIndexed = false;

    internal static List<T> GetValues<T>()
      where T : struct
    {
        return GetValues<T>(false, true);
    }
    /// <summary>
    /// Get all values expect of Nope/None
    /// </summary>
    /// <typeparam name = "T"></typeparam>
    /// <param name = "type"></param>
    internal static List<T> GetValues<T>(bool IncludeNope, bool IncludeShared)
        where T : struct
    {
        var type = typeof(T);
        var values = Enum.GetValues(type).Cast<T>().ToList();
        T nope;
        if (!IncludeNope)
        {
            if (Enum.TryParse<T>(CodeElementsConstants.NopeValue, out nope))
            {
                values.Remove(nope);
            }
        }

        if (!IncludeShared)
        {
            if (type.Name == "MySites")
            {
                if (Enum.TryParse<T>("Shared", out nope))
                {
                    values.Remove(nope);
                }
            }
            else
            {
                if (Enum.TryParse<T>("Sha", out nope))
                {
                    values.Remove(nope);
                }
            }
        }

        if (Enum.TryParse<T>(CodeElementsConstants.NoneValue, out nope))
        {
            values.Remove(nope);
        }

        return values;
    }

    /// <summary>
    /// SourceCodeIndexerRoslyn.ProcessFile
    ///
    /// True if file wasnt indexed yet
    /// False is file was already indexed
    /// </summary>
    /// <param name = "pathFile"></param>
    /// <param name = "namespaceCodeElementsType"></param>
    /// <param name = "classCodeElementsType"></param>
    /// <param name = "tree"></param>
    /// <param name = "root"></param>
    /// <param name = "removeRegions"></param>
    private
#if ASYNC
        async Task<ProcessFileBoolResult> ProcessFileBool
#else
        ProcessFileBoolResult ProcessFileBool
#endif
        (string pathFile, NamespaceCodeElementsType namespaceCodeElementsType, ClassCodeElementsType classCodeElementsType, bool removeRegions, bool fromFileSystemWatcher)
    {
        SyntaxTree tree = null;
        CompilationUnitSyntax root = null;

        // A2 must be false otherwise read file twice
        if (!File.Exists(pathFile))
        {
            return new ProcessFileBoolResult();
        }

        if (!isCallingIsToIndexed)
        {
            if (!IsToIndexed(pathFile))
            {
                return new ProcessFileBoolResult();
            }
        }

        if (!linesWithContent.ContainsKey(pathFile) || isLoadingFromFile)
        {
            IList<NamespaceCodeElementsType> namespaceCodeElementsAll = EnumHelper.GetValues<NamespaceCodeElementsType>();
            IList<ClassCodeElementsType> classodeElementsAll = EnumHelper.GetValues<ClassCodeElementsType>();
            List<string> namespaceCodeElementsKeywords = new List<string>();
            List<string> classCodeElementsKeywords = new List<string>();
            string fileContent = string.Empty;

            var linesWithContent = SourceCodeIndexerRoslyn.Instance.linesWithContent;
            //var linesWithNonTextContent = SourceCodeIndexerRoslyn.Instance.linesWithNonTextContent;
            var linesWithIndexes = SourceCodeIndexerRoslyn.Instance.linesWithIndexes;

            List<string> lines = null;
            if (fromFileSystemWatcher)
            {
                lines = (
#if ASYNC
    await
#endif
 File.ReadAllLinesAsync(pathFile)).ToList();
            }
            else
            {
                if (File.Exists(pathFile))
                {
                    if (linesWithContent.ContainsKey(pathFile))
                    {
                        lines = linesWithContent[pathFile];

                        if (pathFile.EndsWith("\\.cs"))
                        {

                        }

                        var between = GetLinesBetween(linesWithIndexes[pathFile], true);

                        for (int i = 0; i < between.Count; i++)
                        {
                            lines.Insert(between[i], String.Empty);
                        }
                    }
                    else
                    {
                        (
#if ASYNC
                        await
#endif
                        File.ReadAllLinesAsync(pathFile)).ToList();
                    }
                }
            }

            fileContent = string.Join(Environment.NewLine, lines);
            //if (pathFile.EndsWith(@"\RunAutomatically2.cs"))
            //{
            //    var gf = CompareFilesPaths.GetFile(CompareExt.cs, 1);
            //    await File.WriteAllTextAsync(gf, fileContent);
            //}

            List<string> linesAll = lines; // SHGetLines.GetLines(fileContent);
            // nechápu proč to obaluji mezerou ale nevadí
            linesAll = CA.WrapWith(linesAll, " ").ToList();
            List<int> FullFileIndex = new List<int>();
            for (int i = linesAll.Count - 1; i >= 0; i--)
            {
                if (linesAll[i].Contains("dates.Clear()"))
                {

                }

                string item = linesAll[i];
                // nemůžu kontrolovat jen pokud nemá písmeno - do FasterStartup musím vložit i zárovky jinak bez nich nejsem schopen poskládat opět vstupní soubor
                //) //

                /*
Na jednu stranu potřebuji uložit výstupní soubor i se závorkami

                 */



                if (item.Trim() == String.Empty) //!SH.HasLetter(item))
                {
                    linesAll.RemoveAt(i);
                }
                else
                {
                    //var b1 = item.Trim() != String.Empty;
                    //if(b1)
                    //{

                    //}
                    // Přidám pokud má nějaké písmeno
                    FullFileIndex.Add(i);
                }
            }
            FullFileIndex.Reverse();
            ThrowEx.DifferentCountInLists("lines", linesAll.Count, "FullFileIndex", FullFileIndex.Count);
            // Probably was add on background again due to watch for changes
            if (this.linesWithContent.ContainsKey(pathFile))
            {
                this.linesWithContent.Remove(pathFile);
            }
            this.linesWithContent.Add(pathFile, linesAll);
            if (linesWithIndexes.ContainsKey(pathFile))
            {
                linesWithIndexes.Remove(pathFile);
            }

            // Přidám řádky jež mají nějaké písmeno
            linesWithIndexes.AddIfNotExists(pathFile, FullFileIndex);
            foreach (var item in namespaceCodeElementsAll)
            {
                if (namespaceCodeElementsType.HasFlag(item))
                {
                    namespaceCodeElementsKeywords.Add(SH.WrapWith(item.ToString().ToLower(), " "));
                }
            }

            foreach (var item in namespaceCodeElementsKeywords)
            {
                string elementTypeString = item.Trim();
                NamespaceCodeElementsType namespaceCodeElementType = (NamespaceCodeElementsType)Enum.Parse(namespaceCodeElementsType2, item, true);
                List<int> indexes;
                List<string> linesCodeElements = CA.ReturnWhichContains(linesAll, item, out indexes);
                for (int i = 0; i < linesCodeElements.Count; i++)
                {
                    var lineCodeElements = linesCodeElements[i];
                    string namespaceElementName = SH.WordAfter(lineCodeElements, e2sNamespaceCodeElements[namespaceCodeElementType]);
                    if (namespaceElementName.Length > 1)
                    {
                        if (char.IsUpper(namespaceElementName[0]))
                        {
                            NamespaceCodeElement element = new NamespaceCodeElement()
                            { Index = FullFileIndex[indexes[i]], Name = namespaceElementName, Type = namespaceCodeElementType };
                            DictionaryHelper.AddOrCreate<string, NamespaceCodeElement>(namespaceCodeElements, pathFile, element);
                        }
                    }
                }
            }

            ClassCodeElementsType classCodeElementsTypeToFind = ClassCodeElementsType.All;
            if (classCodeElementsType.HasFlag(ClassCodeElementsType.All))
            {
                classCodeElementsTypeToFind |= ClassCodeElementsType.Method;
            }

            tree = CSharpSyntaxTree.ParseText(fileContent);
            root = (CompilationUnitSyntax)tree.GetRoot();
            var c = classCodeElements;
            var ns = root.DescendantNodes();
            IList<NamespaceDeclarationSyntax> namespaces = ns.OfType<NamespaceDeclarationSyntax>().ToList();
            foreach (var nameSpace in namespaces)
            {
                if (classCodeElementsTypeToFind.HasFlag(ClassCodeElementsType.Method))
                {
                    var ancestor = nameSpace;
                    AddMethodsFrom(ancestor, pathFile);
                }
            }
            AddMethodsFrom(root, pathFile);
            return new ProcessFileBoolResult { indexed = true, tree = tree, root = root };
        }

        return new ProcessFileBoolResult();
    }

    private List<int> GetLinesBetween(List<int> i2, bool fromZeroIndex)
    {
        List<int> l = new List<int>();
        i2.Sort();

        if (fromZeroIndex)
        {
            if (i2[0] != 0)
            {
                i2.Insert(0, 0);
            }
        }

        for (int i = 0; i < i2.Count - 1; i++)
        {
            var a1 = i2[i] + 1;
            var a2 = i2[i + 1];
            if (a1 != a2)
            {
                for (int y = a1; y < a2; y++)
                {
                    l.Add(y);
                }
            }
        }

        return l;
    }
}