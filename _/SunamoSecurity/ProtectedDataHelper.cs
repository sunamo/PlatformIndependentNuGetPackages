namespace SunamoSecurity;
using SunamoSecurity;
using SunamoSecurity._sunamo;
using System.Security;
using System.Security.Cryptography;
using System.Text;

public static class ProtectedDataHelper
{
    public static string? EncryptString(string salt, SecureString input)
    {
        byte[] entropy = Encoding.Unicode.GetBytes(salt);

        var insecureString = SecureStringHelper.ToInsecureString(input);

        if (insecureString == null)
        {
            return null;
        }

        byte[] encryptedData = ProtectedData.Protect(
            Encoding.Unicode.GetBytes(insecureString),
            entropy,
            DataProtectionScope.CurrentUser);
        return Convert.ToBase64String(encryptedData);
    }

    public static SecureString DecryptString(string salt, string encryptedData)
    {
        try
        {
            byte[] entropy = Encoding.Unicode.GetBytes(salt);
            byte[] decryptedData = [];
            try
            {
                decryptedData = ProtectedData.Unprotect(
                Convert.FromBase64String(encryptedData),
                entropy,
                DataProtectionScope.CurrentUser);
            }
            catch (Exception ex)
            {
                ThrowEx.Custom(ex.Message);
                return new SecureString();
            }
            return Encoding.Unicode.GetString(decryptedData).ToSecureString();
        }
        catch
        {
            return new SecureString();
        }
    }
}