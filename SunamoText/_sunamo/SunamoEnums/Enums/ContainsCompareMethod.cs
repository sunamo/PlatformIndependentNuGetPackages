namespace SunamoText._sunamo.SunamoEnums.Enums;


/// <summary>
/// Used in SunamoCollectionsGenericStore + SunamoCollections
/// </summary>
internal enum ContainsCompareMethod
{
    WholeInput,
    SplitToWords,
    /// <summary>
    /// split to words and check for ! at [0]
    /// </summary>
    Negations
}