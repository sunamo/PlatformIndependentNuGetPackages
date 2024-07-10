namespace SunamoEditorConfig;

public class EditorConfigContent
{
    public RootBlock RootBlock { get; set; }
    public List<MascBlock> MascBlocks { get; set; }

    public override string ToString()
    {
        var sb = new StringBuilder();

        sb.AppendLine(RootBlock.ToString());

        foreach (var block in MascBlocks) sb.AppendLine(block.ToString());

        return sb.ToString();
    }
}
