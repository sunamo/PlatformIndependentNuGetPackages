namespace SunamoSecurity;
using SunamoSecurity.Crypting;
using System.Net;
using System.Runtime.InteropServices;
using System.Security;

/// <summary>
/// Is 
/// </summary>
public static class SecureStringHelper
{
    public static SecureString ToSecureString(this string value)
    {
        SecureString theSecureString = new NetworkCredential(string.Empty, value).SecurePassword;
        return theSecureString;
        //unsafe
        //{
        //fixed (char* value3 = value)
        //    {
        //        SecureString ss = new System.Security.SecureString(value3, value.Length);
        //        ss.MakeReadOnly();
        //        return ss;
        //    }
        //}
    }

    public static SecureString ToSecureString2(string input)
    {
        SecureString secure = new();
        foreach (char c in input)
        {
            secure.AppendChar(c);
        }
        secure.MakeReadOnly();
        return secure;
    }

    public static string ToInsecureString2(SecureString input)
    {
        string returnValue = string.Empty;
        nint ptr = Marshal.SecureStringToBSTR(input);
        try
        {
            returnValue = Marshal.PtrToStringBSTR(ptr);
        }
        finally
        {
            Marshal.ZeroFreeBSTR(ptr);
        }
        return returnValue;
    }

    public static string? ToInsecureString(SecureString securePassword)
    {
        nint unmanagedString = nint.Zero;
        try
        {
            unmanagedString = Marshal.SecureStringToGlobalAllocUnicode(securePassword);
            return Marshal.PtrToStringUni(unmanagedString);
        }
        finally
        {
            Marshal.ZeroFreeGlobalAllocUnicode(unmanagedString);
        }
    }

    public static string? DecryptString(string salt, string encrypted)
    {
        return ToInsecureString(ProtectedDataHelper.DecryptString(salt, encrypted));
    }

    public static string? EncryptString(string salt, string encrypted)
    {
        SecureString ss = encrypted.ToSecureString();

        return ProtectedDataHelper.EncryptString(salt, ss);
    }

    public static CryptDelegates CreateCryptDelegates()
    {
        CryptDelegates cd = new(DecryptString, EncryptString);
        return cd;
    }
}