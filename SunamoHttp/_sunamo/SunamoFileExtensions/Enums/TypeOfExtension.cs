namespace SunamoHttp._sunamo.SunamoFileExtensions.Enums;


internal enum TypeOfExtension
{
    archive,
    image,
    source_code,
    documentText,
    documentBinary,
    database,
    /// <summary>
    ///     prošel jsem zda v AllExtension jsou všechny textové
    /// </summary>
    configText,
    /// <summary>
    ///     XML, JSON, mdf, ldf, sdf, atd.
    ///     Can't name data because is difficult search (exists also database)
    /// </summary>
    contentText,
    contentBinary,
    /// <summary>
    ///     prošel jsem zda v AllExtension jsou všechny textové
    ///     ini, atd.
    /// </summary>
    settingsText,
    /// <summary>
    ///     prošel jsem zda v AllExtension jsou všechny textové
    /// </summary>
    visual_studioText,
    executable,
    binary,
    /// <summary>
    ///     u resourců by to asi tak nevadilo kdyby byly zakódovany třeba ve b64 ale pro jistotu je všechny řadím do binárních
    ///     ať je nepoškodím
    /// </summary>
    resource,
    /// <summary>
    ///     prošel jsem zda v AllExtension jsou všechny textové
    ///     sql, cmd, ps1,
    /// </summary>
    script,
    font,
    multimedia,
    temporary,
    /// <summary>
    ///     Is used when extension isn't know
    ///     U ostatních souborů vypsat jejich popis z windows
    /// </summary>
    other
}