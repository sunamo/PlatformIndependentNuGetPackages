namespace SunamoEntity.Entity;

/// <summary>
/// Provides methods for working with timestamp strings in the format T00:00:00.
/// </summary>
public class Timestamp
{
    /// <summary>
    /// Extracts all timestamp strings (format T##:##:##, length 9) from the given text.
    /// </summary>
    /// <param name="text">The text to search for timestamps.</param>
    public static List<string> GetAllTimeStamps(string text)
    {
        List<string> result = new List<string>();
        var words = SHSplit.SplitChar(text, ' ', '.');
        foreach (var item in words)
        {
            if (item.Length == 9)
            {
                var firstChar = item[0];
                var secondChar = item[1];
                var thirdChar = item[2];
                var fifthChar = item[4];
                var sixthChar = item[5];
                var eighthChar = item[7];
                var ninthChar = item[8];
                if (firstChar == 'T' && char.IsDigit(secondChar) && char.IsDigit(thirdChar) && char.IsDigit(fifthChar) && char.IsDigit(sixthChar) && char.IsDigit(eighthChar) && char.IsDigit(ninthChar))
                {
                    result.Add(item);
                }
            }
        }

        return result;
    }

    /// <summary>
    /// Pads a single-digit number with a leading zero to ensure two-digit format.
    /// </summary>
    /// <param name="number">The number to pad.</param>
    public static object MakeUpTo2NumbersToZero(int number)
    {
        if (number.ToString().Length == 1)
        {
            return "0" + number;
        }
        return number;
    }
}
