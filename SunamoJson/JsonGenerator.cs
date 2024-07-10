namespace SunamoJson;

public class JsonGenerator
{
    StringBuilder sb = new StringBuilder();

    public void Pair(string key, string value)
    {
        sb.AppendLine("\"" + key + "\": " + "\"" + value + "\",");
    }

    public override string ToString()
    {
        return sb.ToString();
    }
}
