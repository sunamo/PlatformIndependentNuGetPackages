namespace SunamoRoslyn.Roslyns;

public class ProcessFileBoolResult
{
    public ProcessFileBoolResult()
    {

    }

    public bool indexed { get; set; } = false;
    public SyntaxTree tree { get; set;}
    public CompilationUnitSyntax root { get; set; }
}
