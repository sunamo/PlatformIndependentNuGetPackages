namespace SunamoRoslyn._sunamo.SunamoExceptions.OnlyInSE;
internal class TranslateAble
{
    /// <summary>
    ///     je tu jen protože se mi nechce editovat všechny výskyty SunamoPageHelperSunamo kdy byvch musel druhou závorku ručně
    ///     odebrat
    ///     každopádně, do budoucna se s ní nepočítá, viz doc Async in C#
    /// </summary>
    /// <param name="notSupported"></param>
    /// <returns></returns>
    /// <exception cref="NotImplementedException"></exception>
    internal static string i18n(string xlfKey)
    {
        return xlfKey;
    }
}
