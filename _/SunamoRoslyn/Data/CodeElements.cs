namespace SunamoRoslyn.Data;

    public class CodeElements
    {
    /// <summary>
    /// Používá se 2x v DoSearch v Everyline a poté ji vrací společně s classes SourceCodeIndexerRoslyn.cs
    /// 
    /// </summary>
        public Dictionary<string, NamespaceCodeElements> namespaces = new Dictionary<string, NamespaceCodeElements>();
    /// <summary>
    /// Používá se 2x v DoSearch v Everyline a poté ji vrací společně s namespacema SourceCodeIndexerRoslyn.cs
    /// </summary>
        public Dictionary<string, ClassCodeElements> classes = new Dictionary<string, ClassCodeElements>();
    }
