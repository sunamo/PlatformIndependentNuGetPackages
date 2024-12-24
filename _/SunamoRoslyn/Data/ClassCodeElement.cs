namespace SunamoRoslyn.Data;

public class ClassCodeElement : CodeElement<ClassCodeElementsType>
{
    public override string ToString()
    {
        return SourceCodeIndexerRoslyn.e2sClassCodeElements[Type] + " " + Name;
    }
}
