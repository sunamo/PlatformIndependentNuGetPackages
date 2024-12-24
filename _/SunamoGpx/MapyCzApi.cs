namespace SunamoGpx;
// Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(myJsonResponse);
#pragma warning disable IDE1006
#pragma warning disable CS8618
public class Item(string name, Position position)
{
    public string Name { get; set; } = name;

    public Position Position { get; set; } = position;

    public string? Label { get; set; }
    public string? Type { get; set; }
    public string? Location { get; set; }
    public List<RegionalStructure>? RegionalStructure { get; set; }
}

public class Position
{
    public double lon { get; set; }
    public double lat { get; set; }

    public override string ToString()
    {
        return lat + " " + lon;
    }
}

public class RegionalStructure
{
    public string name { get; set; }
    public string type { get; set; }
    public string isoCode { get; set; }
}

public class GeocodeResponse
{
    public List<Item> items { get; set; }
    public List<object> locality { get; set; }
}
#pragma warning restore