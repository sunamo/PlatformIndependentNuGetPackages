namespace SunamoCryptAlgorithms.Crypting;

/// <summary>
/// Provides advanced cryptographic helper methods for text obfuscation and character transformation.
/// </summary>
public class CryptHelperAdvanced
{
    /// <summary>
    /// Rearranges characters in the text by inverting chunks of the specified base size.
    /// </summary>
    /// <param name="text">The input text to process.</param>
    /// <param name="moveBase">The chunk size for inversion.</param>
    private static string InverseByBase(string text, int moveBase)
    {
        StringBuilder stringBuilder = new StringBuilder();
        int chunkLength;
        for (int i = 0; i < text.Length; i += moveBase)
        {
            if (i + moveBase > text.Length - 1)
                chunkLength = text.Length - i;
            else
                chunkLength = moveBase;
            stringBuilder.Append(InverseString(text.Substring(i, chunkLength)));
        }
        return stringBuilder.ToString();
    }

    /// <summary>
    /// Reverses the character order of the string (first letter becomes last and vice versa).
    /// </summary>
    /// <param name="text">The input text to reverse.</param>
    private static string InverseString(string text)
    {
        StringBuilder stringBuilder = new StringBuilder();
        for (int i = text.Length - 1; i >= 0; i--)
        {
            stringBuilder.Append(text[i]);
        }
        return stringBuilder.ToString();
    }

    /// <summary>
    /// Processes letters in the text: digits and letters are kept as-is, other characters are converted to their numeric representation.
    /// </summary>
    /// <param name="text">The input text to process.</param>
    private static string ConvertToLetterDigit(string text)
    {
        StringBuilder stringBuilder = new StringBuilder();
        foreach (char character in text)
        {
            if (char.IsLetterOrDigit(character) == false)
                stringBuilder.Append(Convert.ToInt16(character).ToString());
            else
                stringBuilder.Append(character);
        }
        return stringBuilder.ToString();
    }

    /// <summary>
    /// Shuffles all characters in the string by moving each character to a new computed index.
    /// </summary>
    /// <param name="text">The input text to shuffle.</param>
    private static string Boring(string text)
    {
        int newPlace;
        char character;
        for (int i = 0; i < text.Length; i++)
        {
            newPlace = i * Convert.ToUInt16(text[i]);
            newPlace = newPlace % text.Length;
            character = text[i];
            text = text.Remove(i, 1);
            text = text.Insert(newPlace, character.ToString());
        }
        return text;
    }

    /// <summary>
    /// Transforms a character by shifting its ASCII value based on its range and the provided encoding values.
    /// </summary>
    /// <param name="character">The character to transform.</param>
    /// <param name="encodeValues">The encoding values array used for shifting.</param>
    private static char ChangeChar(char character, int[] encodeValues)
    {
        character = char.ToUpper(character);
        if (character >= 'A' && character <= 'H')
            return Convert.ToChar(Convert.ToInt16(character) + 2 * encodeValues[0]);
        else if (character >= 'I' && character <= 'P')
            return Convert.ToChar(Convert.ToInt16(character) - encodeValues[2]);
        else if (character >= 'Q' && character <= 'Z')
            return Convert.ToChar(Convert.ToInt16(character) - encodeValues[1]);
        else if (character >= '0' && character <= '4')
            return Convert.ToChar(Convert.ToInt16(character) + 5);
        else if (character >= '5' && character <= '9')
            return Convert.ToChar(Convert.ToInt16(character) - 5);
        else
            return '0';
    }
}
