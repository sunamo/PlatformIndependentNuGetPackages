namespace SunamoDotnetCmdBuilder;

public class DotnetCmdBuilder
{
    StringBuilder sb = new StringBuilder();

    public void Cd(string path)
    {
        sb.AppendLine("cd " + path);
    }

    public void AddPackage(string projectPathOrName, string packageName)
    {
        sb.AppendLine($"dotnet add {projectPathOrName} package {packageName}");
    }

    public override string ToString()
    {
        return sb.ToString();
    }
}
