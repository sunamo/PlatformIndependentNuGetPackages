namespace SunamoEditorConfig;

public static class ListHelper
{
    public static List<string> Trim(List<string> list)
    {
        for (var i = 0; i < list.Count; i++) list[i] = list[i].Trim();

        return list;
    }
}
