using SunamoEditorConfig._sunamo;

namespace SunamoEditorConfig;

public static class EditorConfigHelper
{
    public static string Serialize(string path, EditorConfigContent content, string newLine)
    {
        var serialized = content.ToString();

        if (Environment.NewLine != newLine) serialized = serialized.Replace(Environment.NewLine, newLine);

        serialized = serialized.Trim();

        if (path != null) File.WriteAllText(path, serialized);

        return serialized;
    }

    public static ResultWithExceptionEditorConfig<EditorConfigContent> Deserialize(string path, string text)
    {
        if (text == null) text = File.ReadAllText(path);

        var lines = StringHelper.GetLines(text);

        var blocks = new List<string>();

        var sb = new StringBuilder();

        foreach (var line in lines)
        {
            if (MascBlock.IsLineWithMasc(line))
            {
                blocks.Add(sb.ToString());

                sb = new StringBuilder();
            }

            sb.AppendLine(line);
        }

        blocks.Add(sb.ToString());

        RootBlock rootBlock = null;
        var mascBlocks = new List<MascBlock>();

        foreach (var block in blocks)
            if (MascBlock.IsLineWithMasc(StringHelper.GetLines(block).First()))
            {
                var mascBlock = MascBlock.Parse(block);
                if (mascBlock.Exception != null)
                    return new ResultWithExceptionEditorConfig<EditorConfigContent> { Exception = mascBlock.Exception };

                mascBlocks.Add(mascBlock.Result);
            }
            else
            {
                var rootBlockResult = RootBlock.Parse(block, null);

                if (rootBlockResult.Exception != null)
                    return new ResultWithExceptionEditorConfig<EditorConfigContent> { Exception = rootBlockResult.Exception };

                rootBlock = rootBlockResult.Result;
            }

        return new ResultWithExceptionEditorConfig<EditorConfigContent>
        { Result = new EditorConfigContent { MascBlocks = mascBlocks, RootBlock = rootBlock } };
    }
}
