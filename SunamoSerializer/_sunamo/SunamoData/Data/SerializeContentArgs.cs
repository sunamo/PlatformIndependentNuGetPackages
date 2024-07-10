namespace SunamoSerializer._sunamo.SunamoData.Data;


internal class SerializeContentArgs
{
    /// <summary>
    /// Must be property - I can forget change value on three occurences. 
    /// </summary>
    internal char separatorChar
    {
        get
        {
            return separatorString[0];
        }
    }
    internal string separatorString = AllStrings.verbar;
    internal int keyCodeSeparator
    {
        get
        {
            return separatorChar;
        }
    }
}