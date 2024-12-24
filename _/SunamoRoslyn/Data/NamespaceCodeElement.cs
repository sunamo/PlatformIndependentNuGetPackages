namespace SunamoRoslyn.Data;

    public class NamespaceCodeElement : CodeElement<NamespaceCodeElementsType>
    {
        public override string ToString()
        {
            return SourceCodeIndexerRoslyn.e2sNamespaceCodeElements[Type] + " " + Name;
        }
    }
