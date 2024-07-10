using SunamoEditorConfig._sunamo;

namespace SunamoEditorConfig;

public class MascBlock : RootBlock
{
    private string ValidFor { get; set; }

    public static bool IsLineWithMasc(string text)
    {
        text = text.Trim();
        return text.StartsWith(Consts.SquareBracketStart) && text.EndsWith(Consts.SquareBracketEnd);
    }

    public static ResultWithExceptionEditorConfig<MascBlock> Parse(string block)
    {
        var lines = StringHelper.GetLines(block);
        var otherLines = lines.Skip(1).ToList();

        var definitions = Parse(null, otherLines);

        if (definitions.Exception != null)
            return new ResultWithExceptionEditorConfig<MascBlock> { Exception = definitions.Exception };

        return new ResultWithExceptionEditorConfig<MascBlock>
        {
            Result = new MascBlock
            {
                ValidFor = StringHelper.BetweenFirstAndSecondChar(lines.First()),
                Definitions = definitions.Result.Definitions
            }
        };
    }

    public override string ToString()
    {
        var sb = new StringBuilder();

        sb.AppendLine(Consts.SquareBracketStart + ValidFor + Consts.SquareBracketEnd);

        foreach (var definition in Definitions) sb.AppendLine(definition.ToString());

        return sb.ToString();
    }
}
