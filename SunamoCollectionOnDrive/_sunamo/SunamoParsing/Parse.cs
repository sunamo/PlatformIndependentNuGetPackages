namespace SunamoCollectionOnDrive._sunamo.SunamoParsing;


internal class Parse
{
    internal class Byte
    {
        internal byte ParseByte(string p)
        {
            byte b;
            if (byte.TryParse(p, out b))
            {
                return b;
            }
            return 0;
        }
    }
    internal class Double
    {
        /// <summary>
        /// Vrátí -1 v případě že se nepodaří vyparsovat
        /// </summary>
        /// <param name="p"></param>
        internal double ParseDouble(string p)
        {
            double p2;
            if (double.TryParse(p, out p2))
            {
                return p2;
            }
            return 0;
        }
    }
    internal class Integer
    {
        /// <summary>
        /// Vrátí -1 v případě že se nepodaří vyparsovat
        /// </summary>
        /// <param name="p"></param>
        internal int ParseInt(string p)
        {
            int p2;
            if (int.TryParse(p, out p2))
            {
                return p2;
            }
            return -1;
        }
        /// <summary>
        /// Vrátí int.MaxValue v případě že se nepodaří vyparsovat
        /// </summary>
        internal int ParseIntMaxValue(string p)
        {
            int p2;
            if (int.TryParse(p, out p2))
            {
                return p2;
            }
            return int.MaxValue;
        }
    }
    internal class Short
    {
        /// <summary>
        /// Vrátí -1 pokud se nepodaří vyparsovat
        /// </summary>
        /// <param name="d"></param>
        internal short ParseShort(string d)
        {
            short s = 0;
            if (short.TryParse(d, out s))
            {
                return s;
            }
            return -1;
        }
    }
}