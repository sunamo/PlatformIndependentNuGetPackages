namespace SunamoRoslyn._sunamo;
internal class SHJoinPairs
{
    internal static string JoinPairs(string firstDelimiter, string secondDelimiter, params string[] parts)
    {
        //InitApp.TemplateLogger.NotEvenNumberOfElements(type, "JoinPairs", @"args", parts);
        //InitApp.TemplateLogger.AnyElementIsNull(type, "JoinPairs", @"args", parts);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < parts.Length; i++)
        {
            sb.Append(parts[i++] + firstDelimiter);
            sb.Append(parts[i] + secondDelimiter);
        }
        return sb.ToString();
    }
}