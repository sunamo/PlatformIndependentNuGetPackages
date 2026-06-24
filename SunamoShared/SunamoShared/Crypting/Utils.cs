using System;
using System.Collections.Generic;

namespace SunamoShared.Crypting
{
    public static class Utils
    {
        public static string ToBase64(List<byte> byteList)
            => Convert.ToBase64String(byteList.ToArray());

        public static byte[] FromBase64(string base64Encoded)
            => Convert.FromBase64String(base64Encoded);
    }
}
