using SunamoEditorConfig._sunamo;

namespace SunamoEditorConfig;

public class RootBlock
{
    public List<Definition> Definitions { get; set; } = new List<Definition>();

    public static ResultWithExceptionEditorConfig<RootBlock> Parse(string block, List<string> lines)
    {
        var rootBlock = new RootBlock();

        if (lines == null) lines = StringHelper.GetLines(block);

        foreach (var line in lines)
        {
            if (line.Trim() == string.Empty) continue;
            var parts = StringHelper.Split(line, "=");

            if (parts.Count != 2)
                return new ResultWithExceptionEditorConfig<RootBlock> { Exception = "Unparseable line: \"" + line + "\"" };

            parts = ListHelper.Trim(parts);

            rootBlock.Definitions.Add(new Definition { Key = parts[0], Value = parts[1] });
        }

        return new ResultWithExceptionEditorConfig<RootBlock> { Result = rootBlock };
    }

    public override string ToString()
    {
        var sb = new StringBuilder();

        foreach (var definition in Definitions) sb.AppendLine(definition.ToString());

        return sb.ToString();
    }
}
