namespace SunamoSerializer._sunamo.SunamoBts;
internal class BTS
{
    internal static string ToString<T>(T t)
    {
        return t.ToString();
    }

    internal static object MethodForParse<T1>()
    {
        var t = typeof(T1);
        #region Same seria as in DefaultValueForTypeT
        #region MyRegion
        if (t == Types.tString)
        {
            return new Func<string, string>(ToString<string>);
        }
        if (t == Types.tBool)
        {
            return new Func<string, bool>(bool.Parse);
        }
        #endregion

        #region Signed numbers
        if (t == Types.tFloat)
        {
            return new Func<string, float>(float.Parse);
        }
        if (t == Types.tDouble)
        {
            return new Func<string, double>(double.Parse);
        }
        if (t == Types.tInt)
        {
            return new Func<string, int>(int.Parse);
        }
        if (t == Types.tLong)
        {
            return new Func<string, long>(long.Parse);
        }
        if (t == Types.tShort)
        {
            return new Func<string, short>(short.Parse);
        }
        if (t == Types.tDecimal)
        {
            return new Func<string, decimal>(decimal.Parse);
        }
        if (t == Types.tSbyte)
        {
            return new Func<string, sbyte>(sbyte.Parse);
        }
        #endregion

        #region Unsigned numbers
        if (t == Types.tByte)
        {
            return new Func<string, byte>(byte.Parse);
        }
        if (t == Types.tUshort)
        {
            return new Func<string, ushort>(ushort.Parse);
        }
        if (t == Types.tUint)
        {
            return new Func<string, uint>(uint.Parse);
        }
        if (t == Types.tUlong)
        {
            return new Func<string, ulong>(ulong.Parse);
        }
        #endregion

        if (t == Types.tDateTime)
        {
            return new Func<string, DateTime>(DateTime.Parse);
        }
        if (t == Types.tGuid)
        {
            return new Func<string, Guid>(Guid.Parse);
        }
        if (t == Types.tChar)
        {
            return new Func<string, char>((string s) => s[0]);
        }

        #endregion

        return null;
    }

}
