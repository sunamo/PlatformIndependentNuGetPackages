namespace SunamoRoslyn;
public class Class1
{
    static void Main()
    {
        var code = @"
                using System;
                using System.Collections.Generic;
                using System.Linq;
                using System.Text;
                namespace HelloWorld
                {
                    public class MyAwesomeModel
                    {
                        public string MyProperty {get;set;}
                        public int MyProperty1 {get;set;}
                    }
                }";
        var tree = CSharpSyntaxTree.ParseText(code);
        var root = (CompilationUnitSyntax)tree.GetRoot();
        var modelCollector = new ModelCollector();
        modelCollector.Visit(root);
        //Console.WriteLine(JsonSerializer.Serialize(modelCollector.Models));
    }
}
