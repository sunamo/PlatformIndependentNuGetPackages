namespace SunamoStringGetString._sunamo.SunamoExceptions.OnlyInSE;


internal class Types
{

    internal static readonly Type tObject = typeof(object);
    internal static readonly Type tStringBuilder = typeof(StringBuilder);
    internal static readonly Type tIEnumerable = typeof(IEnumerable);
    internal static readonly Type tString = typeof(string);
    internal static readonly Type tFloat = typeof(float);
    internal static readonly Type tDouble = typeof(double);
    internal static readonly Type tInt = typeof(int);
    internal static readonly Type tLong = typeof(long);
    internal static readonly Type tShort = typeof(short);
    internal static readonly Type tDecimal = typeof(decimal);
    internal static readonly Type tSbyte = typeof(sbyte);
    internal static readonly Type tByte = typeof(byte);
    internal static readonly Type tUshort = typeof(ushort);
    internal static readonly Type tUint = typeof(uint);
    internal static readonly Type tUlong = typeof(ulong);
    internal static readonly Type tDateTime = typeof(DateTime);
    internal static readonly Type tBinary = typeof(byte[]);
    internal static readonly Type tChar = typeof(char);
    internal static readonly List<Type> allBasicTypes = new()
{
tObject, tString, tStringBuilder, tInt, tDateTime,
tDouble, tFloat, tChar, tBinary, tByte, tShort, tBinary, tLong, tDecimal, tSbyte, tUshort, tUint, tUlong
};
    internal static readonly Type list = typeof(IList);
    #region Same seria as in DefaultValueForTypeT
    internal static readonly Type tBool = typeof(bool);
    #region Signed numbers
    #endregion
    #region Unsigned numbers
    #endregion
    internal static readonly Type tGuid = typeof(Guid);
    #endregion
}
