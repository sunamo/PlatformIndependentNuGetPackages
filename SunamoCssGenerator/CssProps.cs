
namespace SunamoCssGenerator;
public class CssProps
{
    public static CssProperty Width(string v)
    {
        return new CssProperty { Property = Properties.Width, Value = v };
    }

}
