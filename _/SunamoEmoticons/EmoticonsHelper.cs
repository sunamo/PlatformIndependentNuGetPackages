namespace SunamoEmoticons;
using Microsoft.Extensions.Logging;
using SunamoEmoticons._sunamo;

public class EmoticonsHelper
{
    public static List<string> GetAllEmotions(ILogger logger)
    {
        Emoticons emoticons = new();
        var fields = emoticons.GetType().GetFields();

        List<string> result = new();

        foreach (var item in fields)
        {
            var value = item.GetValue(emoticons);
            if (value != null)
            {
                var ts = value.ToString();

                if (ts != null)
                {
                    result.AddRange(SHSplit.SplitByWhiteSpaces(ts));
                }
                else
                {
                    logger.LogDebug(message: $"{item.Name}.ToString() in Emoticons was null");
                }

            }
            else
            {
                logger.LogDebug(message: $"{item.Name} in Emoticons was null");
            }
        }

        return result;
    }
}