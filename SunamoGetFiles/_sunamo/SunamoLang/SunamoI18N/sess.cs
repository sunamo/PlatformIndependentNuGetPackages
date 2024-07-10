namespace SunamoGetFiles._sunamo.SunamoLang.SunamoI18N;


//namespace
//#if SunamoDevCode
//SunamoDevCode
//#elif SunamoGetFiles
//SunamoGetFiles
//#else
//SunamoLang
//#endif
//;
internal class sess
{
    private static readonly Type type = typeof(sess);
    /// <summary>
    ///     Usage: Exceptions.IsNotWindowsPathFormat
    /// </summary>
    /// <param name="k"></param>
    /// <returns></returns>
    internal static string i18n(string k)
    {
        switch (k)
        {
            case XlfKeys.isNotInWindowsPathFormat:
                return "is not in Windows Path format";
            case XlfKeys.NotImplementedCasePublicProgramErrorPleaseContactDeveloper:
                return "Not implemented case. internal program error. Please contact developer";
            case XlfKeys.DifferentCountElementsInCollection:
                return "Different count elements in collection";
            default:
                ThrowEx.NotImplementedCase(k);
                break;
        }
        return null;
    }
}