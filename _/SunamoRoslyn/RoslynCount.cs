namespace SunamoRoslyn;

public class RoslynCount
{

    public Type type = typeof(RoslynCount);
    /// <summary>
    /// Methods()
    /// </summary>
    public int after2, before2;
    /// <summary>
    /// Members
    /// </summary>
    public int before, after;
    public void FillBefore(ClassDeclarationSyntax cl2_2)
    {
        before = cl2_2.Members.Count;
        before2 = ChildNodes.Methods(cl2_2).Count();
    }
    public void FillAfter(ClassDeclarationSyntax cl2_2)
    {
        after = cl2_2.Members.Count;
        after2 = ChildNodes.Methods(cl2_2).Count();
    }
    public void Log(string operation)
    {
        Console.WriteLine(operation + $": Before members {before}, methods {before2}");
        Console.WriteLine(operation + $": After members {after}, methods {after2}");
    }
    public void ThrowException()
    {
        //string methodName = "ThrowException";
        //// Members
        //ThrowEx.ElementWasntRemoved( "removing class members", before, after);
        //// Methods
        //ThrowEx.ElementWasntRemoved( "removing class methods", before2, after2);
    }
}
