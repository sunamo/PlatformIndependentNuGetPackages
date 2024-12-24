namespace SunamoTypes;
using System.Collections;
using System.Text;

public class Types
{

    public static readonly Type tObject = typeof(object);
    public static readonly Type tStringBuilder = typeof(StringBuilder);
    public static readonly Type tIEnumerable = typeof(IEnumerable);
    public static readonly Type tString = typeof(string);
    public static readonly Type tFloat = typeof(float);
    public static readonly Type tDouble = typeof(double);
    public static readonly Type tInt = typeof(int);
    public static readonly Type tLong = typeof(long);
    public static readonly Type tShort = typeof(short);
    public static readonly Type tDecimal = typeof(decimal);
    public static readonly Type tSbyte = typeof(sbyte);
    public static readonly Type tByte = typeof(byte);
    public static readonly Type tUshort = typeof(ushort);
    public static readonly Type tUint = typeof(uint);
    public static readonly Type tUlong = typeof(ulong);
    public static readonly Type tDateTime = typeof(DateTime);
    public static readonly Type tBinary = typeof(byte[]);
    public static readonly Type tChar = typeof(char);
    public static readonly List<Type> allBasicTypes = new()
{
tObject, tString, tStringBuilder, tInt, tDateTime,
tDouble, tFloat, tChar, tBinary, tByte, tShort, tBinary, tLong, tDecimal, tSbyte, tUshort, tUint, tUlong
};
    public static readonly Type list = typeof(IList);
    #region Same seria as in DefaultValueForTypeT
    public static readonly Type tBool = typeof(bool);
    #region Signed numbers
    #endregion
    #region Unsigned numbers
    #endregion
    public static readonly Type tGuid = typeof(Guid);
    #endregion
}